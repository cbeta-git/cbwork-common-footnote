#
# nkr_note.pl
# �հɲŸ����Ӧb <note> �ح���, �۰ʲ���
#
# v 0.1, 2002/10/8 10:41AM, by Ray
# v 0.2, 2002/10/9 11:07AM, by Ray
# v 0.3, 2002/10/9 06:27PM, by Ray
# v 0.4, 2002/10/15 03:04PM by Ray
# v 0.5, �ѨM²��аO�����N���~���D, 2002/10/23 05:05PM by Ray
#

$out_dir = "d:/temp";  # �s XML �� ����X�ؿ�

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
	$jk = "c:/cbwork/work/footnote/footnotedone/${vol}�հɱ���.txt";
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
	# �p�G�O�渹
	if ($s=~/^T\d\dn(\d{4})([_a-zA-Z])p(\d{4})(.)(\d\d)/) {
		process_line_head($s);
		
		if ( ($simple_sutra_no ne $xml_sutra_no) and $dirty) {
			$dirty=0;
			print_xml();
		}
	}

	# �p�G�հɲŸ�����ۤp�A��
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

		# �h�����������հɲŸ�
		$note_text =~ s/\[\d{2,3}\]//g;
		$note_text =~ s/\[��\]//g;

		$note_text =~ s/\[.*?>>(.*?)\]/$1/eg;

		# �h�����������y��
		while ($note_text =~ /^($big5*)�C(.*)$/) {
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
	# ���հɱ��ؤ�����������
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
			if(/^  (\d{2,3})/) {	# ���������հɱ���
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

	# ���������
	if ($s =~/^($big5)*��/) {
		return $arg1;
	}
	
	# �հɤ�r�����b�άA���A����� <note> ��r������
	if ($s=~/\(\Q$note_text\E\)/) {
		return $arg1;
	}
	
	# �հɤ�r�������άA���A����� <note> ��r������
	if ($s=~/\Q�]$note_text�^\E/) {
		return $arg1;
	}
	
	# �հɤ�r���]�ϢСK�ѡ^�A�ӢϢСK�ѬO��� <note> �����e
	if ($s=~/\Q�]\E(.*?)\Q�K\E(.*?)\Q�^\E/) {
		$temp1 = $1;
		$temp2 = $2;
		if ($note_text =~ /^$temp1.*$temp2$/) {
			return $arg1;
		}
	}
	
	# �հɤ�r�� �������䪺��r�p�G�� <note> ������r�٪��N����
	if ($s=~/\Q$note_text\E.+��/) {
		return $arg1;
	}
	
	# �p�G�հɱ��جO�@�uA�ϡ]B�^����v���A�հɼƦr�]���β���C
	if ($s=~/.+?\Q�ϡ]\E.+?\Q�^����\E/) {
		return $arg1;
	}
	
	# �p�G�հɱ��جO�@�uA�ϡ]B�^�����v���A�հɼƦr�]���β���C
	if ($s=~/.+?\Q�ϡ]\E.+?\Q�^����\E/) {
		return $arg1;
	}

	# �p�G�հɱ��جO�@�uA�ϡ]B�^�ӵ��v���A�հɼƦr�]���β���C
	if ($s=~/.+?\Q�ϡ]\E.+?\Q�^\E.*?\Q�ӵ�\E/) {
		return $arg1;
	}

	# �p�G�հɱ��جO�@�uA�ס]B�^�����v���A�հɼƦr�]���β���C
	if ($s=~/.+?\Q�ס]\E.+?\Q�^\E.*?\Q����\E/) {
		return $arg1;
	}

	# �p�G�հɱ��جO�@�uA�ס]B�^�ӵ��v���A�հɼƦr�]���β���C
	if ($s=~/.+?\Q�ס]\E.+?\Q�^\E.*?\Q�ӵ�\E/) {
		return $arg1;
	}

	# �p�G�հɱ��جO�@�u�]B�^�����Ϣϡv���A�հɼƦr�]���β���C
	if ($s=~/\Q�]\E.+?\Q�^������\E.+?/) {
		return $arg1;
	}

	if ($s=~/^($big5)*��/ or $s=~/^($big5)*��/) {
		print "$vol, p$pb\n";
		print "$s\n";
		print "��������r: $note_text\n";
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
			print "176 ²��аO���䤣�� $line_head\n";
		}
		print STDERR "196 ²��аO�����N����\n";
		if ($xml_sutra_no ne $simple_sutra_no) {
			open_xml();
		}
		$anchor = "<anchor id=\"fn${vol}p?${pb}$col?$n\"/>";
		if ($xml_text =~ m#(<lb n="$pb$col$lb"/>.*?$anchor.*?)\n?#s) {
			$temp = $1;
			$temp =~ s/\n//g;
			print "$temp\n";
		} else {
			print "189 XML ���䤣��������аO\n";
		}
		if ($xml_text =~ m#<note place="inline">\n?$anchor#) {
			print "�� XML <anchor> �w�b <note> ����\n";
		} elsif ($xml_text =~ s#($anchor)((?:<[^>]*?>|\n)*?)(<note place="inline">)#$2$3$1#) {
		} elsif ($xml_text =~ s#($anchor1)(<note place="inline">)#$2$1#) {
		} elsif ($xml_text =~ s#($anchor)(</zi><sg>)#$2$1#) {
		} else {
			print "197 XML ���䤣��������аO\n";
		}
		if ($xml_text =~ m#(<lb n="$pb$col$lb"/>.*?$anchor.*?)\n?#) {
			print "$1\n";
		}
		print STDERR "XML�����N����\n";
		$dirty=1;
		$vol_dirty=1;
		print "\n";
	}
	return $arg1;
}	