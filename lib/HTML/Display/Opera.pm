package HTML::Display::Opera;
use base 'HTML::Display::TempFile';
use vars qw($VERSION);
$VERSION='0.03';

=head1 NAME

HTML::Display::Galeon - display HTML through Galeon

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=head1 ACKNOWLEDGEMENTS

Tina Mueller provided the browser command line

=cut

sub browsercmd { "opera %s" };

1;
