use strict;
use FindBin;

use vars qw( @methods );
BEGIN {
  my $module = "$FindBin::Bin/../lib/WWW/Mechanize/Shell.pm";
  open MODULE, "< $module"
    or die "Couldn't open module file '$module'";
  @methods = map { /^\s*sub run_([a-z]+)\s*\{/ ? $1 : () } <MODULE>;
  close MODULE;
};

use Test::More tests => scalar @methods*3 +2;

SKIP: {
  skip "Can't load Term::ReadKey without a terminal", 2 + scalar @methods*3
    unless -t STDIN;

  eval {
    require Pod::Constants;
  };
  skip "Need Pod::Constants to test the documentation", 2 + scalar @methods*3
    if $@;

  use_ok("WWW::Mechanize::Shell");

  eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize(); };
  if ($@) {
    no warnings 'redefine';
    *Term::ReadKey::GetTerminalSize = sub {80,24};
    diag "Term::ReadKey seems to want a terminal";
  };

  my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef, warnings => undef );
  isa_ok($shell,"WWW::Mechanize::Shell");
  for my $method (@methods) {
    my $helptext = $shell->catch_smry($method);
    is($@,'',"No error");
    isnt( $helptext, undef, "Documentation for $method is there");
    isnt( $helptext, '', "Documentation for $method is not empty");
  };
};
