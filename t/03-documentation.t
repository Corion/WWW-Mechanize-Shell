use strict;
use Test::More qw( no_plan );

SKIP: {
  eval {
    require Pod::Constants;
  };
  skip "Pod::Constants to test the documentation", 1
    if $@;

  eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
  if ($@) {
    no warnings 'redefine';
    *Term::ReadKey::GetTerminalSize = sub {80,24};
    diag "Term::ReadKey seems to want a terminal";
  };

  use_ok("WWW::Mechanize::Shell");
  my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef );

  my $module = $INC{'WWW/Mechanize/Shell.pm'};
  open MODULE, "< $module"
    or die "Couldn't open module file '$module'";
  my @methods = map { /^\s*sub run_([a-z]+)\s*\{/ ? $1 : () } <MODULE>;
  close MODULE;

  isa_ok($shell,"WWW::Mechanize::Shell");
  for my $method (@methods) {
    my $helptext = $shell->catch_smry($method);
    is($@,'',"No error");
    isnt( $helptext, undef, "Documentation for $method is there");
    isnt( $helptext, '', "Documentation for $method is not empty");
  };
};
