use strict;
use Test::More tests => 2;
use vars qw( $display $captured_html $_STDOUT_ $_STDERR_);

package Catch;
use strict;
# ripped from pod2test

sub TIEHANDLE {
    my($class, $var) = @_;
    return bless { var => $var }, $class;
}

sub PRINT  {
    no strict 'refs';
    my($self) = shift;
    ${'main::'.$self->{var}} .= join '', @_;
}

sub OPEN  {}    # XXX Hackery in case the user redirects
sub CLOSE {}    # XXX STDERR/STDOUT.  This is not the behavior we want.

sub READ {}
sub READLINE {}
sub GETC {}
sub BINMODE {}

package main;
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;
$SIG{__WARN__} = sub { $_STDERR_ .= join "", @_};

{ package HTML::Display::TempFile::Test;
  use base 'HTML::Display::TempFile';

  sub browsercmd { qq{$^X -lne "" "%s" } };
};

SKIP: {
  use_ok("HTML::Display");

  $display = HTML::Display->new( class => 'HTML::Display::TempFile::Test' );
  $display->display("# Hello World");
  is($_STDERR_,undef,"Could launch tempfile program");
};
