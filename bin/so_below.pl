#---------------------------------------------------------------------------------------------
# so_below.pl
# 校勘＊自動處理
# 2003/2/25 03:13PM by Ray
# v 0.1, 2003/3/10 04:50PM 解決校勘內容跨行問題, by Ray
# v 0.11, 2003/3/13 02:52PM by Ray
# v 0.12, 2003/3/13 03:03PM by Ray
# v 0.13, 2003/3/13 03:20PM by Ray
# v 0.14, 2003/3/13 03:36PM by Ray
# v 0.15, 2003/3/18 03:06PM by Ray
# v 0.16, 2003/3/20 03:43PM by Ray
# v 0.17, 2003/3/27 04:41PM by Ray
# v 0.18, 2003/4/2 10:53AM by Ray
# v 0.19, 2003/4/28 04:37下午 by Ray
#	1.<app> 裏有 <todo> 也不處理,
# 	2. <todo type="i"/> 的前一組仍要處理
# v 1.0.0, <t place="foot"> 要去掉，2003/5/1 03:09下午 by Ray
# v 1.1.0, 處理一組校勘拆成多組 <app> 的。也就是 n 有分 a,b,c 的。2003/5/1 04:59下午 by Ray
# v 1.1.1, <app> 分 a,b, 仍可找到對應的, 2003/5/12 12:00下午 by Ray
# v 1.2.0, 2003/5/13 04:07下午 by Ray
# 	1.[＊]前有校勘數字, 不處理
# 	2.找到的對應校勘裏如果有對換符號，請查證
# 	3.找到的對應校勘 <app> 裏去除 <sic> 標記
# 	4.如果找到2筆對應校勘, 請查證.
# v 1.2.1, 2003/5/14 05:35下午 by Ray
# v 1.2.2, 2003/5/14 06:05下午 by Ray
# v 1.3.0, 找不到對應的, 再找疑似的 2003/5/26 04:54下午 by Ray
# v 1.3.1, 2003/5/29 06:02下午 by Ray
# v 1.4.0, 找疑似對應校勘時, <sic> 也要比對, 2003/6/5 02:44下午 by Ray
# v 1.4.1, 2003/6/14 05:44下午 by Ray
# v 1.4.2, 2003/6/16 03:16下午 by Ray
# v 1.4.3, 2003/6/17 10:30上午 by Ray
# v 1.5.0, 找到兩個可能對應的, 不寫入 LOGB, 2003/6/17 03:05下午 by Ray
#---------------------------------------------------------------------------------------------

require "so_below.cfg";

$vol=shift;
$vol=uc($vol);


opendir (INDIR, "$in_dir/$vol") or die;
@allfiles = grep(/\.xml$/i, readdir(INDIR));
closedir INDIR;

die "No files to process\n" unless @allfiles;
print STDERR "Initialising....\n";

#utf8 pattern
$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
my $big5 = "(?:[\x00-\x7f]|[\x80-\xff][\x00-\xff])";

($path, $name) = split(/\//, $0);
push (@INC, $path);
push (@INC, "c:/cbwork/work/bin");

require "utf8b5o.plx";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;
       
my $parser = new XML::Parser(NoExpand => True);        
        
$parser->setHandlers(
	Init => \&init_handler,
	Start => \&start_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default,
	Final => \&final
);

mkdir($log_dir, MODE);
open LOGA, ">$log_dir/star_${vol}a.txt" or die;
open LOGB, ">$log_dir/star_${vol}b.txt" or die;
open LOGC, ">$log_dir/star_${vol}c.txt" or die;
open LOGE, ">$log_dir/star_${vol}e.txt" or die;
for $file (sort(@allfiles)) { 
	print LOGB "$file\n";
	process1file($file);
}
close LOGA;
close LOGB;

print STDERR "完成!!\n";
        
sub process1file {
	$file = shift;
	$file =~ s/^t/T/;
	print STDERR "$file\n";
	$parser->parsefile("$in_dir/$vol/$file");
}

#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	#print STDERR "開啟 Entity 定義檔: $file\n";
	if ($file=~/\.gif$/) {
		return;
	}
	open(T, "$in_dir/$vol/$file") || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		$Entities{$ent} = $ent;
		#print STDERR "Entity: $ent -> $ent\n";
  }
}       
        
        
sub default {
    my $p = shift;
    my $string = shift;
	$string =~ s/^&(.+);$/$1/;
	if ( defined($Entities{$string}) ) { 
		my $s="&$string;";
		text_handler($s);
	}
}
        
