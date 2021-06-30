#*********************************************************************************
#*
#*	Extract frame from xtd file (every 100 steps)
#*	Build supercell of each periodic system in each frame
#*	Append to new xtd file.
#*
#*	If mol_name is "ALL", centroid is created for all molecules
#*		
#*
#*
#*	Author	: Sehun Joo
#*	Date	: 09.15.2014
#*
#*********************************************************************************
#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xtddoc = $Documents{"input.xtd"};
my $trajectory = $xtddoc->Trajectory;

my $results = Documents->New("results.xtd");

for(my $i = 1; $i < $trajectory->EndFrame; $i = $i + 100)
{
	$trajectory->CurrentFrame = $i;
	my $temp = $trajectory->SaveAs("temp.xsd");
	$temp->BuildSuperCell(2, 2, 2);
	my $molecules = $temp->Molecules;
	
	$results->Trajectory->AppendFramesFrom($temp);
	$results->Save;
	$temp->Delete;
}
