package WWW::Mechanize::Shell;

use strict;
use Carp;
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use HTTP::Cookies;
use base qw( Term::Shell Exporter );
use FindBin;
use URI::URL;

use vars qw( $VERSION @EXPORT );
$VERSION = '0.21';
@EXPORT = qw( &shell );

=head1 NAME

WWW::Mechanize::Shell - An interactive shell for WWW::Mechanize

=head1 SYNOPSIS

From the command line as

  perl -MWWW::Mechanize::Shell -eshell

or alternatively as a custom shell program via :

=for example begin

  #!/usr/bin/perl -w
  use strict;
  use WWW::Mechanize::Shell;

  my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef );

  if (@ARGV) {
    $shell->source_file( @ARGV );
  } else {
    $shell->cmdloop;
  };

=for example end

=for example_testing
  BEGIN {
    require WWW::Mechanize::Shell;
    $ENV{PERL_RL} = 0;
    #$ENV{PERL_RL_USE_TRK} = 0;
    $ENV{COLUMNS} = '80';
    $ENV{LINES} = '24';
  };
  BEGIN {
    no warnings 'once';
    no warnings 'redefine';
    require Term::ReadKey;
    *WWW::Mechanize::Shell::cmdloop = sub {};
    *Term::ReadKey::GetTerminalSize = sub {80,24};
    *WWW::Mechanize::Shell::display_user_warning = sub {};
  };
  isa_ok( $shell, "WWW::Mechanize::Shell" );

=head1 DESCRIPTION

This module implements a www-like shell above WWW::Mechanize
and also has the capability to output crude Perl code that recreates
the recorded session. Its main use is as an interactive starting point
for automating a session through WWW::Mechanize.

It has "live" display support for Microsoft Internet Explorer on Win32
and thanks to Slaven Rezic for other systems as well. Non-IE browsers
will use tempfiles while IE will be controled via OLE.

The cookie support is there, but no cookies are read from your existing
browser sessions. See L<HTTP::Cookies> on how to implement reading/writing
your current browsers cookies.

=cut

# Blindly allow redirects
{
  no warnings 'redefine';
  *WWW::Mechanize::redirect_ok = sub { $_[0]->{__www_mechanize_shell}->status( "\nRedirecting to ".$_[1]->uri ); $_[0]->{uri} = $_[1]->uri; 1 };
}

eval { require Win32::OLE; Win32::OLE->import() };
my $have_ole = $@ eq '';

=head2 C<WWW::Mechanize::Shell-E<gt>new %ARGS>

This is the constructor for a new shell instance. Some of the options
can be passed to the constructor as parameters.

By default, a file C<.mechanizerc> (respectively C<mechanizerc> under Windows)
in the users home directory is executed before the interactive shell loop is
entered. This can be used to set some defaults. If you want to supply a different
filename for the rcfile, the C<rcfile> parameter can be passed to the constructor :

  rcfile => '.myapprc',

=cut

sub init {
  my ($self) = @_;
  my ($name,%args) = @{$self->{API}{args}};

  $self->{agent} = WWW::Mechanize->new();
  $self->agent->{__www_mechanize_shell} = $self;

  $self->{browser} = undef;
  $self->{formfiller} = WWW::Mechanize::FormFiller->new(default => [ Ask => $self ]);

  $self->{history} = [];

  $self->{options} = {
    autosync => 0,
    warnings => (exists $args{warnings} ? $args{warnings} : 1),
    autorestart => 0,
    watchfiles => (exists $args{watchfiles} ? $args{watchfiles} : 1),
    cookiefile => 'cookies.txt',
    dumprequests => 0,
    useole => ($^O =~ /mswin/i) ? 1:0,
    browsercmd => 'galeon -n %s',
  };
  # Load the proxy settings from the environment
  $self->agent->env_proxy();

  # Read our .rc file :
  # I could use File::Homedir, but the docs claim it dosen't work on Win32. Maybe
  # I should just release a patch for File::Homedir then... Not now.
  my $sourcefile;
  if (exists $args{rcfile}) {
    $sourcefile = delete $args{rcfile};
  } else {
    my $userhome = $^O =~ /win32/i ? $ENV{'USERPROFILE'} || $ENV{'HOME'} : ((getpwuid($<))[7]);
    $sourcefile = "$userhome/.mechanizerc"
      if -f "$userhome/.mechanizerc";
  };
  $self->source_file($sourcefile) if $sourcefile;
  $self->option('cookiefile', $args{cookiefile}) if (exists $args{cookiefile});

  # Keep track of the files we consist of, to enable automatic reloading
  $self->{files} = undef;
  if ($self->option('watchfiles')) {
    eval {
      my @files = values %INC;
      push @files, $0
        unless $0 eq '-e';
      require File::Modified;
      $self->{files} = File::Modified->new(files=>[@files]);
    };
    $self->display_user_warning( "Module File::Modified not found. Automatic reloading disabled.\n" )
      if ($@);
  };
};

