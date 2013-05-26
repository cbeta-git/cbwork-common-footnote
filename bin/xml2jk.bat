@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!perl
#line 14

#-------------------------------------------------------------------------------
# xml2jk.bat
# Version 0.1
# 2002/6/27 05:11PM
#
# 這個程式會讀入一個 XML, 輸出一個去掉校勘標記 XML, 以及另一個校勘條目檔
#
# 處理的校勘標記:
#	<anchor>, <app>, <skgloss>
#
# created by Ray 2002/5/10
#---------------------------------------------------------------------------------
$vol = shift;
$inputFile = shift;

$chm;
$nid=0;
$vol = uc($vol);
$xml_dir = "c:/cbwork/xml/"; # xml 輸入目錄
#$dir = "c:/Documents and Settings/eva.CBETA/桌面/T12";  # 輸出目錄
$dir = "d:/temp";  # 輸出目錄
$vol = substr($vol,0,3);

mkdir($dir . "new-xml", MODE);
mkdir($dir . "new-xml/" . $vol, MODE);
mkdir($dir . "JiaoKan", MODE);
mkdir($dir . "JiaoKan/" . $vol, MODE);

opendir (INDIR, $xml_dir . $vol);
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "utf8b5o.plx";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;


my %Entities = ();
my %dia = (
 "Amacron","AA",
 "amacron","aa",
 "ddotblw",".d",
 "Ddotblw",".D",
 "hdotblw",".h",
 "imacron","ii",
 "ldotblw",".l",
 "Ldotblw",".L",
 "mdotabv","%m",
 "mdotblw",".m",
 "ndotabv","%n",
 "ndotblw",".n.",
 "Ndotblw",".N",
 "ntilde","~n",
 "rdotblw",".r",
 "sacute","`s",
 "Sacute","`S",
 "sdotblw",".s",
 "Sdotblw",".S",
 "tdotblw",".t",
 "Tdotblw",".T",
 "umacron","^u"
);      
        
my $parser = new XML::Parser(NoExpand => True);
        
        
$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);
        
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { process1file($file); }
} else {
  $file = $inputFile;
  process1file($file);
}       
        
print STDERR "完成!!\n";
        
sub process1file {
	$file = shift;
	$file =~ s/^t/T/;

	$jk_file = $file;
	$jk_file =~ s/\.xml$/\.txt/;

	print STDERR "\n==>${dir}/new-xml/$vol/$file $jk_file\n";
	open O, ">$dir/new-xml/$vol/$file" or die;
	open JK, ">$dir/JiaoKan/$vol/$jk_file" or die;
	select O;
	$parser->parsefile($file);
	close O;
}

#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	print STDERR "開啟 Entity 定義檔: $file\n";
	open(T, $file) || die "can't open $file\n";
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
	if ($string eq "&lac;") {
		return;
	}
	$string =~ s/^&(.+);$/$1/;
	if ( defined($Entities{$string}) ) { 
		my $s="&$string;";
		if ($pass==0) {
			print "&$string;"; 
		}
		if ($in_gloss) {
			print JK $dia{$string};
		}
		if ($in_lem) {
			$lem .= $s;
		}
		if ($in_rdg) {
			$rdg .= $s;
		}
		if ($in_term and $in_skgloss) {
			print JK $s;
		}
	}
}
        
sub init_handler
{       
	my $s = $file;
	$s =~ s/\.xml/\.ent/;
	print <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "$s" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
EOD

	$pb="";
	$pass==0;
	$in_lem=0;
	$in_rdg=0;
	$in_gloss=0;
	$in_skgloss=0;
	$in_term=0;
}
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

	# <anchor>
	#if ($el eq "anchor") {
	#	my $id=$att{"id"};
	#	if ($id =~ /^fx/) {
	#		print "[＊]";
	#	}
	#	return;
	#}

	# <app>
	if ($el eq "app") {
		my $n=$att{"n"};
		if ($n =~ /^x/) {			
			my $s=sprintf("%2.2d", $fx);
			print "<anchor id=\"fx${vol}p$pb$s\"/>";
			$fx++;
		} else {
			$n=substr($n,4,2);
			print "<anchor id=\"fn${vol}p$pb$n\"/>";
			print JK "  $n ";
		}
		return;
	}

	# <gloss>
	if ($el eq "gloss") {
		$in_gloss=1;
		$pass++;
		$gloss="";
		return;
	}

	# <lem>
	if ($el eq "lem") {
		$in_lem=1;
		$lem="";
		return;
	}

	# <pb>
	if ($el eq "pb") {
		my $n=$att{"n"};
		#$n=substr($n,0,4);
		if ($n ne $pb) {
			$pb=$n;
			print JK "p$pb\n";
		}
		$fx=1;
	}

	# <rdg>
	if ($el eq "rdg") {
		$wit = myDecode($att{"wit"});
		$in_rdg=1;
		$rdg="";
		$pass++;
		return;
	}

	# <skgloss>
	if ($el eq "skgloss") {
		$in_skgloss=1;
		my $n=$att{"n"};
		$n=substr($n,4,2);
		print "<anchor \"fn$vol$pb$n\"/>";
		print JK "  $n ";
		return;
	}

	# <term>
	if ($el eq "term") {
		$in_term=1;
		if ($parent eq "skgloss") {
			return;
		}
	}

	print "<$el";
	while (($key,$value) = each %att) {
		$value = myDecode($value);
		print " $key=\"$value\"";
	}
	if ($el =~ /^(anchor)|(lb)|(pb)$/) { print "/"; }
	print ">";
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

	# </anchor>
	if ($el eq "anchor") {
		return;
	}

	# </app>
	if ($el eq "app") {
		print JK "\n";
		return;
	}

	# </gloss>
	if ($el eq "gloss") {
		$pass--;
		$in_gloss=0;
		print JK $gloss;
		return;
	}
	
	# </lem>
	if ($el eq "lem") {
		$in_lem=0;
		if ($lem eq "") {
			print JK "＋";
		} else {
			print JK "$lem＝";
		}
		return;
	}

	# </rdg>
	if ($el eq "rdg") {
		$in_rdg=0;
		$pass--;
		print JK "$rdg$wit";
		return;
	}

	# </skgloss>
	if ($el eq "skgloss") {
		print JK "\n";
		$in_skgloss=0;
		return;
	}

	# </term>
	if ($el eq "term") {
		$in_term=0;
		if ($parent eq "skgloss") {
			return;
		}
	}

	if ($el ne "lb" and $el ne "pb") { 
		print "</$el>"; 
	}
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	if ($parent eq "app" or $parent eq "skgloss") {
		return;
	}

	$char =~ s/($pattern)/$utf8out{$1}/g;
	if ($pass==0) {
		print $char;
	}

	if ($in_gloss) {
		print JK $char;
	}

	if ($in_lem) {
		$lem .= $char;
	}
	
	if ($in_rdg) {
		$rdg .= $char;
	}

	if ($in_term and $in_skgloss) {
		print JK $char;
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
        
        
sub myDecode {
	my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}

        
__END__ 
:endofperl
