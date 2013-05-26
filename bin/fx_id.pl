# fx_id.pl
# <anchor id="fx.....a1"> a1 統一成兩碼 a01
# v0.1, 2002/9/23 05:12PM by Ray

$indir = "c:/cbwork/xml";
$out_dir = "d:/temp";

my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	print STDERR "$vol\n";
	$dir = "$indir/$vol";
	if (not -e $dir) { next; }
	mkdir("$out_dir/$vol",MODE);

	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep /\.xml$/, readdir THISDIR;
	closedir THISDIR;
	
	foreach $file (@allfiles) {
		open I, "$dir/$file" or die;
		open O, ">$out_dir/$vol/$file" or die;
		select O;
		while (<I>) {
			s#(<anchor id="fxT\d\dp\d{4}[a-z])(\d"/>)#$1\x30$2#g;
			print;
		}
		close I;
		close O;
	}
}