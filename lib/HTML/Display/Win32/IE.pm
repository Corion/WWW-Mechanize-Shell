package HTML::Display::Win32::IE;

=head1 NAME

HTML::Display::Win32::IE - use IE to display HTML pages

=cut

use base 'HTML::Display::Win32::OLE';

sub new {
  my ($class) = @_;
  my $self = $class->SUPER::new( app_string => "InternetExplorer.Application" );
  $self->{browser}->{'Visible'} = 1;
  $self->{browser}->Navigate('about:blank');
  $self;
};

sub display_html {
  my ($self,$html) = @_;
  my $browser = $self->{browser};
  my $document = $browser->{Document};
  $document->open("text/html","replace");
  $document->write($html);
};

1;