sub init_handler
{       
	my $s = $file;
	print LOGA "$s 開始....\n";
	$s =~ s/\.xml/\.ent/;
	#print <<"EOD";
#<?xml version="1.0" encoding="big5" ?>
#<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
#<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
#[<!ENTITY % ENTY  SYSTEM "$s" >
#<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
#%ENTY;
#%CBENT;
#]>
#EOD
	%anchorJuan=();
	%app_xml=();
	@apps=();
	$buf='';
	$ifStarAtThisLine=0;
	$in_sic=0;
	%lem=();
	@lems=();
	%match=();
	%note_juan=();
	@note_with_star=();
	@n_all=();
	@lem_with_star=();
	%note_text=();
	$note_type="";
	$pass=1;
	@pass=();
	@search_list=();
	%sic=();
}



sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	push @pass, $pass;
	my $parent = lc($p->current_element);

	# <anchor>
	if ($el eq "anchor") {
		if ($att{"id"}=~/^fx/) {
			search_star();
			$anchorID=$att{"id"};
			$anchorJuan{$anchorID}=$juan;
			$lb_of_star{$anchorID}=$lb;
			$buf = "<anchor>";
			print LOGA "$lb 出現＊ id=$anchorID\n";
			#print LOGA "上一條有＊的校勘是";
			$i=scalar @note_with_star-1;
			#print LOGA $note_with_star[$i], "\n";
			$ifStarAtThisLine=1;
			$text_in_line{$lb} .= "[＊]";
		}
	}

	# <app>
	if ($el eq "app") {
		#$appN = substr($att{"n"},0,7);
		$appN = $att{"n"};
		push @apps, $appN;
	}
	
	# <figure>
	if ($el eq "figure") {
		text_handler(uc($att{"entity"}));
	}
	
	# <lb>
	if ($el eq "lb") {
		$lb=$att{"n"};
		$text_in_line{$lb}='';
		$ifStarAtThisLine=0;
	}

	# <lem>
	if ($el eq "lem") {
		#$lem{$appN}='';
		$i=scalar @note_with_star;
		if ($note_with_star[$i-1] eq substr($appN,0,7)) {
			#push @lem_with_star, $appN;
			push @search_list, $appN;
		}
		push @n_all, $appN;
		push @lems, $appN;
	}
	
	# <milestone>
	if ($el eq "milestone") {
		if ($att{"unit"} eq "juan") {
			$juan=$att{"n"};
		}
	}
	
	# <note>
	if ($el eq "note") {
		$note_type = $att{"type"};
		$note_n = $att{"n"};
		$note_juan{$note_n}=$juan;
		if ($note_type =~ /^orig|mod$/) {
			if (not exists $note_text{$note_n}) {
				$n=substr($note_n,4);
				$n=~s/0(\d\d)/$1/;
				$text_in_line{$lb} .= "[" . $n . "]";
			}
			$note_text{$note_n}='';
			search_star();
			$pass=0;
		}
		push @n_all, $note_n;
	}

	# <rdg>
	if ($el eq "rdg") {
		$pass=0;
	}
	
	# <sic>
	if ($el eq "sic") {
		$in_sic=1;
		$sic_n=$att{"n"};
		my $i=scalar @note_with_star-1;
		if ($sic_n ne '' and $note_with_star[$i] eq substr($sic_n,0,7)) {
			push @search_list, $sic_n;
		}
	}
	
	# <t>
	if ($el eq "t") {
		if ($att{"place"}=~/foot/) {
			$pass=0;
		}
	}
	
	# <todo>
	if ($el eq "todo") {
		if ($att{"type"} eq "i") {
			text_handler("<todo_i>");
		} else {
			text_handler("<todo>");
		}
	}

	my $x="<$el";
	while (($key,$value) = each %att) {
		$value = myDecode($value);
		$x .= " $key=\"$value\"";
	}
	if ($el=~/^(lb|pb|figure)$/) { $x .= "/"; }
	$x .= ">";
	#print $x;
	add_app_xml($x);
}

