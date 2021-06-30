sub MIC() # minimum image convention
{
	# Author : Se Hun Joo
	# Usage
	# ($dx, $dy, $dz) = MIC($dx, $dy, $dz, $boxlengx, $boxlengy, $boxlengz)
	
	use POSIX qw/floor/;
	my $dx = shift;
	my $dy = shift;
	my $dz = shift;
	my $boxlengx = shift;
	my $boxlengy = shift;
	my $boxlengz = shift;
	
	my $dxsq = $dx*$dx;
	my $dysq = $dy*$dy;
	my $dzsq = $dz*$dz;
	my $boxlengx2 = $boxlengx/2;
	my $boxlengy2 = $boxlengy/2;
	my $boxlengz2 = $boxlengz/2;
	my $boxlengx2sq = $boxlengx2*$boxlengx2;
	my $boxlengy2sq = $boxlengy2*$boxlengy2;
	my $boxlengz2sq = $boxlengz2*$boxlengz2;
	
	#printf "MIC operation | boxlength (%4.2f, %4.2f, %4.2f) | dxyz (%4.2f, %4.2f, %4.2f) -> ", $boxlengx, $boxlengy, $boxlengz, $dx, $dy, $dz;
		
	if ($dxsq > $boxlengx2sq)
	{
		$dx = $dx - round($dx/$boxlengx)*$boxlengx;
	}
	if ($dysq > $boxlengy2sq)
	{
		$dy = $dy - round($dy/$boxlengy)*$boxlengy;
	}
	if ($dzsq > $boxlengz2sq)
	{
		$dz = $dz - round($dz/$boxlengz)*$boxlengz;
	}
	
	#printf "(%4.2f, %4.2f, %4.2f)\n", $dx, $dy, $dz;
	
	return ($dx, $dy, $dz);
}

sub round {
  $_[0] > 0 ? int($_[0] + .5) : -int(-$_[0] + .5)
}
