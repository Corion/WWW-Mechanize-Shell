# This Makefile is for the WWW::Mechanize::Shell extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.05 (Revision: 1.69) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT_FROM => q[lib/WWW/Mechanize/Shell.pm]
#     AUTHOR => q[Max Maischein <corion@cpan.org>]
#     NAME => q[WWW::Mechanize::Shell]
#     PREREQ_PM => { WWW::Mechanize::FormFiller=>q[0.02], Term::Shell=>q[0.01], WWW::Mechanize=>q[0.35] }
#     VERSION_FROM => q[lib/WWW/Mechanize/Shell.pm]

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via D:/Programme/indigoperl-5.6/lib/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = lib
CC = cl
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = dll
DLSRC = dl_win32.xs
LD = link
LDDLFLAGS = -dll -nologo -nodefaultlib -release  -libpath:"f:\dev\dp\perl-5.6_install\lib\CORE"  -machine:x86
LDFLAGS = -nologo -nodefaultlib -release  -libpath:"f:\dev\dp\perl-5.6_install\lib\CORE"  -machine:x86
LIBC = msvcrt.lib
LIB_EXT = .lib
OBJ_EXT = .obj
OSNAME = MSWin32
OSVERS = 4.0
RANLIB = rem
SO = dll
EXE_EXT = .exe
FULL_AR = 


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
NAME = WWW::Mechanize::Shell
DISTNAME = WWW-Mechanize-Shell
NAME_SYM = WWW_Mechanize_Shell
VERSION = 0.05
VERSION_SYM = 0_05
XS_VERSION = 0.05
INST_BIN = blib\bin
INST_LIB = blib\lib
INST_ARCHLIB = blib\arch
INST_SCRIPT = blib\script
INSTALLDIRS = site
PREFIX = D:\Programme\indigoperl-5.6
SITEPREFIX = D:\Programme\indigoperl-5.6\site
VENDORPREFIX = 
INSTALLPRIVLIB = D:\Programme\indigoperl-5.6\lib
INSTALLSITELIB = D:\Programme\indigoperl-5.6\site\lib
INSTALLVENDORLIB = 
INSTALLARCHLIB = D:\Programme\indigoperl-5.6\lib
INSTALLSITEARCH = D:\Programme\indigoperl-5.6\site\lib
INSTALLVENDORARCH = 
INSTALLBIN = D:\Programme\indigoperl-5.6\bin
INSTALLSITEBIN = D:\Programme\indigoperl-5.6\bin
INSTALLVENDORBIN = 
INSTALLSCRIPT = D:\Programme\indigoperl-5.6\bin
PERL_LIB = D:\Programme\indigoperl-5.6\lib
PERL_ARCHLIB = D:\Programme\indigoperl-5.6\lib
SITELIBEXP = D:\Programme\indigoperl-5.6\site\lib
SITEARCHEXP = D:\Programme\indigoperl-5.6\site\lib
LIBPERL_A = libperl.lib
FIRST_MAKEFILE = Makefile
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = D:\Programme\indigoperl-5.6\lib\CORE
PERL = D:\Programme\indigoperl-5.6\bin\perl.exe
FULLPERL = D:\Programme\indigoperl-5.6\bin\perl.exe
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERL = $(PERL)
ABSPERLRUN = $(ABSPERL)
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULL_AR = 
PERL_CORE = 0

VERSION_MACRO = VERSION
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"

MAKEMAKER = D:/Programme/indigoperl-5.6/lib/ExtUtils/MakeMaker.pm
MM_VERSION = 6.05

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = WWW\Mechanize\Shell
BASEEXT = Shell
PARENT_NAME = WWW::Mechanize
DLBASE = $(BASEEXT)
VERSION_FROM = lib/WWW/Mechanize/Shell.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic

