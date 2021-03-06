#
# nkr_note.pl
# 校勘符號應該在 <note> �堶悸�, 自動移位
#
# v 0.1, 2002/10/8 10:41AM, by Ray
# v 0.2, 2002/10/9 11:07AM, by Ray
# v 0.3, 2002/10/9 06:27PM, by Ray
# v 0.4, 2002/10/15 03:04PM by Ray
# v 0.5, 解決簡單標記版取代錯誤問題, 2002/10/23 05:05PM by Ray
#

$out_dir = "d:/temp";  # 新 XML 檔 的輸出目錄

$debug=0;
$big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';

$xml_sutra_no = "#";
$xml_text;
$simple_text;
$dirty=0;

$pb;
$lb;
$jk_pb;

for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$simple = "c:/cbwork/simple/$vol/new.txt";
	$jk = "c:/cbwork/work/footnote/footnotedone/${vol}校勘條目.txt";
	if (not -e $simple) { next; }
	if (not -e $jk) { next; }
	print STDERR "$vol\n";
	do1vol($vol);
}

sub do1vol {
	open S, $simple or die;
	$simple_text="";
	while (<S>) {
		#s/\[[^\]]*?>>([^\]]*?)\]/$1/eg;
		$simple_text .= $_;
	}
	close S;

	open JK, $jk or die "cannot open $jk";
	$jk_pb="#";

	$vol_dirty=0;
	$jk_n = "#";
	$simple_text =~ s/(T\d\dn\d{4}.p\d{4}.\d\d|\[\d{2,3}\]\(.*?\n?.*?\))/&rep($1)/eg;
	if ($vol_dirty) {
		print_simple();
	}
}

sub rep {
	$s=shift;
	#print STDERR "51 $s\n";
	# 如果是行號
	if ($s=~/^T\d\dn(\d{4})([_a-zA-Z])p(\d{4})(.)(\d\d)/) {
		process_line_head($s);
		
		if ( ($simple_sutra_no ne $xml_sutra_no) and $dirty) {
			$dirty=0;
			print_xml();
		}
	}

	# 如果校勘符號後緊跟著小括號
	if ($s=~/\[(\d{2,3})\]\((.*?\n?.*?)\)/) {
		#if ($simple_text =~ /\[\Q$s\E>>/) {
		#	return $s;
		#}
		$n=$1;
		$note_text = $2;
		if ($note_text =~ /^(.*?)\n(.{20})(.*?)$/) {
			$note_text = $1 . $3;
			$new_line_head = substr($2,0,17);
		} else {
			$new_line_head = "";
		}

		# 去掉夾註中的校勘符號
		$note_text =~ s/\[\d{2,3}\]//g;
		$note_text =~ s/\[＊\]//g;

		$note_text =~ s/\[.*?>>(.*?)\]/$1/eg;

		# 去掉夾註中的句號
		while ($note_text =~ /^($big5*)。(.*)$/) {
			$note_text = $1 . $2;
		}
		
		#print STDERR "73 $pb$lb [$n] $note_text\n";
		$s=do1jk($s);
		process_line_head($new_line_head);
	}
	return $s;
}

sub process_line_head {
	my $s=shift;
	if ($s eq "") {
		return;
	}
	if ($s=~/^T\d\dn(\d{4})([_a-zA-Z])p(\d{4})(.)(\d\d)/) {
		#print "52 $s\n";
		$simple_sutra_no = $1;
		$c=$2;
		$pb=$3;
		$col = $4;
		$lb=$5;
		if ($c ne "_") {
			$simple_sutra_no .= $c;
		}
	}
}

sub open_xml {
	$xml_sutra_no = $simple_sutra_no;
	open XML, "c:/cbwork/xml/$vol/${vol}n$xml_sutra_no.xml" or die;
	$xml_text="";
	while (<XML>) {
		$xml_text .= $_;
	}
	close XML;
}

sub print_xml {
	mkdir("$out_dir/xml", MODE);
	mkdir("$out_dir/xml/$vol", MODE);
	$f = ">$out_dir/xml/$vol/${vol}n$xml_sutra_no.xml";
	open XML, $f or die "cannot open $f\n";
	print XML $xml_text;
	close XML;
}

sub print_simple {
	mkdir("$out_dir/simple", MODE);
	mkdir("$out_dir/simple/$vol", MODE);
	$f = ">$out_dir/simple/$vol/new.txt";
	open SO, $f or die "cannot open $f\n";
	print SO $simple_text;
	close SO;
}

