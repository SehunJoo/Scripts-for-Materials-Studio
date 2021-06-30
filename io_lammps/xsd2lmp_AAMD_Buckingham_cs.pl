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
my ($AAMD_atomtypes, $AAMD_bondtypes);
my $xsddoc = $Documents{$xsdname.".xsd"};
my $output_path = $output_directory_path."/data.".$xsdname;
open(output, ">".$output_path);

# routines
print "Input structure data from ","$xsdname",".xsd\n";
LMP_AAMD_N($xsddoc);
($AAMD_atomtypes, $AAMD_bondtypes) = LMP_AAMD_Ntypes($xsddoc);

#print "@$AAMD_atomtypes","\n";
#print "@$AAMD_bondtypes","\n";

LMP_AAMD_Lattice($xsddoc);
LMP_AAMD_AtomInfo($xsddoc, @$AAMD_atomtypes);
LMP_AAMD_BondInfo($xsddoc, @$AAMD_bondtypes);

close(output);

#======================================================================
# subroutines
#======================================================================

sub LMP_AAMD_N()
{
	my $doc = shift;
	my ($atoms, $natoms);
	my ($nbonds);
	
	printf "\n";
	printf output "\n";
	
	# The number of atoms
	$atoms = $doc->UnitCell->Atoms;
	$natoms = $atoms->Count;
	$natoms = 2 * $natoms;
	
	# The number of bonds
	$nbonds = $natoms / 2;
	
	printf output "%8d   %-15s\n",$natoms,"atoms";
	printf output "%8d   %-15s\n",$nbonds,"bonds";
	printf "%8d   %-15s\n",$natoms,"atoms";
	printf "%8d   %-15s\n",$nbonds,"bonds";
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
		push (@atomtypes, $atomtype."_core");
		push (@atomtypes, $atomtype."_shell");	
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
	
    ###########################################################################
	# bond type                                                               #
	###########################################################################
	
	# variable declaration (6)
	my ($atoms, $atomtype);
	my ($bondtype, $nbondtypes, @bondtypes, @uniq_bondtypes);
	
	# initialization
	
	# bond type
	# bond numbering (name, i_bond)
	# bond type (atomtype1-atomtype2)
	$atoms = $doc->UnitCell->Atoms;
	foreach my $atom (@$atoms)
	{
		$atomtype = $atom->ForcefieldType;
		$bondtype = $atomtype."_core"."-".$atomtype."_shell";
		push (@bondtypes, $bondtype);	
	}
	undef $atoms;
	@uniq_bondtypes = uniq(@bondtypes);
	@uniq_bondtypes = sort @uniq_bondtypes;
	$nbondtypes = scalar(@uniq_bondtypes);
	
	# print bond type
	printf output "%8d   %-15s\n\n",$nbondtypes,"bond types";
	printf "%8d   %-15s\n\n",$nbondtypes,"bond types";	
	for(my $i=0; $i < $nbondtypes; $i++)
	{
		printf output "# %d %s\n", $i+1, $uniq_bondtypes[$i];
		printf "# %d %s\n", $i+1, $uniq_bondtypes[$i];
	}
	printf output "\n";
	printf "\n";
	
	# make variables undefined (5)
	undef $atoms; undef $atomtype;
	undef $bondtype; undef $nbondtypes; undef @bondtypes;
	# return @uniq_bondtypes; Refer to last line of subroutine	

	
	return \(@uniq_atomtypes, @uniq_bondtypes);
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
	my ($i_atom, $i_atom_core, $i_atom_shell, $i_molecule);
    my ($i_type, $i_type_core, $i_type_shell, $q, $x, $y, $z); # index or id for print (number)
	
	# initialize variables
	$i_molecule = 0;
	$i_atom = 0;

	printf "\n\n\nAtoms\n\n";
	printf output "\n\n\nAtoms\n\n";
	
	# find and print atom informations
	$atoms = $doc->UnitCell->Atoms;
	foreach my $atom (@$atoms)
	{
		$i_atom++;
		$i_molecule++;
		$i_atom_core = 2*$i_atom - 1;
		$i_atom_shell = 2*$i_atom;
		
		$atomtype = $atom->ForcefieldType;
		
		# check atom type
		$i_type = 0;
		for(my $i = 0; $i < scalar(@atomtypes); $i++)
		{
			if($atomtype."_core" eq $atomtypes[$i])
			{
				$i_type_core = $i+1;
			}
			if($atomtype."_shell" eq $atomtypes[$i])
			{
				$i_type_shell = $i+1;
			}				
		}
		if(!(defined($i_type_core)) || !defined($i_type_shell))
		{
			die("Atom type is incorrect!\n");
		}

		$q = $atom->Charge;
		$x = $atom->X;
		$y = $atom->Y;
		$z = $atom->Z;
		
		# print atom information
		printf "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom_core, $i_molecule, $i_type_core, $q, $x, $y, $z;
		printf "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom_shell, $i_molecule, $i_type_shell, $q, $x, $y, $z;
		printf output "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom_core, $i_molecule, $i_type_core, $q, $x, $y, $z;
		printf output "%12d%12d%12d %14.7f %14.7f %14.7f %14.7f\n", $i_atom_shell, $i_molecule, $i_type_shell, $q, $x, $y, $z;
		
		undef $atomtype;
		undef $i_type_core; undef $i_type_shell; undef $q; undef $x; undef $y; undef $z;
	} # end atoms loop
	undef $atoms;

	printf "\n\n";
	printf output "\n\n";

	# make variables undefined (14)
	undef $doc;
	undef @atomtypes;
	undef $atoms;
	undef $atomtype;
	undef $i_atom; undef $i_atom_core; undef $i_atom_shell; undef $i_molecule; 
	undef $i_type_core; undef $i_type_shell; undef $q; undef $x; undef $y; undef $z;
}