sub rep{
	local($x) = $_[0];
	return $x;
}       
        

sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
	if ($el!~/^(lb|pb|figure)$/) { 
		#print "</$el>"; 
		add_app_xml("</$el>");
	}

	# </app>
	if ($el eq "app") {
		my $n=substr($appN,0,7);
		#print LOGA "266 $n\n";
		if ($note_text{$n} =~ /^$big5*＊/) {
			print LOGA "$appN <lem> 裏的文字：" . $lem{$appN} . "\n\n";
		}
		$appN=pop @apps;
	}

	# </lem>
	if ($el eq "lem") {
		pop @lems;
	}
	
	# </note>
	if ($el eq "note") {
		if ($note_type =~ /^orig|mod$/) {
			if ($note_text{$note_n} =~ /^$big5*＊/) {
				print LOGA "校勘 [$note_n] ", $note_text{$note_n}, "\n";
				print LOGA "\n";
				$i=scalar @note_with_star;
				if ($note_with_star[$i-1] ne $note_n) {
					push @note_with_star, $note_n;
					$match{$note_n}=0;
				}
			} else {
				#print LOGA "無＊的校勘 [$note_n] ", $note_text{$note_n}, "\n";
			}
		}
		$note_type="";
	}
	
	# </sic>
	if ($el eq "sic") {
		$in_sic=0;
	}

	$pass=pop @pass;
}
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	$char =~ s/($pattern)/$utf8out{$1}/g;
	
	text_handler($char);
}

sub text_handler {
	my $c=shift;
	#print $c;
	if ($note_type =~ /^orig|mod$/) {
		$note_text{$note_n} .= $c;
	}
	if ($pass) {
		$text_in_line{$lb} .= $c;
	}
	
	add_app_xml($c);
	
	$c =~ s/\n$//;
	#my $n;
	#foreach $n (@lems) {
	#	$lem{$n} .= $c;
	#}	
	if ($pass) {
		my $n;
		foreach $n (@lems) {
			$lem{$n} .= $c;
		}	
	}
	$buf .= $c;
	
	if ($in_sic and $sic_n ne '') {
		$sic{$sic_n}.=$c;
	}
}

sub add_app_xml {
	$s=shift;
	foreach $n (@apps) {
		$app_xml{$n} .= $s;
	}
}

sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
	return 1;
}       
        

sub final {
	if ($anchorID ne '') {
		search_star();
	}
	my $first=1;
	foreach $n (sort keys %match) {
		if ($match{$n}==0) {
			if ($first) {
				print LOGA "$file 含＊的校勘條目但內文中無對應的＊:\n";
				$first=0;
			}
			print LOGA "$n\n";
			print LOGC "$file $n\n";
		}
	}
	print LOGA "\n";
}

sub myDecode {
	my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}

