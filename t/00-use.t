use strict;
use Test::More tests => 18;

SKIP: {
  skip "Can't load Term::ReadKey without a terminal", 18
    unless -t STDIN;
  eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize() };
  if ($@) {
    diag "Term::ReadKey seems to want a terminal";
    *Term::ReadKey::GetTerminalSize = sub {80,24};
  };

  use_ok("WWW::Mechanize::Shell");

  my $s = do {
    local $SIG{__WARN__} = sub {};
    WWW::Mechanize::Shell->new("shell",rcfile => undef);
  };
  isa_ok($s,"WWW::Mechanize::Shell");

  # Now check our published API :
  for my $meth (qw( source_file cmdloop agent option restart_shell option)) {
    can_ok($s,$meth);
  };

  # Check that we can set known options
  my $oldvalue = $s->option('autosync');
  $s->option('autosync',"foo");
  is($s->option('autosync'),"foo","Setting an option works");
  $s->option('autosync',$oldvalue);
  is($s->option('autosync'),$oldvalue,"Setting an option still works");

  # Check that trying to set an unknown option gives an error
  {
    my $called;
    local *Carp::carp = sub {
      $called++;
    };
    $s->option('nonexistingoption',"foo");
    is($called,1,"Setting an nonexisting option calls Carp::carp");
  }

  {
    my $called;
    my $filename;
    local *WWW::Mechanize::Shell::source_file = sub {
      $filename = $_[1];
      $called++;
    };
    my $test_filename = '/does/not/need/to/exist';
    my $s = do {
      local $SIG{__WARN__} = sub {};
      WWW::Mechanize::Shell->new("shell",rcfile => $test_filename);
    };
    isa_ok($s,"WWW::Mechanize::Shell");
    ok($called,"Passing an .rc file tries to load it");
    is($filename,$test_filename,"Passing an .rc file tries to load the right file");
  };

  {
    my $called = 0;
    my $filename;
    local *WWW::Mechanize::Shell::source_file = sub {
      $filename = $_[1];
      $called++;
    };
    my $s = do {
      local $SIG{__WARN__} = sub {};
      WWW::Mechanize::Shell->new("shell",rcfile => undef);
    };
    isa_ok($s,"WWW::Mechanize::Shell");
    diag "Tried to load '$filename'" unless is($called,0,"Passing in no .rc file tries not to load it");
  };

  $s = do {
    local $SIG{__WARN__} = sub {};
    WWW::Mechanize::Shell->new("shell",rcfile => undef, cookiefile => 'test.cookiefile');
  };
  isa_ok($s,"WWW::Mechanize::Shell");
  is($s->option('cookiefile'),'test.cookiefile',"Passing in a cookiefile filename works");
};
