package HTML::Display::TempFile;
use base 'HTML::Display::Common';
use vars qw($VERSION);
$VERSION='0.02';

=head1 NAME

HTML::Display::TempFile - base class to display HTML via a temporary file

=head1 SYNOPSIS

=for example begin

  package HTML::Display::External;
  use base 'HTML::Display::TempFile';

  sub browsercmd {
    # Return the string to pass to system()
    # %s will be replaced by the temp file name
  };

=for example end

=cut

sub display_html {
  # We need to use a temp file for communication
  my ($self,$html) = @_;

  $self->cleanup_tempfiles;  

  require File::Temp;
  my($tempfh, $tempfile) = File::Temp::tempfile(undef, SUFFIX => '.html');
  print $tempfh $html;
  close $tempfh;

  push @{$self->{delete}}, $tempfile;  
  
  my $cmdline = sprintf($self->browsercmd, $tempfile);
  system( $cmdline ) == 0
    or warn "Couldn't launch '$cmdline' : $?";
};

sub cleanup_tempfiles {
  my ($self) = @_;
  for my $file (@{$self->{delete}}) {
    unlink $file
      or warn "Couldn't remove tempfile $file : $!\n";
  };
  $self->{delete} = [];
};

sub browsercmd { $_[0]->{browsercmd} };

1;
