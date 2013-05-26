#------------------------------------------------------
# 根據簡單標記版的校勘符號在 xml 版裏加上 <anchor>
# 2002/8/29 03:42PM 簡單標記Ｐ不列入字數計算
# 2002/8/28 04:33PM 全形空白不列入字數計算
# Ray Chou 2002/8/8 11:08PM
#------------------------------------------------------

# 參數區
$vol="T25";
$in_dir = "c:/cbwork/xml/T25";
$simple = "c:/cbwork/simple/T25/new.txt";
$out_dir = "c:/release/new-xml/T25";

mkdir($out_dir, MODE);

$debug=0;
$jk1='\[\d{2,3}\]';
$jk2='\[＊\]';

opendir THISDIR, $in_dir or die "opendir error: $dir";
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

open IS, $simple or die;

foreach $file (sort @allfiles) {
	print STDERR "$file\n";
	open IX, "$in_dir/$file" or die;
	open O, ">$out_dir/$file" or die;
	select O;
	$body=0;
	$lb_old = "";
	while (<IX>) {
		if (not $body) {
			if (/<body>/) {
				$body=1;
			}
			print;
			next
		}

		$xml_new = $_;

		if (/<pb .*? n="(.*?)"/) {
			#print "{pb}";
			$pb=$1;
			if ($lb_old ne "") {
				add_nkr();
				$lb_old='';
				$xml_old='';
			}				
			$fx=0;
			print $xml_new;
			next;
		}

		if (/<lb n=\"(.*?)\"/) {
			$lb_new = $1;
			if ($lb_new =~ /1b12/) {
				#$debug=1;
			}
			#print "{lb=$lb_new}";
			#print "[lb_new=$lb_new]";
			if ($lb_old ne "") {
				add_nkr();
			}
			$lb_old = $lb_new;
			$xml_old=$xml_new;
			next;
		} else {
			$xml_old .= $xml_new;
		}
	}
	if ($lb_old ne '') {
		add_nkr();
	}
	close O;
	close IX;
}

sub add_nkr {
	if ($debug) {
		print STDERR "[add_nkr lb_old=$lb_old xml_old=$xml_old]";
	}
	while(<IS>) {
		if(/^T\d\dn\d{4}.p(.{7})...(.*)$/) {
			$lb = $1;
			$s = $2;
			if ($lb eq $lb_old) {
				last;
			}
		}
	}
	#print "[s=$s]";
	$pb_old = substr($lb_old,0,5);
	$lb_old="";
	if ($s!~/\[\d{2,3}\]/ and $s!~/\[＊\]/) {
		print $xml_old;
		#print "{82}";
		return;
	}
	
	#print STDERR "xml_old={$xml_old}\n";
	$xml_old =~ /^(<lb[^>]*?>)(.*)$/s;
	print $1;
	$xml_old = $2;
	#print STDERR "xml_old={$xml_old}\n";
	
	my $big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';
	@a_simple=();
	@a_xml=();
	#print STDERR "90 {$s}\n";
	push(@a_simple, $s =~ /\[.*?\]|$big5/gs);	
	if ($debug) {
		print STDERR "\n簡單標記: ";
		foreach $s (@a_simple) {
			print STDERR "{$s}";
		}
	}
	push(@a_xml, $xml_old =~ /<[^>]*?>|&[^;]*?;|$big5/gs);
	if ($debug) {
		print STDERR "\nXML: ";
		foreach $s (@a_xml) {
			print STDERR "{$s}";
		}
	}

	$count_s=0;
	$count_x=0;
	$pointer_x=0;
	$out='';
	foreach $s (@a_simple) {
		if ($s!~/^$jk1$/ and $s!~/^$jk2$/) {
			# 不列入字數計算的
			if ($s ne "　" and $s ne "(" and $s ne ")" and $s ne "。" and $s ne "Ｐ") {
				$count_s++;
			}
			next;
		}
		if ($debug) {
			print STDERR "count_s=$count_s\n";
		}
		if ($s=~/\[(\d{2,3})\]/) {
			$fn=$1;
			while ($count_x <= $count_s) {
				$xml = $a_xml[$pointer_x];
				if($xml!~/^<.*>$/ and $xml ne "。" and $xml ne "　") {
					$count_x++;
				}
				if ($count_x <= $count_s) {
					$out .= $xml;
					$pointer_x++;
				}
			}
			$out .= "<anchor id=\"fn${vol}p$pb_old$fn\"/>";
			$out .= $xml;
			$pointer_x++;
		}
		
		if ($s=~/$jk2/) {
			$fx++;
			while ($count_x <= $count_s) {
				$xml = $a_xml[$pointer_x];
				if($xml!~/^<.*>$/ and $xml ne "。" and $xml ne "　")  {
					$count_x++;
				}
				if ($count_x <= $count_s) {
					$out .= $xml;
					$pointer_x++;
				}
			}
			$out .= "<anchor id=\"fx${vol}p$pb_old$fx\"/>";
			$out .= $xml;
			$pointer_x++;
		}
	}
	print $out;
	while($pointer_x < @a_xml) {
		print $a_xml[$pointer_x];
		$pointer_x++;
	}
	$xml_old='';
	if ($debug) {
		getc;
	}
}