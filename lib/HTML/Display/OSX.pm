package HTML::Display::OSX;
use base 'HTML::Display::TempFile';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::OSX - display HTML on OSX

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

This launches the default browser on OSX.

=cut

sub browsercmd { "open %s" };

1;
