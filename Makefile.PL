use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'    => 'WWW::Mechanize::Shell',
    'VERSION_FROM'  => 'lib/WWW/Mechanize/Shell.pm', # finds $VERSION
    'PREREQ_PM'    => {'Term::Shell' => 0.01,
    									 'URI::URL' => 0.00,
                       'WWW::Mechanize' => 0.57,
                       'WWW::Mechanize::FormFiller' => 0.05,
                       'Hook::LexWrap' => 0.20,
                       'HTML::TokeParser::Simple' => 2.0,
                      }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/WWW/Mechanize/Shell.pm', # retrieve abstract from module
       AUTHOR     => 'Max Maischein <corion@cpan.org>') : ()),
);

use vars qw($have_test_inline);
BEGIN {
  eval { require Test::Inline;
         $have_test_inline = $Test::Inline::VERSION ge '0.15_001'; };
  undef $@;
  if ($have_test_inline) {
    print "Good - you have a patched Test::Inline\n";
  } else {
    print "Test::Inline 0.15_001 is nice for testing the examples, but not necessary\n"
  };
};

# Autocreate the synopsis test from the pod of every module
# (if we have Test::Inline)
{
    package MY;
    use strict;
    sub top_targets {

        my($self) = @_;
        my $out = "POD2TEST_EXE = pod2test\n";

        $out .= $self->SUPER::top_targets(@_);
        return $out unless $main::have_test_inline;

        $out =~ s/^(pure_all\b.*)/$1 testifypods/m;

        $out .= "\n\ntestifypods : \n";

        foreach my $pod (keys %{$self->{MAN1PODS}},
                         keys %{$self->{MAN3PODS}})
        {
            (my $test = $pod) =~ s/\.(pm|pod)$//;
            $test =~ s|/|-|g;
            $test =~ s/^lib\W//;
            $test =~ s/\W/-/;
            $test = "embedded-$test.t";
            $out .= "\t$self->{NOECHO}\$(POD2TEST_EXE) ".
                    "$pod t/$test\n";
        }

        return $out;
    }
    
		sub postamble {
    	return <<EOF
cover:
\trm -rf cover_db
\tHARNESS_PERL_SWITCHES=-MDevel::Cover=-coverage,statement,time,-silent,1,-select,^blib/lib,+inc,Win32,-summary,0 \$(MAKE) test || true
\t\$(PERL) /usr/bin/cover cover_db -report html 
EOF
		}
}

# To make Test::Prereq happy
1;
