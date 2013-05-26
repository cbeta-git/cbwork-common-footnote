# rm_mod.pl
# 如果 <note type="mod"> 的內容與 <note type="orig"> 相同,
# 就把它移除
# v0.1, 2002/11/4 05:35PM by Ray
# v0.2, 2002/11/11 04:08PM by Ray
# v0.3, 2002/11/11 04:48PM by Ray

$in="d:/work/T05xml.txt";
$out="d:/work/T05xml-new.txt";
open I, $in or die;
open O, ">$out" or die;
select O;
while (<I>) {
	if (m#<note n="(.*?)" [^>]*?type="orig"[^>]*?>(.*?)</note>#) {
		$n=$1;
		$t=$2;
	}
	if (m#<note n="(.*?)" [^>]*?type="mod"[^>]*?>(.*?)</note>#) {
		if ($1 eq $n and $2 eq $t) {
			next;
		}
	}
	
	# 去掉 <n> 轉出的 <note n="..." place="foot">
	if (m#<note n="[^"]*" place="foot">#) {
		next;
	}
	
	# 為了區別以下三種情況, 將 place="foot" 改成 place="foot text"
	# 1.校勘欄沒校勘符號
	# 2.校勘欄有校勘符號但沒內容
	s/(type="orig" place="foot)"/$1 text"/;
	
	print;
}
close I;
close O;