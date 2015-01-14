use 5.006;
use ExtUtils::MakeMaker;
use File::Spec;
use strict;
use warnings;
use Config;
my ($os, $osmakefile, $osmaketarget, $osobjext, @winobjs, $windllcmd, $winsys);

my $unzip = "unzip-5.52";
my $exe = $Config::Config{_exe};
my $o   = $Config::Config{obj_ext};
my $objects;

if ( 0 ) {
  $winsys = ($Config::Config{cc} eq 'cl') ? 'vc' : 'mingw';

  if( $winsys eq 'vc' ) {
    @winobjs = qw(crci386l crctabl);
    $windllcmd = '$(MAKE) $(USEMAKEFILE) win32/Makefile dll';
  } else {
    @winobjs = qw(crc32l crc_i386);
    $windllcmd = '$(MAKE) $(USEMAKEFILE) win32/makefile.gcc dll';
  }
  push @winobjs, qw(
    api cryptl explodel extractl fileiol globalsl inflatel listl
    matchl ntl processl unreducl unshrnkl win32l windll zipinfol
  );

  $objects .= qq( $unzip/$_$o) for (@winobjs);

  my $cleanfiles;

  for(@winobjs) {
      $cleanfiles .= qq($unzip/$_$o );
  }

  if( $winsys eq 'vc' ) {
      $cleanfiles .= qq($unzip/windll.res $unzip/unzip32.lib $unzip/unzip32.exp);
  } else {
      $cleanfiles .= qq($unzip/windllrc$o $unzip/windll$o);
  }
  $cleanfiles .= qq( $unzip/unzip32.dll);

}

my %OS = (
  win32 => [qr/mswin32/i, 'win32', 'Makefile.gcc', 'dll',           '',     0],
  linux => [qr/linux/i,   'unix',  'Makefile',     'generic_shlib', '.pic', 1],
  os2 =>   [qr/os2/i,     'os2',   'makefile.os2', 'gcc gccdyn',    '',     0],
  dos =>   [qr/dos/i,     'msdos', 'makefile.msc', 'default',       '',     0],
  macos => [qr/macos/i,   'unix',  'Makefile',     'generic_shlib', '.pic', 0],
);

foreach (keys %OS) {
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

if ($os eq 'unix' or $os eq 'win32') {
  $objects = join ' ', map File::Spec->catfile($unzip, "$_$osobjext$o"),
    qw(
      unzip crc32 crctab crypt envargs explode extract fileio globals
      inflate list match process ttyio unreduce unshrink zipinfo api
    ), $os;
} else {
  die "Funny OS. Don't know what to link.";
}

WriteMakefile(
  NAME              => 'Archive::Unzip::Burst',
  VERSION_FROM      => 'lib/Archive/Unzip/Burst.pm',
  CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 7.05_06 },
  ABSTRACT_FROM  => 'lib/Archive/Unzip/Burst.pm',
  AUTHOR         => 'Steffen Mueller <smueller@cpan.org>',
  LIBS              => [''],
  DEFINE            => '-DDLL', # not defines, removed -fPIC -O3
  INC               => "-Iunzip-5.52 -Iunzip-5.52/$os",
  LICENSE           => 'perl',
  clean  => {
    FILES => "$objects $unzip/unzipstb$o $unzip/*.so $unzip/*.dll $unzip/*.so.* $unzip/unzip_shlib$exe $unzip/Makefile $unzip/*$o"
  },
  OBJECT            => "Burst$o $objects",
);

sub MY::postamble {
  my ($self) = @_;
  require File::Copy;
  require Cwd;

  my $use_makefile    = File::Spec->catfile($unzip, $os, $osmakefile);
  my $makefile_target = File::Spec->catfile($unzip, "Makefile");
  File::Copy::copy( $use_makefile, $makefile_target );
  my $abs_unzip_dir = Cwd::abs_path($unzip);
  my $cd = $self->cd($unzip, "\$(MAKE) $osmaketarget \$(PASTHRU)");
"
$objects : $makefile_target
	$cd
"
}
