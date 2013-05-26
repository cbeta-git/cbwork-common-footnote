# sobelow3.pl
# v 1.1.1, 2003/6/20 04:34¤U¤È by Ray
# v 1.2.1, 2003/6/20 05:56¤U¤È by Ray

$in_dir="e:/release/new-xml/T20";
$out_dir="e:/release/new-xml1/T20";

mkdir($out_dir, MODE);

opendir (INDIR, "$in_dir") or die "open directory error: $in_dir\n";
@allfiles = grep(/\.xml$/i, readdir(INDIR));
closedir INDIR;

foreach $f (@allfiles) {
	do1file($f);
}

sub do1file {
	my $f=shift;
	my $xml='';
	open I, "$in_dir/$f" or die;
	while (<I>) {
		$xml .= $_;
	}
	close I;
	
	open O, ">$out_dir/$f" or die;
	select O;
	$xml=~s#(<app type="¡¯" source="[^"]*?"><lem><note place="inline">[^<]*?</lem><rdg[^>]*?>[^<]*?</rdg></app></note>)#&rep($1)#seg;
	print $xml;
	close O;
}

sub rep {
	my $s=shift;
	$s=~/<rdg[^>]*?>([^<]*?)<\/rdg>/;
	my $rdg=$1;
	$rdg=~s/&lac;//g;
	$s=~m#(<app type="¡¯" source="[^"]*?"><lem>)<note place="inline">([^<]*?)(</lem><rdg[^>]*?>[^<]*?</rdg></app>)</note>#s;
	if ($rdg ne '') {
		$s = "<note place=\"inline\">$1$2$3</note>";
	} else {
		$s = "$1<note place=\"inline\">$2</note>$3";
	}
	return $s;
}