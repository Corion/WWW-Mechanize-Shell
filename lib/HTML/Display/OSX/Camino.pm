package HTML::Display::OSX::Camino;
use base 'HTML::Display::TempFile';
sub browsercmd { "open -a Camino.app %s" };

1;