package HTML::Display::Win32;

=head1 NAME

HTML::Display::Win32 - display an URL through the default application for HTML

=head1 BUGS

Currently does not work.

use base 'HTML::Display::TempFile';

sub browsercmd { 'start "%s" "%s"' };

