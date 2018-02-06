
$where = $ARGV[0];
$what = $ARGV[1];
$exclude = $ARGV[2];
$output_format = $ARGV[3];

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
