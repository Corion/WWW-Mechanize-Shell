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
      'save' => 'save /foo/',
      'submit' => 'submit',
      'value' => 'value key value',
      'ua' => 'ua foo/1.0',
  );

  eval {
    require HTML::TableExtract;
    $tests{table} = 'table';
    $tests{table params} = 'table foo bar';
    ;
  };
};

use Test::More tests => scalar (keys %tests) +1;
SKIP: {
skip "Can't load Term::ReadKey without a terminal", scalar (keys %tests) +1
  unless -t STDIN;

eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
if ($@) {
  no warnings 'redefine';
  *Term::ReadKey::GetTerminalSize = sub {80,24};
  diag "Term::ReadKey seems to want a terminal";
};

eval {
  require Test::MockObject;
  Test::MockObject->import();
};
skip "Test::MockObject not installed", scalar keys(%tests) +1
  if $@;

my $mock_result = Test::MockObject->new;
$mock_result->set_always( code => 200 );

my $mock_form = Test::MockObject->new;
$mock_form->mock( value => sub {} )
          ->set_list( inputs => ());

my $mock_uri = Test::MockObject->new;
$mock_uri->set_always( abs => 'http://example.com/' );
$mock_uri->fake_module( 'URI::URL', new => sub {$mock_uri} );

my $mock_agent = Test::MockObject->new;
$mock_agent->set_true($_)
  for qw( back content get mirror open follow );
$mock_agent->set_false($_)
  for qw( form forms );
$mock_agent->set_always( res => $mock_result )
           ->set_always( submit => $mock_result )
           ->set_always( click => $mock_result )
           ->set_always( current_form => $mock_form )
           ->set_always( follow => 1 )
           ->set_always( links => [['foo','foo link','foo_link'],['foo2','foo2 link','foo2_link']])
           ->set_always( agent => 'mocked/1.0')
           ->set_always( uri => $mock_uri );

use_ok('WWW::Mechanize::Shell');
my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );
$s->{agent} = $mock_agent;

my @history;
{ no warnings 'redefine';
  *WWW::Mechanize::Shell::add_history = sub {
    my $shell = shift;
    push @history, $shell->line;
  };
};

sub exactly_one_line {
  my ($command,$testname) = @_;
  $testname ||= $command;
  @history = ();
  $s->cmd($command);
  is_deeply([@history],[$command],"$testname adds one line to history");
};


foreach my $name (sort keys %tests) {
  exactly_one_line( $tests{$name},$name );
};
};
