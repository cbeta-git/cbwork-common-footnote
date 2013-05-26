# corr2app.pl
# <corr> 改用 <app>
#
# 各種類型:
#	<!-- --> 裏面的不轉, T18n0904, Revision 1.13 <corr sic="　">&SD-E347;</corr> 改成 &lac;
#	T01n0001, 0014a04, <lem>蔭<corr resp="say" sic="＆CB00582；">蓋</corr></lem>
#	T18n0860, 0184a01, <corr sic="SD-D957">&SD-A67A;&SD-A5E6;</corr>
#	sic屬性裏的半形括號轉成 <note> T54n2135, 1223c04
#		<corr resp="say" sic="縛字(無可反)"><note place="inline">縛字（無可反）</note></corr>
#		=>
#		<app>
#			<lem resp="say"><note place="inline">縛字（無可反）</note></lem>
#			<rdg wit="【大】">縛字<note place="inline">無可反</note></rdg>
#		</app>
#
# v 0.01, 2003/3/31 11:05AM by Ray
# v 0.2.0, 2003/6/9 03:17下午 by Ray
# v 0.2.1, 2003/6/24 05:29下午 by Ray
# v 0.3.1, 2003/6/25 09:20上午 by Ray
#

$in_dir="c:/cbwork/xml";
#$in_dir="e:/release/new-xml";
$out_dir="e:/release/new-xml";
#$out_dir="e:/release/new-xml1";

$vol=shift;
$vol=uc($vol);
mkdir($out_dir, MODE);
mkdir("$out_dir/$vol", MODE);

opendir (INDIR, "$in_dir/$vol") or die;
@allfiles = grep(/\.xml$/i, readdir(INDIR));
closedir INDIR;
open L, ">corr2app.txt" or die;
foreach $file (sort(@allfiles)) { 
	do1file();
}

sub do1file {
	my $xml='';
	print STDERR "$file ";
	open I, "$in_dir/$vol/$file" or die;
	while (<I>) {
		$xml.=$_;
	}
	close I;
	open O, ">$out_dir/$vol/$file" or die;
	select O;
	$xml=corr2app($xml);
	print $xml;
	close O;
}

sub corr2app {
	my $s=shift;
	$s=~s#(<!\-\-.*?\-\->|<note.*?>(<note.*?</note>|.)*?</note>|<lem>.*?</lem>|<corr.*?>.*?</corr>)#&rep($1)#sge;
	return $s;	
}

sub rep {
	my $s=shift;
	print L "60 $s\n";
	my $s1, $s2, $s3;
	my $att, $att1, $att2;
	my $lem;
	my $sic;
	my $rdg;
	if ($s=~/^<corr(.*?)sic="(.*?)"(.*?)>(.*?)<\/corr>$/) {
		$att1=$1;
		$att2=$3;
		$lem=$4;
		$sic=$2;
		$att1=~s/^ *//;
		$att2=~s/^ *//;
		$att1=~s/ *$//;
		$att2=~s/ *$//;
		if ($att1 ne '' and $att2 ne '') {		
			$att=" $att1 $att2";
		} elsif ($att1 ne '') {
			$att=" $att1";
		} elsif ($att2 ne '') {
			$att=" $att2";
		} else {
			$att='';
		}
		$sic=rep_att($sic);
		return "<app><lem$att>$lem</lem><rdg wit=\"【大】\">$sic</rdg></app>";
	} elsif ($s=~/^<lem>(.*)<\/lem>$/) {
		$s1=$1;
		if ($s1!~/<corr/) {
			return $s;
		}
		$s2=corr2app($s1);
		if ($s2 eq $s1) {
			return $s;
		}
		#if ($s2=~/^(.*?)<app>(<lem.*?>)(.*?)<\/lem><rdg wit="【大】">(.*?)<\/rdg><\/app>(.*)$/) {
			#return "$1$2$5</lem><rdg wit=\"【大】\">$1$4$5</rdg>";
		# 如果 <lem> 裏是整個 <app>, 就簡化
		# 例如 <lem><app><lem resp="cp">膞</lem><rdg wit="【大】">膊</rdg></app></lem>
		#
		# 如果 <lem> 裏只有部份是 <app>, 就維持原狀
		# 例 <lem>蔭<app><lem resp="say">蓋</lem><rdg wit="【大】">&CB00582;</rdg></app></lem>
		#    <lem><note place="inline">毘邪<app><lem>反</lem><rdg wit="【大】">文</rdg></app></note></lem>
		if ($s2=~/^<app>(<lem.*?>.*?<\/lem><rdg wit="【大】">.*?<\/rdg>)<\/app>$/) {
			return $1;
		} else {
			return "<lem>$s2</lem>";
		}
	} elsif ($s=~/^<note([^>]*?)>/) {
		$att=$1;
		# 校勘條目的 <note> 不轉, 但其他 <note> 還是要轉
		if ($att!~/type="orig"/ and $att!~/type="mod"/) {
			$s=~/^(<note.*?>)(.*)(<\/note>)$/s;
			$s1=$1;
			$s2=$2;
			$s3=$3;
			print L "108 [$s2]\n";
			$s2=corr2app($s2);
			$s=$s1.$s2.$s3;
		}
	}
	return $s;
}

sub rep_att {
	my $s=shift;
	my $big5="(?:[\x80-\xff][\x00-\xff]|[\x00-\x7f])";
	$s=~s/(＆.*?；|CB\d{5}|SD\-[A-F0-9]{4})/&rep1($1)/ge;
	while ($s=~/^($big5*)\((.*?)\)(.*)$/) {
		$s="$1<note place=\"inline\">$2</note>$3";
	}
	return $s;
}

sub rep1 {
	my $s=shift;
	if ($s =~ /^＆(.*)；$/) {
		return "&$1;";
	} else {
		return "&$s;";
	}
}