=head2 C<$shell-E<gt>release_agent>

Since the shell stores a reference back to itself within the
WWW::Mechanize instance, it is necessary to break this
circular reference. This method does this.

=cut

sub release_agent {
  my ($self) = @_;
  $self->{agent} = undef;
};

=head2 C<$shell-E<gt>source_file FILENAME>

The C<source_file> method executes the lines of FILENAME
as if they were typed in.

  $shell->source_file( $filename );

=cut

sub source_file {
  my ($self,$filename) = @_;
  local $_; # just to be on the safe side that we don't clobber outside users of $_
  local *F;
  open F, "< $filename" or die "Couldn't open '$filename' : $!\n";
  while (<F>) {
    $self->cmd($_);
  };
  close F;
};

sub add_history {
  my ($self,@code) = @_;
  push @{$self->{history}},[$self->line,join "",@code];
};

=head2 C<$shell-E<gt>display_user_warning>

All user warnings are routed through this routine
so they can be rerouted / disabled easily.

=cut

sub display_user_warning {
  my ($self,@message) = @_;

  warn @message
    if $self->option('warnings');
};

sub agent { $_[0]->{agent}; };

sub option {
  my ($self,$option,$value) = @_;
  if (exists $self->{options}->{$option}) {
    my $result = $self->{options}->{$option};
    if (scalar @_ == 3) {
      $self->{options}->{$option} = $value;
    };
    $result;
  } else {
    Carp::carp "Unknown option '$option'";
    undef;
  };
};

sub restart_shell {
  print "Restarting $0\n";

  exec $^X, $0, @ARGV;
};

sub precmd {
  my $self = shift @_;
  # We want to restart when any module was changed
  if ($self->{files} and $self->{files}->changed()) {
    print "One or more of the base files were changed\n";
    $self->restart_shell if ($self->option('autorestart'));
  };

  $self->SUPER::precmd(@_);
};

sub browser {
  my ($self) = @_;
  return unless $have_ole and $self->option('useole');
  my $browser = $self->{browser};
  unless ($browser) {
    $browser = Win32::OLE->CreateObject("InternetExplorer.Application");
    $browser->{'Visible'} = 1;
    $self->{browser} = $browser;
    $browser->Navigate('about:blank');
  };
  $browser;
};

sub sync_browser {
  my ($self) = @_;

  # We only can display html if we have any :
  return unless $self->agent->res;

  # Prepare the HTML for local display :
  my $html = $self->agent->res->content;
  my $location = $self->agent->{uri};
  $html =~ s!(</head>)!<base href="$location" />$1!i
    unless ($html =~ /<BASE/i);

  my $browser;
  $browser = $self->browser;
  if ($browser) {
    # We can push the HTML into a IE browser window
    my $document = $browser->{Document};
    $document->open("text/html","replace");
    $document->write($html);
  } else {
    # We need to use a temp file for communication
    require File::Temp;
    my($tempfh, $tempfile) = File::Temp::tempfile(undef, UNLINK => 1);
    print $tempfh $html;
    my $cmdline = sprintf($self->option('browsercmd'), $tempfile);
    system( $cmdline ) == 0
      or warn "Couldn't launch '$cmdline' : $?";
  };
};

sub prompt_str { ($_[0]->agent->uri || "") . ">" };

=head2 C<$shell-E<gt>history>

Returns the (relevant) shell history, that is, all commands
that were not solely for the information of the user. The
lines are returned as a list.

  print join "\n", $shell->history;

=cut

sub history {
  my ($self) = @_;
  map { $_->[0] } @{$self->{history}}
};

=head2 C<$shell-E<gt>script>

Returns the shell history as a Perl program. The
lines are returned as a list. The lines do not have
a one-by-one correspondence to the lines in the history.

  print join "\n", $shell->script;

=cut

sub script {
  my ($self,$prefix) = @_;
  $prefix ||= "";

  my @result = sprintf <<'HEADER', $^X;
#!%s -w
use strict;
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use URI::URL;

{ no warnings 'redefine';
  *WWW::Mechanize::redirect_ok = sub { $_[0]->{uri} = $_[1]->uri; 1 };
};

my $agent = WWW::Mechanize->new();
my $formfiller = WWW::Mechanize::FormFiller->new();
$agent->env_proxy();
HEADER

  push @result, map { $prefix.$_->[1] } @{$self->{history}};
  @result;
};

=head2 C<$shell-E<gt>status>

C<status> is called for status updates.

=cut

sub status {
  my $self = shift;
  print join "", @_;
};

=head2 C<$shell-E<gt>display FILENAME LINES>

C<display> is called to output listings, currently from the
C<history> and C<script> commands. If the second parameter
is defined, it is the name of the file to be written,
otherwise the lines are displayed to the user.

