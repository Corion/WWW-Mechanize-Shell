package HTML::Display::Common;

=head1 NAME

HTML::Display::Common - routines common to all HTML::Display subclasses

=cut

use strict;
use HTML::TokeParser;
use Carp qw( croak );

=head2 __PACKAGE__-E<gt>new %ARGS

Creates a new object as a blessed hash. The passed arguments are stored within
the hash. If you need to do other things in your constructor, remember to call
this constructor as well :

=for example begin

  package HTML::Display::WhizBang;
  use base 'HTML::Display::Common';

  sub new {
    my ($class) = shift;
    my %args = @_;
    my $self = $class->SUPER::new(%args);

    # do stuff

    $self;
  };

=for example end

=for example_testing
  package main;
  use HTML::Display;
  my $browser = HTML::Display->new( class => "HTML::Display::WhizBang");
  isa_ok($browser,"HTML::Display::Common");

=cut

sub new {
  my ($class) = shift;
  #croak "Odd number" if @_ % 2;
  my $self = { @_ };
  bless $self,$class;
  $self;
};

=head2 $display->display %ARGS

This is the routine used to display the HTML to the user. It takes the
following parameters :

  html => SCALAR containing the HTML
  file => SCALAR containing the filename of the file to be displayed
  location => optional base url for the HTML, so that relative links still work

=head3 Basic usage :

=for example
  no warnings 'redefine';
  *HTML::Display::new = sub {
    my $class = shift;
    require HTML::Display::Dump;
    return HTML::Display::Dump->new(@_);
  };

=for example begin

  my $html = "<html><body><h1>Hello world!</h1></body></html>";
  my $browser = HTML::Display->new();
  $browser->display( html => $html );

=for example end

=for example_testing
  isa_ok($browser, "HTML::Display::Dump","The browser");
  is( $main::_STDOUT_,"<html><body><h1>Hello world!</h1></body></html>","HTML gets output");

=head3 Location parameter :

If you fetch a page from a remote site but still want to display
it to the user, the C<location> parameter comes in very handy :

=for example
  no warnings 'redefine';
  *HTML::Display::new = sub {
    my $class = shift;
    require HTML::Display::Dump;
    return HTML::Display::Dump->new(@_);
  };

=for example begin

  my $html = '<html><body><img src="/images/hp0.gif"></body>';
  my $browser = HTML::Display->new();

  # This will display part of the Google logo
  $browser->display( html => $html, location => 'http://www.google.com' );

=for example end

=for example_testing
  isa_ok($browser, "HTML::Display::Dump","The browser");
  is( $main::_STDOUT_,'<html><body><img src="/images/hp0.gif"></body>',"HTML gets output");

=cut

sub display {
  my ($self) = shift;
  my %args;
  if (scalar @_ == 1) {
    %args = ( html => $_[0] );
  } else {
    %args = @_;
  };

  $args{location} ||= "";
  if ($args{file}) {
    my $filename = delete $args{file};
    local $/;
    local *FILE;
    open FILE, "<", $filename
      or croak "Couldn't read $filename";
    $args{html} = <FILE>;
  };

  $args{html} =~ s!(</head>)!<base href="$args{location}" />$1!i
    unless ($args{html} =~ /<BASE/i);

  $self->display_html($args{html});
};

1;
