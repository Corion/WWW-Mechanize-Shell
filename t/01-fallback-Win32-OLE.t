use strict;
use Test::More tests => 4;


SKIP: {
  skip "Can't load Term::ReadKey without a terminal", 4
    unless -t STDIN;

  eval {
    require Test::Without::Module;
    Test::Without::Module->import('Win32::OLE')
  };
  skip "Need Test::Without::Module to test the fallback", 4
    if $@;

  eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize() };
  if ($@) {
    no warnings 'redefine';
    *Term::ReadKey::GetTerminalSize = sub {80,24};
    diag "Term::ReadKey seems to want a terminal";
  };

  use_ok("WWW::Mechanize::Shell");
  my $shell = do {
    WWW::Mechanize::Shell->new("shell", rcfile => undef );
  };

  isa_ok($shell,"WWW::Mechanize::Shell");
  my $browser;

  eval {
    $browser = $shell->browser;
  };
  is( $@, '', "No error without Win32::OLE");
  is( $browser, undef, "No browser interface without Win32::OLE");
};
