package HTML::Display::OSX::Safari;
use base 'HTML::Display::TempFile';

=head1 NAME

HTML::Display::OSX::Safari - display HTML through Safari

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Dump',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub browsercmd { "open -a Safari.app %s" };

1;