sub do1jk {
	my $arg1 = shift;
	my $s;
	# 找到校勘條目中對應的頁數
	if($jk_pb ne $pb) {
		$jk_n = "#";
	}
	while($jk_pb ne $pb) {
		if ($s=<JK>) {
			if ($s=~/^p(\d{4})/) {
				$jk_pb = $1;
			} else {
				#if ($debug) { print "jk=$_ "; }
			}
		} else {
			last;
		}
	}

	#print STDERR "130 jk_pb=$jk_pb\n";
	$fount = 0;
	if ($jk_n ne $n) {
		while (<JK>) {
			chomp;
			$s=$_;
			if(/^  (\d{2,3})/) {	# 找到對應的校勘條目
				$jk_n=$1;
				if ($jk_n eq $n) {
					$found=1;
					last;
				}
			}
		}
	}
	
	if (not $found) {
		return $arg1;
	}

	#print STDERR "137 jk_n=$jk_n  $s\n";

	# 有減號的不移
	if ($s =~/^($big5)*－/) {
		return $arg1;
	}
	
	# 校勘文字中有半形括號括住整個 <note> 文字的不移
	if ($s=~/\(\Q$note_text\E\)/) {
		return $arg1;
	}
	
	# 校勘文字中有全形括號括住整個 <note> 文字的不移
	if ($s=~/\Q（$note_text）\E/) {
		return $arg1;
	}
	
	# 校勘文字有（ＡＢ…Ｃ），而ＡＢ…Ｃ是整個 <note> 的內容
	if ($s=~/\Q（\E(.*?)\Q…\E(.*?)\Q）\E/) {
		$temp1 = $1;
		$temp2 = $2;
		if ($note_text =~ /^$temp1.*$temp2$/) {
			return $arg1;
		}
	}
	
	# 校勘文字中 等號左邊的文字如果比 <note> 內的文字還長就不移
	if ($s=~/\Q$note_text\E.+＝/) {
		return $arg1;
	}
	
	# 如果校勘條目是作「A＋（B）本文」的，校勘數字也不用移位。
	if ($s=~/.+?\Q＋（\E.+?\Q）本文\E/) {
		return $arg1;
	}
	
	# 如果校勘條目是作「A＋（B）夾註」的，校勘數字也不用移位。
	if ($s=~/.+?\Q＋（\E.+?\Q）夾註\E/) {
		return $arg1;
	}

	# 如果校勘條目是作「A＋（B）細註」的，校勘數字也不用移位。
	if ($s=~/.+?\Q＋（\E.+?\Q）\E.*?\Q細註\E/) {
		return $arg1;
	}

	# 如果校勘條目是作「A＝（B）夾註」的，校勘數字也不用移位。
	if ($s=~/.+?\Q＝（\E.+?\Q）\E.*?\Q夾註\E/) {
		return $arg1;
	}

	# 如果校勘條目是作「A＝（B）細註」的，校勘數字也不用移位。
	if ($s=~/.+?\Q＝（\E.+?\Q）\E.*?\Q細註\E/) {
		return $arg1;
	}

	# 如果校勘條目是作「（B）夾註＋Ａ」的，校勘數字也不用移位。
	if ($s=~/\Q（\E.+?\Q）夾註＋\E.+?/) {
		return $arg1;
	}

	if ($s=~/^($big5)*＋/ or $s=~/^($big5)*＝/) {
		print "$vol, p$pb\n";
		print "$s\n";
		print "夾註內文字: $note_text\n";
		$temp = $simple_sutra_no;
		if (length($temp)==4) {
			$temp .= "_";
		}
		$line_head = "${vol}n${temp}p$pb$col$lb";
		print "187 line_head=$line_head\n";
		if ($simple_text =~ m#($line_head.*?)\n#) {
			$s=$1;
			print "147 $s\n";
			$s =~ s/(\[$jk_n\])(\()/$2$1/;
			print "149 $s\n";
			$arg1 =~ s/(\[$jk_n\])(\()/$2$1/;
		} else {
			print "176 簡單標記版找不到 $line_head\n";
		}
		print STDERR "196 簡單標記版取代完畢\n";
		if ($xml_sutra_no ne $simple_sutra_no) {
			open_xml();
		}
		$anchor = "<anchor id=\"fn${vol}p?${pb}$col?$n\"/>";
		if ($xml_text =~ m#(<lb n="$pb$col$lb"/>.*?$anchor.*?)\n?#s) {
			$temp = $1;
			$temp =~ s/\n//g;
			print "$temp\n";
		} else {
			print "189 XML 中找不到對應的標記\n";
		}
		if ($xml_text =~ m#<note place="inline">\n?$anchor#) {
			print "原 XML <anchor> 已在 <note> 之內\n";
		} elsif ($xml_text =~ s#($anchor)((?:<[^>]*?>|\n)*?)(<note place="inline">)#$2$3$1#) {
		} elsif ($xml_text =~ s#($anchor1)(<note place="inline">)#$2$1#) {
		} elsif ($xml_text =~ s#($anchor)(</zi><sg>)#$2$1#) {
		} else {
			print "197 XML 中找不到對應的標記\n";
		}
		if ($xml_text =~ m#(<lb n="$pb$col$lb"/>.*?$anchor.*?)\n?#) {
			print "$1\n";
		}
		print STDERR "XML版取代完畢\n";
		$dirty=1;
		$vol_dirty=1;
		print "\n";
	}
	return $arg1;
}	