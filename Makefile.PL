use 5.006;
use ExtUtils::MakeMaker;
use File::Spec;
use strict;
use warnings;
use Config;

my ($os, $osmakefile, $osmaketarget, $osobjext);
my $unzip = "unzip-6.0";
my $exe = $Config::Config{_exe};
my $o   = $Config::Config{obj_ext};
my $objects;
my $makefile_target = File::Spec->catfile($unzip, "Makefile");

my %OS = (
  win32 => [qr/mswin32/i, 'win32', 'Makefile.gcc', 'lib CC_CPU_OPT= NOASM=1',           '',     1],
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

if ($os eq 'unix') {
  $objects = join ' ', map File::Spec->catfile($unzip, "$_$osobjext$o"),
    qw(
      unzip crc32 crypt envargs explode extract fileio globals
      inflate list match process ttyio unreduce unshrink zipinfo api unix
    );
} elsif ($os eq 'win32') {
  if ($Config{cc} =~ /\bgcc\b/) {
    $objects = File::Spec->catfile($unzip, "libunzip32.a"),
  } else {
    $osmakefile = 'Makefile'; # use the VC nmake one and hope for best
    $objects = File::Spec->catfile($unzip, "unzip32.lib"),
  }
} else {
  die "Funny OS. Don't know what to link.";
}

WriteMakefile(
  NAME              => 'Archive::Unzip::Burst',
  VERSION_FROM      => 'lib/Archive/Unzip/Burst.pm',
  CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 7.05_06 },
  ABSTRACT_FROM     => 'lib/Archive/Unzip/Burst.pm',
  AUTHOR            => 'Steffen Mueller <smueller@cpan.org>',
  DEFINE            => qq{-DDLL}, # not defines, removed -fPIC -O3
  INC               => "-I. -I$unzip -I$unzip/$os",
  LICENSE           => 'perl',
  clean             => {
    FILES => "$objects " . join(' ', map "$unzip/$_",
      "unzipstb$o", "unzip_shlib$exe", "*$o", "windllrc$o", "windll$o",
      qw(*.so *.dll *.so.* Makefile libunzip32.a unzip32.lib windll.res
        unzip32.lib unzip32.exp unzip32.dll)
    ),
  },
  dynamic_lib       => {
    INST_DYNAMIC_DEP => $makefile_target,
    OTHERLDFLAGS => $objects,
  },
  XSMULTI           => 1,
  META_MERGE        => {
    "meta-spec" => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'git://github.com/mohawk2/Archive-Unzip-Burst',
        web => 'https://github.com/mohawk2/Archive-Unzip-Burst',
      },
    },
  },
);

sub MY::postamble {
  my ($self) = @_;
  require File::Copy;
  require Cwd;

  my $use_makefile    = File::Spec->catfile($unzip, $os, $osmakefile);
  my $cd = $self->cd($unzip, "\$(MAKE) $osmaketarget \$(PASTHRU)");
  <<EOF;

$makefile_target :
	\$(CP) $use_makefile $makefile_target
	$cd
EOF
}