=cut

sub display {
  my ($self,$filename,@lines) = @_;
  if (defined $filename) {
    eval {
      open my $f, ">", $filename
        or die "Couldn't create $filename : $!";
      print $f join( "", map { "$_\n" } (@lines) );
      close $f;
    };
    warn $@ if $@;
  } else {
    print join( "", map { "$_\n" } (@lines) );
  };
};

# sub-classed from Term::Shell to handle all run_ requests that have no corresponding sub
# This is used for comments
sub catch_run {
  my ($self) = shift;
  my ($command) = @_;
  if ($command =~ /^\s*#/) {
    # Hey, it's a comment.
  } else {
    print $self->msg_unknown_cmd($command);
  };
};

# sub-classed from Term::Shell to handle all smry requests
sub catch_smry {
  my ($self,$command) = @_;

  my $result = eval {
    require Pod::Constants;

    my @summary;
    my $module = (ref $self ).".pm";
    $module =~ s!::!/!g;
    $module = $INC{$module};

    Pod::Constants::import_from_file( $module, $command => \@summary );

    $summary[0];
  };
  if ($@) {
    return undef;
  };
  return $result;
};

# sub-classed from Term::Shell to handle all help requests
sub catch_help {
  my ($self,$command) = @_;

  my @result = eval {
    require Pod::Constants;

    my @summary;
    my $module = (ref $self ).".pm";
    $module =~ s!::!/!g;
    $module = $INC{$module};

    Pod::Constants::import_from_file( $module, $command => \@summary );

    @summary;
  };
  if ($@) {
    my $module = ref $self;
    $self->display_user_warning( "Pod::Constants not available. Use perldoc $module for help.\n" );
    return undef;
  };
  return join( "\n", @result) . "\n";
};

=head1 COMMANDS

The shell implements various commands :

=head2 exit

Leaves the shell.

=cut

sub alias_exit { qw(quit) };

=head2 restart

Restart the shell.

This is mostly useful when you are modifying the shell itself.

=cut

sub run_restart {
  my ($self) = @_;
  $self->restart_shell;
};

sub activate_first_form { $_[0]->agent->form(1) if $_[0]->agent->forms and scalar @{$_[0]->agent->forms}; };

=head2 get

Download a specific URL.

This is used as the entry point in all sessions

Syntax:

  get URL

=cut

sub run_get {
  my ($self,$url) = @_;
  $self->status( "Retrieving $url" );
  my $code;
  eval { $code = $self->agent->get($url)->code };
  if ($@) {
    print "\n$@\n" if $@;
    $self->agent->back;
  } else {
    $self->status( "($code)\n" );
  };

  $self->activate_first_form;
  $self->sync_browser if $self->option('autosync');
  $self->add_history( sprintf q{$agent->get('%s');}."\n".q{  $agent->form(1) if $agent->forms and scalar @{$agent->forms};}, $url);
};

=head2 save

Download a link into a file.

If more than one link matches the RE, all matching links are
saved. The filename is taken from the last part of the
URL. Alternatively, the number of a link may also be given.

Syntax:

  save RE

=cut

sub run_save {
  my ($self,$user_link) = @_;

  unless (defined $user_link) {
    print "No link given to save\n";
    return
  };
  my @history;

  my @links = ();
  my @all_links = $self->agent->links;
  push @history, q{my @links;} . "\n";
  push @history, q{my @all_links = $agent->links();} . "\n";

  if ($user_link =~ m!^/(.*)/$!) {
    my $re = qr($1);
    my $count = -1;
    @links = map { $count++; (($_->[0] =~ /$re/)||($_->[1] =~ /$re/)) ? $count : () } @all_links;
    if (@links == 0) {
      print "No match for /$re/.\n";
    };
    push @history, q{my $count = -1;} . "\n";
    push @history, sprintf q{@links = map { $count++; (($_->[0] =~ /%s/)||($_->[1] =~ /%s/)) ? $count : () } @all_links;} . "\n", $re, $re;
  } else {
    @links = $user_link;
    push @history, sprintf q{@links = '%s';} . "\n", $user_link;
  };

  if (@links) {
    $self->add_history( @history,<<'CODE' );
  my $base = $agent->uri;
  for my $link (@links) {
    my $target = $all_links[$link]->[0];
    my $url = URI::URL->new($target,$base);
    $target = $url->path;
    $target =~ s!^(.*/)?([^/]+)$!$2!;
    $url = $url->abs;
    # use this instead in case you want to use smart mirroring
    #$agent->mirror($url,$target);
    $agent->follow($link);
    local *FILE;
    if (open FILE, "> $target") {
      binmode FILE;
      print FILE $agent->content;
      close FILE;
    } else {
      warn "Couldn't create $target : $!\n";
    };
    $agent->back;
  };
CODE
    my $base = $self->agent->uri;
    for my $link (@links) {
      my $target = $all_links[$link]->[0];
      my $url = URI::URL->new($target,$base);
      $target = $url->path;
      $target =~ s!^(.*/)?([^/]+)$!$2!;
      $url = $url->abs;
      eval {
        $self->status( "$url => $target" );
		    $self->agent->follow($link);
        #$self->agent->get($url);
        local *FILE;
        if (open FILE, "> $target") {
          binmode FILE;
          print FILE $self->agent->content;
          close FILE;
          $self->status( "\n" );
        } else {
          $self->status( ": $!\n" );
        };
        $self->agent->back;
      };
      warn $@ if $@;
    };
  }
};

