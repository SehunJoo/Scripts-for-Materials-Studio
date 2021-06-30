#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xsddoc = $Documents{"Cu2+".".xsd"};

my $atoms = $xsddoc->UnitCell->Atoms;
my $spin_sum = 0;

foreach my $atom (@$atoms)
{
	$spin_sum = $atom->Spin + $spin_sum;
}

print "Total spin = ",$spin_sum;
