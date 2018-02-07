use Getopt::Long;

%output_types = map { $_ => 1 } ("LOCAL", "TEAMCITY");

$usage = "Usage: --path=<PATH TO TARGET DIRECTORY> --what=<REGEX TO SEARCH FOR> [--exclude=<REGEX TO EXCLUDE FILES>] [--output=<LOCAL|TEAMCITY>]";

$where = "";
$what = "";
$exclude = "";
$output_format = "";
GetOptions ("path=s" => \$where,
			"term=s" => \$what,
			"exclude=s"   => \$exclude,
			"output=s"  => \$output_format)
or die $usage;

validate_arguments();

print "Path: " . $where . "\n";
print "Term: " . $what . "\n";
print "Exclude: " . ($exclude eq "" ? "Nothing" : $exclude) . "\n";
print "Output: " . ($output_format eq "" ? "LOCAL" : $output_format) . "\n";

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
		if(m|($what)|) {
			my $match = $1;
			print_match($file, $line_number, @_, $match);
		}
	}
	close(SRC);
}

sub print_match($) {
	my ($file, $line_number, $line, $match) = @_;
	
	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testFailed name='" . $file ."' message='Found " . $match  . "' details='File \"" . $file .  ":" . $line_number . "\" contains \"" . $match . "\". " . $_ . " ']\n";
	} else {
		print $file . ":" . $line_number . ": " . $match ." : " . $_ . "\n";
	}
}

sub validate_arguments() {
	if ($where eq "" || $what eq "") {
		die $usage
	}

	validate_output_format($output_format);
}

sub validate_output_format($) {
	my ($output) = @_;
	
	if($output ne "" && !exists($output_types{$output})) { 
		die "Output format '" . $output  . "' is not valid.\n" . $usage
	}
}