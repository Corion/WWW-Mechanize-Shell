#!/usr/bin/perl -w
use strict;

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
use strict;
use vars qw( @comments $_STDOUT_ $_STDERR_ );

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

BEGIN { @comments = ( "#", "# a test", "#eval 1", "# eval 1", "## eval 1" )};

use Test::More tests => 1 + scalar @comments * 3;
SKIP: {
skip "Can't load Term::ReadKey without a terminal", 1 + scalar @comments * 3
  unless -t STDIN;

eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
if ($@) {
  no warnings 'redefine';
  *Term::ReadKey::GetTerminalSize = sub {80,24};
  diag "Term::ReadKey seems to want a terminal";
};

use_ok('WWW::Mechanize::Shell');

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

for (@comments) {
  $_STDOUT_ = "";
  $_STDERR_ = "";
  eval { $s->cmd($_); };
  is($@,"","Comment '$_' produces no error");
  is($_STDOUT_,"","Comment '$_' produces no output");
  is($_STDERR_,"","Comment '$_' produces no error output");
};

};


