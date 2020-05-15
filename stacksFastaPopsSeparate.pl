#!/usr/bin/perl

# this appends the non gap character length of each sequence to the sequence name

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

if( scalar( @ARGV ) == 0 ){
	&help;
	die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'f:hm:o:', \%opts );

# if -h flag is used kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $fas, $map, $out ) = &parsecom( \%opts );

# variables
my @lines; #holds lines from fasta file
my %hash; #map of ind->population
my %hoa;

# read in file
open( FASTA, $fas ) or die "Can't open $fas: $!\n\n";

while(my $line = <FASTA>){
	chomp( $line );
	push( @lines, $line );
}

close FASTA;

open( MAP, $map ) or die "Can't open $map: $!\n\n";

while( my $line = <MAP> ){
	chomp( $line );
	my @temp = split( /\s+/, $line );
	$hash{$temp[0]} = $temp[1] ;
}

close MAP;

for( my $i=1; $i<@lines; $i++ ){
	if($lines[$i-1] =~ /\[(\w+)\]$/ ){
		#print $hash{$1}, "\n";
		push( @{$hoa{$hash{$1}}}, $lines[$i-1]);
		push( @{$hoa{$hash{$1}}}, $lines[$i]);
	}
}

foreach my $pop( sort keys %hoa ){
	print $pop, "\n";
	open( FILE, '>', "$pop.fa" ) or die "Can't open $pop.fa: $!\n\n";
	foreach my $line( @{$hoa{$pop}} ){
		print FILE $line, "\n";
	}
	close FILE;
}

#print Dumper( \%hoa );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nfasta2nexus.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -f | -h | -o | -m ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".nex\" will be appended to the input file name.\n\n";
  print "\t-f:\tSpecify the name of a fasta file.\n\n";
  print "\t-m:\tSpecify the name of a tab-delimited map file (individual <tab> population).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $fasta = $opts{f} || die "No input file specified.\n\n"; #used to specify input fasta file.
  my $out = $opts{o} || "$fasta.nex"  ; #used to specify output file name.  If no name is provided, the file extension ".fasta" will be appended to the input file name.
  my $map = $opts{m} || die "No map file specified.\n\n"; #used to specify input fasta file.


  return( $fasta, $map, $out );

}

#####################################################################################################