sub search_star {
	# 除了 】 之外的中文字
	my $c="(?:[\x80-\xa0][\x00-\xff]|\xa1[\x00-\x69]|\xa1[\x6b-\xff]|[\xa2-\xff][\x00-\xff])";
	
	if ($buf !~ /<anchor>/) {
		$buf='';
		return;
	}
	
	$i=$lb_of_star{$anchorID};
	my $s=$text_in_line{$i};
	$s=~s/\n$//;
	print LOGA "本文：$s\n";
	if ($s=~/\[＊\](\[\d*?\])?$/) {
		print LOGA "[＊]後無文字\n\n";
		$buf='';
		return;
	}
	
	if ($s=~/\[\d{2,3}\]\[＊\]/) {
		print LOGA "[＊]前有校勘數字，不處理\n\n";
		$buf='';
		return;
	}
	
	print LOGA "搜尋 <anchor id='$anchorID'> 的對應校勘....\n";
	#for($i=scalar @note_with_star-1; $i>=0; $i--) {
	$found_count=0;
	$stop=0;
	$found_sic=0;
	$logb_buf='';
	#for($i=scalar @lem_with_star-1; $i>=0; $i--) {
	#for($i=scalar @n_all-1; $i>=0; $i--) {
	for($i=scalar @search_list-1; $i>=0; $i--) {
		$insert=0;
		#$n=$lem_with_star[$i];
		$n=$search_list[$i];
		$t=$lem{$n};
		$s=$sic{$n};
		$temp_note_n = substr($n,0,7);
		#print LOGA "text in lem($n)=$t\n";
		$found=0;
		if ($t ne '' and $buf=~/<anchor>\Q$t\E/) {
			if ($found_count>0) {
				if (length($t) > $lem_length) { # 如果又找到符合更長的
					$found=1;
					$found_count++;
				}
			} else {
				$found=1;
				$found_count++;
			}
			$insert=1;
			if ($found) {
				#$jk = $note_text{$n};
				$jk = $note_text{$temp_note_n};
				#if ($juan ne $note_juan{$temp_note_n}) {
				if ($anchorJuan{$anchorID} ne $note_juan{$temp_note_n}) {
					#print LOGA "目前在第${juan}卷 $temp_note_n在第", $note_juan{$temp_note_n}, "卷\n";
					print LOGA "\t在另一卷";
					$insert=0;
				}
				print LOGA "\t找到對應的校勘:[$temp_note_n] $jk\n";
				if ($jk=~/^$big5*∞/) {
					print LOGA "找到的校勘有對調符號，請查證！\n";
					$insert=0;
				}
				$lem_length=length($t);
			}
		} elsif ($s ne '' and $buf=~/<anchor>\Q$s\E/) {
			$found=1;
			$found_sic=1;
			$found_count++;
			$jk = $note_text{$temp_note_n};
			if ($anchorJuan{$anchorID} ne $note_juan{$temp_note_n}) {
				print LOGA "在另一卷";
			}
			print LOGA "找到 $anchorID 對應的 sic 校勘:[$temp_note_n] $jk\n";
			$stop=1;
		} elsif ($found_count==0) {
			# 例 <anchor id="fxT08p0281b01"> ＊的文字範圍包校勘符號
			$t = "<anchor>" . $t;
			if ($t =~ /\Q$buf\E/) {
				$found=1;
				$insert=0;
				$found_count=999;
				#$jk = $note_text{$n};
				$jk = $note_text{$temp_note_n};
				print LOGA "\t找到可能對應的校勘:[$temp_note_n] $jk\n";
				print LOGA "\t請查證\n";
			}
		}
		if ($found) {
			#if ($jk =~ /<todo>/) {
			if ($jk =~ /<todo>/ or $app_xml{$n}=~/<todo>/) {
				print LOGA "校勘中有 <todo> 不處理\n\n";
				last;
			}
			$match{$temp_note_n}++; # 記錄本條校勘有被使用到
			if (exists $app_xml{$n}) {
				$vers='';
				$jk=~s/下同/＊/g;
				@tokens=split /，/, $jk;
				$jk='';
				foreach $token (@tokens) {
					#print LOGA "349 $token\n";
					# 如果最後是＊
					if ($token=~/＊$/) {
						if ($token =~ /&M062403;/ and $token =~ /&M062303;/) {
							$token = "【？】＊【Ａ】＊【Ｂ】＊";
						} elsif ($token =~ /&M062403;/) {
							$token = "【？】＊【Ａ】＊";
						} elsif ($token =~ /&M062303;/) {
							$token = "【？】＊【Ｂ】＊";
						} elsif ($token!~/＊.*＊/) { # 前面又沒有夾雜＊
							#$s=~s/(【$c*?】)/$1＊/g; # 那就每個版本都算有＊
							$token=~s/】【/】＊【/g; # 那就每個版本都算有＊
						}
					}
					$jk .= $token;
				}
				#print LOGA "362 $jk\n";
				$jk =~ s/(【$c*?】)＊/&ver($1)/ge;
				if ($vers eq '') {
					print LOGA "沒有符合的版本\n";
				} else {
					print LOGA "\t符合的版本", $vers, "\n";
					print LOGA "\t對應的 app:\n";
					$xml=$app_xml{$n};
					$xml=~s/FIGT\d{8}//g;
					print LOGA "\t" . $xml . "\n";
					print LOGA "\t過濾後的 app:\n";
					$xml=filter_rdg($xml);
					$xml =~ s#<anchor id="fxT\d\dp\d{4}.\d\d"></anchor>##g;
					print LOGA "\t$xml\n";
					if ($insert) {
						$logb_buf .= "$anchorID##$xml\n";
					}
				}
			} elsif (not $found_sic) {
				print LOGA "找不到 app\n";
			}
			print LOGA "\n";
			#last;
		}
		if ($found_count==2) {
			print LOGA "\t找到2個可能對應的校勘，請查證！\n\n";
		}
		if ($found_count>1) {
			last;
		}	
		if ($stop) {
			last;
		}
	}
	if ($found_count==1) {
		print LOGB $logb_buf;
	} elsif ($found_count==0) {
		print LOGA "\tError: 找不到對應的校勘\n\n";
		search_suspect();
	}
	$buf='';
	$anchorID='';
}

