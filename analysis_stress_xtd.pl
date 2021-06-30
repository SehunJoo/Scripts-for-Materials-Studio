#*********************************************************************************
#*
#*	extract stress data of simulation results
#*		
#*
#*
#*	Author	: Sehun Joo
#*	Date	: 09.18.2014
#*
#*********************************************************************************
#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $trjdoc = $Documents{"animation.xtd"};
my $frameoutevery = 100*(1e-3); # ps

my $trajectory = $trjdoc->Trajectory;
my $symmetrysystem = $trjdoc->SymmetrySystem;

my $stress;
my ($Lx0, $Ly0, $Lz0);
my ($Lx, $Ly, $Lz);
my ($Lxn, $Lyn, $Lzn);
my ($Pxx, $Pyy, $Pzz, $Pxy, $Pxz, $Pyz);

	print  "Frame", " ", "Time (ps)", " ";
	print  "Lx", " ", "Ly", " ", "Lz", " ";
	print  "(Lx-Lx0)/Lx0", " ", "(Ly-Ly0)/Ly0", " ", "(Lz-Lz0)/Lz0", " ";
	print  "Pxx", " ", "Pxy", " ", "Pxz", " ";
	print  "Pyy", " ", "Pyz", " ";
	print  "Pzz", "\n";
	
for (my $i = 1; $i <= $trajectory->EndFrame; $i++)
{
	$trajectory->CurrentFrame = $i;
	$stress = $symmetrysystem->Stress;
	$Lx = $trjdoc->Lattice3D->LengthA;
	$Ly = $trjdoc->Lattice3D->LengthB;
	$Lz = $trjdoc->Lattice3D->LengthC;
	
	if($i == 1)
	{
		$Lx0 = $Lx;
		$Ly0 = $Ly;
		$Lz0 = $Lz;
	}
	
	$Lxn = ($Lx-$Lx0)/$Lx0;
	$Lyn = ($Ly-$Ly0)/$Ly0;
	$Lzn = ($Lz-$Lz0)/$Lz0;
	
	$Pxx = $stress->Eij(1,1)*1000; # MPa
	$Pyy = $stress->Eij(2,2)*1000;
	$Pzz = $stress->Eij(3,3)*1000;
	$Pxy = $stress->Eij(1,2)*1000;
	$Pxz = $stress->Eij(1,3)*1000;
	$Pyz = $stress->Eij(2,3)*1000;
	
	
	print  $i, " ", ($i-1)*$frameoutevery, " ";
	print  $Lx, " ", $Ly, " ", $Lz, " ";
	print  $Lxn, " ", $Lyn, " ", $Lzn, " ";
	print  $Pxx, " ", $Pxy, " ", $Pxz, " ";
	print  $Pyy, " ", $Pyz, " ";
	print  $Pzz, "\n";
}

$trjdoc->Discard;
