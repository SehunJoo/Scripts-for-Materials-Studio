#*************************************************************************************
#*                                                                                   *
#*	This script convert MS xsd document to LAMMPS input for All-Atom MD simulation   *
#*                                                                                   *
#*  Assumption : 1. No Improper torsion interaction                                  *
#*               2. atom_style : full                                                *
#*                                                                                   *
#*	Requirements : Forcefield type of each atom should be set first,                 *
#*                 because atom types are classified according to forcefield type.   *
#*                                                                                   *
#*	version  : 1.0                                                                   *
#*	Author   : Sehun Joo                                                             *
#*	Date     : 07.06.2015                                                            *
#*                                                                                   *
#*************************************************************************************

#!perl
use strict;
use MaterialsScript qw(:all);
use Math::Trig;
#======================================================================
# user input
#======================================================================

my $xsdname = "ethane";
my $output_directory_path = "C:/Users/shjoo/Desktop";
# ex) C:/Users/shjoo/Desktop/lammps


#======================================================================
# main
#======================================================================

# variable declaration
my (@AAMD_atomtypes);
my $xsddoc = $Documents{$xsdname.".xsd"};
my $output_path = $output_directory_path."/data.".$xsdname;
open(output, ">".$output_path);

# routines
print "Input structure data from ","$xsdname",".xsd\n";
LMP_AAMD_N($xsddoc);
(@AAMD_atomtypes) = LMP_AAMD_Ntypes($xsddoc);

#print "@$AAMD_atomtypes","\n";

LMP_AAMD_Lattice($xsddoc);
LMP_AAMD_AtomInfo($xsddoc, @AAMD_atomtypes);

close(output);

#======================================================================
# subroutines
#======================================================================

sub LMP_AAMD_N()
{
	my $doc = shift;
	my ($atoms, $natoms);
	
	printf "\n";
	printf output "\n";
	
	# The number of atoms
	$atoms = $doc->UnitCell->Atoms;
	$natoms = $atoms->Count;
	
	printf output "%8d   %-15s\n",$natoms,"atoms";
	printf "%8d   %-15s\n",$natoms,"atoms";
}

sub LMP_AAMD_Ntypes()
{
	my $doc = shift;
	
	###########################################################################
	# atom type                                                               #
	###########################################################################
	
	# variable declaration (6)
	my ($atoms, $i_atom);
	my ($atomtype, $natomtype, @atomtypes, @uniq_atomtypes);
	
	# initialization
	$i_atom = 0;
	
	# atom type
	# atom numbering (name, i_atom)
	# atom type (forcefieldtype)

	$atoms = $doc->UnitCell->Atoms;
	foreach my $atom (@$atoms)
	{
		$i_atom++;
		$atom->Name = "$i_atom";
		$atomtype = $atom->ForcefieldType;
		push (@atomtypes, $atomtype);
	}
	undef $atoms;

	@uniq_atomtypes = uniq(@atomtypes);
	@uniq_atomtypes = sort @uniq_atomtypes;
	$natomtype = scalar(@uniq_atomtypes);

	# print atom type
	printf output "%8d   %-15s\n\n",$natomtype,"atom types";
	printf "%8d   %-15s\n\n",$natomtype,"atom types";
	for(my $i=0; $i < $natomtype; $i++)
	{
		printf output "# %d %s\n", $i+1, $uniq_atomtypes[$i];
		printf "# %d %s\n", $i+1, $uniq_atomtypes[$i];
	}
	printf output "\n";
	printf "\n";
	
	# make variables undefined (5)
	undef $atoms; undef $i_atom;
	undef $atomtype; undef $natomtype; undef @atomtypes;
	# return @uniq_atomtype; Refer to last line of subroutine
	
	return (@uniq_atomtypes);
}

sub LMP_AAMD_Lattice()
{
	my $doc = shift;
	
	# A, B, C, Alpha, Beta, Gamma lattice constants in MS
	my ($boxlengx, $boxlengy, $boxlengz);	
	my ($alpha, $beta, $gamma);
	
	# components of cell matrix
	my ($ax, $bx, $by, $cx, $cy, $cz);
	
	
	$boxlengx = $doc->Lattice3D->LengthA;
	$boxlengy = $doc->Lattice3D->LengthB;
	$boxlengz = $doc->Lattice3D->LengthC;
	$alpha = $doc->Lattice3D->AngleAlpha;
	$beta = $doc->Lattice3D->AngleBeta;
	$gamma = $doc->Lattice3D->AngleGamma;
	
	$ax = $boxlengx;
	$bx = $boxlengy*cos(deg2rad($gamma));
	$by = $boxlengy*sin(deg2rad($gamma));
	$cx = $boxlengz*cos(deg2rad($beta));
	$cy = (($bx*$cx+$by*$cy)-($bx*$cx))/$by;
	$cz = sqrt($boxlengz*$boxlengz-$cx*$cx-$cy*$cy);
	
	printf "%14.7f %14.7f %10s\n",0,$ax,"xlo xhi";
	printf "%14.7f %14.7f %10s\n",0,$by,"ylo yhi";
	printf "%14.7f %14.7f %10s\n",0,$cz,"zlo zhi";
#	printf "%14.7f %14.7f %14.7f %10s\n\n",$bx,$cx,$cy,"xy xz yz";
	
	printf output "%14.7f %14.7f %10s\n",0,$ax,"xlo xhi";
	printf output "%14.7f %14.7f %10s\n",0,$by,"ylo yhi";
	printf output "%14.7f %14.7f %10s\n",0,$cz,"zlo zhi";
#	printf output "%14.7f %14.7f %14.7f %10s\n\n",$bx,$cx,$cy,"xy xz yz";
}

sub LMP_AAMD_AtomInfo()
{
	# variable declaration (14)
	my $doc = shift;
	my @atomtypes = @_;
	my ($atoms);
	my ($atomtype); # atom type (character)
	my ($i_atom, $i_molecule);
    my ($i_type, $q, $x, $y, $z); # index or id for print (number)
	
	# initialize variables
	$i_molecule = 0;
	$i_atom = 0;

	printf "\n\n\nAtoms\n\n";
	printf output "\n\n\nAtoms\n\n";
	
	# find and print atom informations
	$atoms = $doc->UnitCell->Atoms;
	foreach my $atom (@$atoms)
	{
		$i_atom = $atom->Name;
		$i_molecule = $i_atom;
		
		$atomtype = $atom->ForcefieldType;
		
		# check atom type
		$i_type = 0;
		for(my $i = 0; $i < scalar(@atomtypes); $i++)
		{
			if($atomtype eq $atomtypes[$i])
			{
				$i_type = $i+1;
			}
		}
		if(!(defined($i_type)))
		{
			die("Atom type is incorrect!\n");
		}

		$q = $atom->Charge;
		$x = $atom->X;
		$y = $atom->Y;
		$z = $atom->Z;
		
		# print atom information
		printf "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom, $i_molecule, $i_type, $q, $x, $y, $z;
		printf output "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom, $i_molecule, $i_type, $q, $x, $y, $z;
		
		undef $atomtype;
		undef $i_type; undef $q; undef $x; undef $y; undef $z;
	} # end atoms loop
	undef $atoms;

	printf "\n\n";
	printf output "\n\n";

	# make variables undefined (14)
	undef $doc;
	undef @atomtypes;
	undef $atoms;
	undef $atomtype;
	undef $i_atom; undef $i_molecule; 
	undef $i_type; undef $q; undef $x; undef $y; undef $z;
}


sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
