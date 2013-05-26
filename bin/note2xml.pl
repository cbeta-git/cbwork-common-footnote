##################################################################################
# �հɴ��J�{��  V1.0  2002/07/04 by heaven
# �����ѼƽЭק� note2xml_pre.pl �o��{��
##################################################################################

require "note2xml_pre.pl";		#���o�w�]���Ѽ�

# �ܼ� 

my %note_xml;		# �հɪ��O��, �H ID ������
my %note_source;	# �쥻�b XML �W�����
my %note_lines;		# �b xml �W�����
my $DEBUG = 1;		# �S����, �u�O�Y = 0 �h�e�����|���T��.

## �D�{�� #################

open ERROUT, ">$err_out" || die "open error out $err_out fail : $!";

unless(-d $out_dir)
{
	mkdir("$out_dir", 0777);	# ���Ϳ�X�ؿ�
}

unless(-d $out_dir)
{
	print "��X�ؿ����ͥ���, �Цۦ�إߥؿ� $out_dir\n";
	exit;
}

print "Read Note...\n" if $DEBUG;
read_note();

print "Fix Note...\n" if $DEBUG;
fix_note();

print "Run Files...\n\n" if $DEBUG;
run_with_xmls();

close ERROUT;

print "Press any key to exit......";
<>;

##############################
# ���N�հ�Ū�J
##############################

sub read_note()
{
	my $ID;
	my $inXML = 0;		# �ثe�O�_�b xml �аO��?
	
	open NOTE, "$xml_note" || die "open $xml_note fail : $!";
	
	while(<NOTE>)
	{
		if(/<ID>(.*)<\/ID>/)
		{
			$ID = $1;
			next;
		}
		
		if(/<XML>/)
		{
			$inXML = 1;
			next;
		}
		
		if(/<\/XML>/)
		{
			$inXML = 0;
			next;
		}
		
		if($inXML)
		{
			$note_xml{$ID} .= $_;
		}
	}
	close NOTE;
}

##############################
# ���N�հɳB�z�@�U
##############################

sub fix_note()
{
	my $ID;
	my $lines;
	
	foreach $ID (sort(keys(%note_xml)))
	{
		$note_xml{$ID} =~ s/\n<((?:note)|(?:sic)|(?:app)|(?:foreign)|(?:tt))/<$1/g;	# �N�ťզ洫�^��
		$note_xml{$ID} =~ s/\n$//;
		
		if($note_xml{$ID} =~ /<lem>(.*?)<\/lem>/s)		# ���������g��
		{
			$note_source{$ID} = $1;
			if($note_source{$ID} =~ /<t lang="chi"[^>]*>(.*?)<\/t>/s)	# �±�ڤ�
			{
				$note_source{$ID} = $1;
			}
			if($note_source{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)	# �±�ڤ�
			{
				$note_source{$ID} = $1;
			}
		}
		elsif ($note_xml{$ID} =~ /<t lang="chi"[^>]*>(.*?)<\/t>/s)	# �±�ڤ�
		{
			$note_source{$ID} = $1;
			if($note_source{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)	# �±�ڤ�
			{
				$note_source{$ID} = $1;
			}			
		}
		elsif ($note_xml{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)		# �±�ڤ�
		{
			$note_source{$ID} = $1;
		}		
		else											# �S�����e.
		{
			$note_source{$ID} = "";
		}
		
		$note_source{$ID} = "" if($note_source{$ID} eq "&lac;");
		$lines  = 1;

		while($note_source{$ID} =~ /\n/g)
		{
			$lines++;
		}
		
		$note_lines{$ID} = $lines;
	}
}

##############################
# �B�z���U
##############################

sub run_with_xmls()
{
	my $file;
	my @files = <${xml_dir}${vol}/*.xml>;

	foreach $file (sort(@files))
	{
		print "Run $file\n" if $DEBUG;
		run_with_xml($file);
	}
}

##############################
# �B�z�@���ɮ�
##############################

sub run_with_xml()
{
	local $_;
	my $file = shift;
	my $ID;		# �հɪ��ߤ@�s��
	
	open XMLIN, $file;
	@xmls = <XMLIN>;
	close XMLIN;

	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		# <lb n="0001a19"/>�W�C�}<anchor id="fnT01p0001a07"/>�R�׳~�C�ҰO�����C�G�H�����ءC��
		# <lb n="0001a20"/>����̡C���g�y��C������<anchor id="fxT01p0001a1"/>��C��p�ީ]�C��
		# while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([nx])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/)
		
		while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([n])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/) # ���B�z n
		{
			my $pre_anchor = $1;
			my $n_x = $2;
			$ID = $3;

			my $IDtmp = $4;
			my $anchor_other = $5;

			if ($n_x eq "n")		# �հ�
			{
				$IDtmp = "00".$IDtmp if length($IDtmp) == 1;
				$IDtmp = "0".$IDtmp if length($IDtmp) == 2;
				$ID = $ID.$IDtmp;

				# ���X�Ҧ������
				for(my $j=1; $j<$note_lines{$ID}; $j++)
				{
					$anchor_other .= $xmls[$i+$j];
				}
				
				if($anchor_other =~ /^\Q$note_source{$ID}\E/)
				{
					$anchor_other =~ s/^\Q$note_source{$ID}\E/$note_xml{$ID}/;
				}
				else
				{
					$anchor_other = $note_xml{$ID} . $anchor_other;
					# �b xml �䤣���Ӫ����, �o�˴N�����D�F...
					print ERROUT "<�ɮ�>$file</�ɮ�>\n";
					print ERROUT "<ID>$ID</ID>\n\n";
					print ERROUT "<�հɱ���>\n";
					print ERROUT "$note_xml{$ID}\n";
					print ERROUT "</�հɱ���>\n\n";
					print ERROUT "<�g�夺�e>\n";
					print ERROUT "$xmls[$i]";
					print ERROUT "</�g�夺�e>\n\n";
					print ERROUT "<���Ӭ۲Ū����e>\n";
					print ERROUT "$note_source{$ID}\n";
					print ERROUT "</���Ӭ۲Ū����e>\n\n";
					print ERROUT "-----------------------------------\n\n";
				}

				# �A�N�B�z�n�� n ���^�h xml ��
						
				$anchor_ok = $pre_anchor . $anchor_other;
				for(my $j = 0; $j<$note_lines{$ID}; $j++)
				{
					if($anchor_ok =~ s/^(.*\n)//)
					{
						$xmls[$i+$j] = $1;
					}
					else
					{
						$xmls[$i+$j] = $anchor_ok;
						$anchor_ok = "";
					}					
				}
			}
		}
	}
	
	# �g��s�ɮ�
	
	$file =~ /.*\/(.*?\.xml)/;
	my $filename = $1;
	open XMLOUT, ">${out_dir}$filename" or die "open ${out_dir}$filename fail : $!";
	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		print XMLOUT $xmls[$i];
	}
	close XMLOUT;
}
