#!/usr/bin/perl -w

use strict;
use Carp;
use WWW::Mechanize;
use HTTP::Cookies;

use vars qw( $VERSION );
$VERSION = '0.12';

=head1 NAME

WWW::Mechanize::Shell - A crude shell for WWW::Mechanize

=head1 SYNOPSIS

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
    no warnings 'once';
    *WWW::Mechanize::Shell::cmdloop = sub {};
    eval { require Term::ReadKey; Term::ReadKey::GetTerminalSize() };
    if ($@) {
      diag "Term::ReadKey seems to want a terminal";
      *Term::ReadKey::GetTerminalSize = sub {80,24};
    };
  };
  isa_ok( $shell, "WWW::Mechanize::Shell" );

=head1 DESCRIPTION

This module implements a www-like shell above WWW::Mechanize
and also has the capability to output crude Perl code that recreates
the recorded session. Its main use is as an interactive starting point
for automating a session through WWW::Mechanize.

It has "live" display support for Microsoft Internet Explorer on Win32,
if anybody has an idea on how to implement this for other browsers, I'll be
glad to build this in - from what I know, you cannot write raw HTML into
any other browser window.

The cookie support is there, but no cookies are read from your existing
sessions. See L<HTTP::Cookies> on how to implement reading/writing
your current browser cookies.

=cut

# Blindly allow redirects
{
  no warnings;
  *WWW::Mechanize::redirect_ok = sub { print "\nRedirecting to ",$_[1]->uri; $_[0]->{uri} = $_[1]; 1 };
}

{
  package WWW::Mechanize::FormFiller::Value::Ask;
  use WWW::Mechanize::FormFiller;
  use base 'WWW::Mechanize::FormFiller::Value::Callback';

  use vars qw( $VERSION );
  $VERSION = '0.10';

  sub new {
    my ($class,$name,$shell) = @_;
    my $self = $class->SUPER::new($name, \&ask_value);
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
    $value;
  };
};

package WWW::Mechanize::Shell;

# TODO:
# * Log facility, log all stuff to a file
# * History persistence (see log facility)
# * Add comment facility to Term::Shell
# DONE:
# * Add auto form fill out stuff
# * Add "open()" and "click()" RE functionality
# * Modify WWW::Mechanize to accept REs as well as the other stuff
# * Add simple script generation
# * Fix Term::Shell command repetition on empty lines

use strict;
use base 'Term::Shell';
use FindBin;

use WWW::Mechanize::FormFiller;
eval { require Win32::OLE; Win32::OLE->import() };
my $have_ole = $@ eq '';

