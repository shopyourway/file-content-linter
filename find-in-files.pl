$what = $ARGV[1];
$where = $ARGV[0];

read_dir($where);

exit(0);

sub read_dir($) {
	my ($dir) = @_;
	opendir(DIR, $dir) || die "cannot read dir: $dir";
	foreach my $elem (readdir(DIR)) {
		my $child = $dir  . "\\" . $elem;
		if(-d $child && $elem !~ m|^\.|) { #directory
			read_dir($child);
		} else { #parse the file
			parse_file($child);
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
			print $file . ":" . $line_number . ": " . $_ . "\n";
		}
	}
	close(SRC);
}
