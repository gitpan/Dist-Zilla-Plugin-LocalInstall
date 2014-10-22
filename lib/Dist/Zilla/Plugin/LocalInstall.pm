use strict;
use warnings;

package Dist::Zilla::Plugin::LocalInstall;
BEGIN {
  $Dist::Zilla::Plugin::LocalInstall::VERSION = '0.001';
}
# ABSTRACT: installs your dist after releasing

use Carp ();
use Moose;
with 'Dist::Zilla::Role::Plugin';
with 'Dist::Zilla::Role::AfterRelease';


has install_command => (
    is      => 'ro',
    isa     => 'Str',
);


sub after_release {
    my $self = shift;

    eval {
        require File::pushd;
        my $built_in = $self->zilla->built_in;
        ## no critic Punctuation
        my $wd = File::pushd::pushd($built_in);
        my @cmd = $self->{install_command}
                    ? split(/ /, $self->{install_command})
                    : ($^X => '-MCPAN' =>
                            $^O eq 'MSWin32' ? q{-e"install '.'"} : q{-einstall "."});

        $self->log_debug([ 'installing via %s', \@cmd ]);
        system(@cmd) && $self->log_fatal([ 'Error running %s', \@cmd ]);
    };

    if ($@) {
        $self->log($@);
        $self->log('Install failed');
    }
    else {
        $self->log('Installed OK');
    }
    return;
}
no Moose;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::LocalInstall - installs your dist after releasing

=head1 VERSION

version 0.001

=head1 DESCRIPTION

After doing C<dzil release>, this plugin will install your dist so you
are always the first person to have the latest and greatest version. It's
like getting first post, only useful.

To use it, add the following in F<dist.ini>:

    [LocalInstall]

You can specify an alternate install command:

    [LocalInstall]
    install_command = cpanm .

=head1 METHODS

=head2 after_release

This gets called after the release is completed - it installs the built dist
using L<CPAN> (unless you specified something different).

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Dist-Zilla-Plugin-LocalInstall/>.

The development version lives at L<http://github.com/doherty/Dist-Zilla-Plugin-LocalInstall>
and may be cloned from L<git://github.com/doherty/Dist-Zilla-Plugin-LocalInstall>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://github.com/doherty/Dist-Zilla-Plugin-LocalInstall/issues>.

=head1 AUTHOR

Mike Doherty <doherty@cs.dal.ca>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2100 by Mike Doherty.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut


__END__