=head2 content

Display the HTML for the current page

=cut

sub run_content {
  my ($self,$url) = @_;
  print $self->agent->content,"\n";
  $self->add_history('print $agent->content,"\n";');
};

=head2 ua

Get/set the current user agent

Syntax:

  # fake Internet Explorer
  ua "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)"

  # fake QuickTime v5
  ua "QuickTime (qtver=5.0.2;os=Windows NT 5.0Service Pack 2)"

  # fake Mozilla/Gecko based
  ua "Mozilla/5.001 (windows; U; NT4.0; en-us) Gecko/25250101"

  # set empty user agent :
  ua ""

=cut

sub run_ua {
  my ($self,$ua) = @_;
  my ($result) = $self->agent->agent;
  if (scalar @_ == 2) {
    $self->agent->agent($ua);
    $self->add_history( sprintf q{$agent->agent('%s');}, $ua);
  } else {
    print "Current user agent: $result\n";
  };
};

=head2 links

Display all links on a page

=cut

sub run_links {
  my ($self) = @_;
  my $links = $self->agent->links;
  my $count = 0;
  for my $link (@$links) {
    print "[", $count++, "] ", $link->[1],"\n";
  };
};

=head2 parse

Dump the output of HTML::TokeParser of the current content

=cut

sub run_parse {
  my ($self) = @_;
  my $content = $self->agent->content;
  my $p = HTML::TokeParser->new(\$content);

  while (my $token = $p->get_token()) {
  #while (my $token = $p->get_tag("frame")) {
  #  print "<",$token->[0],":",ref $token->[1] ? $token->[1]->{src} : "",">";
    print "<",$token->[0],":",$token->[1],">";
  }
};

=head2 forms

Display all forms on the current page

=cut

sub run_forms {
  my ($self,$number) = @_;
  if ($number) {
    $self->agent->form($number);
    $self->status($self->agent->current_form->dump);
    $self->add_history(sprintf q{$agent->form(%s);}, $number);
  } else {
    my $count = 1;
    my $formref = $self->agent->forms;
    if ($formref) {
      my @forms = @$formref;
      for my $form (@forms) {
        print "Form [",$count++,"]\n";
        $form->dump;
      };
    };
  };
};

=head2 dump

Dump the values of the current form

=cut

sub run_dump {
  my ($self) = @_;
  my $form = $self->agent->current_form;
  if ($form) {
    $form->dump
  } else {
    warn "There is no form on the current page\n"
      if $self->option('warnings');
  };
};

=head2 value

Set a form value

Syntax:

  value NAME [VALUE]

=cut

sub run_value {
  my ($self,$key,$value) = @_;

  eval {
    local $^W;
    $self->agent->current_form->value($key,$value);
    # Hmm - neither $key nor $value may contain backslashes nor single quotes ...
    $self->add_history( sprintf q{{ local $^W; $agent->current_form->value('%s', '%s'); };}, $key, $value);
  };
  warn $@ if $@;
};

=head2 submit

Clicks on the button labeled "submit"

=cut

sub run_submit {
  my ($self) = @_;
  eval {
    $self->status( $self->agent->submit->code."\n" );
    $self->add_history('$agent->submit();');
  };
  warn $@ if $@;
};

=head2 click

Clicks on the button named NAME.

No regular expression expansion is done on NAME.

Syntax:

  click NAME

=cut

sub run_click {
  my ($self,$button) = @_;
  $button ||= "";
  print $self->agent->current_form->click($button, 1, 1)
    if ($self->option("dumprequests"));
  eval {
    my $res = $self->agent->click($button);
    $self->activate_first_form;
    $self->status( "(".$res->code.")\n");
    if ($self->option('autosync')) {
      $self->sync_browser;
    };
    $self->add_history( sprintf qq{\$agent->click('%s');}, $button );
  };
  warn $@ if $@;
};

=head2 open

Open a link on the current page

It opens the link whose text is matched by RE,
and displays all links if more than one matches.

Syntax:

  open RE

=cut

