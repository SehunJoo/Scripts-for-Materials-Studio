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
my ($CGMD_atomtypes, $CGMD_bondtypes, $CGMD_angletypes, $CGMD_dihedraltypes);
my $xsddoc = $Documents{$xsdname.".xsd"};
my $output_path = $output_directory_path."/data.".$xsdname;
open(output, ">".$output_path);

# routines
print "Input structure data from ","$xsdname",".xsd\n";
LMP_CGMD_N($xsddoc);
($CGMD_atomtypes, $CGMD_bondtypes, $CGMD_angletypes, $CGMD_dihedraltypes) = LMP_CGMD_Ntypes($xsddoc);

#print "@$AAMD_atomtypes","\n";
#print "@$AAMD_bondtypes","\n";
#print "@$AAMD_angletypes","\n";
#print "@$AAMD_dihedraltypes","\n";

LMP_CGMD_Lattice($xsddoc);
LMP_CGMD_AtomInfo($xsddoc, @$CGMD_atomtypes);
LMP_CGMD_BondInfo($xsddoc, @$CGMD_bondtypes);
LMP_CGMD_AngleInfo($xsddoc, @$CGMD_angletypes);
LMP_CGMD_DihedralInfo($xsddoc, @$CGMD_dihedraltypes);

close(output);


#======================================================================
# subroutines
#======================================================================

sub LMP_CGMD_N()
{
	my $doc = shift;

	my ($atoms, $natoms);
	my ($bonds, $nbonds);
	my ($attatoms, $nattatoms, $nangles);
	my ($nnbbonds1, $nnbbonds2, $ndihedrals);
	
	# The number of beads
	$atoms = $doc->UnitCell->Beads;
	$natoms = $atoms->Count;
	
	# The number of bonds
	$bonds = $doc->UnitCell->BeadConnectors;
	$nbonds = $bonds->Count;

	# The number of angles
	$nangles = 0;
	foreach my $atom (@$atoms)
	{
		$attatoms = $atom->AttachedBeads;
		$nattatoms = $attatoms->Count;
		if($nattatoms >= 2)
		{
			for(my $i=0; $i < $nattatoms; $i++)
			{
				for(my $j=$i+1; $j < $nattatoms; $j++)
				{
					$nangles++;
				}
			}
		}
	}
	
	# The number of dihedrals
	foreach my $bond (@$bonds)
	{
		$nnbbonds1 = $bond->Bead1->BeadConnectors->Count;
		$nnbbonds2 = $bond->Bead2->BeadConnectors->Count;
		if($nnbbonds1 >= 2 && $nnbbonds2 >=2)
		{
			$ndihedrals = $ndihedrals + (($nnbbonds1-1)*($nnbbonds2-1));
		}
		
	}
	
	printf output "%8d   %-15s\n",$natoms,"atoms";
	printf output "%8d   %-15s\n",$nbonds,"bonds";
	printf output "%8d   %-15s\n",$nangles,"angles";
	printf output "%8d   %-15s\n\n",$ndihedrals,"dihedrals";
	printf "%8d   %-15s\n",$natoms,"atoms";
	printf "%8d   %-15s\n",$nbonds,"bonds";
	printf "%8d   %-15s\n",$nangles,"angles";
	printf "%8d   %-15s\n\n",$ndihedrals,"dihedrals";
}