# Handy lists of source code files:
XS_FILES= 
C_FILES = 
O_FILES = 
H_FILES = 
MAN1PODS = 
MAN3PODS = lib/WWW/Mechanize/Shell.pm
INST_MAN1DIR = blib\man1
MAN1EXT = 1
INSTALLMAN1DIR = D:\Programme\indigoperl-5.6\man\man1
INSTALLSITEMAN1DIR = D:\Programme\indigoperl-5.6\site\man\man1
INST_MAN3DIR = blib\man3
MAN3EXT = 3
INSTALLMAN3DIR = D:\Programme\indigoperl-5.6\man\man3
INSTALLSITEMAN3DIR = D:\Programme\indigoperl-5.6\site\man\man3

# work around a famous dec-osf make(1) feature(?):
makemakerdflt: all

.SUFFIXES: .xs .c .C .cpp .cxx .cc $(OBJ_EXT)

# Nick wanted to get rid of .PRECIOUS. I don't remember why. I seem to 
# recall, that some make implementations will delete the Makefile when we 
# rebuild it. Because we call false(1) when we rebuild it. So make(1) is 
# not completely wrong when it does so. Our milage may vary.
# .PRECIOUS: Makefile    # seems to be not necessary anymore

.PHONY: all config static dynamic test linkext manifest

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)\Config.pm $(PERL_INC)\config.h

# Where to put things:
INST_LIBDIR      = $(INST_LIB)\WWW\Mechanize
INST_ARCHLIBDIR  = $(INST_ARCHLIB)\WWW\Mechanize

INST_AUTODIR     = $(INST_LIB)\auto\$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)\auto\$(FULLEXT)

INST_STATIC  =
INST_DYNAMIC =
INST_BOOT    =

EXPORT_LIST = Shell.def

PERL_ARCHIVE = $(PERL_INC)\perl56.lib

TO_INST_PM = lib/WWW/Mechanize/Shell.pm

PM_TO_BLIB = lib/WWW/Mechanize/Shell.pm \
	blib\lib\WWW/Mechanize/Shell.pm


# --- MakeMaker tool_autosplit section:

# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(PERLRUN) -MAutoSplit  -e "autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1);"


# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:

SHELL = cmd /x /c
CHMOD = $(PERLRUN) -MExtUtils::Command -e chmod
CP = $(PERLRUN) -MExtUtils::Command -e cp
LD = link
MV = $(PERLRUN) -MExtUtils::Command -e mv
NOOP = rem
RM_F = $(PERLRUN) -MExtUtils::Command -e rm_f
RM_RF = $(PERLRUN) -MExtUtils::Command -e rm_rf
TEST_F = $(PERLRUN) -MExtUtils::Command -e test_f
TOUCH = $(PERLRUN) -MExtUtils::Command -e touch
UMASK_NULL = umask 0
DEV_NULL = > NUL

# The following is a portable way to say mkdir -p
# To see which directories are created, change the if 0 to if 1
MKPATH = $(PERLRUN) -MExtUtils::Command -e mkpath

# This helps us to minimize the effect of the .exists files A yet
# better solution would be to have a stable file in the perl
# distribution with a timestamp of zero. But this solution doesn't
# need any changes to the core distribution and works with older perls
EQUALIZE_TIMESTAMP = $(PERLRUN) -MExtUtils::Command -e eqtime

# Here we warn users that an old packlist file was found somewhere,
# and that they should call some uninstall routine
WARN_IF_OLD_PACKLIST = $(PERL) -lwe "exit unless -f $$ARGV[0];" \
-e "print 'WARNING: I have found an old package in';" \
-e "print '	', $$ARGV[0], '.';" \
-e "print 'Please make sure the two installations are not conflicting';"

UNINST=0
VERBINST=1

MOD_INSTALL = $(PERL) -I$(INST_LIB) -I$(PERL_LIB) -MExtUtils::Install \
-e "install({ @ARGV },'$(VERBINST)',0,'$(UNINST)');"

DOC_INSTALL = $(PERL) -e "$$\=\"\n\n\";" \
-e "print '=head2 ', scalar(localtime), ': C<', shift, '>', ' L<', $$arg=shift, '|', $$arg, '>';" \
-e "print '=over 4';" \
-e "while (defined($$key = shift) and defined($$val = shift)) { print '=item *';print 'C<', \"$$key: $$val\", '>'; }" \
-e "print '=back';"

