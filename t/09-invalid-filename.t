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
use File::Temp qw( tempfile );

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;

use Test::More tests => 2;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

SKIP: {
#skip "Can't load Term::ReadKey without a terminal", 2
#  unless -t STDIN;
#eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
#if ($@) {
#  no warnings 'redefine';
#  *Term::ReadKey::GetTerminalSize = sub {80,24};
#  diag "Term::ReadKey seems to want a terminal";
#};

use_ok('WWW::Mechanize::Shell');

# Silence all warnings
my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

eval {
  $s->cmd('source this_file_does_not_exist');
};
is($@,"","A nonexisting file does not crash the shell");
};


