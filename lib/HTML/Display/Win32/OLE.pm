package HTML::Display::Win32::OLE;
use base 'HTML::Display::Common';

=head1 NAME

HTML::Display::Win32::OLE - use an OLE object to display HTML

=head1 SYNOPSIS

=for example begin

  package HTML::Display::Win32::OleControl;
  use base 'HTML::Display::Win32::OLE';

  sub new {
    my $class = shift;
    $class->SUPER::new( app_string => "FooBrowser.Application", @_ );
    $self;
  };

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Win32::OleControl',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

=cut

sub new {
  eval "use Win32::OLE";
  die $@ if $@;
  my ($class) = shift;
  my %args = @_;

  my $self = $class->SUPER::new( %args );
  $self;
};

=head2 control

This initializes the OLE control and returns it. Only one
control is initialized for each object instance. You don't need
to store it separately.

=cut

sub control {
  my $self = shift;
  $self->{control} ||= Win32::OLE->CreateObject($self->{app_string});
  $self->{control};
};

1;