sub LMP_CGMD_Ntypes()
{
	my $doc = shift;

	###########################################################################
	# atom type                                                               #
	###########################################################################
	
	# variable declaration (6)
	my ($molecules, $i_molecule);
	my ($atoms, $i_atom, $atomtype, $natomtype);
	my (@atomtypes, @uniq_atomtypes);

	# initialization
	$i_atom = 0;
	$i_molecule = 0;
	
	# atom type
	# atom numbering (name, i_atom)
	# atom type (forcefieldtype)
	$molecules = $doc->UnitCell->Molecules;
	foreach my $molecule (@$molecules)
	{
		$atoms = $molecule->Beads;
		foreach my $atom (@$atoms)
		{
			$i_atom++;
			$atom->Name = "$i_atom";
			$atomtype = $atom->ForcefieldType;
			push (@atomtypes, $atomtype);
		}
		undef $atoms;
	}
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
	undef $molecules;
	undef $atoms;
	undef $atomtype;
	undef $natomtype;
	undef @atomtypes;
	# return @uniq_atomtype; Refer to last line of subroutine

    ###########################################################################
	# bond type                                                               #
	###########################################################################
	
	# variable declaration (8)
	my ($bonds, $i_bond, $bondtype, $nbondtypes);
	my ($batom1, $batom2, @batoms);
	my (@bondtypes, @uniq_bondtypes);
	
	# initialization
	$i_bond = 0;
	
	# bond type
	# bond numbering (name, i_bond)
	# bond type (atomtype1-atomtype2)
	$bonds = $doc->UnitCell->BeadConnectors;
	foreach my $bond (@$bonds)
	{
		$i_bond++;
		$bond->Name = "$i_bond";
		$batom1 = $bond->Bead1->ForcefieldType;
		$batom2 = $bond->Bead2->ForcefieldType;
		push (@batoms, $batom1);
		push (@batoms, $batom2);
		@batoms = sort @batoms;
		
		$bondtype = "$batoms[0]"."-"."$batoms[1]";
		push (@bondtypes, $bondtype);
		
		if(defined(@batoms))
		{
			undef @batoms;
		}
	}
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
	
	# make variables undefined (7)
	undef $bonds;
	undef $bondtype;
	undef $nbondtypes;
	undef $batom1;
	undef $batom2;
	undef @batoms;
	undef @bondtypes;
	# return @uniq_bondtypes; Refer to last line of subroutine

	###########################################################################
	# angle type                                                              #
	###########################################################################
	
	# variable declaration
	my ($atoms, $i_atom1, $i_atom2, $i_atom3, $attatoms, $nattatoms);
	my ($angletype, $nangletype); 
	my ($aatom1, $aatom2, $aatom3, @aatoms);
	my ($nangletypes, @angletypes, @uniq_angletypes);
	
	# angle type
	$atoms = $doc->UnitCell->Beads;
	foreach my $atom (@$atoms)
	{

		$attatoms = $atom->AttachedBeads;
		$nattatoms = $attatoms->Count;
		
		# Check existence of angles
		if($nattatoms >= 2)
		{
			$i_atom2 = $atom->Name;
			$aatom2 = $atom->ForcefieldType;
			
			for(my $i=0; $i < $nattatoms; $i++)
			{
				for(my $j=$i+1; $j < $nattatoms; $j++)
				{
					#$i_atom1 = $attatoms->Item[$i]->Name;
					#$i_atom3 = $attatoms->Item[$j]->Name;
					$aatom1 = $attatoms->Item($i)->ForcefieldType;
					$aatom3 = $attatoms->Item($j)->ForcefieldType;
					
					push (@aatoms, $aatom1);
					push (@aatoms, $aatom3);
					@aatoms = sort @aatoms;	
					$angletype = "$aatoms[0]"."-".$aatom2."-"."$aatoms[1]";
					push (@angletypes, $angletype);
					
					if(defined(@aatoms))
					{
						undef @aatoms;
					}
				}
			}
		}
	}
	@uniq_angletypes = uniq(@angletypes);
	@uniq_angletypes = sort @uniq_angletypes;
	$nangletypes = scalar(@uniq_angletypes);
	# print angle type
	printf output "%8d   %-15s\n\n",$nangletypes,"angle types";
	printf "%8d   %-15s\n\n",$nangletypes,"angle types";
	for(my $i=0; $i < $nangletypes; $i++)
	{
		printf output "# %d %s\n", $i+1, $uniq_angletypes[$i];
		printf "# %d %s\n", $i+1, $uniq_angletypes[$i];
	}
	printf output "\n";
	printf "\n";
	
	# make variables undefined
	undef $atoms;
	undef $i_atom1;
	undef $i_atom2;
	undef $i_atom3;
	undef $attatoms;
	undef $nattatoms;
	undef $angletype;
	undef $nangletypes;
	undef $aatom1;
	undef $aatom2;
	undef $aatom3;
	undef @aatoms;
	undef @angletypes;
	# return @uniq_angletypes; Refer to last line of subroutine	
	
	###########################################################################
	# dihedral type                                                           #
	###########################################################################
	
	# variable declaration
	my ($bonds, $i_bond1, $i_bond2, $i_bond3, $nnbbonds1, $nnbbonds2);
	my ($dihedraltype, $ndihedraltype); 
	my ($dbond1, $dbond3);
	my ($datom1, $datom2, $datom3, $datom4, @datoms14, @datoms23);
	my ($i_atom1, $i_atom2, $i_atom3, $i_atom4);
	my ($ndihedraltypes, @dihedraltypes, @uniq_dihedraltypes);
	
	# dihedral type
	$bonds = $doc->UnitCell->BeadConnectors;
	foreach my $bond (@$bonds)
	{
	
		$nnbbonds1 = $bond->Bead1->BeadConnectors->Count;
		$nnbbonds2 = $bond->Bead2->BeadConnectors->Count;
		
		# check existence of dihedrals
		if($nnbbonds1 >= 2 && $nnbbonds2 >=2)
		{
		
			$i_bond2 = $bond->Name;
			$i_atom2 = $bond->Bead1->Name;
			$i_atom3 = $bond->Bead2->Name;
			$datom2 = $bond->Bead1->ForcefieldType;
			$datom3 = $bond->Bead2->ForcefieldType;
			push (@datoms23, $datom2);
			push (@datoms23, $datom3);
			@datoms23 = sort @datoms23;
			
			for (my $i=0; $i < $nnbbonds1; $i++)
			{
				for (my $j=0; $j < $nnbbonds2; $j++)
				{
					$dbond1 = $bond->Bead1->BeadConnectors->Item($i);
					$dbond3 = $bond->Bead2->BeadConnectors->Item($j);
					$i_bond1 = $dbond1->Name;
					$i_bond3 = $dbond3->Name;
					if(($i_bond1 ne $i_bond2) && ($i_bond3 ne $i_bond2))
					{
						# find datom1
						$datom1 = $dbond1->Bead1->ForcefieldType;
						$i_atom1 = $dbond1->Bead1->Name;
						if($i_atom1 eq $i_atom2)
						{
							$datom1 = $dbond1->Bead2->ForcefieldType;
							$i_atom1 = $dbond1->Bead2->Name;
						}
						
						# find datom4
						$datom4 = $dbond3->Bead1->ForcefieldType;
						$i_atom4 = $dbond3->Bead1->Name;
						if($i_atom4 eq $i_atom3)
						{
							$datom4 = $dbond3->Bead2->ForcefieldType;
							$i_atom4 = $dbond3->Bead2->Name;
						}
						
						push (@datoms14, $datom1);
						push (@datoms14, $datom4);
						@datoms14 = sort @datoms14;
						
						$dihedraltype = "$datoms14[0]"."-"."$datoms23[0]"."-"."$datoms23[1]"."-"."$datoms14[1]";
						push (@dihedraltypes, $dihedraltype);
						
						if(defined(@datoms14))
						{
							undef @datoms14;
						}
					}
				}
			} # end neighboring bonds loop
		} 
		if(defined(@datoms23))
		{
			undef @datoms23;
		}
	} # end bonds loop
	@uniq_dihedraltypes = uniq(@dihedraltypes);
	@uniq_dihedraltypes = sort @uniq_dihedraltypes;
	$ndihedraltypes = scalar(@uniq_dihedraltypes);
	
	# print dihedral type
	printf output "%8d   %-15s\n\n",$ndihedraltypes,"dihedral types";
	printf "%8d   %-15s\n\n",$ndihedraltypes,"dihedral types";
	for(my $i=0; $i < $ndihedraltypes; $i++)
	{
		printf output "# %d %s\n", $i+1, $uniq_dihedraltypes[$i];
		printf "# %d %s\n", $i+1, $uniq_dihedraltypes[$i];
	}
	printf output "\n";
	printf "\n";
	
	return \(@uniq_atomtypes, @uniq_bondtypes, @uniq_angletypes, @uniq_dihedraltypes);
	
}

