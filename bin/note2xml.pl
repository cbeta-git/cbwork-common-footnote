##################################################################################
# 校勘插入程式  V1.0  2002/07/04 by heaven
# 相關參數請修改 note2xml_pre.pl 這支程式
##################################################################################

require "note2xml_pre.pl";		#取得預設的參數

# 變數 

my %note_xml;		# 校勘的記錄, 以 ID 為索引
my %note_source;	# 原本在 XML 上的資料
my %note_lines;		# 在 xml 上的行數
my $DEBUG = 1;		# 沒什麼, 只是若 = 0 則畫面不會有訊息.

## 主程式 #################

open ERROUT, ">$err_out" || die "open error out $err_out fail : $!";

unless(-d $out_dir)
{
	mkdir("$out_dir", 0777);	# 產生輸出目錄
}

unless(-d $out_dir)
{
	print "輸出目錄產生失敗, 請自行建立目錄 $out_dir\n";
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
# 先將校勘讀入
##############################

sub read_note()
{
	my $ID;
	my $inXML = 0;		# 目前是否在 xml 標記中?
	
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
# 先將校勘處理一下
##############################

sub fix_note()
{
	my $ID;
	my $lines;
	
	foreach $ID (sort(keys(%note_xml)))
	{
		$note_xml{$ID} =~ s/\n<((?:note)|(?:sic)|(?:app)|(?:foreign)|(?:tt))/<$1/g;	# 將空白行換回來
		$note_xml{$ID} =~ s/\n$//;
		
		if($note_xml{$ID} =~ /<lem>(.*?)<\/lem>/s)		# 有相應的經文
		{
			$note_source{$ID} = $1;
			if($note_source{$ID} =~ /<t lang="chi"[^>]*>(.*?)<\/t>/s)	# 純梵巴文
			{
				$note_source{$ID} = $1;
			}
			if($note_source{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)	# 純梵巴文
			{
				$note_source{$ID} = $1;
			}
		}
		elsif ($note_xml{$ID} =~ /<t lang="chi"[^>]*>(.*?)<\/t>/s)	# 純梵巴文
		{
			$note_source{$ID} = $1;
			if($note_source{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)	# 純梵巴文
			{
				$note_source{$ID} = $1;
			}			
		}
		elsif ($note_xml{$ID} =~ /<sic[^>]*>(.*?)<\/sic>/s)		# 純梵巴文
		{
			$note_source{$ID} = $1;
		}		
		else											# 沒有內容.
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
# 處理全冊
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
# 處理一個檔案
##############################

sub run_with_xml()
{
	local $_;
	my $file = shift;
	my $ID;		# 校勘的唯一編號
	
	open XMLIN, $file;
	@xmls = <XMLIN>;
	close XMLIN;

	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		# <lb n="0001a19"/>名。開<anchor id="fnT01p0001a07"/>析修途。所記長遠。故以長為目。翫
		# <lb n="0001a20"/>茲典者。長迷頓曉。邪正難<anchor id="fxT01p0001a1"/>辨。顯如晝夜。報
		# while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([nx])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/)
		
		while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([n])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/) # 先處理 n
		{
			my $pre_anchor = $1;
			my $n_x = $2;
			$ID = $3;

			my $IDtmp = $4;
			my $anchor_other = $5;

			if ($n_x eq "n")		# 校勘
			{
				$IDtmp = "00".$IDtmp if length($IDtmp) == 1;
				$IDtmp = "0".$IDtmp if length($IDtmp) == 2;
				$ID = $ID.$IDtmp;

				# 取出所有的資料
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
					# 在 xml 找不到原來的資料, 這樣就有問題了...
					print ERROUT "<檔案>$file</檔案>\n";
					print ERROUT "<ID>$ID</ID>\n\n";
					print ERROUT "<校勘條目>\n";
					print ERROUT "$note_xml{$ID}\n";
					print ERROUT "</校勘條目>\n\n";
					print ERROUT "<經文內容>\n";
					print ERROUT "$xmls[$i]";
					print ERROUT "</經文內容>\n\n";
					print ERROUT "<應該相符的內容>\n";
					print ERROUT "$note_source{$ID}\n";
					print ERROUT "</應該相符的內容>\n\n";
					print ERROUT "-----------------------------------\n\n";
				}

				# 再將處理好的 n 行放回去 xml 中
						
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
	
	# 寫到新檔案
	
	$file =~ /.*\/(.*?\.xml)/;
	my $filename = $1;
	open XMLOUT, ">${out_dir}$filename" or die "open ${out_dir}$filename fail : $!";
	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		print XMLOUT $xmls[$i];
	}
	close XMLOUT;
}
