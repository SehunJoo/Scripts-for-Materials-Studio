#*********************************************************************************
#*
#*	This script make the centroid of molecule whose name is set by mol_name
#*
#*	If mol_name is "ALL", centroid is created for all molecules
#*		
#*
#*
#*	Author	: Sehun Joo
#*	Date	: 02.11.2014
#*
#*********************************************************************************

use strict;
use MaterialsScript qw(:all);


my $file_name	=	"water1.xtd";
my $mol_name	=	"";


printf "%s, %s\n",$file_name,$mol_name;
printf "%d, %d\n",length($file_name),length($mol_name);

my $doc = $Documents{$file_name};
die "Cannot open $file_name.\n please check file name again\n"
unless $doc;

my $molecules = $doc->DisplayRange->Molecules;
my $ctr = 0;

foreach my $molecule (@$molecules)
{	
	$doc->CreateCentroid($molecule->Atoms);
	printf "Centroid of %s molecule is created\n",$molecule->Name;
	
	$ctr++;
}

printf "\nTotally %d centroids are created",$ctr;
