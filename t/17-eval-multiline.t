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
use vars qw($_STDOUT_ $_STDERR_);

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

use Test::More tests => 4;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

SKIP: {

use_ok('WWW::Mechanize::Shell');
my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

eval {
  $s->cmd('eval "Hello",
" World";
');
};
is($@,"","Multiline eval does not crash");
is($_STDERR_,undef,"Multiline eval produces no warnings");
is($_STDOUT_,"Hello World\n","Multiline eval produces the desired output");
};


