$vol = "T30";

open IN, "®Õ°É±ø¥Ø${vol}.txt";
open OUT, ">${vol}note.txt";
select OUT;
$page = "0000";

while(<IN>) {
	if (/^#/) {
		print;
		next;
	}

	if (/^\[(\d{4})(\d{2})\](?:\d\d)? (¡·)?(.*)/) {
		$pagenow = $1;
		$num = $2;
		$sign = $3;
		$line = $4;
		$sign = "  " if $sign ne "¡·";
		if($pagenow ne $page) {
			$page = $pagenow;
			print "p$pagenow\n";
		}
		print $sign . $num . " " . $line . "\n";
	}
	elsif (/^<\d{6}>¡¯ (?:¡·)?(.*)/) {
		print "# $_";
	}
	else {
		print "????$_";
	}
}
close OUT;
close IN;
		
		
		