UNINSTALL =   $(PERL) -MExtUtils::Install \
-e "uninstall($$ARGV[0],1,1); print \"\nUninstall is deprecated. Please check the";" \
-e "print \" packlist above carefully.\n  There may be errors. Remove the\";" \
-e "print \" appropriate files manually.\n  Sorry for the inconveniences.\n\""


# --- MakeMaker dist section:
DIST_DEFAULT = tardist
POSTOP = @$(NOOP)
PREOP = @$(NOOP)
SHAR = shar
COMPRESS = gzip --best
CI = ci -u
ZIPFLAGS = -r
DIST_CP = best
DISTVNAME = $(DISTNAME)-$(VERSION)
ZIP = zip
TARFLAGS = cvf
TAR = tar
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
TO_UNIX = @$(NOOP)
SUFFIX = .gz


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:
PASTHRU = -nologo

# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
POD2TEST_EXE = pod2test

all :: pure_all manifypods
	@$(NOOP)

pure_all :: config pm_to_blib subdirs linkext testifypods
	@$(NOOP)

subdirs :: $(MYEXTLIB)
	@$(NOOP)

config :: Makefile $(INST_LIBDIR)\.exists
	@$(NOOP)

config :: $(INST_ARCHAUTODIR)\.exists
	@$(NOOP)

config :: $(INST_AUTODIR)\.exists
	@$(NOOP)

$(INST_AUTODIR)\.exists :: D:\Programme\indigoperl-5.6\lib\CORE\perl.h
	@$(MKPATH) $(INST_AUTODIR)
	@$(EQUALIZE_TIMESTAMP) D:\Programme\indigoperl-5.6\lib\CORE\perl.h $(INST_AUTODIR)\.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_AUTODIR)

$(INST_LIBDIR)\.exists :: D:\Programme\indigoperl-5.6\lib\CORE\perl.h
	@$(MKPATH) $(INST_LIBDIR)
	@$(EQUALIZE_TIMESTAMP) D:\Programme\indigoperl-5.6\lib\CORE\perl.h $(INST_LIBDIR)\.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_LIBDIR)

$(INST_ARCHAUTODIR)\.exists :: D:\Programme\indigoperl-5.6\lib\CORE\perl.h
	@$(MKPATH) $(INST_ARCHAUTODIR)
	@$(EQUALIZE_TIMESTAMP) D:\Programme\indigoperl-5.6\lib\CORE\perl.h $(INST_ARCHAUTODIR)\.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_ARCHAUTODIR)

config :: $(INST_MAN3DIR)\.exists
	@$(NOOP)


$(INST_MAN3DIR)\.exists :: D:\Programme\indigoperl-5.6\lib\CORE\perl.h
	@$(MKPATH) $(INST_MAN3DIR)
	@$(EQUALIZE_TIMESTAMP) D:\Programme\indigoperl-5.6\lib\CORE\perl.h $(INST_MAN3DIR)\.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_MAN3DIR)

help:
	perldoc ExtUtils::MakeMaker


testifypods : 
	@$(POD2TEST_EXE) lib/WWW/Mechanize/Shell.pm t/embedded-WWW-Mechanize-Shell.t


# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	@$(NOOP)


# --- MakeMaker dlsyms section:

Shell.def: Makefile.PL
	$(PERLRUN) -MExtUtils::Mksymlists \
     -e "Mksymlists('NAME'=>\"WWW::Mechanize::Shell\", 'DLBASE' => '$(BASEEXT)', 'DL_FUNCS' => {  }, 'FUNCLIST' => [], 'IMPORTS' => {  }, 'DL_VARS' => []);"


