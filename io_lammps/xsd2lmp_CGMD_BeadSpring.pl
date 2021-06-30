#*********************************************************************************
#*
#*	This script convert MS xsd document to LAMMPS input for bead-spring simulation
#*		
#*
#*	version  : 1.0
#*	Author   : Sehun Joo
#*	Date     : 03.31.2015
#*
#*********************************************************************************

#!perl
use strict;
use MaterialsScript qw(:all);


#======================================================================
# main
#======================================================================

my $xsdname;
my (@BS_atomtype, @BS_bondtype);
$xsdname = "H16_6552bds";
my $xsddoc = $Documents{$xsdname.".xsd"};
open(output, ">C:/Users/shjoo/Desktop/lmp_joob/data".$xsdname);

LMP_BS_N($xsddoc);
(@BS_atomtype) = LMP_BS_Ntypes($xsddoc);
LMP_BS_Lattice($xsddoc);
print "\nprint atom information\n\n";
LMP_BS_Atominfo($xsddoc, @BS_atomtype);
print "\nprint bond information\n\n";
LMP_BS_Bondinfo($xsddoc);


close(output);


#======================================================================
# subroutines
#======================================================================

sub LMP_BS_N()
{
	my $doc = shift;
	
	my $atoms = $doc->UnitCell->Beads;
	my $natom = $atoms->Count;
	my $bonds = $doc->UnitCell->BeadConnectors;
	my $nbond = $bonds->Count;
	
	printf output "\n%8d   %-15s\n\n",$natom,"atoms";
	printf output "\n%8d   %-15s\n\n",$nbond,"bonds";
	printf "%8d   %-15s\n",$natom,"atoms";
	printf "%8d   %-15s\n",$nbond,"bonds";	
}

sub LMP_BS_Ntypes()
{
	my $doc = shift;
	
	my ($atoms, $atomtype, $natomtype);
	my (@atomtypes, @uniq_atomtypes);
	my ($bonds, $bondtype, $nbondtype);
	my (@bondtypes, @uniq_bondtypes);
	
	# atom type
	$atoms = $doc->UnitCell->Beads;
	foreach my $atom (@$atoms)
	{
		$atomtype = $atom->BeadTypeName;
		push (@atomtypes, $atomtype);
	}
	@uniq_atomtypes = uniq(@atomtypes);
	@uniq_atomtypes = sort @uniq_atomtypes;
	
	# print atom type
	printf output "%8d   %-15s\n\n",scalar(@uniq_atomtypes),"atom types";
	printf "%8d   %-15s\n",scalar(@uniq_atomtypes),"atom types";
	
	for(my $i=0; $i < scalar(@uniq_atomtypes); $i++)
	{
		printf output "# %d %s\n", $i+1, $uniq_atomtypes[$i];
	}
	printf output "\n";

	# print bond type
	printf output "%8d   %-15s\n\n",1,"bond types";
	printf "%8d   %-15s\n",1,"bond types";

	
	return @uniq_atomtypes;
	
}

sub LMP_BS_Lattice()
{
	my $doc = shift;
	
	my ($boxlengx, $boxlengy, $boxlengz);	

	
	$boxlengx = $doc->Lattice3D->LengthA;
	$boxlengy = $doc->Lattice3D->LengthB;
	$boxlengz = $doc->Lattice3D->LengthC;
	
	printf output "%14.7f %14.7f %10s\n",0,$boxlengx,"xlo xhi";
	printf output "%14.7f %14.7f %10s\n",0,$boxlengy,"ylo yhi";
	printf output "%14.7f %14.7f %10s\n\n",0,$boxlengz,"zlo zhi";

}

sub LMP_BS_Atominfo()
{
	my $doc = shift;
	my @atomtypes = @_;
	
	
	my ($molecules, $atoms);
	my ($atomtype, $x, $y, $z);
	my ($i_molecule, $i_atom, $i_type);
	
	# initialize variables
	$i_molecule = 0;
	$i_atom = 0;

	printf output "Atoms\n\n";
	$molecules = $doc->UnitCell->Molecules;
	foreach my $molecule (@$molecules)
	{
		$i_molecule++;
		$atoms = $molecule->Beads;
		foreach my $atom (@$atoms)
		{
			$i_atom++;
			$atom->Name = "$i_atom";
			$atomtype = $atom->BeadTypeName;
			
			# check atomtype
			$i_type = 0;
			for(my $i = 0; $i < scalar(@atomtypes); $i++)
			{
				if($atomtype eq $atomtypes[$i])
				{
					$i_type = $i+1;
				}
				
			}
			if ($i_type == 0) {
				print "Error! bead type is wrong!\n";
			}
	
			$x = $atom->X;
			$y = $atom->Y;
			$z = $atom->Z;
			
			# print atom information
			printf output "%12d%12d%12d %14.7f %14.7f %14.7f\n", $i_atom, $i_molecule, $i_type, $x, $y, $z;
			
		}
	}
	print "The number of molecules printed : $i_molecule molecules\n";
	print "The number of atoms printed : $i_atom atoms\n";
}

sub LMP_BS_Bondinfo()
{
	my $doc = shift;
	my ($bonds);
	my ($i_bond, $i_type);
	my ($atom1, $atom2);
	
	# initialize variables
	$i_bond = 0;
	$i_type = 1;
	$bonds = $doc->UnitCell->BeadConnectors;

	print output "\n\nBonds\n\n";
	foreach my $bond (@$bonds)
	{
		$i_bond++;
		$atom1 = $bond->Bead1->Name;
		$atom2 = $bond->Bead2->Name;

		printf output "%12d%12d%12d%12d\n", $i_bond, $i_type, $atom1, $atom2;
		
	}
	print "The number of bonds printed : $i_bond bondss\n";
}


sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
