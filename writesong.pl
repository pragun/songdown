 # This file is part of SongDown.

 #    SongDown is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU General Public License as published by
 #    the Free Software Foundation, either version 3 of the License, or
 #    (at your option) any later version.

 #    SongDown is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU General Public License for more details.

 #    You should have received a copy of the GNU General Public License
 #    along with SongDown.  If not, see <https://www.gnu.org/licenses/>.


#!/usr/bin/perl
use Cwd 'abs_path','getcwd';
use File::Basename;
use Data::Dump qw(dump);

my $inputfile = $ARGV[0];
my ($a, $input_dir_path, $c) = fileparse($inputfile,qr/\.[^.]*/);
$input_dir_path = abs_path($input_dir_path)."/";
print "input dir path:$input_dir_path\n";

my $htmlfile = "$input_dir_path$a.html";
my $pdffile = "$input_dir_path$a.pdf";

my $cwd = getcwd();
my $stylesheet;
my $script_path = dirname(abs_path(__FILE__));

use lib (dirname abs_path $0) . '/';
require ChordImageGenerator;

#The following lines will look for a stylesheet for the intermediate html file
#The following paths are considered in this order
#1. <CWD>/style.css [For custom style application for all songs in a folder]
#2. <CWD>/../defaults/style.css [For custom style application
#   for all the songs in their own specific folder within a
#   song-diary kind of a folder
#3. If none of these above stylesheets are found, it uses the stylesheet
#   from the script folder

print $script_path;
#Check if there is a style sheet in the folder where this script is run

if(-e ($stylesheet = "$cwd/style.css")){
    print "Found stylesheet here:$stylesheet\n";
}elsif(-e ($stylesheet = "$cwd/../defaults/style.css")){
    $stylesheet = abs_path($stylesheet);
    print "Found stylesheet here:$stylesheet\n";
}elsif(-e ($stylesheet = "$script_path/style.css")){
    print "Found stylesheet here:$stylesheet\n";
}else{
    print "Could not find stylesheet.";
    exit -1;
}


print $inputfile,"\n";
print "Outputting to $htmlfile\n";

open(IFILE, '<', $inputfile) or die $!;
open(my $ofile, '>', $htmlfile) or die $!;

print $ofile join("\n", '<!doctype html>',
'<html lang="en">',
'<head>',
'<meta charset="utf-8">',
'<title>',"$inputfile",'</title>',       
'<meta name="description" content="">',
'<meta name="author" content="SongDown SongWriting Markdown">',		  
'<link rel="stylesheet" href="'.$stylesheet.'">',
'</head>',
"<body>\n");


sub get_next_top_bottom{
    my $input = @_[0];
    
    #    ~/^(\{.*?})?(.*?[{\n])/p;
    $input =~/^         #Look for a match starting at the beigninning of the string
    (\{.*?})    		#match the shortest substring bracketed with escaped curly brackets
    ?          			#no worries if there is no bracketed substring, this is often true for the first line of songs
    (.*?[{\n]) 			#look for the words for the chords matched above by going upto the next occurrence of the curly bracket
    /xp;       			#The x lets this regex to be split over multiple lines, p allows using postmatch variable
    
    my $last_char_bottom = substr $2, -1;
    my $leftover = "${last_char_bottom}${^POSTMATCH}";
    my $top = substr $1, 1, -1;
    my $bottom = substr $2, 0, -1;
    return ($top,$bottom,$leftover);
}

sub handle_heading{
    my ($hnum,$text) = @_;
    
    print "Handling heading $_\n";
    print "Leading Hashes:$hnum, Text:$text\n";
    print $ofile '<div class="line">',"<h$hnum>",$text,"</h></div>\n";
}

sub handle_generic{
    my ($name, $input) = @_;
    #print "Handling generic:$name, with text:$input\n";
    print $ofile '<div class="line"><span class="',$1,'"',">$2",'</span>';
    if ($name eq "section"){
		print $ofile "<hr>";
    }
    print $ofile "</div>\n";
}

sub handle_comment{
    my $input = @_[0];
    print $ofile '<div class="line"><span class="comment">',$input;
    print $ofile "</span></div>\n";
}

sub handle_pagebreak{
    print $ofile '<div class="pagebreak"></div>';
}	

sub handle_chord_section{
    my $chord_section = @_[0];
    my @chords = split /\s+/,$chord_section;
    my @chords = grep /\S*/, @chords;

    print $ofile '<div class="chord-section">'."\n";
    
    for $i (0..@chords-1){
	print "For chord:$chords[$i]\n";
	if ($chords[$i] =~ /^(.*?)(?:$|(?::(.*)))/){
	    $chord_name = $1;
	    $chord_fingering = $2;
	    print "Chord Name:$chord_name, Fingering:$2\n";
	    my $img_name = $chord_name.'.png';
	    ChordImageGenerator::generate_chord_image( $chord_fingering,$input_dir_path.$img_name );
	    print $ofile "\t".'<div class="chord-image">'."\n";
	    print $ofile "\t\t".'<img src="'.$img_name.'"></img>'."\n";
	    print $ofile "\t\t".'<div class="chord-name">'.$chord_name."</div>\n";
	    print $ofile "\t</div>"
	}
    }

    print $ofile "\n</div>\n";
}

sub handle_tuning{
	print "Tuning:@_[0]\n";
	$ChordImageGenerator::tuning_input_string = @_[0];
}
	

while(<IFILE>){
    my @top_text_fragments = ();
    my @bottom_text_fragments = ();
    my $top, $bottom, $leftover;
    
    if(/^(#+) (.*)/){
	handle_heading((length $1),$2);
    }
    elsif(/^(title|artist|section):(.*)/){
	handle_generic($1,$2);
    }
    elsif(/^(%)(.*)/){
	handle_comment $2;
    }
    elsif(/^pagebreak(.*)/){
	handle_pagebreak;
    }
    elsif(/^chordsection(?:\s+)([\S\s]*)/){
	handle_chord_section $1;
    }
    elsif(/^tuning\s+(.*)/){
	handle_tuning $1;
    }
    else{	
	$leftover = $_;
	print $ofile '<div class="lyricline">',"\n";

	until($leftover =~ /^[\n\r\s]*$/)
	{
	    #print "Processing: $leftover";
	    
	    ($top,$bottom,$leftover) = get_next_top_bottom $leftover;
	    push(@top_text_fragments,$top);
	    push(@bottom_text_fragments,$bottom);
	    
	    #print "Top:$top, Bottom:$bottom, Leftover:$leftover\n";
	    #print "Came to an end" if $leftover =~ /^[\n\r\s]*$/;
	    
	    print $ofile "\t",'<div class="block">',"\n";
	    print $ofile "\t\t",'<div class="chord">',$top,"</div>\n";   
	    print $ofile "\t\t",'<div class="words">',$bottom,"</div>\n";
	    print $ofile "\t",'</div>',"\n";
	}

	print $ofile "\t",'<div class="endblock">',"\n\t</div>\n";
	print $ofile "</div>\n";
    }
	
    # print "Top Fragments\n";
    # foreach my $n (@top_text_fragments) {
    # 	print $n,"\n";
    # }

    # print "Bottom Fragments\n";
    # foreach my $n (@bottom_text_fragments) {
    # 	print $n,"\n";
    # }

    print "\n";

}

print $ofile "</body>\n</html>";

close IFILE;
close $ofile;

`weasyprint "$htmlfile" "$pdffile"`
    
