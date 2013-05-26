##############################################################
# $Id: add_zh2.pl,v 1.1 2001/11/09 05:44:00 heaven Exp $
#
# add_zh.pl	將校勘條目檔沒有中文的梵巴註解加上中文經文
#
# 本程式二支為一套
#
# add_zh.pl 由舊的校勘條目產生新的校勘條目, 並且在有梵巴卻沒中文的條目上,
#           附上原始經文, 提供選擇, 以便插入校勘條目中.
# del_zh.pl 將處理好的校勘條目當中額外的資料刪除, 也就是簡單標記的經文, 
#           其特色是每一行首都是 <z> 開頭
#
# 使用法: 主要要修改下列三個參數
#   
#         $infile : 原始的校勘條目檔的位置
#         $sutra : 簡單標記版經文的位置
#
#         $outfile : 要輸出的新的校勘條目檔
##############################################################

use strict;

#-------------------------------------------
# 和傳入參數有關的變數
#-------------------------------------------

# 目前有 rd, heaven 若有特殊需求者, 請告訴我
my $Iam = "heaven";	
$Iam = $ARGV[0] if($ARGV[0]);	# 若有傳入參數, 則用此參數

#-------------------------------------------
# 可修改的變數
#-------------------------------------------

my $vol = "T01";

my $infile = "${vol}校勘條目.txt";				# 校勘條目檔
my $sutra = "c:/cbwork/simple/${vol}/new.txt";	# 原始經文檔（簡單標記版）

#if($Iam eq "rd")
#{
#	$infile = "${vol}校勘條目.txt";				# 校勘條目檔
#	$sutra = "c:/cbwork/work/maha/${vol}/T01maha.txt";	# 原始經文檔（簡單標記版）
#}

my $outfile = "${vol}notenew.txt";			# 基本輸出結果檔

#-------------------------------------------
# 無需修改的參數
#-------------------------------------------
#-------------------------------------------
# 檔案 handle
#-------------------------------------------

local *IN;
local *OUT;

#-------------------------------------------
# 校勘資料
#-------------------------------------------

my @note;		# 校勘條目
my @sutra;		# 簡單標記版

##########################################################
#  主 程 式
##########################################################

open IN, $infile || die "open $infile error";
@note = <IN>;	# 校勘資料
close IN;

open IN, $sutra || die "open $sutra error";
my @sutra = <IN>;	# 簡單標記經文
close IN;

open OUT, ">$outfile" || die "open $outfile error";
note_analysis();	# 簡單分析校勘條目, 並存入 %note
close OUT;

select STDOUT;
print "ok [any key to exit]\n";
<>;
exit;
########################################################

sub note_analysis()
{
	my $ID;				# %note 的ID
	my $note_page;		# 校勘的頁
	my $note_num;		# 校勘的編號
	my $ptr = 0;		# 已在簡單標記版檢查到的數字

	select OUT;

	for(my $i = 0;$i <= $#note; $i++)
	{
		if($note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			print $note[$i];
			next;
		}

		if($note[$i] =~ /^\s*(?:◎)?(\d+)\s*(?:(?:<~>)|(?:<s>)|(?:<p>)|(?:～)).+$/)	# 標準格式的校勘
		{
			$note_num = $1;
			#print $note[$i];
			$ptr = print_sutra($ptr, $note_page, $note_num, $note[$i]);
		}
		else					# 非標準格式校勘
		{
			print $note[$i];
		}
	}
}

###############################################

sub print_sutra()
{
	# T01n0001_p0001a04A##[02]長安釋僧肇[03]述
	
	local $_;
	my $ptr = shift;
	my $page = shift;
	my $note_num = shift;
	my $oldnote = shift;
	my $mypage;

	for(my $i = $ptr; $i<=$#sutra; $i++)
	{
		$_ = $sutra[$i];
		/T.{8}p(\d{4})/;
		$mypage = $1;

		if ($mypage > $page)		# 頁數超過了
		{
			print $oldnote;
			print "<z>\n<z> not found\n<z>\n";
			return $i;
		}
		
		if(($mypage == $page) && (/\[$note_num\]/))
		{
			# 先將 <z> 那些東西做出來
			
			my $zh1 = $sutra[$i];
			my $zh2 ="";
			$zh2 =  $sutra[$i+1] if($i < $#sutra);
			
			chomp($zh1);
			chomp($zh2);
			$zh1 =~ s/^T.{19}//;
			$zh2 =~ s/^T.{19}//;
			$zh1 .= $zh2;
			$zh1 =~ s/^.*?\[$note_num\](.*)/$1/;
			$zh1 =~ s/^(.*?)。.*/$1/;	# 只剩下句點處
			$zh1 = "<z>" . $zh1 . "■";
			$oldnote =~ s/^(\s*(?:◎)?(?:\d+)\s*)((?:(?:<~>)|(?:<s>)|(?:<p>)|(?:～)).+)$/$1$zh1$2/;
			print $oldnote;
			
			
			print "<z>\n";
			print "<z>$sutra[$i-1]" if($i > 0);
			s/(\[$note_num\])/$1●<z>/;
			print "<z>$_";
			print "<z>$sutra[$i+1]" if($i < $#sutra);
			print "<z>\n";
			return $i;
		}
	}
	return $#sutra;
}

############### end #######################