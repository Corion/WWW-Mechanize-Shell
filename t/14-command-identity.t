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
    autofill => { requests => 2, lines => [ 'get %s', 'autofill query Fixed foo', 'fillout', 'submit' ], location => '%sformsubmit'},
    back => { requests => 2, lines => [ 'get %s','open 0','back' ], location => '%s' },
    eval => { requests => 1, lines => [ 'eval "Hello World"', 'get %s','eval "Goodbye World"' ], location => '%s' },
    eval_shell => { requests => 1, lines => [ 'get %s', 'eval $self->agent->ct' ], location => '%s' },
    eval_sub => { requests => 2, lines => [
						'# Fill in the "date" field with the current date/time as string',
  					'eval sub ::custom_today { "20030511" };',
  					'autofill session Callback ::custom_today',
  					'get %s',
  					'fillout',
  					'eval $self->agent->current_form->value("session")',
  					'submit',
  					'content',
    ], location => '%sformsubmit' },
    form => { requests => 2, lines => [ 'get %s','form 1','submit' ], location => '%sformsubmit' },
    formfiller_chars => { requests => 2,
    									lines => [ 'eval srand 0', 'autofill query Random::Chars size 5 set alpha', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_date => { requests => 2,
    									lines => [ 'eval srand 0', 'autofill query Random::Date string %%Y%%m%%d', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_default => { requests => 2,
    									lines => [ 'autofill query Default foo', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_fixed => { requests => 2,
    									lines => [ 'autofill query Fixed foo', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_keep => { requests => 2,
    									lines => [ 'autofill query Keep foo', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_random => { requests => 2,
    									lines => [ 'autofill query Random foo', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    formfiller_word => { requests => 2,
    									lines => [ 'eval srand 0', 'autofill query Random::Word size 1', 'get %s', 'fillout','submit','content' ],
    									location => '%sformsubmit' },
    get => { requests => 1, lines => [ 'get %s' ], location => '%s' },
    get_content => { requests => 1, lines => [ 'get %s', 'content' ], location => '%s' },
    get_redirect => { requests => 1, lines => [ 'get %sredirect/startpage' ], location => '%sstartpage' },
    get_save => { requests => 4, lines => [ 'get %s','save "/\.save_log_server_test\.tmp$/"' ], location => '%s' },
    get_value_click => { requests => 2, lines => [ 'get %s','value query foo', 'click submit' ], location => '%sformsubmit' },
    get_value_submit => { requests => 2, lines => [ 'get %s','value query foo', 'submit' ], location => '%sformsubmit' },
    get_value2_submit => { requests => 2, lines => [
    				'get %s',
    				'value query foo',
    				'value session 2',
    				'submit'
    ], location => '%sformsubmit' },
    interactive_script_creation => { requests => 2,
    									lines => [ 'eval @::list=qw(foo bar xxx)', 
    														 'eval no warnings "once"; *WWW::Mechanize::FormFiller::Value::Ask::ask_value = sub { my $value=shift @::list; push @{$_[0]->{shell}->{answers}}, [ $_[1]->name, $value ]; $value }', 
    														 'get %s', 
    														 'fillout',
    														 'submit',
    														 'content' ],
    									location => '%sformsubmit' },
    open_parm => { requests => 2, lines => [ 'get %s','open 0','content' ], location => '%stest' },
    open_re => { requests => 2, lines => [ 'get %s','open "foo1"','content' ], location => '%sfoo1.save_log_server_test.tmp' },
    open_re2 => { requests => 2, lines => [ 'get %s','open "/foo1/"','content' ], location => '%sfoo1.save_log_server_test.tmp' },
    open_re3 => { requests => 2, lines => [ 'get %s','open "/Link /foo/"','content' ], location => '%sfoo' },
    open_re4 => { requests => 2, lines => [ 'get %s','open "/Link \/foo/"','content' ], location => '%sfoo' },
    open_re5 => { requests => 2, lines => [ 'get %s','open "/Link /$/"','content' ], location => '%sslash_end' },
    open_re6 => { requests => 2, lines => [ 'get %s','open "/^/Link$/"','content' ], location => '%sslash_front' },
    open_re7 => { requests => 2, lines => [ 'get %s','open "/^/Link in slashes//"','content' ], location => '%sslash_both' },
    ua_get => { requests => 1, lines => [ 'ua foo/1.1', 'get %s' ], location => '%s' },
    ua_get_content => { requests => 1, lines => [ 'ua foo/1.1', 'get %s', 'content' ], location => '%s' },
  );

  eval {
    require HTML::TableExtract;
    $tests{get_table} = { requests => 1, lines => [ 'get %s','table' ], location => '%s' };
    $tests{get_table_params} = { requests => 1, lines => [ 'get %s','table Col2 Col1' ], location => '%s' };
  };
  
  # To ease zeroing in on tests
  #for (sort keys %tests) {
  #  delete $tests{$_} unless /^i|^eval_sub/;
  #};
};

use Test::More tests => 1 + (scalar keys %tests)*6;
SKIP: {

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

  my $result_location = sprintf $tests{$name}->{location}, $server->url;
	my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );
	for my $line (@lines) {
	  $line = sprintf $line, $server->url;
  	$s->cmd($line);
	};
	$s->cmd('eval $self->agent->uri');
  my $code_output = $_STDOUT_;
  diag join( "\n", $s->history )
    unless is($s->agent->uri,$result_location,"Shell moved to the specified url for $name");
	is($_STDERR_,undef,"Shell produced no error output for $name");
	is($actual_requests,$requests,"$requests requests were made for $name");
	my $code_requests = $server->get_output;
	my $code_port = $server->port;

  my $script_server = Test::HTTP::LocalServer->spawn();
	my $script_port = $script_server->port;

  # Modify the generated Perl script to match the new? port
  my $script = join "\n", $s->script;
  s!\b$code_port\b!$script_port!smg for ($script, $code_output);
  undef $s;

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
