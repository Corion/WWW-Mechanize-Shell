package HTML::Display::Dump;
use base 'HTML::Display::Common';

=head1 NAME

HTML::Display::Dump - dump raw HTML to the console

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Dump',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub display_html { print $_[1]; };

1;
