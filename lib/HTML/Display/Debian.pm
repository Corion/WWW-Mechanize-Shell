package HTML::Display::Debian;

=head1 NAME

HTML::Display::Debian - display HTML using the Debian default

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

This module implements displaying HTML through the Debian default web browser
referenced as the program C</bin/x-www-browser>.

=cut

use base 'HTML::Display::TempFile';
sub browsercmd { "x-www-browser %s" };

1;
