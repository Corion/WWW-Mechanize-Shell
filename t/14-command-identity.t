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
use File::Temp qw( tempfile );
use vars qw( %tests $_STDOUT_ $_STDERR_ );
use URI::URL;
use LWP::Simple;

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

BEGIN {
  %tests = (
    autofill => { requests => 2, lines => [ 'get %s', 'autofill query Fixed foo', 'fillout', 'submit' ]},
    back => { requests => 2, lines => [ 'get %s','get %s/back1','back' ] },
    eval => { requests => 1, lines => [ 'eval "Hello World"', 'get %s','eval "Goodbye World"' ] },
    eval_shell => { requests => 1, lines => [ 'get %s', 'eval $self->agent->ct' ] },
    get => { requests => 1, lines => [ 'get %s' ] },
    get_content => { requests => 1, lines => [ 'get %s', 'content' ] },
    get_save => { requests => 4, lines => [ 'get %s','save "/\.save_log_server_test\.tmp$/"' ] },
    get_value_click => { requests => 2, lines => [ 'get %s','value query foo', 'click submit' ] },
    get_value_submit => { requests => 2, lines => [ 'get %s','value query foo', 'submit' ] },
    get_value2_submit => { requests => 2, lines => [ 'get %s','value query foo', 'value session 2', 'submit' ] },
    open_parm => { requests => 2, lines => [ 'get %s','open 0','content' ] },
    open_re => { requests => 2, lines => [ 'get %s','open "foo1"','content' ] },
    ua_get => { requests => 1, lines => [ 'ua foo/1.1', 'get %s' ] },
    ua_get_content => { requests => 1, lines => [ 'ua foo/1.1', 'get %s', 'content' ] },
  );

  eval {
    require HTML::TableExtract;
    $tests{get_table} = { requests => 1, lines => [ 'get %s','table' ] };
    $tests{get_table_params} = { requests => 1, lines => [ 'get %s','table Col2 Col1' ] };
  };
};

use Test::More tests => 1 + (scalar keys %tests)*5;
SKIP: {
#skip "Can't load Term::ReadKey without a terminal", 1 +(scalar keys %tests)*5
#  unless -t STDIN;

#eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
#if ($@) {
#  no warnings 'redefine';
#  *Term::ReadKey::GetTerminalSize = sub {80,24};
#  diag "Term::ReadKey seems to want a terminal";
#};

# start a fake webserver, fork, and connect to ourselves
{
  package Test::HTTP::LocalServer;
  use LWP::Simple;

  sub spawn {
    my ($class,%args) = @_;
    my $self = { %args };
    bless $self,$class;

    open my $server, qq'"$^X" $FindBin::Bin/log-server|'
      or die "Couldn't spawn fake server : $!";
    sleep 1; # give the child some time
    my $url = <$server>;
    chomp $url;

    $self->{_fh} = $server;
    $self->{_server_url} = $url;

    $self;
  };

  sub port { URI::URL->new($_[0]->url)->port };
  sub url { $_[0]->{_server_url} };
  sub stop { get( $_[0]->{_server_url} . "quit_server" )};

  sub get_output {
    my ($self) = @_;
    $self->stop;
    my $fh = $self->{_fh};
    my $result = join "\n", <$fh>;
    $self->{_fh}->close;
    $result;
  };
};

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

use_ok('WWW::Mechanize::Shell');

eval { require HTTP::Daemon; };
skip "HTTP::Daemon required to test script/code identity",(scalar keys %tests)*5
  if ($@);

# We want to be safe from non-resolving local host names
delete $ENV{HTTP_PROXY};

my $actual_requests;
{
  no warnings 'redefine';
  my $old_do_request = *WWW::Mechanize::_do_request{CODE};
  *WWW::Mechanize::_do_request = sub {
    $actual_requests++;
    goto &$old_do_request;
  };

  *WWW::Mechanize::Shell::status = sub {};
};

for my $name (sort keys %tests) {
  $_STDOUT_ = '';
  undef $_STDERR_;
  $actual_requests = 0;
  my @lines = @{$tests{$name}->{lines}};
  my $requests = $tests{$name}->{requests};

  my $server = Test::HTTP::LocalServer->spawn();
	my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );
	for my $line (@lines) {
	  $line = sprintf $line, $server->url;
  	$s->cmd($line);
	};
  my $code_output = $_STDOUT_;
	is($_STDERR_,undef,"Shell produced no error output for $name");
	is($actual_requests,$requests,"$requests requests were made for $name");
	my $code_requests = $server->get_output;
	my $code_port = $server->port;

  my $script_server = Test::HTTP::LocalServer->spawn();
	my $script_port = $script_server->port;

  # Modify the generated Perl script to match the new? port
  my $script = join "\n", $s->script;
  $script =~ s!\b$code_port\b!$script_port!smg;

	# Write the generated Perl script
  my ($fh,$tempname) = tempfile();
  print $fh $script;
  close $fh;

  my ($compile) = `$^X -c "$tempname" 2>&1`;
  chomp $compile;
  unless (is($compile,"$tempname syntax OK","$name compiles")) {
    $script_server->stop;
    diag $script;
    ok(0, "Script $name didn't compile" );
    ok(0, "Script $name didn't compile" );
  } else {
    my ($output);
    my $command = qq($^X -Ilib "$tempname" 2>&1);
    $output = `$command`;
    is( $output, $code_output, "Output of $name is identical" )
      or diag "Script:\n$script";
		my $script_requests = $script_server->get_output;
	  $code_requests =~ s!\b$code_port\b!$script_port!smg;
		is($code_requests,$script_requests,"$name produces identical queries");
  };
  unlink $tempname
    or diag "Couldn't remove tempfile '$name' : $!";
};

unlink $_ for (<*.save_log_server_test.tmp>);

};
