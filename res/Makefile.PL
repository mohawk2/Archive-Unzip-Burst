use ExtUtils::MakeMaker;
use Config;
use vars qw/$os $osmakefile $osmaketarget $osobjext/;
require File::Spec;
$Verbose = 1;
my $exe = $Config::Config{_exe};
my $o   = $Config::Config{obj_ext};

if (not defined $os) {
  die "The Makefile.PL in res/ is designed to be included by the main Makefile.PL!";
}

my $unzipdir = "unzip-5.52";

my $objects;
if ($os eq 'unix' or $os eq 'win32') {
  $objects = join(' ', map {File::Spec->catfile($unzipdir, "$_$osobjext$o")} qw|unzip crc32 crctab crypt envargs explode extract fileio globals inflate list match process ttyio unreduce unshrink zipinfo api|, "$os");
}
else {
  die "Funny OS. Don't know what to link.";
}

WriteMakefile(
  NAME   => 'Archive::Unzip::Burst',
  #SKIP   => [qw(all static static_lib dynamic dynamic_lib)],
  DEFINE            => '-fPIC -DDLL -O3', # e.g., '-DHAVE_SOMETHING'
  INC               => "-I. -Iunzip-5.52 -Iunzip-5.52/$os", # e.g., '-I. -I/usr/include/other'
  clean  => {
    'FILES' => "libmyunzip\$(LIB_EXT) $objects $unzipdir/unzipstb.o $unzipdir/*.so $unzipdir/*.dll $unzipdir/*.so.* $unzipdir/unzip_shlib$exe $unzipdir/Makefile"
  },
  OBJECT            => $objects,
);
sub MY::top_targets {
                       "
all :: static

pure_all :: static

static ::       libmyunzip\$(LIB_EXT)

libmyunzip\$(LIB_EXT): \$(O_FILES)
	\$(AR) cr libmyunzip\$(LIB_EXT) $objects
	\$(RANLIB) libmyunzip\$(LIB_EXT)
";
}

#	\$(AR) cr libmyunzip\$(LIB_EXT) \$(O_FILES)