sub LMP_CGMD_Lattice()
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
	printf "%14.7f %14.7f %14.7f %10s\n\n",$bx,$cx,$cy,"xy xz yz";
	
	printf output "%14.7f %14.7f %10s\n",0,$ax,"xlo xhi";
	printf output "%14.7f %14.7f %10s\n",0,$by,"ylo yhi";
	printf output "%14.7f %14.7f %10s\n",0,$cz,"zlo zhi";
	printf output "%14.7f %14.7f %14.7f %10s\n\n",$bx,$cx,$cy,"xy xz yz";
}

sub LMP_CGMD_AtomInfo()
{
	# variable declaration (12)
	my $doc = shift;
	my @atomtypes = @_;
	my ($molecules, $atoms);
	my ($atomtype); # atom type (character)
	my ($i_atom, $i_molecule, $i_type, $q, $x, $y, $z); # index or id for print (number)
	
	# initialize variables
	$i_molecule = 0;
	$i_atom = 0;

	printf "\n\n\nAtoms\n\n";
	printf output "\n\n\nAtoms\n\n";
	
	# find and print atom informations
	$molecules = $doc->UnitCell->Molecules;
	foreach my $molecule (@$molecules)
	{
		$i_molecule++;
		$atoms = $molecule->Beads;
		foreach my $atom (@$atoms)
		{
			$i_atom++;
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
			if(!defined($i_type))
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
	} # end molecules loop

	print "\n# The number of molecules printed : $i_molecule molecules\n";
	print "# The number of atoms printed : $i_atom atoms\n";
	
	printf "\n\n";
	printf output "\n\n";

	# make variables undefined (12)
	undef $doc;
	undef @atomtypes;
	undef $molecules; undef $atoms;
	undef $atomtype;
	undef $i_atom; undef $i_molecule; undef $i_type; undef $q; undef $x; undef $y; undef $z;
}

sub LMP_CGMD_BondInfo()
{
	# variable declaration (11)
	my $doc = shift;
	my @bondtypes = @_;
	my ($bonds);
	my ($bondtype, $batom1, $batom2, @batoms); # bond & atom type (character)
	my ($i_bond, $i_type, $i_atom1, $i_atom2); # index or id for print (number)
	
	print "Bonds\n\n";
	print output "Bonds\n\n";
	
	# initialize variables
	$i_bond = 0;
	
	# find and print bonds
	$bonds = $doc->UnitCell->BeadConnectors;
	foreach my $bond (@$bonds)
	{
		$i_bond++;
		$i_atom1 = $bond->Bead1->Name;
		$i_atom2 = $bond->Bead2->Name;
		$batom1 = $bond->Bead1->ForcefieldType;
		$batom2 = $bond->Bead2->ForcefieldType;
		
		# check bond type
		push (@batoms, $batom1);
		push (@batoms, $batom2);
		@batoms = sort @batoms;
		$bondtype = "$batoms[0]"."-"."$batoms[1]";
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
		printf "%12d%12d%12d%12d\n", $i_bond, $i_type, $i_atom1, $i_atom2;
		printf output "%12d%12d%12d%12d\n", $i_bond, $i_type, $i_atom1, $i_atom2;
		
		undef $i_atom1; undef $i_atom2;
		undef $batom1; undef $batom2; undef @batoms;
		undef $bondtype; undef $i_type;
	} # end bonds loop

	printf "\n\n";
	printf output "\n\n";
		
	# make variables undefined (11)
	undef $doc;
	undef @bondtypes;
	undef $bonds; undef $bondtype;
	undef $i_bond; undef $i_type;
	undef $i_atom1; undef $i_atom2;
	undef $batom1; undef $batom2; undef @batoms;
}

sub LMP_CGMD_AngleInfo()
{
	# variable declaration (15)
	my $doc = shift;
	my @angletypes = @_;
	my ($atoms,  $attatoms, $nattatoms);
	my ($angletype, $aatom1, $aatom2, $aatom3, @aatoms); # angle & atom type (character)
	my ($i_angle, $i_type, $i_atom1, $i_atom2, $i_atom3); # index or id for print (number)

	print "Angles\n\n";	
	print output "Angles\n\n";
	
	# initialize variables
	$i_angle = 0;
	
	# find and print angle
	$atoms = $doc->UnitCell->Beads;
	foreach my $atom (@$atoms)
	{
		$attatoms = $atom->AttachedBeads;
		$nattatoms = $attatoms->Count;
		
		# Check existence of angles
		if($nattatoms >= 2)
		{
			$i_atom2 = $atom->Name;
			$aatom2 = $atom->ForcefieldType;
			# attached atoms loop
			for(my $i=0; $i < $nattatoms; $i++)
			{
				for(my $j=$i+1; $j < $nattatoms; $j++)
				{
					$i_angle++;
					$i_atom1 = $attatoms->Item($i)->Name;
					$i_atom3 = $attatoms->Item($j)->Name;
					$aatom1 = $attatoms->Item($i)->ForcefieldType;
					$aatom3 = $attatoms->Item($j)->ForcefieldType;
					
					# check angle type
					push (@aatoms, $aatom1);
					push (@aatoms, $aatom3);
					@aatoms = sort @aatoms;	
					$angletype = "$aatoms[0]"."-"."$aatom2"."-"."$aatoms[1]";
					for (my $i=0; $i < scalar(@angletypes); $i++)
					{
						if (@angletypes[$i] eq $angletype)
						{
							$i_type = $i+1;
						}
					}
					if(!defined($i_type))
					{
						die("Angle type is incorrect!\n");
					}			
					
					# print angle list
					printf "%12d%12d%12d%12d%12d\n", $i_angle, $i_type, $i_atom1, $i_atom2, $i_atom3;
					printf output "%12d%12d%12d%12d%12d\n", $i_angle, $i_type, $i_atom1, $i_atom2, $i_atom3;
					
					undef $i_atom1; undef $i_atom3; 
					undef $angletype; undef $aatom1; undef $aatom3; undef @aatoms;
					undef $i_type;
				}
			} # end attached atoms loop
			undef $i_atom2;
			undef $aatom2;
		}
		undef $attatoms; undef $nattatoms;
	} # end atoms loop
	
	printf "\n\n";
	printf output "\n\n";
		
	# make variables undefined (15)
	undef $doc;
	undef @angletypes;
	undef $atoms; undef $attatoms; undef $nattatoms;
	undef $angletype; undef $aatom1; undef $aatom2; undef $aatom3; undef @aatoms; 
	undef $i_angle; undef $i_type; undef $i_atom1; undef $i_atom2; undef $i_atom3;
}

sub LMP_CGMD_DihedralInfo()
{
	# variable declaration (23)
	my $doc = shift;
	my @dihedraltypes = @_;
	my ($bonds, $nnbbonds1, $nnbbonds2, $dbond1, $dbond3);
	my ($i_bond1, $i_bond2, $i_bond3); # index or id for bonds
	my ($dihedraltype, $datom1, $datom2, $datom3, $datom4, @datoms14, @datoms23); # dihedral & atom type (character)
	my ($i_dihedral, $i_type, $i_atom1, $i_atom2, $i_atom3, $i_atom4); # index or id for print (number)

	print "Dihedrals\n\n";
	print output "Dihedrals\n\n";
	
	# initialize variables
	$i_dihedral = 0;
	
	# find and print dihedrals
	$bonds = $doc->UnitCell->BeadConnectors;
	foreach my $bond (@$bonds)
	{
		$nnbbonds1 = $bond->Bead1->BeadConnectors->Count;
		$nnbbonds2 = $bond->Bead2->BeadConnectors->Count;
		
		# check existence of dihedrals
		if($nnbbonds1 >= 2 && $nnbbonds2 >=2)
		{
			$i_bond2 = $bond->Name;
			$i_atom2 = $bond->Bead1->Name;
			$i_atom3 = $bond->Bead2->Name;
			$datom2 = $bond->Bead1->ForcefieldType;
			$datom3 = $bond->Bead2->ForcefieldType;
			push (@datoms23, $datom2);
			push (@datoms23, $datom3);
			@datoms23 = sort @datoms23;
			
			for (my $i=0; $i < $nnbbonds1; $i++)
			{
				for (my $j=0; $j < $nnbbonds2; $j++)
				{
					$dbond1 = $bond->Bead1->BeadConnectors->Item($i);
					$dbond3 = $bond->Bead2->BeadConnectors->Item($j);
					$i_bond1 = $dbond1->Name;
					$i_bond3 = $dbond3->Name;
					if(($i_bond1 ne $i_bond2) && ($i_bond3 ne $i_bond2))
					{
						$i_dihedral++;
						# find datom1
						$datom1 = $dbond1->Bead1->ForcefieldType;
						$i_atom1 = $dbond1->Bead1->Name;
						if($i_atom1 eq $i_atom2)
						{
							$datom1 = $dbond1->Bead2->ForcefieldType;
							$i_atom1 = $dbond1->Bead2->Name;
						}
						
						# find datom4
						$datom4 = $dbond3->Bead1->ForcefieldType;
						$i_atom4 = $dbond3->Bead1->Name;
						if($i_atom4 eq $i_atom3)
						{
							$datom4 = $dbond3->Bead2->ForcefieldType;
							$i_atom4 = $dbond3->Bead2->Name;
						}
						
						push (@datoms14, $datom1);
						push (@datoms14, $datom4);
						@datoms14 = sort @datoms14;
						
						$dihedraltype = "$datoms14[0]"."-"."$datoms23[0]"."-"."$datoms23[1]"."-"."$datoms14[1]";
						for (my $i=0; $i < scalar(@dihedraltypes); $i++)
						{
							if (@dihedraltypes[$i] eq $dihedraltype)
							{
								$i_type = $i+1;
							}
						}
						if(!defined($i_type))
						{
							die("Dihedral type is incorrect!\n");
						}
						
						# print dihedral list
						printf "%12d%12d%12d%12d%12d%12d\n", $i_dihedral, $i_type, $i_atom1, $i_atom2, $i_atom3, $i_atom4;
						printf output "%12d%12d%12d%12d%12d%12d\n", $i_dihedral, $i_type, $i_atom1, $i_atom2, $i_atom3, $i_atom4;
					}
					undef $dbond1; undef $dbond3;
					undef $i_bond1; undef $i_bond3;
					undef $dihedraltype; undef $datom1; undef $datom4; undef @datoms14;
					undef $i_type; undef $i_atom1; undef $i_atom4;
				}
			} # end neighbouring bonds loop
		} 
		undef $nnbbonds1; undef $nnbbonds2; undef $i_bond2;
		undef $datom2; undef $datom3; undef @datoms23;
		undef $i_atom2; undef $i_atom3;
	} # end bonds loop

	printf "\n\n";
	printf output "\n\n";
		
	# make variables undefined (23)	
	undef $doc;
	undef @dihedraltypes;
	undef $bonds; undef $nnbbonds1; undef $nnbbonds2; undef $dbond1; undef $dbond3;
	undef $i_bond1; undef $i_bond2; undef $i_bond3;
	undef $dihedraltype; undef $datom1; undef $datom2; undef $datom3; undef $datom4; undef @datoms14; undef @datoms23;
	undef $i_dihedral; undef $i_type; undef $i_atom1; undef $i_atom2; undef $i_atom3; undef $i_atom4;
}

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
