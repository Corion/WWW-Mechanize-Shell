package HTML::Display::Debian;
use base 'HTML::Display::TempFile';
sub browsercmd { "x-www-browser -n %s" };

1;