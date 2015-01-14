use File::Spec;

# runs 3 tests
sub testrun {
  my $file = shift;
  Archive::Unzip::Burst::unzip($file, "blah");

  ok -d("blah"), "specified dir exists";
  ok -d(File::Spec->catdir("blah", "t2")), "expected subdir exists";
  my $outfile = File::Spec->catfile("blah", "t2", "Archive-InfoUnzip.t");
  ok -f($outfile), "expected file exists";

  unlink $outfile;
  rmdir File::Spec->catdir("blah", "t2");
  rmdir "blah";
}

1;