sub LMP_AAMD_BondInfo()
{
	# variable declaration (11)
	my $doc = shift;
	my @bondtypes = @_;
	my ($atoms);
	my ($atomtype, $bondtype); # bond & atom type (character)
	my ($i_bond, $i_type, $i_atom, $i_atom_core, $i_atom_shell); # index or id for print (number)
	
	print "Bonds\n\n";
	print output "Bonds\n\n";
	
	# initialize variables
	$i_bond = 0;
	
	# find and print bonds
	$atoms = $doc->UnitCell->Atoms;
	foreach my $atom (@$atoms)
	{
		$i_bond++;
		$i_atom = $atom->Name;
		$i_atom_core = 2*$i_atom - 1;
		$i_atom_shell = 2*$i_atom;

		
		# check bond type
		$atomtype = $atom->ForcefieldType;
		$bondtype = $atomtype."_core"."-".$atomtype."_shell";
		
		for (my $i=0; $i < scalar(@bondtypes); $i++)
		{
			if (@bondtypes[$i] eq $bondtype)
			{
				$i_type = $i+1;
			}
		} # end bondtypes loop
		if(!defined($i_type))
		{
			die("Bond type is incorrect!\n");
		}
		
		# print bond list
		printf "%12d%12d%12d%12d\n", $i_bond, $i_type, $i_atom_core, $i_atom_shell;
		printf output "%12d%12d%12d%12d\n", $i_bond, $i_type, $i_atom_core, $i_atom_shell;
		
		undef $i_atom_core; undef $i_atom_shell;
		undef $bondtype; undef $i_type;
	} # end bonds loop

	printf "\n\n";
	printf output "\n\n";
		
	# make variables undefined (11)
	undef $doc;
	undef @bondtypes;
	undef $atoms; undef $bondtype;
	undef $i_atom; undef  $i_bond; undef $i_type;
	undef $i_atom_core; undef $i_atom_shell;
}


sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
