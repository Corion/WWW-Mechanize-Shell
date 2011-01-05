use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'    => 'WWW::Mechanize::Shell',
    'VERSION_FROM'  => 'lib/WWW/Mechanize/Shell.pm', # finds $VERSION
    'PREREQ_PM'    => {'Term::Shell' => 0.02,
                       'parent' => 0,
		       'URI::URL' => 0.00,
		       'Test::Harness' => 2.30,
                       'LWP' => 5.69,
                       'WWW::Mechanize' => 1.20,
                       'WWW::Mechanize::FormFiller' => 0.05,
                       'Hook::LexWrap' => 0.20,
		       'HTML::Display' => 0,
                       'HTML::TokeParser::Simple' => 2.0,
                      }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/WWW/Mechanize/Shell.pm', # retrieve abstract from module
       AUTHOR     => 'Max Maischein <corion@cpan.org>') : ()),
);

# To make Test::Prereq happy
1;
