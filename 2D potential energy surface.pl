#!perl

# ====================================================================================================
# Generate translated structures along lattice vectors a and b
# for constructing two-dimensional (2D) potential energy surface (PES)
#
# @Author: Se Hun Joo
# @Version: 2019-10-28
# ====================================================================================================

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

# ====================================================================================================
# Required user input field
# ====================================================================================================

my $xsdname = "PI-COF_1x1x2";				# xsd name
my $setname = "top_layer";					# set for 2D translation
my $writelevel = "xtd+xsd";					# 1) text 2) xtd+xsd 3) xtd
my ($ia, $ib) = (16, 16);					# Range: from (0, 0) to ($ia, $ib) (# points: ($ia+1)*($ib+1))
my ($na, $nb) = (16, 16);					# subdivisions along the lattice vectors a and b
my ($sa, $sb) = (-$ia/$na/2,-$ib/$nb/2);	# optional shift of the grid: 1) origin (0,0) 2) center (-$ia/$na/2,-$ib/$nb/2)

# ====================================================================================================
# Variables
# ====================================================================================================

#variables for file
my ($xsddoc, $xtddoc);
my ($tempname, $tempdoc);

# variables for lattice
my ($latveca, $latvecb, $latvecc);
my ($latlenga, $latlengb, $latlengc);

# variables for translation
my ($sets, $atoms, $setmove);
my ($tx, $ty);
my ($dlatlenga, $dlatlengb);

# dummy variables
my ($i, $j);

# ====================================================================================================
# Main
# ====================================================================================================

# Open input file (.xsd)
$xsddoc = $Documents{$xsdname.".xsd"};

# Get lattice information
$latveca = $xsddoc->Lattice3D->VectorA;
$latvecb = $xsddoc->Lattice3D->VectorB;
$latvecc = $xsddoc->Lattice3D->VectorC;
$latlenga = $xsddoc->Lattice3D->LengthA;
$latlengb = $xsddoc->Lattice3D->LengthB;
$latlengc = $xsddoc->Lattice3D->LengthC;

# Open output file (.xtd)
if ($writelevel ne "text")
{
	$xtddoc = Documents->New($xsdname.".xtd");
}

# Open output file (.xtd)
for ($i = 0; $i < $ia+1; $i++)
{
	for ($j = 0; $j < $ib+1; $j++)
	{
		
		# Set translation vector, t = (tx, ty), translation from ($sa, $sb)
		$dlatlenga = (($i/$na)+$sa)*($latlenga);
		$dlatlengb = (($j/$nb)+$sb)*($latlengb);
		$tx = (($i/$na)+$sa)*($latveca->X) + (($j/$nb)+$sb)*($latvecb->X);
		$ty = (($i/$na)+$sa)*($latveca->Y) + (($j/$nb)+$sb)*($latvecb->Y);
		
		printf "%02d/%02d\t%02d/%02d\t%14.7f\t%14.7f\t%14.7f\t%14.7f\n",  $i,$na,$j,$nb,$dlatlenga,$dlatlengb,$tx,$ty;

		# Output
		if ($writelevel ne "text")
		{
			# Copy xsd file and find target set
			$tempname = sprintf("%02d_%02d.xsd",$i,$j);
			$tempdoc = $xsddoc->SaveAs($tempname);
			$sets = $tempdoc->UnitCell->Sets;
			
			# Find target set & atoms
			foreach my $set (@$sets)
			{
				if ($set->Name eq $setname)
				{
					$setmove = $set;
				}
			}
			$atoms = $setmove->Atoms;
			
			# Translate target atoms
			$atoms->Translate(Point(X => $tx, Y => $ty, Z => 0));
			
			# Export or append file
			$xtddoc->Trajectory->AppendFramesFrom($tempdoc);
			$xtddoc->Save;
			
			$tempdoc->Save;
			if ($writelevel eq "xtd+xsd")
			{
				$tempdoc->Discard;
			} elsif ($writelevel eq "xtd")
			{
				$tempdoc->Delete;
			}
						
		}
		
		#Tools->Symmetry->FindSymmetry;
		
		undef $tempdoc;
	}
}
