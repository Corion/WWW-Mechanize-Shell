package HTML::Display::Mozilla;
use base 'HTML::Display::TempFile';

=head1 NAME

HTML::Display::Mozilla - display HTML through Mozilla

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub browsercmd { 'mozilla -remote "openURL(%s)"' };

1;
