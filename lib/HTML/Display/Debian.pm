package HTML::Display::Debian;
use base 'HTML::Display::TempFile';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::Debian - display HTML using the Debian default

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

This module implements displaying HTML through the Debian default web browser
referenced as the program C<x-www-browser>.

=cut

sub browsercmd { "x-www-browser %s" };

1;
