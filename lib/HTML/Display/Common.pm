package HTML::Display::Common;

=head1 NAME

HTML::Display::Common - routines common to all HTML::Display subclasses

=cut

use strict;
use HTML::TokeParser;
use Carp qw( croak );

sub new {
  my ($class) = shift;
  my $self = { @_ };
  bless $self,$class;
  $self;
};

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