sub run_open {
  my ($self,$user_link) = @_;
  my $link = $user_link;
  my $user_link_expr = qq{'$user_link'};
  unless (defined $link) {
    print "No link given\n";
    return
  };
  if ($link =~ m!^/(.*)/$!) {
    my $re = $1;
    my $count = -1;
    my @possible_links = @{$self->agent->links()};
    my @links = map { $count++; $_->[1] =~ /$re/ ? $count : () } @possible_links;
    if (@links > 1) {
      $self->print_pairs([ @links ],[ map {$possible_links[$_]->[1]} @links ]);
      undef $link;
    } elsif (@links == 0) {
      print "No match.\n";
      undef $link;
    } else {
      $self->status( "Found $links[0]\n" );
      $link = $links[0];
      if ($possible_links[$count]->[0] =~ /^javascript:(.*)/i) {
        print "Can't follow javascript link $1\n";
        undef $link;
      };
      # Quote all unescaped slashes
      $re =~ s!([^\\])/([^\\]|$)!$1\\/$2!g;
      $user_link_expr = sprintf 'qr/%s/', $re;
    };
  };

  if (defined $link) {
    eval {
      $self->agent->follow($link);
      $self->add_history( sprintf qq{\$agent->follow(%s);}, $user_link_expr);
      $self->activate_first_form;
      if ($self->option('autosync')) {
        $self->sync_browser;
      } else {
        $self->status( "(".$self->agent->res->code.")\n" );
      };
    };
    warn $@ if $@;
  };
};

# Complete partially typed links :
sub comp_open {
  my ($self,$word,$line,$start) = @_;
  return grep {/^$word/} map {$_->[1]} (@{$self->agent->extract_links()});
};

=head2 back

Go back one page in the browser page history.

=cut

sub run_back {
  my ($self) = @_;
  eval {
    $self->agent->back();
    $self->add_history('$agent->back();');
    $self->sync_browser
      if ($self->option('autosync'));
  };
  warn $@ if $@;
};

=head2 browse

Open the web browser with the current page

Displays the current page in the browser.

=cut

sub run_browse {
  my ($self) = @_;
  $self->sync_browser;
};

=head2 set

Set a shell option

Syntax:

   set OPTION [value]

The command lists all valid options. Here is a short overview over
the different options available :

    autosync     - automatically synchronize the browser window
    autorestart  - restart the shell when any base file changes
    watchfiles   - watch all base files for changes
    cookiefile   - the file where to store all cookies
    dumprequests - dump all requests to STDOUT
    useole       - use MS IE OLE to display HTML
    browsercmd   - the shell command to display a HTML page. If you have
                   MS Internet Explorer, you won't need this
                   The first %s in this string will be replaced by
                   the current url.

=cut

sub run_set {
  my ($self,$option,$value) = @_;
  $option ||= "";
  if ($option && exists $self->{options}->{$option}) {
    if ($option and defined $value) {
      $self->option($option,$value);
    } else {
      $self->print_pairs( [$option], [$self->option($option)] );
    };
  } else {
    print "Unknown option '$option'\n" if $option;
    print "Valid options are :\n";
    $self->print_pairs( [keys %{$self->{options}}], [ map {$self->option($_)} (keys %{$self->{options}}) ] );
  };
};

=head2 history

Display your current session history as the relevant commands.

Syntax:

  history [FILENAME]

Commands that have no influence on the browser state are not added
to the history. If a parameter is given to the C<history> command,
the history is saved to that file instead of displayed onscreen.

=cut

sub run_history {
  my ($self,$filename) = @_;
  $self->display($filename,$self->history);
};

=head2 script

Display your current session history as a Perl script using WWW::Mechanize.

Syntax:

  script [FILENAME]

If a parameter is given to the C<script> command, the script is saved to
that file instead of displayed on the console.

This command was formerly known as C<history>.

=cut

sub run_script {
  my ($self,$filename) = @_;
  $self->display($filename,$self->script("  "));
};

=head2 fillout

Fill out the current form

Interactively asks the values hat have no preset
value via the autofill command.

=cut

sub run_fillout {
  my ($self) = @_;
  my @interactive_values;
  eval {
    $self->{answers} = [];
    $self->{formfiller}->fill_form($self->agent->current_form);
    @interactive_values = @{$self->{answers}};
  };
  warn $@ if $@;
  $self->add_history( join( "\n", 
                      map { sprintf( q[$formfiller->add_filler( '%s' => Fixed => '%s' );], @$_ ) } @interactive_values) . '$formfiller->fill_form($agent->current_form);');
};

=head2 auth

Set basic authentication credentials.

Syntax:

  auth [authority realm] user password

If you get back a 401, you can simply supply the matching
user and password, as the authority and realm are already
known :

	>get http://www.example.com
	Retrieving http://www.example.com(401)
	http://www.example.com>auth corion secret
	http://www.example.com>get http://www.example.com
	Retrieving http://www.example.com(200)
	http://www.example.com>

