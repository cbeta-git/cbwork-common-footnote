# sobelow2.pl
# v 0.01, 2003/3/27 02:39PM by Ray
# v 0.02, 2003/4/2 05:06PM by Ray
# v 0.03, 2003/4/4 02:29下午 by Ray
# v 0.04, 2003/4/4 02:51下午 by Ray
# v 0.05, 2003/4/4 05:57下午 by Ray
# v 0.5.1, debug 有些沒加上 <todo type="＊"/>, 2003/4/9 06:53下午 by Ray
# v 0.5.2, debug, 2003/4/11 06:09下午 by Ray
# v 0.6.0, 執行前先檢查 B 檔中有無重複, 2003/5/15 10:43上午 by Ray
# v 0.7.0, 即使重複仍然繼續執行, 2003/5/19 04:22下午 by Ray

require "so_below.cfg";

$vol=shift;
$vol=uc($vol);
mkdir($out_dir, MODE);
mkdir("$out_dir/$vol", MODE);

$xml='';

$f="$log_dir/star_${vol}b.txt";
#check_logb($f);
open I, $f or die;
$f="$log_dir/star_${vol}d.txt";
open LOG, ">$f" or die;
$oldAnchorID='';
while (<I>) {
	chomp;
	if (/^T.*xml$/) {
		$xml_file = $_;
		print XO $xml;
		close XO;
		readXML();
		open XO, ">$out_dir/$vol/$xml_file" or die;
	} elsif (/^(fx.*?)##(<app.*?)<lem>(.*?)<\/lem>(.*)$/) {
		print STDERR ".";
		$anchorID=$1;
		$appOpenTag=$2;
		#print XO "[32 $appOpenTag]";
		$lem=$3;
		$rdg=$4;
		#print LOG "\n\n30 $anchorID\n";
		if ($anchorID eq $oldAnchorID) {
			print LOG "\n$anchorID 重複\n";
			next;
		}
		if ($xml =~ /^(.*?)<anchor id="$anchorID"\/>(.*)$/s) {
			print XO $1;
			$xml=$2;
			$insert='';
			if (insertLem()) {
				$xml = "$appOpenTag<lem>$insert</lem>$rdg" . $xml;
			} else {
				$xml = "<anchor id=\"$anchorID\"/>" . $insert . $xml;
			}
		} else {
			open O, ">$log_dir/temp.txt" or die;
			print O $xml;
			close O;
			die "在 $xml_file 找不到 $anchorID\n";
		}
		$oldAnchorID = $anchorID;
	}
}
close I;
print XO $xml;
close XO;

sub readXML {
	print STDERR "\nreading $xml_file...";
	open XI, "$in_dir/$vol/$xml_file" or die;
	$xml='';
	while (<XI>) {
		$xml.=$_;
	}
	close XI;
	print STDERR "\n根據C檔插入 <todo type=\"＊\"/>...";
	open LC, "$log_dir/star_${vol}c.txt" or die;
	while (<LC>) {
		chomp;
		$s=$_;
		if ($s=~/$xml_file/) { 
			last;
		}
	}
	if ($s=~/$xml_file/) { 
		starTodo($s);
	}
	while (<LC>) {
		chomp;
		$s=$_;
		if ($s=~/$xml_file/) {
			print STDERR ".";
			starTodo($s);
		} else {
			last;
		}
	}
	close LC;
	print STDERR "\n開始插入校勘";
}

sub starTodo {
	$s=shift;
	($f,$n)=split / /,$s;
	#print STDERR "81 s=[$s] n=[$n]\n";

	# 除了 > 之外的 big5 字元
	$b5 = "(?:[\x00-\x3d]|[\x3f-\x7f]|[\x80-\xff].)";
	
	if ($xml=~ /^(.*<note$b5*?n=\"$n\"$b5*?type=\"mod\"$b5*?>)(.*?<\/note>.*$)/s) {
		$xml = $1 . '<todo type="＊"/>' . $2;
	} elsif ($xml=~ /^(.*)(<note$b5*?n=\"$n\"$b5*?type=\")orig(\"$b5*?>)(.*?<\/note>)(.*)$/s) {
		$s1=$1;
		$s2=$2;
		$s3=$3;
		$s4=$4;
		$s5=$5;
		$s6=$s3;
		$s6=~s/ ?place="foot text"//;
		$s7=$s2;
		$s7=~s/resp=".*?"/resp="CBETA"/;
		$xml = "$s1$s2" . 'orig' . "$s3$s4$s7" . 'mod' . $s6 . '<todo type="＊"/>' . "$s4$s5";
	} else {
		print LOG "93 目前開啟檔:$xml_file 找不到在$f的校勘條目:$n\n";
	}
}

sub insertLem {
	my $big5 = "(?:<corr.*?sic=\".*?\".*?>.*?<\/corr>|<.*?>|&.*?;|[\x00-\x7f]|[\x80-\xff][\x00-\xff])";
	#print LOG "\n99 lem=[$lem]\n";
	while ($lem=~/^($big5)(.*?)$/s) {
		$c1=$1;
		#print LOG "[58$c1]";
		if ($c1=~/^<corr.*?sic="(.*?)".*?>.*?<\/corr>/) {
			$sic=$1;
			$corrFlag=1;
		} else {
			$corrFlag=0;
		}
		$lem=$2;
		while ($xml=~/^($big5)(.*?)$/s) {
			$c2=$1;
			$xml=$2;
			#print LOG "[62$c2]";
			if ($corrFlag) {
				if ($c2 eq $sic) {
					$insert .= $c1;
					last;
				} elsif ($c2=~/^</ or $c2 eq "\n") {
					$insert .= $c2;
				} else {
					$insert .= $c2;
					print LOG "131 內文＊ 與校勘＊來源 文字不符:\n";
					print LOG "$anchorID $appOpenTag c1=[$c1] c2=[$c2]\n\n";
					return 0;
				}
			} else {
				$insert .= $c2;
				if ($c2 eq $c1) {
					last;
				} elsif ($c2 eq "\n") {
				} elsif ($c2 !~ /^</) {
					print LOG "135 內文＊ 與校勘＊來源 文字不符:\n";
					print LOG "$anchorID $appOpenTag c1=[$c1] c2=[$c2]\n\n";
					return 0;
				}
			}
		}
	}
	#print LOG "[137]";
	return 1;
}

sub check_logb {
	$f=shift;
	open I, $f or die;
	my $n='';
	while (<I>) {
		if (/^(fx.*?)##/) {
			if ($1 ne $n) {
				$n=$1;
			} else {
				die "$f 中有重複 $n\n";
			}
		}
	}
	close I;
}	