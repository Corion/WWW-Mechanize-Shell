package HTML::Display::Dump;
use base 'HTML::Display::Common';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::Dump - dump raw HTML to the console

=head1 SYNOPSIS

=for example
  use HTML::Display;

=for example begin

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Dump',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=for example_testing
  isa_ok($browser,"HTML::Display::Common");
  is($_STDOUT_,"<html><body><h1>Hello world!</h1></body></html>","Dumped output");
  is($_STDERR_,undef,"No warnings");

=cut

sub display_html { print $_[1]; };

1;