If you know the authority and the realm in advance, you can
presupply the credentials, for example at the start of the script :

	>auth www.example.com:80 secure_realm corion secret
	>get http://www.example.com
	Retrieving http://www.example.com(200)
	http://www.example.com>

=cut

sub run_auth {
    my ($self) = shift;
    my ($authority, $realm, $user, $password);
    if (scalar @_ == 2) {
      unless ($self->agent->res) {
        print "Can't guess authentification elements without a request.";
        print "Use the four parameter version instead.";
        return;
      };

      ($user,$password) = @_;
      if ($self->agent->res->www_authenticate =~ /\brealm=(['"]?)(.*)\1/) {
        $realm = $2
      } else {
        $self->warn_user();
        $realm = "";
      };
      $authority = $self->agent->req->uri->authority();

      $self->add_history(          q{($agent->res->www_authenticate =~ /\brealm=(['"]?)(.*)\1/) or die "Couldn't find realm";},
        						   q{my $realm = $2;},
                                   q{my $authority = $agent->req->uri->authority();},
                          sprintf( q{$agent->credentials($authority,$realm,'%s','%s');}, $user,$password ));
    } else {
      ($authority, $realm, $user, $password) = @_;
      $self->add_history( sprintf q{$self->agent->credentials('%s','%s','%s','%s')}, $authority,$realm,$user,$password);
    };
    $self->agent->credentials($authority,$realm,$user,$password);
};

=head2 table

Display a table described by the columns COLUMNS.

Syntax:

  table COLUMNS

Example:

  table Product Price Description

If there is a table on the current page that has in its first row the three
columns C<Product>, C<Price> and C<Description> (not necessarily in that order),
the script will display these columns of the whole table.

The C<HTML::TableExtract> module is needed for this feature.

=cut

sub run_table {
  my ($self,@columns) = @_;

  eval {
    require HTML::TableExtract;

    my $table = HTML::TableExtract->new( headers => [ @columns ] );
    (my $content = $self->agent->content) =~ s/\&nbsp;?//g;
    $table->parse($content);
    print join(", ", @columns),"\n";
    for my $ts ($table->table_states) {
      for my $row ($ts->rows) {
        print join(", ", @$row), "\n";
      };
    };

    $self->add_history( sprintf( 'my @columns = ( %s );'."\n", join( ",", map( { s/(['\\])/\\$1/g; qq('$_') } @columns ))),
                        <<'PRINTTABLE' );
require HTML::TableExtract;
my $table = HTML::TableExtract->new( headers => [ @columns ]);
(my $content = $agent->content) =~ s/\&nbsp;?//g;
$table->parse($content);
print join(", ", @columns),"\n";
for my $ts ($table->table_states) {
  for my $row ($ts->rows) {
    print join(", ", @$row), "\n";
  };
};
PRINTTABLE
  };
  $self->display_user_warning( "Couldn't load HTML::TableExtract: $@" )
    if ($@);
};

=head2 tables

Display a list of tables.

Syntax:

  tables

This command will display the top row for every
table on the current page. This is convenient if you want
to find out what the exact spellings for each column are.

The command does not always work nice, for example if a
site uses tables for layout, it will be harder to guess
what tables are irrelevant and what tables are relevant.

L<HTML::TableExtract> is needed for this feature.

=cut

sub run_tables {
  my ($self,@columns) = @_;

  eval {
    require HTML::TableExtract;

    my $table = HTML::TableExtract->new( subtables => 1 );
    (my $content = $self->agent->content) =~ s/\&nbsp;?//g;
    $table->parse($content);
    for my $ts ($table->table_states) {
      my ($row) = $ts->rows;
      if (grep { /\S/ } (@$row)) {
        print "Table ", join( ",",$ts->coords ), " : ", join(",", @$row),"\n";
      };
    };
  };
  $self->display_user_warning( $@ )
    if $@;
};

=head2 cookies

Set the cookie file name

Syntax:

  cookies FILENAME

=cut

sub run_cookies {
  my ($self,$filename) = @_;
  $self->agent->cookie_jar(HTTP::Cookies->new(
    file => $filename,
    autosave => 1,
    ignore_discard => 1,
  ));
};

sub run_ {
  # ignore empty lines
};

=head2 autofill

Define an automatic value

Sets a form value to be filled automatically. The NAME parameter is
the WWW::Mechanize::FormFiller::Value subclass you want to use. For
session fields, C<Keep> is a good candidate, for interactive stuff,
C<Ask> is a value implemented by the shell.

Syntax:

  autofill NAME [PARAMETERS]

Examples:

  autofill login Fixed corion
  autofill password Ask
  autofill selection Random red green orange
  autofill session Keep

=cut

sub run_autofill {
  my ($self,$name,$class,@args) = @_;
  @args = ($self)
    if ($class eq 'Ask');
  if ($class) {
    eval {
      $self->{formfiller}->add_filler($name,$class,@args);
      $self->add_history( sprintf qq{\$formfiller->add_filler( "%s" => "%s" => %s ); }, $name, $class, join( ",", map {qq{'$_'}} @args));
    };
    warn $@
      if $@;
  } else {
    warn "No class for the autofiller given\n";
  };
};

=head2 eval

Evaluate Perl code and print the result

Syntax:

  eval CODE

For the generated scripts, anything matching the regular expression
C</\$self-E<gt>agent\b/> is automatically
replaced by C<$agent> in your eval code, to do the Right Thing.

Examples:

  # Say hello
  eval "Hello World"

  # And take a look at the current content type
  eval $self->agent->ct

=cut

sub run_eval {
  my ($self) = @_;
  my $code = $self->line;
  $code =~ /^eval\s+(.*)$/ and do {
    my $code = $1;
    my $script_code = $code;
    $script_code =~ s/\$self->agent\b/\$agent/g;
    $script_code =~ s/\$shell->agent\b/\$agent/g;
    $self->add_history( sprintf q{ print( do { %s },"\n" );}, $script_code);
    print eval $code,"\n";
  };
};

=head2 source

Execute a batch of commands from a file

Syntax:

  source FILENAME

=cut

sub run_source {
  my ($self,$file) = @_;
  if ($file) {
    eval { $self->source_file($file); };
    if ($@) {
      print "Could not source file '$file' : $@";
    };
  } else {
    print "Syntax: source FILENAME\n";
  };
};

=head2 versions

Print the version numbers of important modules

Syntax:

  versions

=cut

sub run_versions {
  my ($self) = @_;
  no strict 'refs';
  my @modules = qw( WWW::Mechanize::Shell WWW::Mechanize::FormFiller WWW::Mechanize
  							    Term::Shell
                    HTML::Parser HTML::TableExtract HTML::Parser
                    Pod::Constants
                    File::Modified );
  eval "use $_" foreach @modules;
  $self->print_pairs( [@modules], [map { defined ${"${_}::VERSION"} ? ${"${_}::VERSION"} : "<undef>" } @modules]);
};

sub shell {
  my $shell = WWW::Mechanize::Shell->new("shell");

  if (@ARGV) {
    $shell->source_file( @ARGV );
  } else {
    $shell->cmdloop;
  };
};

{
  package WWW::Mechanize::FormFiller::Value::Ask;
  use WWW::Mechanize::FormFiller;
  use base 'WWW::Mechanize::FormFiller::Value::Callback';

  use vars qw( $VERSION );
  $VERSION = '0.21';

  sub new {
    my ($class,$name,$shell) = @_;
    # Using the name here to allow for late binding and overriding via eval()
    # from the shell command line
    my $self = $class->SUPER::new($name, __PACKAGE__ . '::ask_value');
    $self->{shell} = $shell;
    Carp::carp "WWW::Mechanize::FormFiller::Value::Ask->new called without a value for the shell" unless $self->{shell};

    $self;
  };

  sub ask_value {
    my ($self,$input) = @_;
    my @values;
    if ($input->possible_values) {
      @values = $input->possible_values;
      print join( "|", @values ), "\n";
    };
    my $value;
    $value = $input->value;
    if ($value eq "") {
      $value = $self->{shell}->prompt("(" . $input->type . ")" . $input->name . "> [" . ($input->value || "") . "] ",
                            ($input->value||''), @values );
    };
    undef $value if ($value eq "" and $input->type eq "checkbox");
    push @{$self->{shell}->{answers}}, [ $input->name, $value ];
    $value;
  };
};

1;

__END__

=head1 SAMPLE SESSIONS

=head2 Entering values

  # Search for a term on Google
  get http://www.google.com
  value q "Corions Homepage"
  click btnG
  script
  # (yes, this is a bad example of automating, as Google
  #  already has a Perl API. But other sites don't)

=head2 Retrieving a table

  get http://www.perlmonks.org
  open "/Saints in/"
  table User Experience Level
  script
  # now you have a program that gives you a csv file of
  # that table.

=head2 Uploading a file

  get http://aliens:xxxxx/
  value f path/to/file
  click "upload"

=head2 Batch download

  # download prerelease versions of my modules
  get http://www.corion.net/perl-dev
  save /.tar.gz$/

=head1 DISPLAYING HTML

WWW::Mechanize::Shell can display the HTML of the current page
in your browser. Under Windows, this is done via an OLE call
to Microsoft Internet Explorer. If you don't like MSIE or are
working under Unix where IE is not an option, you can try one
of the following lines in your .mechanizerc :

  # for galeon
  set browsercmd "galeon -n %s"

  # for opera (thanks to Tina Mueller)
  set browsercmd "opera -newwindow %s"

  # for Win32, using Phoenix instead of IE
  set useole 0
  set browsercmd "phoenix.exe %s"

  # for the Mac (thanks to merlyn)
  set browsercmd "open -a Camino.app %s"
  # or
  set browsercmd "open -a Safari.app %s"

  # More lines for other browsers are welcome

The communication is done either via OLE or through tempfiles, so
the URL in the browser will look weird.

=head1 FILLING FORMS VIA CUSTOM CODE

If you want to stay within the confines of the shell, but still
want to fill out forms using custom Perl code, here is a recipe
how to achieve this :

Code passed to the C<eval> command gets evalutated in the WWW::Mechanize::Shell
namespace. You can inject new subroutines there and these get picked
up by the Callback class of WWW::Mechanize::FormFiller :

  # Fill in the "date" field with the current date/time as string
  eval sub &::custom_today { scalar localtime };
  autofill date Callback WWW::Mechanize::Shell::custom_today
  fillout

This method can also be used to retrieve data from shell scripts :

  # Fill in the "date" field with the current date/time as string
  # works only if there is a program "date"
  eval sub &::custom_today { chomp `date` };
  autofill date Callback WWW::Mechanize::Shell::custom_today
  fillout
  
As the namespace is different between the shell and the generated
script, make sure you always fully qualify your subroutine names,
either in your own namespace or in the main namespace.

=head1 GENERATED SCRIPTS

The C<script> command outputs a skeleton script that reproduces
your actions as done in the current session. It pulls in
C<WWW::Mechanize::FormFiller>, which is possibly not needed. You
should add some error and connection checking afterwards.

=head1 ADDING FIELDS TO HTML

If you are automating a JavaScript dependent site, you will encounter
JavaScript like this :

    <script>
      document.write( "<input type=submit name=submit>" );
    </script>

HTML::Form will not know about this and will not have provided a
submit button for you (understandably). If you want to create such
a submit button from within your automation script, use the following
code :

  $agent->current_form->push_input( submit => { name => "submit", value =>"submit" } );

This also works for other dynamically generated input fields.

To fake an input field from within a shell session, use the C<eval> command :

  eval $self->agent->current_form->push_input(submit=>{name=>"submit",value=>"submit"});

And yes, the generated script should do the Right Thing for this eval as well.

=head1 PROXY SUPPORT

Currently, the proxy support is realized via a call to
the C<env_proxy> method of the WWW::Mechanize object, which
loads the proxies from the environment. There is no provision made
to prevent using proxies (yet). The generated scripts also
load their proxies from the environment.

=head1 ONLINE HELP

The online help feature is currently a bit broken in C<Term::Shell>,
but a fix is in the works. Until then, you can reenable the
dynamic online help by patching C<Term::Shell> :

Remove the three lines

      my $smry = exists $o->{handlers}{$h}{smry}
    ? $o->summary($h)
    : "undocumented";

in C<sub run_help> and replace them by

      my $smry = $o->summary($h);

The shell works without this patch and the online help is still
available through C<perldoc WWW::Mechanize::Shell>

=head1 BUGS

=over 4

=item *

The two parameter version of the C<auth> command guesses the realm from
the last received response. Currently a RE is used to extract the realm,
but this fails with some servers resp. in some cases. Use the four
parameter version of C<auth>, or if not possible, code the extraction
in Perl, either in the final script or through C<eval> commands.

=item *

The shell currently detects when you want to follow a JavaScript link and tells you
that this is not supported. It would be nicer if there was some callback mechanism
to (automatically?) extract URLs from JavaScript-infected links.

=item *

The embedded test C<t/embedded-WWW-Mechanize-Shell.t> currently dies under Perl 5.8
and Solaris after successfully running all tests. I can't test this myself so I don't
know where the reason for that lies - any hints are welcome !

=back

=head1 TODO

=over 4

=item *

Add XPath expressions (by moving C<WWW::Mechanize> from HTML::Parser to XML::XMLlib
or maybe easier, by tacking Class::XPath onto an HTML tree)

=item *

Add C<head> as a command ?

=item *

Add C<referer> and C<referrer> as commands to set the C<Referer> (sic) header

=item *

Add C<ct> as a convenience command instead of C<eval $self-E<gt>agent-E<gt>ct>

=item *

Optionally silence the HTML::Parser / HTML::Forms warnings about invalid HTML.

=back

=head1 EXPORT

The routine C<shell> is exported into the importing namespace. This
is mainly for convenience so you can use the following commandline
invocation of the shell like with CPAN :

  perl -MWWW::Mechanize::Shell -e"shell"

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

Copyright (C) 2002,2003 Max Maischein

=head1 AUTHOR

Max Maischein, E<lt>corion@cpan.orgE<gt>

Please contact me if you find bugs or otherwise improve the module. More tests are also very welcome !

=head1 SEE ALSO

L<WWW::Mechanize>,L<WWW::Mechanize::FormFiller>

=cut