# --- MakeMaker dynamic section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make dynamic"
#dynamic :: Makefile $(INST_DYNAMIC) $(INST_BOOT) $(INST_PM)
dynamic :: Makefile $(INST_DYNAMIC) $(INST_BOOT)
	@$(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
#static :: Makefile $(INST_STATIC) $(INST_PM)
static :: Makefile $(INST_STATIC)
	@$(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

manifypods :
	@$(NOOP)


# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean ::
	-$(PERLRUN) -MExtUtils::Command -e rm_rf ./blib $(MAKE_APERL_FILE) $(INST_ARCHAUTODIR)/extralibs.all perlmain.c tmon.out mon.out so_locations pm_to_blib *$(OBJ_EXT) *$(LIB_EXT) perl.exe perl perl$(EXE_EXT) $(BOOTSTRAP) $(BASEEXT).bso $(BASEEXT).def lib$(BASEEXT).def $(BASEEXT).exp $(BASEEXT).x core core.*perl.*.? *perl.core
	-$(PERLRUN) -MExtUtils::Command -e mv Makefile Makefile.old $(DEV_NULL)
clean ::
	-$(RM_F) *.pdb



# --- MakeMaker realclean section:

# Delete temporary files (via clean) and also delete installed files
realclean purge ::  clean
	$(PERLRUN) -MExtUtils::Command -e rm_rf $(INST_AUTODIR) $(INST_ARCHAUTODIR)
	$(PERLRUN) -MExtUtils::Command -e rm_rf $(DISTVNAME)
	$(PERLRUN) -MExtUtils::Command -e rm_f  blib\lib\WWW/Mechanize/Shell.pm
	$(PERLRUN) -MExtUtils::Command -e rm_rf Makefile Makefile.old


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ *.orig */*~ */*.orig



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT)
	@$(PERL) -le "print \"Warning: Makefile possibly out of date with $$vf\" if " \
	    -e "-e ($$vf=\"$(VERSION_FROM)\") and -M $$vf < -M \"Makefile\";"

tardist : $(DISTVNAME).tar$(SUFFIX)

zipdist : $(DISTVNAME).zip

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) \
		$(DISTVNAME).tar$(SUFFIX) > \
		$(DISTVNAME).tar$(SUFFIX)_uu

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker dist_dir section:
distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"



# --- MakeMaker dist_test section:

disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)


# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) -MExtUtils::Manifest=maniread \
		-e "@all = keys %{ maniread() };" \
		-e "print(\"Executing $(CI) @all\n\"); system(\"$(CI) @all\");" \
		-e "print(\"Executing $(RCS_LABEL) ...\n\"); system(\"$(RCS_LABEL) @all\");"


# --- MakeMaker install section:

install :: all pure_install doc_install

install_perl :: all pure_perl_install doc_perl_install

install_site :: all pure_site_install doc_site_install

install_vendor :: all pure_vendor_install doc_vendor_install

pure_install :: pure_$(INSTALLDIRS)_install

doc_install :: doc_$(INSTALLDIRS)_install

