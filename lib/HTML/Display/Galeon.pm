package HTML::Display::Galeon;
use base 'HTML::Display::TempFile';
sub browsercmd { "galeon -n %s" };

1;