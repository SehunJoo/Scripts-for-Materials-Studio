sub PBC
{
	# Author : Se Hun Joo
	# Usage
	# (xnew, ynew, znew) = PBC(x, y, z, boxlengx, boxlengy, boxlengz)

	use POSIX qw/floor/;
	my ($x, $y, $z, $boxlengx, $boxlengy, $boxlengz) = @_;
	
	# Define local veriables
	my ($invlengx, $invlengy, $invlengz);
	
	$invlengx = 1/$boxlengx;
	$invlengy = 1/$boxlengy;
	$invlengz = 1/$boxlengz;
	
	# Apply 3D periodic boundary condition
		
	if($x < 0 || $x > $boxlengx || $y < 0 || $y > $boxlengy || $z < 0 || $z > $boxlengz)
	{
		#printf "PBC operation | boxlength (%4.2f, %4.2f, %4.2f) | xyz (%4.2f, %4.2f, %4.2f) -> ", $boxlengx, $boxlengy, $boxlengz, $x, $y, $z;
		$x = $x - $boxlengx*floor($x*$invlengx);
		$y = $y - $boxlengy*floor($y*$invlengy);
		$z = $z - $boxlengz*floor($z*$invlengz);
		#printf "(%4.2f, %4.2f, %4.2f)\n", $x, $y, $z;
	}
	
	return ($x, $y, $z);
}
