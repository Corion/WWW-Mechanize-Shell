package HTML::Display::Win32::IE;
use base 'HTML::Display::Win32::OLE';

=head1 NAME

HTML::Display::Win32::IE - use IE to display HTML pages

=head1 SYNOPSIS

=for example begin

  my $browser = HTML::Display->new(
    class => 'HTML::Display::Dump',
  );
  $browser->display("<html><body><h1>Hello world!</h1></body></html>");

=for example end

This implementation avoids temporary files by using OLE to push
the HTML directly into the browser.

=cut

sub new {
  my ($class) = @_;
  my $self = $class->SUPER::new( app_string => "InternetExplorer.Application" );
  $self;
};

sub setup {
  my ($self,$control) = @_;
  warn "Setting up browser";
  $control->{'Visible'} = 1;
  $control->Navigate('about:blank');
};

sub display_html {
  my ($self,$html) = @_;
  my $browser = $self->control;
  my $document = $browser->{Document};
  $document->open("text/html","replace");
  $document->write($html);
};

1;