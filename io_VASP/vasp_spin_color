#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xsddoc = $Documents{"".".xsd"};

my $atoms = $xsddoc->UnitCell->Atoms;

foreach my $atom (@$atoms)
{
	if($atom->ElementSymbol eq "Mn")
	{
		if($atom->Spin > 0)
		{
			$atom->Color = RGB(0, 0, 255);
		}
	}
}
