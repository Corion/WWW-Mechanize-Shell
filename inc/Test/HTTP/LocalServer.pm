package Test::HTTP::LocalServer;

# start a fake webserver, fork, and connect to ourselves
use strict;
use LWP::Simple;
use FindBin;
use File::Spec;

=head 2 C<Test::HTTP::LocalServer-E<gt>spawn %ARGS>

This spawns a new HTTP server. The server will stay running until
  $server->stop
is called.

=cut

sub spawn {
  my ($class,%args) = @_;
  my $self = { %args };
  bless $self,$class;
  
  my $server_file = File::Spec->catfile( $FindBin::Bin,File::Spec->updir,'inc','Test','HTTP','log-server' );

  open my $server, qq'"$^X" $server_file |'
    or die "Couldn't spawn fake server $server_file : $!";
  #sleep 0; # give the child some time
  my $url = <$server>;
  chomp $url;

  $self->{_fh} = $server;
  $self->{_server_url} = $url;

  $self;
};

=head2 C<$server-E<gt>port>

This returns the port of the current server. As new instances
will most likely run under a different port, this is convenient
if you need to compare results from two runs.

=cut

sub port { URI::URL->new($_[0]->url)->port };

=head2 C<$server-E<gt>url>

This returns the url where you can contact the server. This url
is valid until you call 
  $server->stop;
  
=cut

sub url { $_[0]->{_server_url} };

=head2 C<$server-E<gt>stop>

This stops the server process by requesting a special
url.
  
=cut

sub stop { get( $_[0]->{_server_url} . "quit_server" )};

=head2 C<$server-E<gt>get_output>

This stops the server by calling C<stop> and then returns the
output of the server process. This output will be a list of
all requests made to the server concatenated together
as a string.

=cut

sub get_output {
  my ($self) = @_;
  $self->stop;
  my $fh = $self->{_fh};
  my $result = join "\n", <$fh>;
  $self->{_fh}->close;
  $result;
};

1;