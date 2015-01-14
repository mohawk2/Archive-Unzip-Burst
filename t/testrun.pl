use File::Spec;

# runs 4 tests
sub testrun {
  my $file = shift;
  is Archive::Unzip::Burst::unzip($file, "blah"), 0, "unzip retval";

  ok -d("blah"), "specified dir exists";
  ok -d(File::Spec->catdir("blah", "t2")), "expected subdir exists";
  my $outfile = File::Spec->catfile("blah", "t2", "Archive-InfoUnzip.t");
  ok -f($outfile), "expected file exists";

  unlink $outfile;
  rmdir File::Spec->catdir("blah", "t2");
  rmdir "blah";
}

1;
