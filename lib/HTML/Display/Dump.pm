package HTML::Display::Dump;
use base 'HTML::Display::Common';

=head1 NAME

HTML::Display::Dump - dump raw HTML to the console

=cut

sub display_html { print $_[1]; };

1;
