#-------------------------------------------------------------------------------------
# sanben.pl
# 將原來是 "【三】＊ " 的 "【宋】【元】【明】＊" 改成 "【宋】＊【元】＊【明】＊"
#
# v0.1, 2002/12/17 05:24PM by Ray
# V0.2, 2002/12/19 10:58AM by Ray
#------------------------------------------------------------------------------------
$xml_dir = "c:/cbwork/xml/T03";
$out_dir = "d:/temp/T03";

$debug = 0;

mkdir($out_dir,MODE);

opendir THISDIR, $xml_dir or die "opendir error: $xml_dir";
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

foreach $file (@allfiles) {
	open I, "$xml_dir/$file" or die;
	open O, ">$out_dir/$file" or die;
	select O;
	while (<I>) {
		s#(<note[^>]*?type="orig"[^>]*?>[^<]*?【三】＊.*?</note><note[^>]*?type="mod">.*?)【宋】【元】【明】＊(.*?</note>)#$1【宋】＊【元】＊【明】＊$2#g;
		s#(<note[^>]*?type="orig"[^>]*?>[^<]*?【三】下同[^<]*?</note><note[^>]*?type="mod">.*?)【宋】【元】【明】下同(.*?</note>)#$1【宋】下同【元】下同【明】下同$2#g;
		print;
	}
	close O;
	close I;
}