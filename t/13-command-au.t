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

use Test::More tests => 7;
SKIP: {

use_ok('WWW::Mechanize::Shell');

eval { require HTTP::Daemon; };
skip "HTTP::Daemon required to test basic authentication",7
  if ($@);

# We want to be safe from non-resolving local host names
delete @ENV{qw(HTTP_PROXY http_proxy CGI_HTTP_PROXY)};

my $user = 'foo';
my $pass = 'bar';

# Now start a fake webserver, fork, and connect to ourselves
open SERVER, qq{"$^X" "$FindBin::Bin/401-server" $user $pass |}
  or die "Couldn't spawn fake server : $!";
sleep 1; # give the child some time
my $url = <SERVER>;
chomp $url;
die "Couldn't decipher host/port from '$url'"
    unless $url =~ m!^http://([^/]+)/!;
my $host = $1;

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );

# First try with an inline username/password
my $pwd_url = $url;
$pwd_url =~ s!^http://!http://$user:$pass\@!;
diag "get $pwd_url";
$s->cmd( "get $pwd_url" );
diag $s->agent->res->message
  unless is($s->agent->res->code, 200, "Request with inline credentials gives 200");
is($s->agent->content, "user = 'foo' pass = 'bar'", "Credentials are good");

# Now try without credentials
$s->cmd( "get $url" );
is($s->agent->res->code, 401, "Request without credentials gives 401");
like($s->agent->content, '/^auth required /', "Content requests authentication");

# Now try the shell command for authentication
$s->cmd( "auth foo bar" );
#use Data::Dumper;
#diag Dumper $s->agent->{'basic_authentication'};

# WWW::Mechanize breaks the LWP::UserAgent API in a bad, bad way
# so we have to be explicit about who we ask about information:
my @credentials = LWP::UserAgent::credentials($s->agent,$host,'testing realm');
diag "LWP stored credentials: @credentials";
is_deeply( \@credentials, ["foo","bar"],"UA stored the authentification");

@credentials = $s->agent->credentials($host,'testing realm');
diag "WWW::Mechanize returned credentials: @credentials";

if ($credentials[0] ne 'foo') {
    SKIP: { 
        skip "WWW::Mechanize $WWW::Mechanize::VERSION has buggy implementation/override of ->credentials", 1;
    };
} else {
    $s->cmd( "get $url" );
    diag $s->agent->res->message
      unless is($s->agent->res->code, 200, "Request with credentials gives 200");
    is($s->agent->content, "user = 'foo' pass = 'bar'", "Credentials are good");
};

diag "Shutting down test server at $url";
$s->agent->get("${url}exit"); # shut down server

};

END {
  close SERVER; # boom
};
