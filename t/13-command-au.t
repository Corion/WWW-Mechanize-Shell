#!/usr/bin/perl -w
use strict;
use FindBin;

use lib 'inc';
use IO::Catch;
use vars qw( $_STDOUT_ $_STDERR_ );

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'IO::Catch', '_STDOUT_' or die $!;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

use Test::More tests => 8;
SKIP: {

use_ok('WWW::Mechanize::Shell');

eval { require HTTP::Daemon; };
skip "HTTP::Daemon required to test basic authentication",7
  if ($@);

# We want to be safe from non-resolving local host names
delete @ENV{qw(HTTP_PROXY http_proxy CGI_HTTP_PROXY)};

# Now start a fake webserver, fork, and connect to ourselves
open SERVER, qq'"$^X" "$FindBin::Bin/401-server" |'
  or die "Couldn't spawn fake server : $!";
sleep 1; # give the child some time
my $url = <SERVER>;
chomp $url;
die unless $url =~ m!^http://([^/]+)/!;
my $host = $1;

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

# First try with an inline username/password
my $pwd_url = $url;
$pwd_url =~ s!^http://!http://foo:bar@!;
$s->cmd( "get $pwd_url" );
diag $s->agent->res->message
  unless is($s->agent->res->code, 200, "Request with inline credentials gives 200");
is($s->agent->content, "user = 'foo' pass = 'bar'", "Credentials are good");

$s->cmd( "get $url" );
is($s->agent->res->code, 401, "Request without credentials gives 401");
is($s->agent->content, "auth required", "Content requests authentication");

$s->cmd( "auth foo bar" );
is_deeply( $s->agent->{'basic_authentication'}{$host}{"testing realm"}, ["foo","bar"],"UA stored the authentification");

$s->cmd( "get $url" );
diag $s->agent->res->message
  unless is($s->agent->res->code, 200, "Request with credentials gives 200");
is($s->agent->content, "user = 'foo' pass = 'bar'", "Credentials are good");

};

END {
  close SERVER; # boom
};
