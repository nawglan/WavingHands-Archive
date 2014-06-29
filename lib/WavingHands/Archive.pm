package WavingHands::Archive;

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Path qw(make_path remove_tree);
use File::Spec;
use Carp qw(croak);
use mop;

=head1 NAME

WavingHands::Archive - A module to archive games based on Waving Hands by Richard Bartle.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module provides the main interface for creating and accessing an archive
of games for the various versions of Waving Hands games.

Perhaps a little code snippet.

    use WavingHands::Archive;

    # create a new archive object.  The parameter config is optional.  If
    # not used, you will need to supply the configuration parameters to the
    # initialize method.
    my $archive = WavingHands::Archive->new(config => 'path/to/config_file');

    $archive->initialize();

    # add some games (one game per file in the input directory)
    $archive->add();

    # remove some games from the archive
    $archive->remove(IDS => ['id1', 'id2', 'id3', 'id4']);

    # find some stuff in the archive, see the section on Queries for more info.
    my $result = $archive->search(QUERY => $query, ... );

    # destroy the archive completely
    $archive->destroy();

    ...


=head1 FUNCTIONS

=head2 new

    Creates the archive object.  There is an optional parameter 'config' that
    can be supplied to the new method.  If this parameter is not used, then all
    manditory configuration options need to be supplied to the initialize
    method as a hashref argument.  The 'config' parameter should contain the
    filename of the configuration file that contains all the manditory settings.
    The file should be formatted like this:

    # any line beginning with a hash mark is considered to be a comment and is
    # skipped. Also, any lines containing only whitespace are skipped.

    # The format is setting = value.  There must be at least one whitespace
    # character on each side of the equal sign.  The value is terminated by a
    # newline and can contain spaces if the setting allows it.  See section on
    # configuration settings for the full list.
    name = test_archive
    basedir = ./some/path


=head2 initialize

    Initialize the archive.  The argument to initialize is optional if the
    archive was created using the 'config' parameter. The hashref must contain
    at a minimum the keys 'name' and 'basedir'.  The archive will be created in
    the 'basedir' directory in a sub-directory named 'name' assuming you have
    sufficient permission to create the directory.

=cut

class WavingHands::Archive {
    has $!options is ro = {};
    has $!config is ro = './archive.config';
    has $!name is ro = 'Unnamed_Archive';

    method validate_path($path) {
        croak('Error: must call validate_path with an argument containing a path to validate.') if !defined $path || $path eq '';
        my $abs_path = abs_path($path);
        $path = $abs_path if $abs_path;

        local ($1);
        $path =~ /^(.*)\z/s;
        eval {
          $path = $1;
          make_path($path);
        };
        die $@ if $@;
        die "Error: Unable to make $path." unless -d $path;
        return $path;
    }

