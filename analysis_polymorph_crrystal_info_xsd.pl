#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xsdname = "PI-COF";
my $xsddoc = $Documents{$xsdname.".xsd"};


	printf "%s\t", $xsddoc->Lattice3D->SpaceGroupCrystalSystem;		# Triclinic
	printf "%s\t", $xsddoc->Lattice3D->SpaceGroupCrystalClass;		# 2/m
	printf "%s\t", $xsddoc->Lattice3D->GroupName;					# P21/C
	printf "%s\t", $xsddoc->Lattice3D->SpaceGroupSchoenfliesName;	# C2H-6
	printf "%.2f\t", $xsddoc->Lattice3D->LengthA;					# lattice parameter 
	printf "%.2f\t", $xsddoc->Lattice3D->LengthB;					# lattice parameter
	printf "%.2f\t", $xsddoc->Lattice3D->LengthC;					# lattice parameter
	printf "%.2f\t", $xsddoc->Lattice3D->AngleAlpha;				# lattice parameter
	printf "%.2f\t", $xsddoc->Lattice3D->AngleBeta;					# lattice parameter
	printf "%.2f\t", $xsddoc->Lattice3D->AngleGamma;				# lattice parameter
#	printf "%.2f\t", $xsddoc->UnitCell->Molecules->count;			# number of asymmetric unit
	printf "%s\t", $xsddoc->SymmetrySystem->CellFormula;			# cell formula
	printf "%.2f\t", $xsddoc->SymmetrySystem->Density;				# density (g/cc)
#	printf "%.5f\t", $xsddoc->PotentialEnergy/($xsddoc->UnitCell->Molecules->count);		# Potential energy 
#	printf "%.5f\t", $xsddoc->VanDerWaalsEnergy/($xsddoc->UnitCell->Molecules->count);		# van der Waals energy
#	printf "%.5f\t", $xsddoc->ElectrostaticEnergy/($xsddoc->UnitCell->Molecules->count);	# electrostatic energy	
	printf "\n";