# 尋找疑似對應的校勘
sub search_suspect {
	# 除了 】 之外的中文字
	my $c="(?:[\x80-\xa0][\x00-\xff]|\xa1[\x00-\x69]|\xa1[\x6b-\xff]|[\xa2-\xff][\x00-\xff])";
	my $s;
	$found=0;
	for($i=scalar @n_all-1; $i>=0; $i--) {
		$n=$n_all[$i];
		$t=$lem{$n};
		$temp_note_n = substr($n,0,7);
		$s=$sic{$temp_note_n};
		#print LOGE "571 $n $temp_note_n $t $s\n";
		if ($t ne '' and $buf=~/<anchor>\Q$t\E/) {
			$found=1;
			$jk = $note_text{$temp_note_n};
			if ($anchorJuan{$anchorID} ne $note_juan{$temp_note_n}) {
				print LOGE "在另一卷";
			}
			print LOGE "找到 $anchorID 疑似對應的校勘:[$temp_note_n] $jk\n";
			if ($jk=~/^$big5*∞/) {
				print LOGE "找到的校勘有對調符號，請查證！\n";
			}
		} elsif ($s ne '' and $buf=~/<anchor>\Q$s\E/) {
			$found=1;
			$jk = $note_text{$temp_note_n};
			if ($anchorJuan{$anchorID} ne $note_juan{$temp_note_n}) {
				print LOGE "在另一卷";
			}
			print LOGE "找到 $anchorID 疑似對應的 sic 校勘:[$temp_note_n] $jk\n";
			if ($jk=~/^$big5*∞/) {
				print LOGE "找到的校勘有對調符號，請查證！\n";
			}
		} else {
			# 例 <anchor id="fxT08p0281b01"> ＊的文字範圍包校勘符號
			$t = "<anchor>" . $t;
			if ($t =~ /\Q$buf\E/) {
				$found=1;
				$jk = $note_text{$temp_note_n};
				print LOGE "找到 $anchorID 疑似可能對應的校勘:[$temp_note_n] $jk\n";
				print LOGE "請查證\n";
			}
		}
		if ($found) {
			last;
		}
	}
}

sub ver {
	my $s=shift;
	$vers .= $s;
}

sub filter_rdg {
	my $x=shift;
	$x =~ s/\n//g;
	$x =~ s/(<rdg.*?wit=")(.*?)(".*?>.*?<\/rdg>)/&rep1($1,$2,$3)/ge;
	$x =~ s/<lb.*?\/>//g;
	$x =~ s/(<app[^>]*?)n(=".*?">)/$1type="＊" source$2/;
	$x =~ s#<sic[^>]*?>(.*?)</sic>#$1#g;
	#print LOGA "333 $x\n";
	return $x;
}

sub rep1 {
	my $before=shift;
	my $wit=shift;
	my $after=shift;
	#print LOGA "340 $before$wit$after\n";
	$wit =~ s/(【.*?】)/&rep2($1)/ge;
	#print LOGA "342 $wit\n";
	if ($wit eq '') {
		return '';
	} else {
		return $before . $wit . $after;
	}
}

sub rep2 {
	my $s=shift;
	#print LOGA "351 $s\n";
	if ($vers =~ /\Q$s\E/) {
		return $s;
	} else {
		return '';
	}
}
        
__END__ 
:endofperl
