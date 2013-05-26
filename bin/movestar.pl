# movestar.pl
# 把行末＊移到行首
# v 0.0.1, 2003/4/9 01:30下午 by Ray

require "so_below.cfg";

$vol=shift;
if ($vol eq '') {
	print STDERR "Ex: movestar.pl T01\n";
	exit;
}

$vol=uc($vol);
mkdir($out_dir, MODE);
mkdir("$out_dir/$vol", MODE);

opendir THISDIR, "$in_dir/$vol" or die;
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

foreach $file (@allfiles) {
	$f="$in_dir/$vol/$file";
	open I, $f or die "open $f error\n";
	$xml='';
	while (<I>) {
		$xml.=$_;
	}
	close I;
	$xml =~ s#(<anchor id="fx[^>]*?"/>)(\n(:?<pb[^>]*?>\n)?<lb n="[^>]*?"/>)#$2$1#sg;
	open O, ">$out_dir/$vol/$file" or die;
	select O;
	print $xml;
	close O;
}