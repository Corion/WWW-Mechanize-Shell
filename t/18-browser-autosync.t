#!/usr/bin/perl -w
use strict;
use Test::HTTP::LocalServer;
use lib './inc';
use IO::Catch;

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'IO::Catch', '_STDOUT_' or die $!;

use vars qw( %tests );

BEGIN {
  %tests = (
      back => { count => 3, commands => ['get %s','click submit','back']},
      browse => { count => 2, commands => [ 'get %s', 'browse' ] },
      get => { count => 1, commands => ['get %s']} ,
      open => { count => 2, commands => ['get %s','open 1'] },
      submit => { count => 2, commands => ['get %s','submit']},
      click => { count => 2, commands => ['get %s','click submit']},
      reload => { count => 2, commands => ['get %s','reload'] },
  )
};

use Test::More tests => scalar (keys %tests) +1;
SKIP: {

BEGIN {
  # Disable all ReadLine functionality
  $ENV{PERL_RL} = 0;
  use_ok('WWW::Mechanize::Shell');

};

my $browser_synced;
{ no warnings 'redefine';
  *WWW::Mechanize::Shell::sync_browser = sub {
    $browser_synced++;
  };
};

my $server = Test::HTTP::LocalServer->spawn();

sub sync_ok {
  my %args = @_;
  my $name = $args{name};
  my $count = $args{count};
  my (@commands) = @{$args{commands}};

  my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef, warnings => undef );
  $s->option('autosync', 1);
  $browser_synced = 0;

  for my $cmd (@commands) {
    no warnings;
    $cmd = sprintf $cmd, $server->url;
    $s->cmd($cmd);
  };
  is($browser_synced,$count,"'$name' synchronizes $count times")
    or diag join "\n", @commands;
};

for my $cmd (sort keys %tests) {
  sync_ok( name => $cmd, %{$tests{$cmd}} );
};

$server->stop;
