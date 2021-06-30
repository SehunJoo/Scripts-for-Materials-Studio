# 2D_potential_energy_surface_make_input 
#
# script for running DFTB single-point energy calculations 
# for generating two-dimensional potential energy surface
#
# @author  Se Hun Joo
# @version 2019. 10. 28.


#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my ($ia, $ib) = (16, 16);
my ($na, $nb) = (16, 16);

for (my $i = 0; $i < $ia+1; $i++)
{
	for (my $j = 0; $j < $ib+1; $j++)
	{
		my $xsdname = sprintf("%02d_%02d.xsd",$i,$j);
		my $xsddoc = $Documents{$xsdname};
		my $outputData = Modules->DFTB->Energy->Run($xsddoc,
                                            Settings(
							Quality => "Fine",
							ElectronicQuality => "Fine",
							SKFLibrary => "3ob",
							Charge => "0",
							UseSCC => "Yes",
							SCCConvergence => "1.0e-8",
							MaximumSCCIterations => "500",
							UseSmearing => "No",
							SmearingFunction => "Fermi",
							UseDC => "Yes",
							SpinUnrestricted => "No",
							UseFormalSpin => "Yes",
							
							KPointQuality => "Fine",
							ParameterA => "1",
							ParameterB => "1",
							ParameterC => "4"
							)
							);
				printf "%02d/%02d\t%02d/%02d\t%14.7f \n",  $i,$na,$j,$nb,$xsddoc->PotentialEnergy;

                undef $xsdname;                                     
                undef $xsddoc;
                undef $outputData;
	}
}	                                                     
