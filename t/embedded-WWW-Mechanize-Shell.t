#!D:\Programme\indigoperl-5.6\bin\perl.exe -w

use Test::More 'no_plan';

package Catch;

sub TIEHANDLE {
    my($class, $var) = @_;
    return bless { var => $var }, $class;
}

sub PRINT  {
    my($self) = shift;
    ${'main::'.$self->{var}} .= join '', @_;
}

sub OPEN  {}    # XXX Hackery in case the user redirects
sub CLOSE {}    # XXX STDERR/STDOUT.  This is not the behavior we want.

sub READ {}
sub READLINE {}
sub GETC {}
sub BINMODE {}

my $Original_File = 'D:lib\WWW\Mechanize\Shell.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module WWW::Mechanize::Shell
  eval { require WWW::Mechanize::Shell };
  skip "Need module WWW::Mechanize::Shell to run this test", 1
    if $@;

  # Check for module strict
  eval { require strict };
  skip "Need module strict to run this test", 1
    if $@;


    # The original POD test
        undef $main::_STDOUT_;
    undef $main::_STDERR_;
eval q{
  my $example = sub {
    local $^W = 0;

#line 18 lib/WWW/Mechanize/Shell.pm

  #!/usr/bin/perl -w
  use strict;
  use WWW::Mechanize::Shell;

  my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef );

  if (@ARGV) {
    $shell->source_file( @ARGV );
  } else {
    $shell->cmdloop;
  };




;

  }
};
is($@, '', "example from line 18");

};
SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Term::ReadKey
  eval { require Term::ReadKey };
  skip "Need module Term::ReadKey to run this test", 1
    if $@;

  # Check for module WWW::Mechanize::Shell
  eval { require WWW::Mechanize::Shell };
  skip "Need module WWW::Mechanize::Shell to run this test", 1
    if $@;

  # Check for module strict
  eval { require strict };
  skip "Need module strict to run this test", 1
    if $@;


    # The original POD test
    {
    undef $main::_STDOUT_;
    undef $main::_STDERR_;
#line 18 lib/WWW/Mechanize/Shell.pm

  #!/usr/bin/perl -w
  use strict;
  use WWW::Mechanize::Shell;

  my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef );

  if (@ARGV) {
    $shell->source_file( @ARGV );
  } else {
    $shell->cmdloop;
  };




  BEGIN {
    require WWW::Mechanize::Shell;
    no warnings 'once';
    *WWW::Mechanize::Shell::cmdloop = sub {};
    eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize() };
    if ($@) {
      diag "Term::ReadKey seems to want a terminal";
      *Term::ReadKey::GetTerminalSize = sub {80,24};
    };
  };
  isa_ok( $shell, "WWW::Mechanize::Shell" );

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

};
SKIP: {
    # A header testing whether we find all prerequisites :
    
    # The original POD test
        undef $main::_STDOUT_;
    undef $main::_STDERR_;

};
