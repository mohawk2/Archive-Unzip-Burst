use Test::More tests => 4;
use Cwd;
use File::Spec;
BEGIN { use_ok('Archive::Unzip::Burst') };

chdir("t");
require 'testrun.pl';
testrun("foo.zip");
