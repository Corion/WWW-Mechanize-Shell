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

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;

use vars qw( %tests );

BEGIN {
  # Disable all ReadLine functionality
  $ENV{PERL_RL} = 0;

  %tests = (
      'autofill' => 'autofill test Fixed value',
      'back' => 'back',
      'click' => 'click',
      'content' => 'content',
      'eval' => 'eval 1',
      'fillout' => 'fillout',
      'get @' => 'get http://admin@www.google.com/',
      'get plain' => 'get http://www.google.com/',
      'open' => 'open foo',
      'reload' => 'reload',
      'referrer' => 'referrer ""',
      'referer' => 'referer ""',
      'save' => 'save 0',
      'save re' => 'save /.../',
      'submit' => 'submit',
      'tick' => 'tick key value',
      'tick_all' => 'tick key',
      'timeout' => 'timeout 60',
      'value' => 'value key value',
      'ua' => 'ua foo/1.1',
      'untick' => 'untick key value',
      'untick_all' => 'untick key',
  );

  eval {
    require HTML::TableExtract;
    $tests{table} = 'table';
    $tests{'table params'} = 'table foo bar';
  };
};

use Test::More tests => scalar (keys %tests)*2 +1;
SKIP: {
use_ok('WWW::Mechanize::Shell');

eval {
  require Test::MockObject;
  Test::MockObject->import();
};
skip "Test::MockObject not installed", scalar (keys %tests)*2
  if $@;

my $mock_result = Test::MockObject->new;
$mock_result->set_always( code => 200 );

my $mock_form = Test::MockObject->new;
$mock_form->mock( value => sub {} )
          ->set_list( inputs => ())
          ->set_list( find_input => ());

my $mock_agent = Test::MockObject->new;
$mock_agent->set_true($_)
  for qw( back content get open  );
$mock_agent->set_false($_)
  for qw( form forms );
my $mock_uri = Test::MockObject->new;
$mock_uri->set_always( abs => 'http://example.com/' )
         ->set_always( path => '/' );
$mock_uri->fake_module( 'URI::URL', new => sub {$mock_uri} );

$mock_agent->set_always( res => $mock_result )
           ->set_always( add_header => 1 )
           ->set_always( submit => $mock_result )
           ->set_always( click => $mock_result )
           ->set_always( reload => $mock_result )
           ->set_always( current_form => $mock_form )
           ->set_always( follow => 1 )
           ->set_always( links => [['foo','foo link','foo_link'],['foo2','foo2 link','foo2_link']])
           ->set_always( agent => 'foo/1.0' )
           ->set_always( tick => 1 )
           ->set_always( timeout => 1 )
           ->set_always( untick => 1 )
           ->set_always( uri => $mock_uri );

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef, watchfiles => undef );
$s->{agent} = $mock_agent;

my @history;
{ no warnings 'redefine';
  *WWW::Mechanize::Shell::add_history = sub {
    shift;
    push @history, join "", @_;
  };
};

sub compiles_ok {
  my ($command,$testname) = @_;
  $testname ||= $command;
  @history = ();
  $s->cmd('links');
  $s->cmd($command);
  local $, = "\n";
  my ($fh,$name) = tempfile();
  print $fh ( "@history" );
  close $fh;
  ok( scalar @history != 0, "$testname is history relevant");

  my $output = `$^X -Ilib -c $name 2>&1`;
  chomp $output;
  is( $output, "$name syntax OK", "$testname compiles")
    or diag "Created file was :\n@history";
  unlink $name
    or diag "Couldn't remove tempfile '$name' : $!";
};


foreach my $name (sort keys %tests) {
  compiles_ok( $tests{$name},$name );
};
};
