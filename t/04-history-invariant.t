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

# pre-5.8.0's warns aren't caught by a tied STDERR.
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;

use vars qw( @history_invariant @history_add );

BEGIN {
  @history_invariant = qw(
      browse
      cookies
      dump
      eval
      exit
      forms
      history
      links
      parse
      quit
      restart
      set
      source
      tables
  );

  @history_add = qw(
      autofill
      back
      click
      content
      fillout
      get
      open
      submit
      table
      value
  );
};

use Test::More tests => scalar @history_invariant +1;
SKIP: {
skip "Can't load Term::ReadKey without a terminal", scalar @history_invariant +1
  unless -t STDIN;


eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
if ($@) {
  no warnings 'redefine';
  *Term::ReadKey::GetTerminalSize = sub {80,24};
  diag "Term::ReadKey seems to want a terminal";
};

use_ok('WWW::Mechanize::Shell');

# Silence all warnings
$SIG{__WARN__} = sub {};

my $s = WWW::Mechanize::Shell->new( 'test', rcfile => undef );
$s->agent->{content} = '';

my @history;

sub disable {
  my ($namespace,$subname) = @_;
  no strict 'refs';
  no warnings 'redefine';
  *{$namespace."::".$subname} = sub {};
};

{ no warnings 'redefine';
  *WWW::Mechanize::Shell::add_history = sub {
    shift;
    push @history, join "", @_;
  };
};

disable( "WWW::Mechanize::Shell", $_ )
  for (qw( restart_shell browser ));

disable( "WWW::Mechanize",$_ )
  for (qw( links cookie_jar current_form forms ));

disable( "Term::Shell",$_ )
  for (qw( print_pairs ));

for my $cmd (@history_invariant) {
  @history = ();
  $s->cmd($cmd);
  is_deeply( \@history, [], "$cmd is history invariant");
};
};
