#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xtdname = "4F-cHBC P-1";
my $xtddoc = $Documents{$xtdname.".xtd"};
my $trajectory = $xtddoc->Trajectory;
my $xsdname_out;

for (my $i=1; $i<=10; ++$i)
{
	$trajectory->CurrentFrame = $i;
	printf "%s\t", $i;												# Rank
	printf "%s\t", $xtddoc->Lattice3D->SpaceGroupCrystalSystem;		# Triclinic
	printf "%s\t", $xtddoc->Lattice3D->SpaceGroupCrystalClass;		# 2/m
	printf "%s\t", $xtddoc->Lattice3D->GroupName;					# P21/C
	printf "%s\t", $xtddoc->Lattice3D->SpaceGroupSchoenfliesName;	# C2H-6
	printf "%.2f\t", $xtddoc->Lattice3D->LengthA;					# lattice parameter 
	printf "%.2f\t", $xtddoc->Lattice3D->LengthB;					# lattice parameter
	printf "%.2f\t", $xtddoc->Lattice3D->LengthC;					# lattice parameter
	printf "%.2f\t", $xtddoc->Lattice3D->AngleAlpha;				# lattice parameter
	printf "%.2f\t", $xtddoc->Lattice3D->AngleBeta;					# lattice parameter
	printf "%.2f\t", $xtddoc->Lattice3D->AngleGamma;				# lattice parameter
	printf "%.2f\t", $xtddoc->UnitCell->Molecules->count;			# number of asymmetric unit
	printf "%s\t", $xtddoc->SymmetrySystem->CellFormula;			# cell formula
	printf "%.2f\t", $xtddoc->SymmetrySystem->Density;				# density (g/cc)
	printf "%.5f\t", $xtddoc->PotentialEnergy/($xtddoc->UnitCell->Molecules->count);		# Potential energy 
	printf "%.5f\t", $xtddoc->VanDerWaalsEnergy/($xtddoc->UnitCell->Molecules->count);		# van der Waals energy
	printf "%.5f\t", $xtddoc->ElectrostaticEnergy/($xtddoc->UnitCell->Molecules->count);	# electrostatic energy	
	printf "\n";
}


