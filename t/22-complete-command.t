#!/usr/bin/perl -w
use strict;

use Test::More tests => 2;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

use_ok('WWW::Mechanize::Shell');

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

# We don't want to annoy the user :
# $s->cmd('set useole 0');
# $s->cmd('set browsercmd ""');

# Now test
{ no warnings 'redefine';
	local *WWW::Mechanize::find_all_links = sub { [ ["","foo"],["","bar"] ] };
	my @comps = $s->comp_open("fo","fo",0);
	is_deeply(\@comps,["foo"],"Completion works");
};


