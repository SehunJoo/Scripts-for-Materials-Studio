#!perl

use strict;
use MaterialsScript qw(:all);

my $boxSize = 60; # size of the box in angstrom
my $resolution = 1; # resolution of the field in angstrom

# create an empty box
my $doc = Documents->New("droplet.xsd");
Tools->CrystalBuilder->SetSpaceGroup("P1");
Tools->CrystalBuilder->SetCellParameters($boxSize, $boxSize, $boxSize, 90.0, 90.0, 90.0);
Tools->CrystalBuilder->Build($doc);

# add a field
my $field = $doc->CreateField($resolution);

# set the field value to the (fractional) distance from the box centre
my $probe = $field->CreateFieldProbe([ProbeMode => "NearestGridPoint"]);
my $extent1 = $field->GridExtent1;
my $extent2 = $field->GridExtent2;
my $extent3 = $field->GridExtent3;
for (my $i = 0; $i < $extent1; $i++)
{
   for (my $j = 0; $j < $extent2; $j++)
   {
      for (my $k = 0; $k < $extent3; $k++)
      {
         $probe->ProbeVoxelPosition = Point(X => $i, Y => $j, Z => $k);
         my $frac = $probe->ProbeFractionalPosition;
         my $rx = $frac->X-0.5;
         my $ry = $frac->Y-0.5;
         my $rz = $frac->Z-0.5;
         my $distance = sqrt($rx**2+$ry**2+$rz**2);
         if ($distance > 0.35)
         {
         print 
         $probe->FieldValue = 1;
         }
         else
         {
         print 
         $probe->FieldValue = 2;
         }
      }
   }
}
$probe->Delete;

# add an isosurface
$field->CreateIsosurface([Isovalue => 2]);
$field->IsVisible = "Yes";
