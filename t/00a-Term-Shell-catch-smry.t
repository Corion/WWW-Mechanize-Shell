use strict;
use Test::More tests => 1;

{
  package Catch;
  sub TIEHANDLE {
      my($class, $var) = @_;
      return bless { var => $var }, $class;
  }

  sub PRINT {};
};

# Disable all ReadLine functionality
$ENV{PERL_RL} = 0;

SKIP: {
  #skip "Can't load Term::ReadKey without a terminal", 1
  #  unless -t STDIN;
  #eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize() };
  #if ($@) {
  #  diag "Term::ReadKey seems to want a terminal";
  #  no warnings 'redefine';
  #  *Term::ReadKey::GetTerminalSize = sub {80,24};
  #};

  # Now check that the Term::Shell summary calls catch_smry

  require Term::Shell;
  use vars qw( $called );
  {
    package Term::Shell::Test;
    use base 'Term::Shell';
    sub summary { $::called++ };
    sub print_pairs {};
  };
  my $s = { handlers => { foo => { run => sub {}}} };
  bless $s, 'Term::Shell::Test';

  { local *STDOUT;
    tie *STDOUT, 'Catch';
    $s->run_help();
  };

  if (not is($called,1,"Term::Shell::Test::catch_smry gets called for unknown methods")) {
    diag "Term::Shell did not call a custom catch_smry handler";
    diag "This is most likely because your version of Term::Shell";
    diag "has a bug. Please upgrade to v0.02 or higher, which";
    diag "should close this bug.";
    diag "If that is no option, patch sub help() in Term/Shell.pm, line 641ff.";
    diag "to:";
    diag '      #my $smry = exists $o->{handlers}{$h}{smry};';
		diag '    #? $o->summary($h);';
		diag '    #: "undocumented";';
    diag '      my $smry = $o->summary($h);';
    diag 'Fixing this is not necessary - you will get no online help';
    diag 'but the shell will otherwise work fine. Help is still';
    diag 'available through ``perldoc WWW::Mechanize::Shell``';
  };
};