    method initialize(%options) {
        local ($1);
        if (!keys %options) {
            # read in config file
            open my $CF, '<', $!config or
                die("Error: Config file [$!config] not found.");
            my $basedir;
            my $archivedir;
            my $gamedir;
            my $errordir;
            my $logdir;
            my $datadir;
            my $inputdir;
            while (my $buffer = <$CF>) {
                next if $buffer =~ /^\s*#/; # skip comments
                next if $buffer =~ /^\s*$/; # skip whitespace only lines
                if ($buffer =~ /^\s*name\s+=\s+(.+)$/) {
                    $!name = $1;
                } elsif ($buffer =~ /^\s*basedir\s+=\s+(.+)$/) {
                    $basedir = $1;
                } elsif ($buffer =~ /^\s*gamedir\s+=\s+(.+)$/) {
                    $gamedir = $1;
                } elsif ($buffer =~ /^\s*errordir\s+=\s+(.+)$/) {
                    $errordir = $1;
                } elsif ($buffer =~ /^\s*logdir\s+=\s+(.+)$/) {
                    $logdir = $1;
                } elsif ($buffer =~ /^\s*datadir\s+=\s+(.+)$/) {
                    $datadir = $1;
                } elsif ($buffer =~ /^\s*inputdir\s+=\s+(.+)$/) {
                    $inputdir = $1;
                }
            }
            close $CF;

            die ('Error: name value must be (alphanumeric or _), not just [0-9a-zA-Z_] but also digits and characters from non-roman scripts are allowed.') unless defined $!name && $!name =~ /\w+/;

            die ("Error: basedir is not defined or is the empty string")
                if !defined $basedir || $basedir eq '';

            $archivedir = File::Spec->catdir($basedir, $!name);
            $gamedir = File::Spec->catdir($archivedir, 'games') unless defined $gamedir;
            $errordir = File::Spec->catdir($archivedir, 'error') unless defined $errordir;
            $logdir = File::Spec->catdir($archivedir, 'logs') unless defined $logdir;
            $datadir = File::Spec->catdir($archivedir, 'data') unless defined $datadir;
            $inputdir = File::Spec->catdir($archivedir, 'input') unless defined $inputdir;

            $!options = {
                basedir => $self->validate_path($basedir),
                archivedir => $self->validate_path($archivedir),
                gamedir => $self->validate_path($gamedir),
                errordir => $self->validate_path($errordir),
                logdir => $self->validate_path($logdir),
                datadir => $self->validate_path($datadir),
                inputdir => $self->validate_path($inputdir),
            };
        } else {
            ($!name) = ($options{name}) =~ /^(\w+)\z/s;
            die('Error: name value must be (alphanumeric or _), not just [0-9a-zA-Z_] but also digits and characters from non-roman scripts are allowed.') if !defined $!name;

            die('Error: basedir value must be defined.') if (!defined $options{basedir} || $options{basedir} eq '');

            $options{basedir} = $self->validate_path($options{basedir});
            $options{archivedir} = $self->validate_path(File::Spec->catdir($options{basedir}, $!name));

            if (!exists $options{gamedir}) {
                $options{gamedir} = File::Spec->catdir($options{archivedir}, 'games');
            }
            if (!exists $options{errordir}) {
                $options{errordir} = File::Spec->catdir($options{archivedir}, 'error');
            }
            if (!exists $options{logdir}) {
                $options{logdir} = File::Spec->catdir($options{archivedir}, 'logs');
            }
            if (!exists $options{datadir}) {
                $options{datadir} = File::Spec->catdir($options{archivedir}, 'data');
            }
            if (!exists $options{inputdir}) {
                $options{inputdir} = File::Spec->catdir($options{archivedir}, 'input');
            }
            $options{gamedir} = $self->validate_path($options{gamedir});
            $options{errordir} = $self->validate_path($options{errordir});
            $options{logdir} = $self->validate_path($options{logdir});
            $options{datadir} = $self->validate_path($options{datadir});
            $options{inputdir} = $self->validate_path($options{inputdir});

            # if we make it to here, all manditory options have been validated and
            # all directories and files that are necessary for the archive are in
            # place.
            $!options = \%options;
        }
        return 1;
    }

    method add(%options) {
    }

    method destroy($remove_basedir = 0) {
        eval {
            if (!$remove_basedir) {
                remove_tree($!options->{gamedir});
                remove_tree($!options->{errordir});
                remove_tree($!options->{logdir});
                remove_tree($!options->{datadir});
                remove_tree($!options->{inputdir});
                remove_tree(File::Spec->catdir($!options->{basedir}, $!name));
            } else {
                remove_tree($!options->{basedir});
            }
        };
        die $@ if ($@);
        return 1;
    }
}

=head1 AUTHOR

Desmond Daignault, C<< <nawglan at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-warlocks-archive at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NAWGLAN/ReportBug.html?Queue=WavingHands::Archive>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WavingHands::Archive


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NAWGLAN/Bugs.html?Dist=WavingHands::Archive>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WavingHands::Archive>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WavingHands::Archive>

=item * Search CPAN

L<http://search.cpan.org/dist/WavingHands::Archive>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2014 Desmond Daignault, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WavingHands::Archive
