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
  %tests = (
      'autofill' => 'autofill test Fixed value',
      'back' => 'back',
      'click' => 'click',
      'content' => 'content',
      'fillout' => 'fillout',
      'get @' => 'get http://admin@www.google.com/',
      'get plain' => 'get http://www.google.com/',
      'open' => 'open foo',
      'save' => 'save 0',
      'save re' => 'save /.../',
      'submit' => 'submit',
      'table' => 'table',
      'table params' => 'table foo bar',
      'value' => 'value key value',
      'ua' => 'ua foo/1.1',
  );
};

use Test::More tests => scalar (keys %tests)*2 +1;
SKIP: {
skip "Can't load Term::ReadKey without a terminal", scalar (keys %tests)*2 +1
  unless -t STDIN;

eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
if ($@) {
  no warnings 'redefine';
  *Term::ReadKey::GetTerminalSize = sub {80,24};
  diag "Term::ReadKey seems to want a terminal";
};

use_ok('WWW::Mechanize::Shell');

eval {
  require Test::MockObject;
  Test::MockObject->import();
};
skip "Test::MockObject not installed", scalar keys %tests
  if $@;

my $mock_result = Test::MockObject->new;
$mock_result->set_always( code => 200 );

my $mock_form = Test::MockObject->new;
$mock_form->mock( value => sub {} )
          ->set_list( inputs => ());

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
           ->set_always( submit => $mock_result )
           ->set_always( click => $mock_result )
           ->set_always( current_form => $mock_form )
           ->set_always( follow => 1 )
           ->set_always( links => [['foo','foo link','foo_link'],['foo2','foo2 link','foo2_link']])
           ->set_always( agent => 'foo/1.0' )
           ->set_always( uri => $mock_uri );

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );
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
