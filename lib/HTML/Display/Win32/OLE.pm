package HTML::Display::Win32::OLE;
use base 'HTML::Display::Common';

=head1 NAME

HTML::Display::Win32::OLE - use an OLE object to display HTML

=cut

sub new {
  eval "use Win32::OLE";
  die $@ if $@;
  my ($class) = shift;
  my %args = @_;
  my $browser = Win32::OLE->CreateObject(delete $args{app_string});

  my $self = $class->SUPER::new( %args );
  $self->{browser} = $browser;

  $self;
};

1;