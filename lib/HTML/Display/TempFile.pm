package HTML::Display::TempFile;
use base 'HTML::Display::Common';

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

  require File::Temp;
  my($tempfh, $tempfile) = File::Temp::tempfile(undef, UNLINK => 1);
  print $tempfh $html;
  my $cmdline = sprintf($self->browsercmd, $tempfile x 2);
  system( $cmdline ) == 0
    or warn "Couldn't launch '$cmdline' : $?";
};

sub browsercmd { $_[0]->{browsercmd} };

1;
