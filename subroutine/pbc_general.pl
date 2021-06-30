#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

# mode = "ATOM" or "BEAD" 
my $xsdname = "to lam";

my $doc = $Documents{$xsdname.".xsd"};
PBC("Bead", $doc);

sub PBC
{
	use POSIX qw/floor/;
	my $mode = shift;	
	my $xsddoc = shift;

	
	# Define local veriables
	my $time;
	my ($x, $y, $z);
	my ($boxlengx, $boxlengy, $boxlengz);
	my ($invlengx, $invlengy, $invlengz);
	my ($elements, $element);
	my ($elementctr, $pbcctr);

	print "-------------------------------------------------\n";
	print "Apply 3D periodic boundary condition\n\n";

	# Get start time
	$time = time;
			
	# Initialize variables
	$elementctr = 0;
	$pbcctr = 0;
		
	# Check mode and get data
	if($mode eq "Atom")
	{
		$elements = $xsddoc->UnitCell->Atoms;
	} elsif ($mode eq "Bead")
	{
		$elements = $xsddoc->UnitCell->Beads;
	} else {
		die "Error : mode $mode does not exist. Please check again\n";
	}

	$elementctr = $elements->Count;
	print "Total number of $mode(s) : $elementctr\n\n";
	

		
	# Get lattice paramaeter
	$boxlengx = $xsddoc->Lattice3D->LengthA;
	$boxlengy = $xsddoc->Lattice3D->LengthB;
	$boxlengz = $xsddoc->Lattice3D->LengthC;
	$invlengx = 1/$boxlengx;
	$invlengy = 1/$boxlengy;
	$invlengz = 1/$boxlengz;
	printf "%15s%15s%15s\n", "boxlengx", "boxlengy", "boxlengz";
	printf "%15f%15f%15f\n\n", $boxlengx, $boxlengy, $boxlengz;
	
	# Apply 3D periodic boundary condition
	foreach $element (@$elements)
	{
		$x = $element->X;
		$y = $element->Y;
		$z = $element->Z;
		
		if($x < 0 || $x > $boxlengx || $y < 0 || $y > $boxlengy || $z < 0 || $z > $boxlengz)
		{
			$element->X = $x - $boxlengx*floor($x*$invlengx);
			$element->Y = $y - $boxlengy*floor($y*$invlengy);
			$element->Z = $z - $boxlengz*floor($z*$invlengz);
			$pbcctr++;
		}
	}
	
	$time = time - $time;
	print "The number of $mode(s) that 3D PBC is applied : $pbcctr\n\n";
	print "3D PBC application takes $time seconds\n\n";
	
}
