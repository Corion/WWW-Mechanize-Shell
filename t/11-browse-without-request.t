#!/usr/bin/perl -w
use strict;

use Test::More tests => 2;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

SKIP: {
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

# We don't want to annoy the user :
$s->cmd('set useole 0');
$s->cmd('set browsercmd ""');

# Now test
eval { $s->cmd('browse'); };
is($@, "", "Browsing without requesting anything does not crash the shell");

};