sub source_file {
  my ($self,$filename) = @_;
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

sub init {
  my ($self) = @_;
  my ($name,%args) = @{$self->{API}{args}};

  $self->{agent} = WWW::Mechanize->new();
  $self->{browser} = undef;
  $self->{formfiller} = WWW::Mechanize::FormFiller->new(default => [ Ask => $self ]);

  $self->{history} = [];

  $self->{options} = {
    autosync => 0,
    autorestart => 0,
    watchfiles => defined $args{watchfiles} ? $args{watchfiles} : 1,
    cookiefile => 'cookies.txt',
    dumprequests => 0,
  };

  # Keep track of the files we consist of, to enable automatic reloading
  $self->{files} = undef;
  if ($self->{options}->{watchfiles}) {
    eval {
      require File::Modified;
      $self->{files} = File::Modified->new(files=>[values %INC, $0]);
    };
    if ($@) {
      warn "Module File::Modified not found. Automatic reloading disabled.\n";
    };
  };

  # Read our .rc file :
  # I could use File::Homedir, but the docs claim it dosen't work on Win32. Maybe
  # I should just release a patch for File::Homedir then... Not now.
  my $sourcefile;
  if (exists $args{rcfile}) {
    $sourcefile = delete $args{rcfile};
  } else {
    my $userhome = $^O =~ /win32/i ? $ENV{'USERPROFILE'} || $ENV{'HOME'} : `cd ~; pwd`;
    $sourcefile = "$userhome/.mechanizerc";
  };
  $self->option('cookiefile', $args{cookiefile}) if (exists $args{cookiefile});

  # Load the proxy settings from the environment
  $self->agent->env_proxy();

  $self->source_file($sourcefile) if $sourcefile; # and -f $sourcefile and -r $sourcefile;
};

sub agent { $_[0]->{agent}; };

sub option {
  my ($self,$option,$value) = @_;
  if (exists $self->{options}->{$option}) {
    my $result = $self->{options}->{$option};
    if (defined $value) {
      $self->{options}->{$option} = $value;
    };
    $result;
  } else {
    Carp::carp "Unknown option '$option'";
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

sub postcmd {
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
  return unless $have_ole;
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
  my $browser = $self->browser;
  if ($browser) {
    my $document = $browser->{Document};
    $document->open("text/html","replace");
    my $html = $self->agent->{res}->content;
    my $location = $self->agent->{uri};

    # If there is no <BASE> tag, set one

    $html =~ s!(</head>)!<base href="$location" />$1!i
      unless ($html =~ /<BASE/i);

    $document->write($html);
  };
};

sub prompt_str { $_[0]->agent->{uri} . ">" };

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
    $self = ref $self;
    warn "Pod::Constants not available. Use perldoc $self for help.";
    return undef;
  };
  return join( "\n", @result) . "\n";
};

=head1 COMMANDS

The shell implements various commands :

=head2 exit

See "quit"

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

=head2 get

Download a specific URL.

This is used as the entry point in all sessions

Syntax:
  get URL

=cut

sub run_get {
  my ($self,$url) = @_;
  print "Retrieving $url";
  print "(",$self->agent->get($url)->code,")";
  print "\n";

  $self->agent->form(1);
  $self->sync_browser if $self->option('autosync');
  $self->add_history('$agent->get("'.$url.'");'."\n",'  $agent->form(1);');
};

=head2 content

Display the HTML for the current page

This is used as the entry point in all sessions.

=cut

sub run_content {
  my ($self,$url) = @_;
  print $self->agent->content;
  $self->add_history('print $agent->content,"\n"');
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

  #while (my $token = $p->get_token()) {
  while (my $token = $p->get_tag("frame")) {
    print "<",$token->[0],":",ref $token->[1] ? $token->[1]->{src} : "",">";
  }
};

=head2 forms

Display all forms on the current page

=cut

sub run_forms {
  my ($self,$number) = @_;
  if ($number) {
    $self->agent->form($number);
    $self->agent->current_form->dump;
    $self->add_history('$agent->form('.$number.');');
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
    warn "There is no form on the current page\n";
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
    $self->agent->current_form->value($key,$value);
    # Hmm - neither $key nor $value may contain backslashes nor single quotes ...
    $self->add_history('$agent->current_form->value(\''.$key.'\',\''.$value.'\');');
  };
  warn $@ if $@;
};

=head2 submit

Clicks on the button labeled "submit"

=cut

sub run_submit {
  my ($self) = @_;
  eval {
    print $self->agent->submit->code;
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
    $self->agent->form(1);
    print "(",$res->code,")\n";
    if ($self->option('autosync')) {
      $self->sync_browser;
    };
    $self->add_history('$agent->click(\''.$button.'\');');
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
      print "Found $links[0]\n";
      $link = $links[0];
    };
  };

  if (defined $link) {
    eval {
      $self->agent->follow($link);
      $self->add_history('$agent->follow(\''.$user_link.'\');');
      $self->agent->form(1);
      if ($self->option('autosync')) {
        $self->sync_browser;
      } else {
        #print $self->agent->{res}->as_string;
        print "(",$self->agent->{res}->code,")\n";
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

Go back one page in history.

=cut

sub run_back {
  my ($self) = @_;
  eval {
    $self->agent->back();
    $self->sync_browser
      if ($self->option('autosync'));
    $self->add_history('$agent->back();');
  };
  warn $@ if $@;
};

=head2 browse

Open Internet Explorer with the current page

Displays the current page in Microsoft Internet Explorer. No
provision is currently made about IE not being available.

=cut

sub run_browse {
  my ($self) = @_;
  $self->sync_browser;
};

=head2 set

Sets a shell option

Syntax:
   set OPTION [value]

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

Displays your current session history

=cut

sub run_history {
  my ($self) = @_;
  print sprintf <<'HEADER', $^X;
#%s -w
use strict;
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;

my $agent = WWW::Mechanize->new();
my $formfiller = WWW::Mechanize::FormFiller->new();
$agent->env_proxy();
HEADER
  print join( "", map { "  " . $_->[1] . "\n" } @{$self->{history}}), "\n";
  print <<'FOOTER';
print $agent->content;
FOOTER
};

=head2 fillout

Fill out the current form

Interactively asks the values hat have no preset
value via the autofill command.

=cut

sub run_fillout {
  my ($self) = @_;
  $self->{formfiller}->fill_form($self->agent->current_form);
  $self->add_history('$formfiller->fill_form($agent->current_form);');
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

L<HTML::TableExtract> is needed for this feature.

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

    $self->add_history('my @columns = ( ' . map( { s/(['\\])/\\$1/g; qq('$_') } @columns ) . ' );' );
    $self->add_history( <<'PRINTTABLE' );
my $table = HTML::TableExtract->new( headers => [ @columns ]);');
(my $content = $self->agent->content) =~ s/\&nbsp;?//g;
$table->parse($content);
print join(", ", @columns),"\n";
for my $ts ($table->table_states) {
  for my $row ($ts->rows) {
    print join(", ", @$row), "\n";
  };
};
PRINTTABLE
  };
  warn "Couldn't load HTML::TableExtract: $@" if ($@);
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
  warn $@ if $@;
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
  autofill selection Random
  autofill session Keep

=cut

sub run_autofill {
  my ($self,$name,$class,@args) = @_;
  @args = ($self)
    if ($class eq 'Ask');
  if ($class) {
    eval {
      $self->{formfiller}->add_filler($name,$class,@args);
      $self->add_history('$formfiller->add_filler( ',$name, ' => ',$class, ' => ', join( ",", @args), ');' );
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

=cut

sub run_eval {
  my ($self) = @_;
  my $code = $self->line;
  $code =~ /^eval\s+(.*)$/ and do {
    print eval $1,"\n";
  };
};

=head2 source

Execute a batch of commands from a file.

Syntax:
  source FILENAME

=cut

sub run_source {
  my ($self,$file) = @_;
  if ($file) {
    $self->source_file($file);
  } else {
    print "Syntax: source FILENAME\n";
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
  history
  # (yes, this is a bad example of automating, as Google
  #  already has a Perl API. But other sites don't)


=head2 Retrieving a table

  get http://www.perlmonks.org
  open "/Saints in/"
  table User Experience Level
  history
  # now you have a program that gives you a csv file of
  # that table.

=head1 GENERATED SCRIPTS

The C<history> command outputs a skeleton script that reproduces
your actions as done in the current session. It pulls in
L<WWW::Mechanize::FormFiller>, which is possibly not needed. You
should add some error and connection checking afterwards.

=head1 PROXY SUPPORT

Currently, the proxy support is realized via a call to
the C<env_proxy> method of the WWW::Mechanize object, which
loads the proxies from the environment. There is no provision made
to prevent using proxies (yet). The generated scripts also
load their proxies from the environment.

=head1 ONLINE HELP

The online help feature is currently a bit broken in C<Term::Shell>,
but a fix is in the works. Until then, you can reenable the
dynamic online help by patching L<Term::Shell> :

Remove the three lines

      my $smry = exists $o->{handlers}{$h}{smry}
    ? $o->summary($h)
    : "undocumented";

in C<sub run_help> and replace them by

      my $smry = $o->summary($h);

=head1 EXPORT

None by default.

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

Copyright (C) 2002,2003 Max Maischein

=head1 AUTHOR

Max Maischein, E<lt>corion@cpan.orgE<gt>

Please contact me if you find bugs or otherwise improve the module. More tests are also very welcome !

=head1 SEE ALSO

L<WWW::Mechanize>,L<WWW::Mechanize::FormFiller>

=cut
