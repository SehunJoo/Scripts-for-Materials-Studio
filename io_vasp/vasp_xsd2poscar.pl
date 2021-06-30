#*************************************************************************************
#*                                                                                   *
#*	This script convert MS xsd document to POSCAR for VASP                           *
#*                                                                                   *
#*                                                                                   *
#*	version  : 1.0                                                                   *
#*	Author   : Se Hun Joo                                                            *
#*	Date     : 12.14.2016                                                            *
#*                                                                                   *
#*************************************************************************************

#!perl
use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

#======================================================================
# user input
#======================================================================

my $xsdname = "model";
my $doc = $Documents{$xsdname.".xsd"};
my $coordinate = "Direct"; # "Direct" or "Cartesian"

# 고정하고 싶은 원자의 이름은 Fix로 설정

#======================================================================
# main
#======================================================================

my $atoms = $doc->UnitCell->Atoms;
my $vectorA = $doc->Lattice3D->VectorA;
my $vectorB = $doc->Lattice3D->VectorB;
my $vectorC = $doc->Lattice3D->VectorC;

printf "%s\n", $xsdname;
printf "   1.00000000000000\n";
printf "  %21.16f %21.16f %21.16f\n", $vectorA->X,$vectorA->Y,$vectorA->Z;
printf "  %21.16f %21.16f %21.16f\n", $vectorB->X,$vectorB->Y,$vectorB->Z;
printf "  %21.16f %21.16f %21.16f\n", $vectorC->X,$vectorC->Y,$vectorC->Z;

	# variable declaration (6)

	my ($i_atom, $atomtype, $natomtype);
	my (@atomtypes, @uniq_atomtypes);
	
	
# atom type
# atom type (ElementSymbol)

foreach my $atom (@$atoms)
{
	$atomtype = $atom->ElementSymbol;
	push (@atomtypes, $atomtype);
}
@uniq_atomtypes = uniq(@atomtypes);
@uniq_atomtypes = sort @uniq_atomtypes;
$natomtype = scalar(@uniq_atomtypes);
	
# Element
for(my $i=0; $i < $natomtype; $i++)
{
	printf "   %-2s", @uniq_atomtypes[$i];
	if ($i == $natomtype-1) {printf "\n"};
}

# Number of element
for(my $i=0; $i < $natomtype; $i++)
{
	$i_atom = 0;
	foreach my $atom (@$atoms)
	{
		if (@uniq_atomtypes[$i] eq $atom->ElementSymbol)
		{
			$i_atom++;
		}
	}
	printf "%6d",$i_atom;
	if ($i == $natomtype-1) {printf "\n"};
}

# Print out coordinate of each atom
printf "%s\n", "Selective dynamics";
printf "%s\n", $coordinate;
for(my $i=0; $i < $natomtype; $i++)
{
	$i_atom = 0;
	foreach my $atom (@$atoms)
	{
		if (@uniq_atomtypes[$i] eq $atom->ElementSymbol)
		{
			if ($coordinate eq "Direct")
			{
				printf " %20.16f %20.16f %20.16f ", $atom->FractionalXYZ->X,$atom->FractionalXYZ->Y,$atom->FractionalXYZ->Z;
			} elsif ($coordinate eq "Cartesian")
			{
				printf " %20.16f %20.16f %20.16f ", $atom->X,$atom->Y,$atom->Z;
			}
			
			if ($atom->Name eq "Fix")
			{
				printf "%s ", "F F F";
			} elsif ($atom->Name eq "Fix_z")
			{
				printf "%s ", "T T F";
			} else
			{
				printf "%s ", "T T T";
			}
			printf "#%3.0f\n", $atom->FormalSpin;

		}
	}
}
	

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
