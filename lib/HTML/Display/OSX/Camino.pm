package HTML::Display::OSX::Camino;
use base 'HTML::Display::TempFile';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::OSX::Camino - display HTML via Camino

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Dump',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub browsercmd { "open -a Camino.app %s" };

1;
