package HTML::Display::OSX::Safari;
use base 'HTML::Display::TempFile';
sub browsercmd { "open -a Safari.app %s" };

1;