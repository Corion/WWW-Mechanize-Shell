package HTML::Display::OSX;
use base 'HTML::Display::TempFile';
sub browsercmd { "open %s" };

1;