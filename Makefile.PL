use 5.006;
use ExtUtils::MakeMaker;
use File::Spec;
use strict;
use warnings;
use vars qw/$os $osmakefile $osmaketarget $osobjext/;

my $unzip = "unzip-5.52";

my @OS = qw(
  win32 os2 dos macos linux
);
my %OS = (
  win32 => [qr/mswin32/i, 'win32', 'Makefile.gcc', 'dll lib',       '',     0],
  linux => [qr/linux/i,   'unix',  'Makefile',     'generic_shlib', '.pic', 1],
  os2 =>   [qr/os2/i,     'os2',   'makefile.os2', 'gcc gccdyn',    '',     0],
  dos =>   [qr/dos/i,     'msdos', 'makefile.msc', 'default',       '',     0],
  macos => [qr/macos/i,   'unix',  'Makefile',     'generic_shlib', '.pic', 0],
);

foreach (@OS) {
  my $desc = $OS{$_};
  my $regex = $desc->[0];
  if ($^O =~ $regex) {
    $os = $desc->[1];
    $osmakefile   = $desc->[2];
    $osmaketarget = $desc->[3]||'generic_shlib';
    $osobjext     = $desc->[4];
    if (not $desc->[5]) {
      warn "BEWARE! The module has not been tested on this OS!\n"
          ."It turns out its working, please inform the maintainer so he can\n"
          ."remove this notice. Thank you! (Patches welcome, too.)\n";
    }
    last;
  }
}

if (not defined $os) {
  warn "Could not determine that you are running any supported\n"
      ."Operating System. I will try the generic 'unix' Makefile.\n";
  my $osdesc = $OS{linux};
  $os = $osdesc->[1];
  $osmakefile = $osdesc->[2];
  $osmaketarget = $osdesc->[3];
}

WriteMakefile(
    NAME              => 'Archive::Unzip::Burst',
    VERSION_FROM      => 'lib/Archive/Unzip/Burst.pm', # finds $VERSION
    PREREQ_PM         => {
        'File::Spec' => '0',
        'Cwd' => '0',
      }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Archive/Unzip/Burst.pm', # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '-fPIC -DDLL -O3', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
    MYEXTLIB => 'res/libmyunzip$(LIB_EXT)',
    LICENSE           => 'perl',
);

sub MY::postamble {
  require File::Copy;
  require File::Spec;
  my $unzip_dir = File::Spec->catdir("res", $unzip);
  my $use_makefile    = File::Spec->catfile($unzip_dir, $os, $osmakefile);
  my $makefile_target = File::Spec->catfile($unzip_dir, "Makefile");
  File::Copy::copy( $use_makefile, $makefile_target );
"
\$(MYEXTLIB): $makefile_target
	cd $unzip_dir && \$(MAKE) $osmaketarget \$(PASSTHRU)
"
}

