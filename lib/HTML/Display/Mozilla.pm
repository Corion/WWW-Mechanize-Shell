package HTML::Display::Mozilla;
use base 'HTML::Display::TempFile';
sub browsercmd { 'mozilla -remote "openURL(%s)"' };

1;