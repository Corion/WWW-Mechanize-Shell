package HTML::Display::Galeon;
use base 'HTML::Display::TempFile';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::Galeon - display HTML through Galeon

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub browsercmd { "galeon -n %s" };

1;
