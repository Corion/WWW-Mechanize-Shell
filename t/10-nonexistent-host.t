#!/usr/bin/perl -w
use strict;

use Test::More tests => 2;
SKIP: {
# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

#skip "Can't load Term::ReadKey without a terminal", scalar 2
#  unless -t STDIN;
#eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
#if ($@) {
#  no warnings 'redefine';
#  *Term::ReadKey::GetTerminalSize = sub {80,24};
#  diag "Term::ReadKey seems to want a terminal";
#};

use_ok('WWW::Mechanize::Shell');

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

$s->cmd('get nonexistent.host');
like($@,'/^Can\'t locate object method "host"/',"The 'get' command does not crash the shell");

};
