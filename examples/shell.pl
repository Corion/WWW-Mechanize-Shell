#!/usr/bin/perl -w
use strict;
use lib 'FormFiller/lib';
use lib 'Shell/lib';
use WWW::Mechanize::Shell;

my $shell = WWW::Mechanize::Shell->new("shell", rcfile => undef );

if (@ARGV) {
  $shell->source_file( @ARGV );
} else {
  $shell->cmdloop;
};