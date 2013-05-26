
$xml_dir = 'c:/cbwork/xml/';

open OUT, ">all_note.txt" || die "open all_note.txt error";

for(my $i=1; $i<=1; $i++)
{
	$i = 85 if $i == 56;
	$vol = sprintf("T%02d",$i);
	run_xmls($vol);
}

close OUT;

##############################
# 處理全冊
##############################

sub run_xmls()
{
	my $vol = shift;
	my $file;
	my @files = <${xml_dir}${vol}/*.xml>;

	foreach $file (sort(@files))
	{
		print "Run $file\n";
		run_xml($file);
	}
}

##############################
# 處理單冊
##############################

sub run_xml()
{
	my $file = shift;

	open IN, "$file" || die "open $file error";
	@lines = <IN>;
	close IN;
	
	# 要處理的資料有
	#
	#<note n="xxxxxx" place="foot">
	#<note resp="CBETA" type="mod">
	#<app>...</app>
	#<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\
	#<sic n=\"$ID\" resp=\"Taisho\" cert=\"?\" corr=\"$tmp\">$note_old{$subID}</sic>
	#<tt n=\"${ID}\" type=\"app\">

	my $fine_body = 0;

	for(my $i=0; $i<=$#lines; $i++)
	{
		while ($fine_body == 0)
		{
			if($lines[$i] =~ /<body>/)
			{
				$fine_body = 1;
				last;
			}
			else
			{
				$i++;
			}
		}
	
		if($lines[$i] =~ /<note[^>]*place="foot/)
		{
			$lines[$i] =~ s/.*?(<note[^>]*place="foot.*)/$1/;
			
			$lines[$i] =~ s/^(<note.*?<\/note>)//;
			
			print OUT $1 . "\n";
		}
	}
}
