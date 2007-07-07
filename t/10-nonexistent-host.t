#!/usr/bin/perl -w
use strict;

use Test::More tests => 2;
SKIP: {
# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;
delete @ENV{qw(HTTP_PROXY http_proxy CGI_HTTP_PROXY)};

use_ok('WWW::Mechanize::Shell');

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

my $called;
{ no warnings 'redefine','once';
  *WWW::Mechanize::Shell::status = sub {};
};

$s->cmd('get http://nonexistent.host');
is($s->agent->res->code, 500, "LWP returns 500 for host not found");

};
