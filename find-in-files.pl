use Getopt::Long;

%output_types = map { $_ => 1 } ("LOCAL", "TEAMCITY");

$usage = "Usage: --path=<PATH TO TARGET DIRECTORY> --term=<REGEX TO SEARCH FOR> [--exclude=<REGEX TO EXCLUDE FILES>] [--output=<LOCAL|TEAMCITY>]";

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

print_start();

read_dir($where);

print_finish();

exit(0);

sub read_dir($) {
	my ($dir) = @_;
	opendir(DIR, $dir) || die "cannot read dir: $dir";
	foreach my $elem (readdir(DIR)) {
		my $child = $dir  . "\\" . $elem;
		if(-d $child && $elem !~ m|^\.|) { #directory
			read_dir($child);
		} else {
			if ($exclude eq "" || $child !~ m|$exclude| ) { #parse the file
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
	print_start_file($file);
	open(SRC, $file);
	#read file line-by-line
	while(<SRC>) {
		
		$line_number++;
		#Regex the line
		if(m|($what)|) {
			my $match = $1;
			print_match($file, $line_number, $match);
		}
		
	}
	close(SRC);
	print_finish_file($file);
}

sub print_start_file($) {
	my ($file) = @_;

	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testStarted name='" .  $file ."']\n";
	}
}

sub print_finish_file($) {
	my ($file) = @_;

	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testFinished  name='" .  $file ."']\n";
	}
}

sub print_match($) {
	my ($file, $line_number, $match) = @_;

	my $line = $_;
	$line =~ s|\n||;
	$line =~ s|\t||;

	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testFailed name='" . $file .":". $line_number . "' message='Found " . $match  . "' details='" . $line_number . ":" . $match . ":" . $line . "']\n";
	} else {
		print $file . ":" . $line_number . ": " . $match ." : " . $_ . "\n";
	}
}

sub print_start() {
	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testSuiteStarted name='Content validaton']\n";
	} 

	print "Path: " . $where . "\n";
	print "Term: " . $what . "\n";
	print "Exclude: " . ($exclude eq "" ? "Nothing" : $exclude) . "\n";
	print "Output: " . ($output_format eq "" ? "LOCAL" : $output_format) . "\n";
}

sub print_finish() {
	if ($output_format eq "TEAMCITY") {
		print "##teamcity[testSuiteFinished name='Content validaton']\n";
	} else {
		print "All done!\n";
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
