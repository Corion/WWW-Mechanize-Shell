#!/usr/bin/perl -w
use strict;
use FindBin;

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
use vars qw( $_STDOUT_ $_STDERR_ );

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

use Test::More tests => 7;
SKIP: {
#skip "Can't load Term::ReadKey without a terminal", 7
#  unless -t STDIN;
#eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
#if ($@) {
#  no warnings 'redefine';
#  *Term::ReadKey::GetTerminalSize = sub {80,24};
#  diag "Term::ReadKey seems to want a terminal";
#};

use_ok('WWW::Mechanize::Shell');

eval { require HTTP::Daemon; };
skip "HTTP::Daemon required to test basic authentication",6
  if ($@);

# We want to be safe from non-resolving local host names
delete $ENV{HTTP_PROXY};

# Now start a fake webserver, fork, and connect to ourselves
open SERVER, qq'"$^X" $FindBin::Bin/401-server |'
  or die "Couldn't spawn fake server : $!";
sleep 1; # give the child some time
my $url = <SERVER>;

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
$s->cmd( "get $url" );
diag $s->agent->res->message
  unless is($s->agent->res->code, 200, "Request with credentials gives 200");
is($s->agent->content, "user = 'foo' pass = 'bar'", "Credentials are good");

};

END {
  close SERVER; # boom
};
