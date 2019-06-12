
package ChordImageGenerator;

use strict;
use warnings;
use GD::Simple;
use List::Util qw(min max);


sub draw_cross{
    my($image,$center_x,$center_y,$size) = @_;
    $image->penSize(10,10);
    $image->line($center_x+($size/2),$center_y+($size/2),$center_x-($size/2),$center_y-($size/2));
    $image->line($center_x+($size/2),$center_y-($size/2),$center_x-($size/2),$center_y+($size/2));
    $image->line($center_x+($size/2),$center_y+($size/2));
    $image->penSize(1,1);
}

#Inputs to generate chord diagram

our $min_num_frets_to_display = 3;
our $tuning = "EADGBE";

#By default it goes from thickest to thinnest

#More specific rendering configuration values
my @string_note_offsets = (-10,-40);
my @fret_number_offsets = (-60,20);
my $string_left_offset = 100;
my $string_right_offset = 50;
my $fret_top_offset = 100;
my $fret_bottom_offset = 50;
my ($width, $height) = (500,500);
my $finger_dot_size = 40;

sub generate_chord_image{
	
	my $fingering = @_[0];
	my $out_filename = @_[1];
	
	print "Tuning:$tuning\n";
	my @tuning = split("",$tuning);
	my $num_strings = @tuning;
	
	# create a new image (width, height)
	my $img = GD::Simple->new($width,$height);
	$img->font("Arial");
	$img->fontsize(30);
	$img->bgcolor('white');
	$img->fgcolor('black');
	my $black = $img->colorAllocate(0,0,0);
	my $white = $img->colorAllocate(255,255,255);


	my @fingering = split("",$fingering);
	if (@fingering != $num_strings){
		print "Chord input does not match number of strings:$fingering\n";
		print "Expecting $num_strings fret positions, found only ${\scalar(@fingering)}\n";
		exit -1;
	}

	my @fret_positions_only_numbers = grep {!/[oOxX]/} @fingering;
	my $min_chord_fret = min @fret_positions_only_numbers;
	my $max_chord_fret = max @fret_positions_only_numbers;
	my $min_display_fret = max (($min_chord_fret),0);
	my $max_display_fret = max($max_chord_fret, ($min_display_fret + $min_num_frets_to_display));
	my @frets = ($min_display_fret..$max_display_fret);
	my $num_display_frets = @frets;
	print "Display frets:@frets. Num frets:$num_display_frets\n";
	#print "@fingering, @fret_positions_only_numbers, $min_chord_fret  $max_chord_fret \n";

	my $string_distance = ($width - $string_left_offset - $string_right_offset)/($num_strings-1);
	my $fret_distance = ($height- $fret_top_offset - $fret_bottom_offset)/($num_display_frets-1);

	print "string_distance:${string_distance}px, fret_distance:${fret_distance}px\n";

	my @string_x_positions = ();
	my %fret_y_positions = ();

	for my $i (0..($num_strings-1)){
		my $x = ($i*$string_distance)+$string_left_offset;
		push @string_x_positions,$x;
		my $pensize = $num_strings - $i + 1;
		$img->penSize($pensize,$pensize);
		$img->line($x,$fret_top_offset,$x,$height-$fret_bottom_offset);
		$img->moveTo($x+$string_note_offsets[0],$fret_top_offset+$string_note_offsets[1]);
		$img->string($tuning[$i]);
	}

	for my $i (0..($num_display_frets-1)){
		if($i == 0){
			$img->penSize(4,4);
			}else{
			$img->penSize(1,1);
		}
		my $y = ($i*$fret_distance)+$fret_top_offset;
		$img->line($string_left_offset,$y,$width-$string_right_offset,$y);
		$img->moveTo($string_left_offset+$fret_number_offsets[0],$y+$fret_number_offsets[1]);
		$img->string($frets[$i]);
		$fret_y_positions{$frets[$i]} = $y + ($fret_distance/2);
	}

	for my $i (0..(@fingering-1)){
		print "${fingering[$i]}\n";
		if ($fingering[$i] =~ /[xX]/){
		print "Muted String\n";
		draw_cross($img,$string_x_positions[$i],$fret_top_offset,$finger_dot_size);
		}elsif($fingering[$i] =~ /[ooO]/){
		print "Open String\n";
		$img->bgcolor($white);
		$img->penSize(8,8);
		$img->filledArc($string_x_positions[$i],$fret_top_offset,
			  $finger_dot_size,$finger_dot_size,0,360,$black);
		$img->filledArc($string_x_positions[$i],$fret_top_offset,
			  $finger_dot_size-10,$finger_dot_size-10,0,360,$white);
		$img->penSize(1,1);
		}else{
		$img->filledArc($string_x_positions[$i],$fret_y_positions{$fingering[$i]},
				$finger_dot_size,$finger_dot_size,0,360,$black);
		}
	}

	open my $out, '>', $out_filename or die;
	binmode $out;
	print $out $img->png;
}

1;