package My::Math;

use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib (dirname abs_path $0) . '/';

require ChordImageGenerator;

$ChordImageGenerator::tuning = "ACCFGH";
ChordImageGenerator::generate_chord_image( "2o43x2","a.png" );

 