use Test::More tests => 5;
use Cwd;
use File::Spec;
BEGIN { use_ok('Archive::Unzip::Burst') };

chdir("t");
require 'testrun.pl';
testrun(File::Spec->catfile(Cwd::cwd(), "foo.zip"));
