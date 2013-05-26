#-------------------------------------------------------------------------------------
# move_jk.pl
# checknote 在本文找不到對應用字的(例如A=B【X】裏的A), 
# 如果是因為A跑到校勘符號前面, 程式自動把 A 移校勘符號後面
#
# Version 0.2, 2002/9/11 05:27PM by Ray
# Version 0.1, 2002/9/11 02:55PM by Ray
#------------------------------------------------------------------------------------
$xmllog = "d:/temp/T08xmllog-1.txt";
$xml_dir = "c:/cbwork/xml/T08";
$out_dir = "d:/temp";

$debug = 0;

open I, $xmllog or die;
while (<I>) {
	if (/(\d{7}): (\S+) <==>/) {
		$log{$1} = $2;
	}
}

opendir THISDIR, $xml_dir or die "opendir error: $xml_dir";
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

foreach $file (@allfiles) {
	open I, "$xml_dir/$file" or die;
	open O, ">$out_dir/$file" or die;
	select O;
	while (<I>) {
		print do1line($_);
	}
	close O;
	close I;
}

sub do1line {
	$s = shift;
	#if ($s=~/0107a11/) {
	#	$debug=1;
	#}
	$out = '';
	while ($s =~ /^(.*?)(<anchor id="fnT(\d\d)p(\d{4})([abc])(\d{2,3})"\/>)(.*)$/s) {
		$front = $1;
		$anchor = $2;
		$vol = $3;
		$pb = $4;
		$col = $5;
		$count = $6;
		$back = $7;
		$log_id = $pb . sprintf("%3.3d", $count);
		if (exists($log{$log_id})) {
			$val = $log{$log_id};
			if ($front =~ /^(.*)\Q$val\E$/) {
				$front = $1;
				$anchor .= $val;
			}
		}
		$out .= $front . $anchor;
		$s = $back;
		if ($debug) {
			print STDERR "[$out] [$s]\n";
		}
	}
	$out .= $s;
	if ($debug) {
		getc;
	}
	return $out;
}