package HTML::Display::Opera;
use base 'HTML::Display::TempFile';
# for opera (thanks to Tina Mueller)
sub browsercmd { "opera -newwindow %s" };

1;