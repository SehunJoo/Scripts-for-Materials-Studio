#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $xtdname = "c-HBC_D3d P-1";
my $xtddoc = $Documents{$xtdname.".xtd"};
my $trajectory = $xtddoc->Trajectory;
my $xsdname_out;

for (my $i=1; $i<=10; ++$i)
{
    $trajectory->CurrentFrame = $i;
    $xsdname_out = sprintf("%s_Rank%.2d.xsd", $xtdname,$i);
    $xtddoc->Export($xsdname_out);
}
