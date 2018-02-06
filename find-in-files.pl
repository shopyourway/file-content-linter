
use Getopt::Long;

$usage = "Usage: --path=<PATH TO TARGET DIRECTORY> --what=<REGEX TO SEARCH FOR> [--exclude=<REGEX TO EXCLUDE FILES>] [--output=<LOCAL|TEAMCITY>]";

$where = "";
$what = "";
$exclude = "";
$output_format = "";
GetOptions ("path=s" => \$where,
			"what=s" => \$what,
			"exclude=s"   => \$exclude,
			"output=s"  => \$output_format)
or die $usage;

if ($where eq "" || $what eq "") {
	die $usage
}

read_dir($where);

exit(0);

sub read_dir($) {
	my ($dir) = @_;
	opendir(DIR, $dir) || die "cannot read dir: $dir";
	foreach my $elem (readdir(DIR)) {
		my $child = $dir  . "\\" . $elem;
		if(-d $child && $elem !~ m|^\.|) { #directory
			read_dir($child);
		} else {
			if ($child !~ m|$exclude| ) { #parse the file
				next if(-B $child || -z $child); #skip binary and empty files
				parse_file($child);
			}
		} 
	}
	closedir(DIR);
}
sub parse_file($) {
	my ($file) = @_;
	my $line_number = 0;
	open(SRC, $file);
	#read file line-by-line
	while(<SRC>) {
		$line_number++;
		#Regex the line
		if(m|$what|) {
			print_match($file, $line_number, @_);
		}
	}
	close(SRC);
}

sub print_match($) {
	my ($file) = @_[0];
	my ($line_number) = @_[1];
	my ($line) = @_[2];

	print $file . ":" . $line_number . ": " . $_ . "\n";
}