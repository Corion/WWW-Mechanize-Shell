package Test::HTTP::LocalServer;

# start a fake webserver, fork, and connect to ourselves
use strict;
use LWP::Simple;
use FindBin;
use File::Spec;
use File::Temp;

=head 2 C<Test::HTTP::LocalServer-E<gt>spawn %ARGS>

This spawns a new HTTP server. The server will stay running until
  $server->stop
is called.

Valid arguments are :

  html => scalar containing the page to be served
  file => filename containing the page to be served
  debug => 1 # to make the spawned server output debug information

All served HTML will have the first %s replaced by the current location.

=cut

sub spawn {
  my ($class,%args) = @_;
  my $self = { %args };
  bless $self,$class;
  
  if (delete $args{debug}) {
    $ENV{TEST_HTTP_VERBOSE} = 1;
  };

  if (my $html = delete $args{html}) {
    # write the html to a temp file
    my ($fh,$tempfile) = File::Temp::tempfile();
    binmode $fh;
    print $fh $html
      or die "Couldn't write tempfile $tempfile : $!";
    close $fh;
    $self->{delete} = $tempfile;
    $args{file} = $tempfile;
  };
  my $web_page = delete $args{file};
  if (defined $web_page) {
    $web_page = qq{"$web_page"}
  } else {
    $web_page = "";
  };

  my $server_file = File::Spec->catfile( $FindBin::Bin,File::Spec->updir,'inc','Test','HTTP','log-server' );

  open my $server, qq'$^X $server_file $web_page |'
    or die "Couldn't spawn fake server $server_file : $!";
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
or
  $server->get_output;

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

=head1 EXPORT

None by default.

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

Copyright (C) 2003 Max Maischein

=head1 AUTHOR

Max Maischein, E<lt>corion@cpan.orgE<gt>

Please contact me if you find bugs or otherwise improve the module. More tests are also very welcome !

=head1 SEE ALSO

L<WWW::Mechanize>,L<WWW::Mechanize::Shell>

=cut

1;