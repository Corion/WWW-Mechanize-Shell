package HTML::Display::Win32;
use vars qw($VERSION);
$VERSION='0.03';

=head1 NAME

HTML::Display::Win32 - display an URL through the default application for HTML

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new();
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=head1 BUGS

Currently does not work.

Making it work will need either munging the tempfilename to
become ".html", or looking through the registry whether we find
a suitable application there.

=cut

use base 'HTML::Display::TempFile';

sub browsercmd { 
  # cmd.exe needs two arguments, command.com needs one
  ($ENV{COMSPEC} =~ /cmd.exe$/i) ? 'start "HTML::Display" "%s"' : 'start "%s"'
};

1;