pure__install : pure_site_install
	@echo INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	@echo INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	@$(MOD_INSTALL) \
		read $(PERL_ARCHLIB)\auto\$(FULLEXT)\.packlist \
		write $(INSTALLARCHLIB)\auto\$(FULLEXT)\.packlist \
		$(INST_LIB) $(INSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(INSTALLARCHLIB) \
		$(INST_BIN) $(INSTALLBIN) \
		$(INST_SCRIPT) $(INSTALLSCRIPT) \
		$(INST_MAN1DIR) $(INSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(INSTALLMAN3DIR)
	@$(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)\auto\$(FULLEXT)


pure_site_install ::
	@$(MOD_INSTALL) \
		read $(SITEARCHEXP)\auto\$(FULLEXT)\.packlist \
		write $(INSTALLSITEARCH)\auto\$(FULLEXT)\.packlist \
		$(INST_LIB) $(INSTALLSITELIB) \
		$(INST_ARCHLIB) $(INSTALLSITEARCH) \
		$(INST_BIN) $(INSTALLSITEBIN) \
		$(INST_SCRIPT) $(INSTALLSCRIPT) \
		$(INST_MAN1DIR) $(INSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(INSTALLSITEMAN3DIR)
	@$(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)\auto\$(FULLEXT)

pure_vendor_install ::
	@$(MOD_INSTALL) \
		read $(VENDORARCHEXP)\auto\$(FULLEXT)\.packlist \
		write $(INSTALLVENDORARCH)\auto\$(FULLEXT)\.packlist \
		$(INST_LIB) $(INSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(INSTALLVENDORARCH) \
		$(INST_BIN) $(INSTALLVENDORBIN) \
		$(INST_SCRIPT) $(INSTALLSCRIPT) \
		$(INST_MAN1DIR) $(INSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(INSTALLVENDORMAN3DIR)

doc_perl_install ::
	@echo Appending installation info to $(INSTALLARCHLIB)/perllocal.pod
	-@$(MKPATH) $(INSTALLARCHLIB)
	-@$(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(INSTALLARCHLIB)\perllocal.pod

doc_site_install ::
	@echo Appending installation info to $(INSTALLSITEARCH)/perllocal.pod
	-@$(MKPATH) $(INSTALLSITEARCH)
	-@$(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(INSTALLSITEARCH)\perllocal.pod

doc_vendor_install ::
	@echo Appending installation info to $(INSTALLVENDORLIB)/perllocal.pod
	-@$(MKPATH) $(INSTALLVENDORLIB)
	-@$(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(INSTALLVENDORARCH)\perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs

uninstall_from_perldirs ::
	@$(UNINSTALL) $(PERL_ARCHLIB)\auto\$(FULLEXT)\.packlist

uninstall_from_sitedirs ::
	@$(UNINSTALL) $(SITEARCHEXP)\auto\$(FULLEXT)\.packlist

uninstall_from_vendordirs ::
	@$(UNINSTALL) $(VENDORARCHEXP)\auto\$(FULLEXT)\.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	@$(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:

# We take a very conservative approach here, but it\'s worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
Makefile : Makefile.PL $(CONFIGDEP)
	@echo "Makefile out-of-date with respect to $?"
	@echo "Cleaning current config before rebuilding Makefile..."
	-@$(RM_F) Makefile.old
	-@$(MV) Makefile Makefile.old
	-$(MAKE) -f Makefile.old clean $(DEV_NULL) || $(NOOP)
	$(PERLRUN) Makefile.PL 
	@echo "==> Your Makefile has been rebuilt. <=="
	@echo "==> Please rerun the make command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = D:\Programme\indigoperl-5.6\bin\perl.exe

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) -f $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE)
	@echo Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	@$(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t\00-use.t t\01-fallback-Win32-OLE.t t\02-fallback-Pod-Constant.t t\03-documentation.t t\99-pod.t t\embedded-WWW-Mechanize-Shell.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: pure_all
	$(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	$(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	@$(PERL) -e "print qq{<SOFTPKG NAME=\"$(DISTNAME)\" VERSION=\"0,05,0,0\">\n\t<TITLE>$(DISTNAME)</TITLE>\n\t<ABSTRACT>A crude shell for WWW::Mechanize</ABSTRACT>\n\t<AUTHOR>Max Maischein &lt;corion\@cpan.org&gt;</AUTHOR>\n}" > $(DISTNAME).ppd
	@$(PERL) -e "print qq{\t<IMPLEMENTATION>\n\t\t<DEPENDENCY NAME=\"Term-Shell\" VERSION=\"0,01,0,0\" />\n\t\t<DEPENDENCY NAME=\"WWW-Mechanize\" VERSION=\"0,35,0,0\" />\n\t\t<DEPENDENCY NAME=\"WWW-Mechanize-FormFiller\" VERSION=\"0,02,0,0\" />\n}" >> $(DISTNAME).ppd
	@$(PERL) -e "print qq{\t\t<OS NAME=\"$(OSNAME)\" />\n\t\t<ARCHITECTURE NAME=\"MSWin32-x86-multi-thread\" />\n\t\t<CODEBASE HREF=\"\" />\n\t</IMPLEMENTATION>\n</SOFTPKG>\n}" >> $(DISTNAME).ppd

# --- MakeMaker pm_to_blib section:

pm_to_blib: $(TO_INST_PM)
	@$(PERLRUNINST) -MExtUtils::Install \
        -e "pm_to_blib(qw[ <<pmfiles.dat ],'$(INST_LIB)\auto','$(PM_FILTER)')"

$(PM_TO_BLIB)
<<
		@$(TOUCH) $@


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
