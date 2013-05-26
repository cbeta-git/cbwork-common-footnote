
open CFG, "checknote.cfg";

while(<CFG>){
	next if (/^#/); 	#comments
	chop;
	($key, $val) = split(/\s*=\s*/, $_);
	$key = lc($key);
	$cfg{$key}=$val;	#store cfg values
}
close CFG;

if (defined($cfg{"vol"})) {
	$vol = $cfg{"vol"};
}


if (defined($cfg{"infile"})) {
	$infile = $cfg{"infile"};
	$infile =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"sutra"})) {
	$sutra = $cfg{"sutra"};
	$sutra =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"xml_dir"})) {
	$xml_dir = $cfg{"xml_dir"};
	$xml_dir =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"outfile"})) {
	$outfile = $cfg{"outfile"};
	$outfile =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"xmlout"})) {
	$xmlout = $cfg{"xmlout"};
	$xmlout =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"xmllogout"})) {
	$xmllogout = $cfg{"xmllogout"};
	$xmllogout =~ s/\$\{vol\}/$vol/g;
}

if (defined($cfg{"show_no_word_error"})) {
	$show_no_word_error = $cfg{"show_no_word_error"};
}

if (defined($cfg{"run_check_with_sutra"})) {
	$run_check_with_sutra = $cfg{"run_check_with_sutra"};
}

if (defined($cfg{"useodbc"})) {
	$useODBC = $cfg{"useodbc"};
}

if (defined($cfg{"run_check_with_xml"})) {
	$run_check_with_xml = $cfg{"run_check_with_xml"};
}