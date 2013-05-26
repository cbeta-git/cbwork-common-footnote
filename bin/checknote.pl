#############################################
# 校勘檢查程式
# $Id: checknote.pl,v 1.1.1.1 2003/05/05 04:04:55 ray Exp $
#
# V0.1 (2001/08/11)	第一版
# V0.2 (2001/08/12)	1.處理 ∞ 標記
#					2.將版本與星號的判斷改一改, 讓星號可夾在版本之間, 例:
#					 ((?:\s*【.*】\s*)+)((?:＊)?)  ==> 【明】【三】【元】＊ (星號只在後面)
#					 改成
#					 ((?:\s*【.*】\s*(?:＊)?)+)((?:＊)?)  ==> 【明】＊【三】【元】＊ (星號可在中間)
#					 這樣錯誤會較少, 但 $ver 的儲存則不準了
#					3.將文字的判斷改一改, 有…不算錯, 只是無法判斷是否與經文相合, 例:
#					 if (($oldword !~ /(…)|(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)| /) and ($newword !~ /(…)|(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)| /))
#					 改成
#					 if (($oldword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)| /) ....
#					4.允許格式 2, 3 加上 xx 字
# 					 格式 2. 缺字: 14 〔為〕－【三】＊
#					 格式 3. 前加字: 12 （彼）＋放逸【三】＊
# 					 格式 4. 後加字: 28 壁＋（者）【三】＊
#					 變成
# 					 格式 2. 缺字: 14 〔為〕xx字－【三】＊
#					 格式 3. 前加字: 12 （彼）xx字＋放逸【三】＊
#					 格式 4. 後加字: 28 壁＋（者）xx字【三】＊
# V0.3 (2001/08/13)	1.處理 ◎　 ── 異同 (似乎不用特別理它, 只要知道它的存在即可)
#					2.處理（（））─ 與＝配合使用
#					3.星號的位置, 有時也會用 "下同"
#					4.允許一些不重要位置的空格(包括全半型)
#					5.允許某些 "夾註" 的出現
#					6.格式8. 允許一些特殊的句子
# V0.4 (2001/08/15)	1.格式 6 忘了處理比較複雜的版本
#					  0379003 : 南無普德佛∞南無妙智佛【宋】【元】【宮】
#					  18 （南無勝…劫佛）十三字∞南無離劫佛【三】【宮】
# V0.5 (2001/08/22)	1.修改輸出格式, 以配合漢書的 .search
# V0.6 (2001/09/03)	1.嘗試做 xml 版
####  開始使用 CVS
# V3.0 (2001/09/09) 1.改了很多....
# V3.2 (2001/09/13)
# V3.3 (2001/09/17) 1.處理自訂的標記 <n><x><a><d><?><~>
#					2.處理多層的全型括號
#					3.自動處理倒八符號(∞)的校勘 (第二組會自動換位置)
# V3.4 (2001/09/17) 1.改上一版小 bug
####  移到新位置, 所以換成 1.2 版
# V1.2 (2001/09/20) 1.梵巴文字變成 &xxxx; 碼了
# V1.3 (2001/09/20)	1.增加執行參數, 以方便預設變數, 例如 rd 可輸入 checknote.pl rd
# V1.4 (2001/09/20)	1.缺字可以換成 CB 碼了.
# V1.5 (2001/09/24)	1.小括號要換成 <note place=inline>
#                   2.尋找 xml 的精準範圍
# V1.6 被別人改了   Id: checknote.pl,v 1.6 2001/09/25 02:55:16 vinking Exp
# V1.7 (2001/09/27) 1.修正輸出的 bug
#					2.交換 <n> <x> 二者的意義
# V1.8 (2001/10/02) 1.修改梵巴的格式
# V1.9 (2001/10/03) 1.在判斷經文的校勘範圍之後, 最後也判斷是否有 </corr>
# V1.10(2001/10/12) 1.加入 <r> 的處理
#                   2.加入 <o> 的處理
#                   3.[A>B]<resp="CBETA.xxx cf1="xxx" cf2="xxx"> 的處理
#                   4.☆(已確認)◆(待查) 的處理
# V1.11(2001/10/12) 1.勘誤忘了簡單標記版的相關處理
# V1.13(2001/10/16) 1.處理 "勘誤" 符號的地方有問題, 已修正
# V1.15(2001/10/21) 1."不分卷" , 卷第xx終 , 卷第xx首, 改採用 <a> 
#					2.處理 <c>
#					3.處理 <k>
#					4.處理通用詞
#					5.處理 "碁、銹、裏、墻、恒、粧、嫺"，這七個字是BIG5後增的新字，要使用&M碼
# V1.18(2001/11/09) 1.在 "版本星號欄位" 中支援 "；" 這個符號		# V1.20 版放棄此項
#					2.處理標記 <m> , xml 是 <note n="xxxxxx" place="foot">
#					3.處理標記 <e> , xml 是 <note n="xxxxxx" place="foot" type="equivalent">
#					4.處理標記 <f> , xml 是 <note n="xxxxxx" place="foot" type="cf.">
#					5.處理標記 <l> , xml 是 <note n="xxxxxx" place="foot" type="<l>"> , 本組的位置要放到 <lem> 後面
#					6.梵巴的標記 ～<~><s><p>, 以及同時多組梵巴, 如 ～pali<s>sk<p>pali<~>unknown
# V1.19(2001/11/09) 1.處理 <z> 造成原始經文不合的問題
# V1.20(2001/11/15) 1.處理並還原 <,>, 放棄使用 '；' 代替 '，' 的做法
#					2.讓這類的梵巴可以通過 ～sp or pali（最後可以用全型括號括一段文字）
#					3.處理 <u> 標記, 類似 <a> , 但是產生 <tt> 的格式
# V1.21(2001/11/29) 1.暫時處理 <g> , 實際上 <g> 的內容應是獨立 note 中的 orig ..... 後來好像沒有 <g> 了
# V1.22(2002/01/18) 1.處理第二組是加字的問題.
# V1.23(2002/02/19) 1.改用外掛的參數檔 checknote.cfg
#					2.修改輸出檔, 讓它更標準化
#					3.翻修處理 [xx...xx]xx字的處理法
# V1.25(2002/03/20) 1.處理 <oo>
#                   2.暫時不比對小括號, 以利密教部比對 (二合)(引)...
# V1.26(2002/03/20) 1.先將悉曇字移除來比對.
#					2.移除日文符號ユ(c77e)，ロ(c7a7)
# V1.27(2002/03/22) 1.再加一個日文符號ゆ(c6ea), ろ(c6f1)
#					2.簡單標記經文由二行變成三行來判斷, 因為密教部有時會夾雜一行悉曇字, 故要多一行
# V1.28(2002/04/11) 1.將 <term> 改成 <t>
# V1.29(2002/04/12) 1.T44p0137 [11] 狹＝挾？  暫時處理成 <rdg wit="？">...</rdg>
#					  理論上應處理成 <sic n="xxxxxxx" resp="Taisho" cert="?" corr="挾">狹</sic>
# V1.30(2002/04/16) 1.修正 [[01]>] 及 [[01]>>] 這二種不應該在檢查簡單標記版時出現問題. (以前就應該正確的, 可惜沒寫好)
# V1.31(2002/04/30) 1.避開經文中 [經], [論] 造成的問題.
#					2.因為 T49 經文有不少移位, 所以不檢查這方面的問題.
# V1.32(2002/05/02) 1.修改一些錯誤
# V1.33(2002/05/03) 1.若校勘跨到下一組, 則本組結束, 不要干擾到下一組
#					2.特殊符號改成警告, 不要直接中止, 因為有些是二個中文的中間碼造成的.
# V1.34(2002/05/03) 1.若校勘有日文特殊略符, 全部暫時忽略, 加上 <n> , 以後再說
# V1.35(2002/05/03) 1.補足二個 : 若校勘跨到下一組, 則本組結束, 不要干擾到下一組
# V1.36(2002/05/07) 1.是否可以跨到下一個校勘, 改用參數決定 multi_anchor
# V1.37(2002/05/07) 1.避開經文中 【經】, 【論】造成的問題. V1.88 重新處理
# V1.38(2002/05/08) 1.取消 multi_anchor , 改成只有在取最後的 tag 時遇到的 anchor 才取消, 
#                     因為這時表示文字都沒了, 再取只會破壞標記
# V1.39(2002/05/08) 1.處理校勘條目特殊的 ... 符號
# V1.40(2002/05/13) 1.處理梵巴文之後的 "?", "(?)", （中文字）, 使用後處理程式
#                   2.原來的 orig 都獨立出來變成 note
#                   3.處理版本是？的問題，使用 <sic> , 獨立出來
#                   4.處理沒有中文的梵巴文, 使用 <foreign> 獨立出來
#                   5.處理沒資料只有 <note..></note> 的問題, 要改成 &lac;
#                   6.處理側註與傍註
# V1.41(2002/05/13) 1.cert="？" 改成 cert="?"
# V1.42(2002/05/14) 1.第二組之後校勘內容有…的話, 提出警告
#                   2.若有二組以上的校勘，有版本是？，提出警告
#                   3.版本有星號,下同,混用....等等, 在 wit="" 都移除, 只留在 desc 中.
# V1.43(2002/05/15) 1.處理 "<sic> 的 ... 還沒處理"
# V1.44(2002/05/20) 1.修改多個版本也會出現 desc 的問題.
# V1.45(2002/05/21) 1.處理【明南藏】問題 <rdg wit="【明南藏】<resp="【明】">"> 變成 
#                     <rdg wit="【明南藏】" resp="【明】">
# V1.46(2002/05/22) 1.原本日文弄成 <n> , 現在還是改成先移除再說, 再看看有沒有什麼問題.
# V1.47(2002/05/28) 1.在 xml 校勘中不能自行加入 \n, 會造成其它地方判斷錯誤, 現已改成呈現時才加了.
# V1.48(2002/05/28) 1.日文還是得先弄成 <n> 才行.
# V1.49(2002/06/04) 1.若是梵巴文, 一律在屬性加上 resp="Taisho"
#                   2.若結尾是 (?xx) 或 (xx?) 則再加上 cert="?"
# V1.50(2002/06/06) 1.處理梵巴結尾是 ? (?) (?xxx) 的差異
# V1.51(2002/06/07) 1.解決不應該跑出來的 <tt> 問題.
# V1.52(2002/06/10) 1.處理一些標記增加屬性所產生的問題.
# V1.53(2002/06/11) 1.暫時將梵巴開頭的校勘標成 <n>
#                   2.處理【◇】與【圖】,避免與版本混淆, 就是先將它換成 &xxx;
# V1.56(2002/06/24) 1.處理悉曇字的 bug
# V1.57(2002/06/25) 1.處理 "本文" 的問題
# V1.58(2002/07/02) 1.處理 <y> , 和 <c><o><oo> 類似
#                   2.處理勘誤無法處理 &xx-xxxx; 的問題
#					3.處理本文的問題
# V1.59(2002/07/10) 1.簡單標記版的檢查改成六行
# V1.60(2002/07/13) 1.處理 xml 時, 要避開 log 檔的資料
# V1.61(2002/07/16) 1.修改 <u> <a> 的結果
# V1.62(2002/07/19) 1.新增 <cm> , 和 <m> 相同, 但這是 CBETA 改寫的
# V1.63(2002/07/22) 1.增加第二層的 Note , <note resp="CBETA" type="mod">
#                   2.處理日本略符[仁-二] C77E "ユ"
# V1.64(2002/07/26) 1.修改一堆小東東
# V1.65(2002/07/29) 1.處理圖的部份, 圖有二種, 一種是【圖】, 一種是 <figure .....>
#                   2.取消 desc 屬性, 改用 <note n="xxxxxx" resp="CBETA" type="mod">
#                     但 desc 不一定是在 <d> 標記, 星號或混同之類的東西以前也會移到 desc 之中 , V1.42
#                   3.<rdg> 都加 resp="Taisho"
# V1.66(2002/07/29) 1.校勘的梵巴文結尾如果有問號「?」，轉出 xml 時不把「?」留在<t>裡面
# V1.67(2002/07/29) 1.日本略符[力]  "ロ"(C7A7), "ろ"(C6F1) 
# V1.68(2002/07/31) 1.勘誤的處理
# V1.69(2002/08/01) 1.處理 <note ....>&lac;</note> ==> &lac;
# V1.70(2002/08/01) 1.經文資料的勘誤要先處理.
# V1.71(2002/08/02) 1.模糊版本【■】用【unknown】表示
#                   2.缺■：用&lac;表示 
#                   3.模糊字●：用&unrec;表示
#                   4.同一組的 n="xxxx" 最末不用 abcd 來區別了, 以前有的要清除
#                   5.處理屬性裡面的缺字 (&xxxx; 變成 xxxx)
#                   6.處理 <l> 標記, 它產生的 note 要放在 <lem> 的後面, 變成 <lem><note..type="l"..
#                   7.處理 【明X藏】, <rdg wit="【X】【明X藏】<resp="【明】">"...> 變成 <rdg wit="【X】>...<rdg wit="【明X藏】" resp="【明】"...>
# V1.72(2002/08/05) 1.調整上面 7. 【明X藏】的問題, 而且在 modify stack 中不要留有 <resp="【明】">
#                   2.【■】要比 ■ 先處理
#                   3.<?> 改成在 modify stack 加上 <todo type="i">
#                   4.若沒有 <o><y><c> 標記的, 就自動將原校勘放入 orig stack
#                   5.將簡單標記儘量清除.
#                   6.□以一般文字處理
#                   7.處理 <mg><sic corr="長者子" resp="【明】" orig="明校[言*為]曰長者當作長者子">長者</sic>
# V1.74(2002/08/05) 1.因為梵巴先進行轉寫, 所以在判斷式中要加入 & 符號
# V1.75(2002/08/09) 1.當二組標記, 且有 <z> 時, 加上 xxxx 屬性的警告
#                   2.<z> 的標記在 modify stack 的內容要變成 <corr sic="lac">...</corr>
#                   3.<c> 標記的 modify stack 要加上 <todo type="c"/>
#                   4.modify stack  的 <s><~> 轉成半型空白, <ｐ> 轉成 ～
# V1.76(2002/08/09) 1.上一版只處理 <z> 配合 <s><p><~> , 忘了處理 <z> 配合 ～
# V1.77(2002/08/09) 1.缺■：改用&lac-space;表示，以前用&lac;表示，但不適合。
# V1.78(2002/08/14) 1.數字判斷可以超過 1000 , 並且處理了組合字.
#                   2.處理日本略符, 改大小寫及[仁-二] 有二種, 在不同的經中要分別處理
# V1.79(2002/08/15) 1.增加日本略符[力]   "⑨"(C7F1), 原來只有 "ロ"(C7A7), "ろ"(C6F1)
#                   2.修改小 bug
# V1.80(2002/08/16) 1.<y> 的格式改成 <y>....，<oo>or<o>.......
# V1.81(2002/08/20) 1.大寫日文略符要有錯誤報告, 而且小寫日文略符要改成 entity 格式
# V1.82(2002/08/21) 1.屬性中的 &xxxx; 改成 ＆xxxx；, 而原來若有＆則改成＆big-amp；
#                   2.A＝B【三】，<c>B＝A【三】希望第二層的 <note type="mod"><todo type="c"/>內容是  B＝A【三】：
# V1.83(2002/08/22) 1.第二層 note 的勘誤也要加上 <resp....>
#                   2.讓 ＊ 也變成格式 5. 梵巴轉寫字的一部份
#                   3.在計算字數時, （ (a15d) 或 ）(a15e) 不算字
# V1.84(2002/08/22) 1. <c> 標記的校勘改成 <n> 的處理方式.
#                   2. <s><~> 在換成空白時, 若是在第一個字, 則不要換.
# V1.85(2002/08/22) 1. 修改上一版 bug ，<s><~> 在換成空白時, 若是在第一個字, 則不要換.
#                   2. 取消 <sup> 標記
#                   3. 將 <,> 換成 ，
# V1.86(2002/08/23) 1. 修改上一版 bug ，<s><~> 在換成空白時, 若是在 </corr> 後面, 一樣留空格
# V1.87(2002/08/27) 1. 簡單標記版移去Ｒ及 <no_nor> 的影響
#                   2. 梵巴字加入 = 的符號
# V1.88(2002/08/27) 1. V1.37 避開經文中 【經】, 【論】造成的問題. V1.88 重新處理
# V1.89(2002/09/03) 1. 不讓【經】, 【論】處理成版本
# V1.90(2002/09/04) 1. 處理【經】【論】的餘毒
# V1.91(2002/09/26) 1. 如果有 … 的符號, 則加上此校勘在經文的數目, 讓人可以判斷.
#                   2. 直接採用原始校勘檔當成第一組 note
# V1.92(2002/09/26) 1. 原始校勘的梵巴改 entitiy 的桯式沒寫好, 已改過.
# V1.93(2002/09/28) 1. 加入 ray 寫的 y2mod.pl 程式, 以處理 <y> 標記.
#                   2. 加入 ray 寫的 jap2ent.pl 程式, 以處理日文.
#                   3. 除了第一層的 note 之外，【三】換成【宋】【元】【明】
# V1.94(2002/10/04) 1. 第二層 note 的 </todo> 要移除
#                   2. 處理原始校勘和研發組校勘的差異問題, 包括悉曇字及修改符號
# V1.95(2002/10/07) 1. 修改一些小問題隔
# V1.96(2002/10/11) 1. 處理 <z> 的問題, 讓原始版與研發組版看不到差異
# V1.97(2002/10/11) 1. 處理悉曇字的差異問題
# V1.98(2002/10/11) 1. 處理日文字的差異問題
# V1.99(2002/10/11) 1. 取消處理日文字的差異問題, 處理分號的問題
############################################

use strict;

#---------------------------------------------------
# 和傳入參數有關的變數
#---------------------------------------------------

# 目前有 rd, heaven 若有特殊需求者, 請告訴我
my $Iam = "heaven";	
$Iam = $ARGV[0] if($ARGV[0]);	# 若有傳入參數, 則用此參數

#---------------------------------------------------
# 可修改的變數, 若有 checknote.cfg , 則以 cfg 檔為主
#---------------------------------------------------

my $vol = "T01";

my $infile = "${vol}校勘條目.txt";				# 校勘條目檔
my $originfile = "${vol}原始校勘條目.txt";		# 原始校勘條目檔
my $sutra = "c:/cbwork/simple/${vol}/new.txt";	# 原始經文檔（簡單標記版）
my $xml_dir = "c:/cbwork/xml/$vol/";			# xml 經文的目錄

#if($Iam eq "rd")
#{
#	$infile = "${vol}校勘條目.txt";					# 校勘條目檔
#	$sutra = "c:/cbwork/work/maha/${vol}maha.txt";	# 原始經文檔（簡單標記版）
#	$xml_dir = "c:/cbwork/xml/$vol/";				# xml 經文的目錄
#}

my $outfile = "${vol}out.txt";			# 基本輸出結果檔
my $xmlout = "${vol}xml.txt";			# 產生 xml 標記的輸出檔
my $xmllogout = "${vol}xmllog.txt";		# 測試 xml 版校勘檢查的結果

my $jap_ent_file = "c:/cbwork/xml/dtd/jap.ent";

# 底下是判斷是否要處理? 0 表示不處理, 1 表示要處理

my $show_no_word_error = 0;				# 若梵巴文字沒配合中文時, 要不要秀出錯誤?
my $run_check_with_sutra = 1;			# 是否配合簡單標記版經文交叉檢查?

my $useODBC = 1;						# 使用ODBC, 才能將缺字換成 &CB 碼, 也才能配合 xml 檢查.
my $run_check_with_xml = 1;				# 是否配合 xml 版經文交叉檢查? (目前只檢查可插入的東西)

# my $multi_anchor = 1;					# 本組標記是否可以跨到下一組的 anchor 標記 (0 或 1)

#---------------------------------------------------
# 無需修改的參數
#---------------------------------------------------

#---------------------------------------------------
# 常數(patten)
#---------------------------------------------------

my $roma = '(?:(?:(?:～)|(?:<~>)|(?:<[pP]>)|(?:<[sS]>))(?:(?:[0-9a-zA-Z=&\.\-~`\(\)\^\[\]\'\"\;\|\:,\? <>])|(?:°)|(?:～)|(?:…))+(?:\xa1\x5d.*?\s?\xa1\x5e)?)';	# 羅馬轉寫字
my $cnum = '(?:(?:一)|(?:二)|(?:三)|(?:\xa5\x7c)|(?:五)|(?:六)|(?:七)|(?:八)|(?:九)|(?:十)|(?:廿)|(?:卅)|(?:百)|(?:千))';	# 中文數字
my $notestar = '(?:(?:\s*＊\s*)|(?:\s*下\s*)|(?:\s*次\s*)|(?:\s*以下\s*)|(?:\s*次下\s*)|(?:\s*順之\s*)|(?:\s*同\s*)|(?:\s*皆同\s*)|(?:\s*混用\s*)|(?:\s*省略\s*)|(?:\s*，\s*)|(?:\s*<,>\s*))';		# 下同用的星號 ~V0.3 , V1.42
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
#缺字裡面沒有>[]  0-9 a-z A-Z
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x21-\x2f]|[\x3a-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
my $fullspace = '(?:　)';
my $allspace = '(?:(?:　)|\s)';
my $sppattern = '(?:(?:～)|(?:<[pP]>)|(?:<[sS]>)|(?:<~>))';
my $smallnote = '(?:(?:夾註)|(?:夾注)|(?:細書)|(?:細註)|(?:細注)|(?:傍註)|(?:傍注)|(?:旁註)|(?:旁注)|(?:側註)|(?:側注)|(?:小註)|(?:小注)|(?:細字))';  # 夾註的樣式
my $allsmallnote = '(?:(?:夾註)|(?:夾注)|(?:細書)|(?:細註)|(?:細注)|(?:傍註)|(?:傍注)|(?:旁註)|(?:旁注)|(?:側註)|(?:側注)|(?:小註)|(?:小注)|(?:細字)|(?:本文))';  # 夾註的樣式
my $interlinear_note = '(?:(?:傍註)|(?:傍注)|(?:側註)|(?:側注)|(?:旁註)|(?:旁注))';  		# 側註的樣式
my $max_line_xml = 5;		# 處理 xml 校勘時, 最多拿幾行來比對? 太多了則不太好唷, 太多最好用手動.
my $manyver = '(?:(?:(?:【.*?】)|(?:？))(?:(?:【.*?】)|(?:？)|(?:<resp=".*?">))*)'; 	# 各種版本會有的符號
my $DEBUG = 1;

#my $jp0 = '(?:(?:ュ)|(?:ユ))';			# 日本略符[仁-二]  "ュ"(C77D), "ユ"(C77E)
#my $jp1 = '(?:(?:ゅ)|(?:ゆ))';			# 日本略符[仁-二]  "ゅ"(C6E9), "ゆ"(C6EA) 
#my $jp2 = '(?:(?:ロ)|(?:ろ)|(?:⑨))';		# 日本略符[力]  "ロ"(C7A7), "ろ"(C6F1), "⑨"(C7F1)

my $jp0 = '(?:ュ)';			# 日本略符[仁-二]  "ュ"(C77D), 後面這個不用了 "ユ"(C77E)
my $jp1 = '(?:ゅ)';			# 日本略符[仁-二]  "ゅ"(C6E9), 後面這個不用了 "ゆ"(C6EA) 
my $jp2 = '(?:(?:ろ)|(?:⑨))';		# 日本略符[力]  "ろ"(C6F1), "⑨"(C7F1) 後面這個不用了 "ロ"(C7A7)

my $big_jp = '(?:(?:ユ)|(?:ゆ)|(?:ロ))';		# 不該出現的日文大寫略符 "ユ"(C77E), "ゆ"(C6EA), "ロ"(C7A7)

#---------------------------------------------------
# 檔案 handle
#---------------------------------------------------

local *IN;
local *SUTRA;
local *XMLIN;
local *XMLOUT;		# 產生 XML 校勘的輸出
local *XMLLOGOUT;	# 測試在 XML 檔尋找校勘與符號的數目
local *OUT;
local *CFG;

#---------------------------------------------------
# 校勘資料
#---------------------------------------------------

my @note;		# 校勘條目
my %note;		# 處理過的校勘條目 索引用的 ID 是 "四位頁碼" 加 "三位編碼"
my %has_note;	# 若此校勘有出現在經文, 則設定為 1, 用以檢查某個校勘是否出現在經文中.

my @orig_note;		# 最原始的校勘條目
my %orig_note;		# 原始校勘條目 索引用的 ID 是 "四位頁碼" 加 "三位編碼"
my %orig_note_line;	# 原始校勘出現在原始檔案的行數

my %note_form;		# 分析校勘格式
my %note_old;		# 原經文的內容
my %note_new;		# 校勘的經文內容
my %note_ver;		# 校勘的版本
my %note_star;		# 是否有校勘星號
my %note_word_num;	# 字數, 例如 [如是...我聞]十八字 (本變數就是 18)
my %note_spell;		# 校勘的梵巴資料

my %note_line;		# 校勘出現在原始檔案的行數
my %note_xml;		# XML 格式的校勘
my %note_total;		# 校勘的組數 (用全型逗號隔開的數目)
my %note_stack_total;	# note stack 型校勘的組數 (用全型逗號隔開的數目)
my %note_add_desc;	# 是否將原校勘加入 desc 屬性中
my %note_add_xxxx;	# 是否將原校勘加入 xxxx 屬性, 目前這是為了 <?> 而設計的
my %note_add_resp;	# 將 <k> 標記之後的標記內容, 目前這是為了 <k> 而設計的
my %xml_err_msg;	# 轉成 xml 所產生的錯誤訊息
my @sutra_err;		# 經文的錯誤我先放在這裡
my @both_sutra_note_err;	# 經文與校勘沒有同步
my %eight_note;		# 用來處理∞符號的校勘 (傳入校勘, 第一次傳入就等於 1 , 第二次讓它 = 0)
my %interlinear;	# 用來記錄校勘是小註或側註.	V1.40
my %note_ztag;		# 如果有 <z> 標記, 則要記錄在這裡. V1.49

my %orig_stack;		# 將 <o> 標記之後的東西全部放在這裡, 目前這是為了 <o><oo><c> 而設計的
my %modify_stack;	# 這是除了 <o> 之外, 其它的東西.
my %note_stack;		# 校勘一堆需要使用 <note> 堆在後面的東西, 都放在這裡, 這是為了 <m><e><r>
my %note_stack_total;	# note stack 型校勘的組數 (用全型逗號隔開的數目)
my %sic_stack;		# 獨立的 <sic> 標記內容, 這是為了 A=B？ 這種沒有版本的校勘
my %foreign_stack;	# 獨立的 <foreign> 標記內容, 這是為了那些沒有中文的梵巴文字
my %foreign_stack_total;	# foreign stack 型校勘的組數 (用全型逗號隔開的數目)

my %has_japan0;		# 判斷有沒有日本略符[仁-二]  "ュ"(C77D), 後面這個不用了 "ユ"(C77E)
my %has_japan1;		# 判斷有沒有日本略符[仁-二]  "ゅ"(C6E9), 後面這個不用了 "ゆ"(C6EA) 
my %has_japan2;		# 判斷有沒有日本略符[力]  "ろ"(C6F1), "⑨"(C7F1), 後面這個不用了 "ロ"(C7A7)

my %jap;			# 處理日文字用的;

#-------------------------------------------
# 處理 xml 時用的變數
#-------------------------------------------

my $note_count = 0;				# 校勘數目
my $note_found_count = 0;		# 校勘能處理的數目
my $note_no_found_count = 0;	# 校勘不能處理的數目
my $note_star_count = 0;		# 星號數目
my $note_star_found_count = 0;	# 星號能處理的數目

##################### 處理資料的變數
my @xmls;			# xml 全部經文
my $pre_anchor; 	# <anchor 標記之前的字
my $anchor_ok;		# <anchor 標記之後已確定的字
my $anchor_other;	# 還沒處理的資料
	
my $note_old_head;	# 校勘條目中, 原始經文的前半段
my $note_old_tail;	# 校勘條目中, 原始經文的後半段

my $xml_start_line;	# 開始尋找的行數
my $xml_now_line;	# 目前所在的行數

my $xml_word_num;	# xml 所取出的數字, 配合 [xx...xx]xx字 的計算數字用的
my $xml_last_word_num;	# 最後一次合格的字數, xml 所取出的數字, 配合 [xx...xx]xx字 的計算數字用的
my $note_word_num;	# 目前這一組的字數

my @xml_tag_stack;	# 儲存 tag 用的, 要處理是否有結尾的標記要取出
my $xml_pure_data;	# 儲存純文字資料

my $xml_err_message;	# 放一些容許的錯誤訊息

#-------------------------------------------
# 梵巴羅馬轉寫字
#-------------------------------------------

my %s2ref = (
	"aa", "&amacron;", 
	"AA", "&Amacron;", 
	"^a", "&acirc;", 
	".d", "&ddotblw;", 
	".D", "&Ddotblw;", 
	".h", "&hdotblw;", 
	"ii", "&imacron;", 
	".l", "&ldotblw;", 
	".L", "&Ldotblw;", 
	"^m", "&mdotabv;", 
	".m", "&mdotblw;", 
	"^n", "&ndotabv;", 
	".n", "&ndotblw;", 
	".N", "&Ndotblw;", 
	"~n", "&ntilde;", 
	".r", "&rdotblw;", 
	"'s", "&sacute;", 
	".s", "&sdotblw;", 
	".S", "&Sdotblw;", 
	".t", "&tdotblw;", 
	".T", "&Tdotblw;", 
	"uu", "&umacron;", 
	"^u", "&ucirc;", 
	"~S", "&Sacute;",
	"`S", "&Sacute;",);
	
#-------------------------------------------
# 缺字資料庫用的
#-------------------------------------------

#my %gaiji_nr;	# 輸入 ent , 傳出通用字
my %gaiji_cb;	# 傳入組字式, 傳出 CB 碼
my %gaiji_zu;	# 傳入entity(其實是 CIxxxx 通用詞碼), 傳出組字式
#my %gaiji_ent;	# 傳入 CB 碼, 傳出 ent

#-------------------------------------------
# 其它
#-------------------------------------------

my @sutra;	# 本冊經文
my $line;	# 某行資料

##############################################################################
#  主 程 式
##############################################################################
print "read config....\n";
read_config();
print "read japan entity....\n";
read_jap_ent();

#先讀原始資料檔

open OUT, ">$outfile" || die "open $outfile error";
open IN, $originfile;

my @orig_note = <IN>;	# 校勘資料
close IN;
if($#orig_note >= 0)
{
	print "analysis orig note file\n";
	orignote_analysis();	# 簡單分析校勘條目, 並存入 %orignote
	print OUT "\n$originfile : found => \[\n\n";
}
else
{
	print "\nError : open $originfile error!\n";
	close IN;	
}

# 再讀改過的校勘條目

open IN, $infile || die "open $infile error";
@note = <IN>;	# 校勘資料
close IN;

print "analysis note file\n";
note_analysis();	# 簡單分析校勘條目, 並存入 %note

print "analysis note form\n";
analysis_note_form();	# 分析校勘條目的格式

if($run_check_with_sutra)
{
	print "check with sutra\n";
	check_with_sutra();	# 配合經文做簡單分析
	print "check lose note\n";
	check_lose_note();	# 檢查有沒有校勘配不到經文的
}
print OUT "$infile : found => \[\n\n";

print "make the sk-pali standard form\n";
#sk_pali_normalize();	# 將梵巴文標準化 , #V1.72 改成一開始就做了

# 從這裡以後, 會用到 access (ODBC mode) 缺字資料庫

if($useODBC)	# 讀入缺字
{
	readGaiji();
	print "make the loseword to \$CBxxxxx;\n";
	note_gaiji_normalize();		# 將校勘的缺字做成&CB碼標準格式
}

note_inline_normalize();		# 將小括號變成 <note inline

print "make xml format footnote\n";
make_xml_formate();			# 做成 xml 格式

if($run_check_with_xml)
{
	print "check with xml sutra\n";
	check_with_xmls();		# 試著與 xml 經文比對看看
}

other_output();		# 結果輸出 (有一部份結果是在上面的副程式中輸出的)

close OUT;
print "ok [any key to exit]\n";
<>;
exit;

##############################################################################
# 讀入 config 檔
#####################

sub read_config
{
	my %cfg;
	
	open CFG, "checknote.cfg";
	
	while(<CFG>){
		next if (/^#/); 	#comments
		chomp;
		my ($key, $val) = split(/\s*=\s*/, $_);
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

	if (defined($cfg{"originfile"})) {
		$originfile = $cfg{"originfile"};
		$originfile =~ s/\$\{vol\}/$vol/g;
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
	
#	if (defined($cfg{"multi_anchor"})) {
#		$multi_anchor = $cfg{"multi_anchor"};
#	}
}

##############################################
# 分析原始校勘條目, 並存入 %orig_note
# 檢查項目
# 1. 頁數小於前一頁 (不可後面的頁碼小於或等於前面的)
# 2. 檢查格式是否正確
# 3. 檢查編號是否連續
##############################################

sub orignote_analysis()
{
	my $ID;				# %note 的ID
	my $note_page;		# 校勘的頁
	my $note_num;		# 校勘的編號
	my $note_data;		# 校勘的內容

	my $note_pre_page = 0;	# 上一個校勘的頁數
	my $note_pre_num = 0;	# 上一個校勘的編號

	for(my $i = 0;$i <= $#orig_note; $i++)
	{
		my $linenum = sprintf("%05d",$i+1);
		next if $orig_note[$i] eq "" ;
		next if $orig_note[$i] =~ /^#/;
		last if $orig_note[$i] =~ /^<eof>/i;		#測試用的, 若校勘出現 <eof> 則不繼續下去

		if($orig_note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			if ($note_page <= $note_pre_page)	# 頁數不對
			{
				print OUT "${linenum}:err2: 頁數應大於前一頁==> p$note_page <= p$note_pre_page";
			}

			$note_pre_num = 0;		# 這二個要重設
			$note_pre_page = $note_page;

			next;
		}

		if($orig_note[$i] =~ /^\s*(?:◎)?(\d+)\s*(.+)$/)	# 標準格式的校勘
		{
			$note_num = $1;
			$note_data = $2;
			if($note_num != $note_pre_num+1)
			{
				print OUT "${linenum}:err3: 校勘數字不連續==> p$note_page, $note[$i]";
			}
			$note_pre_num = $note_num;

			# 判斷一下下一行是否是接續本行的

			for(my $j = $i+1; $j<= $#orig_note; $j++)
			{
				if($orig_note[$j] =~ /^    \s*(.*)$/)
				{
					$note[$j] = $1;
					chomp($note_data);
					if($note[$j] =~ /^[a-z]/i)
					{
						$note_data .= " $orig_note[$j]";
					}
					else
					{
						$note_data .= $orig_note[$j];
					}
					$orig_note[$j] = "";
				}
				else
				{
					$j = $#orig_note + 1;	# 強迫跳出迴圈
				}
			}

			$ID = $note_page . sprintf("%03d",$note_num);
			$orig_note{$ID} = $note_data;

			# 處理【圖】【◇】, 不要讓它和版本混淆

			# $note{$ID} =~ s/【圖】/&pic;/g;
			# $note{$ID} =~ s/【◇】/&manysk;/g;
			# $note{$ID} =~ s/【經】/&jing;/g;
			# $note{$ID} =~ s/【論】/&lum;/g;
			
			# 將 梵巴轉寫字一次全部換掉 V1.72
			
			$orig_note{$ID} = sp_pali_to_CB($orig_note{$ID});
			#$orig_note{$ID} =~ s/($big5)/&jap_rep($1)/eg;		# 將日文變成 entity V1.93 (by ray)

			# 暫時處理成 <n> , 日後再說 V1.34  , V1.63 開始動手處理日文略符

			#if($note{$ID} =~ /^$big5*?(ロ)|(ゆ)|(ろ)/)
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

			# 梵文的開頭也暫時處理成 <n>, 日後再說 V1.53
			
			#if($note{$ID} =~ /^(?:(?:◇)|(?:&manysk;)|(?:□))/)
			#if($note{$ID} =~ /^(?:(?:◇)|(?:&manysk;))/)			# V1.72 移除 □ , □以一般文字處理
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

=begin
			# 暫時移除日文符號, ユ(c77e)，ロ(c7a7) 以後要處理喔 (V1.26) 

			while($note{$ID} =~ /^$big5*?ユ/)
			{
				$note{$ID} =~ s/^($big5*?)ユ/$1/;
			}
			while($note{$ID} =~ /^$big5*?ロ/)
			{
				$note{$ID} =~ s/^($big5*?)ロ/$1/;
			}
			# 暫時移除日文符號, ゆ(c6ea), ろ(c6f1)以後要處理喔 (V1.27) 
			while($note{$ID} =~ /^$big5*?ゆ/)
			{
				$note{$ID} =~ s/^($big5*?)ゆ/$1/;
			}
			while($note{$ID} =~ /^$big5*?ろ/)
			{
				$note{$ID} =~ s/^($big5*?)ろ/$1/;
			}
=end
=cut
			$orig_note_line{$ID} = $linenum;	# 記錄在原檔的出現行數
		}
		else					# 非標準格式校勘
		{
			print OUT "${linenum}:err1: 校勘格式不對==> p$note_page, $orig_note[$i]";
		}
	}
}

##############################################
# 分析校勘條目, 並存入 %note
# 檢查項目
# 1. 頁數小於前一頁 (不可後面的頁碼小於或等於前面的)
# 2. 檢查格式是否正確
# 3. 檢查編號是否連續
##############################################

sub note_analysis()
{
	my $ID;				# %note 的ID
	my $note_page;		# 校勘的頁
	my $note_num;		# 校勘的編號
	my $note_data;		# 校勘的內容

	my $note_pre_page = 0;	# 上一個校勘的頁數
	my $note_pre_num = 0;	# 上一個校勘的編號

	for(my $i = 0;$i <= $#note; $i++)
	{
		my $linenum = sprintf("%05d",$i+1);
		next if $note[$i] eq "" ;
		next if $note[$i] =~ /^#/;
		last if $note[$i] =~ /^<eof>/i;		#測試用的, 若校勘出現 <eof> 則不繼續下去

		if($note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			if ($note_page <= $note_pre_page)	# 頁數不對
			{
				print OUT "${linenum}:err2: 頁數應大於前一頁==> p$note_page <= p$note_pre_page";
			}

			$note_pre_num = 0;		# 這二個要重設
			$note_pre_page = $note_page;

			next;
		}

		if($note[$i] =~ /^\s*(?:◎)?(\d+)\s*(.+)$/)	# 標準格式的校勘
		{
			$note_num = $1;
			$note_data = $2;
			if($note_num != $note_pre_num+1)
			{
				print OUT "${linenum}:err3: 校勘數字不連續==> p$note_page, $note[$i]";
			}
			$note_pre_num = $note_num;

			# 判斷一下下一行是否是接續本行的

			for(my $j = $i+1; $j<= $#note; $j++)
			{
				if($note[$j] =~ /^    \s*(.*)$/)
				{
					$note[$j] = $1;
					chomp($note_data);
					if($note[$j] =~ /^[a-z]/i)
					{
						$note_data .= " $note[$j]";
					}
					else
					{
						$note_data .= $note[$j];
					}
					$note[$j] = "";
				}
				else
				{
					$j = $#note + 1;	# 強迫跳出迴圈
				}
			}

			$ID = $note_page . sprintf("%03d",$note_num);
			$note{$ID} = $note_data;

			# 處理【圖】【◇】, 不要讓它和版本混淆

			$note{$ID} =~ s/【圖】/&pic;/g;
			$note{$ID} =~ s/【◇】/&manysk;/g;
			$note{$ID} =~ s/【經】/&jing;/g;
			$note{$ID} =~ s/【論】/&lum;/g;
			
			# 將 梵巴轉寫字一次全部換掉 V1.72
			
			$note{$ID} = sp_pali_to_CB($note{$ID});

			# 暫時處理成 <n> , 日後再說 V1.34  , V1.63 開始動手處理日文略符

			#if($note{$ID} =~ /^$big5*?(ロ)|(ゆ)|(ろ)/)
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

			# 梵文的開頭也暫時處理成 <n>, 日後再說 V1.53
			
			#if($note{$ID} =~ /^(?:(?:◇)|(?:&manysk;)|(?:□))/)
			if($note{$ID} =~ /^(?:(?:◇)|(?:&manysk;))/)			# V1.72 移除 □ , □以一般文字處理
			{
				$note{$ID} = "<n>$note{$ID}";
			}

=begin
			# 暫時移除日文符號, ユ(c77e)，ロ(c7a7) 以後要處理喔 (V1.26) 

			while($note{$ID} =~ /^$big5*?ユ/)
			{
				$note{$ID} =~ s/^($big5*?)ユ/$1/;
			}
			while($note{$ID} =~ /^$big5*?ロ/)
			{
				$note{$ID} =~ s/^($big5*?)ロ/$1/;
			}
			# 暫時移除日文符號, ゆ(c6ea), ろ(c6f1)以後要處理喔 (V1.27) 
			while($note{$ID} =~ /^$big5*?ゆ/)
			{
				$note{$ID} =~ s/^($big5*?)ゆ/$1/;
			}
			while($note{$ID} =~ /^$big5*?ろ/)
			{
				$note{$ID} =~ s/^($big5*?)ろ/$1/;
			}
=end
=cut
			$note_line{$ID} = $linenum;	# 記錄在原檔的出現行數
		}
		else					# 非標準格式校勘
		{
			print OUT "${linenum}:err1: 校勘格式不對==> p$note_page, $note[$i]";
		}
	}
}

########################################################################
# 分析校勘條目的格式
# 格式 1. 換字: 21 騫茶＝騫荼【三】＊～Kha.n.daa.
# 格式 2. 缺字: 14 夾註〔為〕xx字 or 夾註－【三】＊
# 格式 3. 前加字: 12 夾註（彼）xx字 or 夾註＋放逸【三】＊
# 格式 4. 後加字: 28 壁＋夾註（者）xx字 or 夾註【三】＊
# 格式 5. 純轉寫字: 12 舍衛～Saavatthii.
#                   32 ～Vessava.na.
# 格式 6. 經文位置交換: 0379002 : 南無普德佛∞南無妙智佛【宋】【元】【宮】
#			0379003 : 南無普德佛∞南無妙智佛【宋】【元】【宮】
#			18 （南無勝…劫佛）十三字∞南無離劫佛【三】【宮】【中】
# 格式 7. 複雜的換字: 06 （（展轉…決定 ））十字＝（（定展轉增上力二識成決 ））十字【元】
# 格式 8. 特殊的句字: 不分卷【三】【宮】, 卷第一終【三】【宮】, 卷第二首【三】【宮】
# 格式 9. 無法處理的句子: 只要是 <x> 開頭的句子, 我就不處理, xml 會放入 note 中, 會在 xxxx 屬性註記
# 格式 10. 無法處理的句子: 只要是 <n> 開頭的句子, 我就不處理, xml 會放入 note 中, 且不會有 xxxx 屬性
# 格式 11. 無法處理的句子: 只要是 <a> 開頭的句子, 我就不處理, xml 會放入 app 中, 會在 xxxx 屬性註記
# 格式 12. <?> 開始的該組不處理: 阿修囉＝阿脩羅【三】＊，<?>修脩混用【明】, 全部會放在 desc 中.
# 格式 13. <r>A. IX. 3. Meghiya. ==> <note n="0491004" place="foot" type="resource">A. IX. 3. Meghiya.</note>
#################### 第二層之後才會出現的 ##############################
# 格式 100. 換字: 21 ＝夾註（（騫荼））xx字 或 夾註【三】＊～Kha.n.daa.
# 格式 101. 缺字: 14 －【三】＊
# 格式 102. 雙括號的換字:  夾註（（騫荼））xx字 or 夾註【三】＊～Kha.n.daa.
# 格式 103 , 加字的變形, 但沒有＋，也沒原來的字: 12 夾註（彼）xx字 or 夾註【三】＊
# 格式 104. <o> , 若發現 <o> , 則其後所有的東西都放到 orig 屬性之中

# 格式 999, 無法分析的格式
########################################################################

sub analysis_note_form()
{
	my $oldword;	# 原來的經文
	my $newword;	# 改過的經文
	my $ver;		# 版本
	my $star;		# 有校勘星號
	my $word_num;	# 字數, 例如 [如是...我聞]十八字 (本變數就是 18)
	my $spell;		# 其它轉寫拼音資訊
	my $sp_note;	# 特殊的註解, 格式 8 開始有的
	my $ID;
	my $note;
	my $this_note;		# 目前要分析的校勘
	my $other_note;		# 尚未被分析的校勘
	my $notenum;		# 校勘在第幾組呢?
	my $subID;			# 每一組校勘的小組的編號,也就是 $ID_xxx

	foreach $ID (sort(keys(%note)))
	{
		$note = $note{$ID};

		if($note =~ /<c>/)		# V1.84 <c> 標記的校勘改成 <n> 的處理方式, 而且都要是 <c> 後面那一組
		{
			if($note !~ /<n>/)
			{
				$note{$ID} =~ /^.*?，<c>(.*)$/;
				$note{$ID} = "<n>$1，<c>$1";
				$note = $note{$ID};
			}
		}

		my $find_oc = 0;		# 判斷有沒有 <o><c> 標記 V1.72
		my $find_y = 0;			# 判斷有沒有 <y> 標記 V1.80
		
		# 若發現 <o> or <oo>, 則其後所有的東西都放到 orig 屬性之中
			
		if($note =~ /<o{1,2}>/)
		{
			$orig_stack{$ID} = $note{$ID};				# 是全部喔!  # V1.91 被移除了
			$orig_stack{$ID} =~ s/^.*?<o{1,2}>//;		
			
			# V1.91 有新的原始校勘, 所以就不用 <o> 標記了
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# 原始校勘與 <o> 標記的校勘不同
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# 傳回來的結果
			}
			$orig_stack{$ID} = $orig_note{$ID};		# V1.91 原始校勘採用 $orig_note 的內容

			$modify_stack{$ID} = $note{$ID};			# 是全部喔!
			$modify_stack{$ID} =~ s/(?:，)?<o{1,2}>.*$//;
			$find_oc = 1;
		}

		# 若發現 <c> , 則其後所有的東西都放到 orig 屬性之中
			
		if($note =~ /<c>/)
		{
			$orig_stack{$ID} = $note{$ID};				# 是全部喔!
			$orig_stack{$ID} =~ s/^.*?<c>//;

			# V1.91 有新的原始校勘, 所以就不用 <o> 標記了
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# 原始校勘與 <o> 標記的校勘不同
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# 傳回來的結果
			}
			$orig_stack{$ID} = $orig_note{$ID};		# V1.91 原始校勘採用 $orig_note 的內容
				
			#$modify_stack{$ID} = $note{$ID};			# 是全部喔!
			#$modify_stack{$ID} =~ s/(?:，)?<c>.*$//;
			$modify_stack{$ID} = $orig_stack{$ID};		# V1.82 和第一組一樣.
			$modify_stack{$ID} = "<todo type=\"c\"/>" . $modify_stack{$ID};		# V 1.75  <c> 標記的 modify stack 要加上 <todo type="c"/>
			#$note_total{$ID}--;						# 不算一組
			$find_oc = 1;
		}

		# 若發現 <y> , 則其後所有的東西都放到 orig 屬性之中
			
		if($note =~ /<y>/)
		{
			# <y> 標記不決定 orig 的內容, 因為 <y> 後面還可能有 <o> 或 <oo>
			# $orig_stack{$ID} = $note{$ID};				# 是全部喔!
			# $orig_stack{$ID} =~ s/^.*?<y>//;

			$modify_stack{$ID} = $note{$ID};			# 是全部喔!
			$modify_stack{$ID} =~ s/^.*?<y>//;
			$modify_stack{$ID} =~ s/，<o{1,2}>.*$//;
			
			# $modify_stack{$ID} = "wait for ray";		# 暫時用的 V1.80 , V1.93 取消

			# $note_total{$ID}--;						# 不算一組
			$find_y = 1;
		}

		if($find_oc == 0)		# V 1.72 沒有 <o><c> 標記, 則 orig = modify = 校勘條目
		{
			# V1.91 有新的原始校勘, 所以就不用 <o> 標記了
			$orig_stack{$ID} = $note{$ID};				# 是全部喔!
			if($find_y)
			{
				$orig_stack{$ID} =~ s/^.*?<y>//;		# V1.95 若有 <y> , 只取 <y> 之後來的比對
			}
			
			# 因為它不是真的 orig , 所以要去除標記
			$orig_stack{$ID} =~ s/<z>.*?((?:<[sp~]>)|(?:～))/$1/;	# 移除一些標記. V1.96
			$orig_stack{$ID} =~ s/<resp=".*?">//g;		# 移除一些標記.
			$orig_stack{$ID} =~ s/，<.{1,2}>/，/g;		# 移除一些標記.
			$orig_stack{$ID} =~ s/<,>/，/g;				# 移除一些標記.
			$orig_stack{$ID} =~ s/^<.{1,2}>//g;			# 移除一些標記.
			$orig_stack{$ID} =~ s/<p>/～/g;				# 移除一些標記.
			$orig_stack{$ID} =~ s/><[s~]>/>/g;			# 移除一些標記.
			$orig_stack{$ID} =~ s/^<[s~]>//g;			# 移除一些標記.
			$orig_stack{$ID} =~ s/，<[s~]>/，/g;		# 移除一些標記.
			$orig_stack{$ID} =~ s/<[s~]>/ /g;			# 移除一些標記.
			$orig_stack{$ID} =~ s/<t>//g;				# 移除一些標記.
			$orig_stack{$ID} = get_corr_left($orig_stack{$ID});		# 找出原始的文字
			
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# 原始校勘與 <o> 標記的校勘不同
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# 傳回來的結果
			}
			$orig_stack{$ID} = $orig_note{$ID};			# 是全部喔!
			
			# V1.91 之後, 這些都不用了
			#$orig_stack{$ID} = $note{$ID};				# 是全部喔!
			#if($find_y == 1)
			#{
			#	$orig_stack{$ID} =~ s/^.*<y>//;			# 如果有 <y> 無 <o> , 第一層暫時用 <y> 的
			#}

			if($find_y == 0)
			{
				$modify_stack{$ID} = $note{$ID};			# 是全部喔!
			}
			$find_oc = 1;
			$find_y = 1;
		}

		if($modify_stack{$ID} =~ /<\?>/)		# V1.72
		{
			$modify_stack{$ID} = "<todo type=\"i\"/>" . $modify_stack{$ID};
		}
		
		$modify_stack{$ID} =~ s/<z>(.*?)((?:<)|(?:～))/<corr sic="&lac;">$1<\/corr>$2/g;		# V1.75, <z> 的標記在 modify stack 的內容要變成 <corr sic="lac">...</corr> # 後來決定屬性的要改成 ＆lac：
		# $modify_stack{$ID} =~ s/><[s~]>/>/g;				# V1.75 <s><~> 轉成半型空白, # V1.84 但若是第一個字, 就不要換
		$modify_stack{$ID} =~ s/^<[s~]>//g;					# V1.75 <s><~> 轉成半型空白, # V1.84 但若是第一個字, 就不要換
		$modify_stack{$ID} =~ s/，<[s~]>/，/g;				# V1.75 <s><~> 轉成半型空白, # V1.84 但若是第一個字, 就不要換
		$modify_stack{$ID} =~ s/<[s~]>/ /g;					# V1.75 <s><~> 轉成半型空白, # V1.84 但若是第一個字, 就不要換
		$modify_stack{$ID} =~ s/<p>/～/g;					# V1.75 <p>　轉成 ～
		$modify_stack{$ID} =~ s/<todo\/>//g;				# V1.94 <todo/> 移除
		while ($modify_stack{$ID} =~ /^($big5*?)◆/)		# V1.95 ◆ 移除, 因為它會變成 <todo/>
		{
			$modify_stack{$ID} =~ s/^($big5*?)◆/$1/;
		}
		# $modify_stack{$ID} =~ s/<resp=".*?">//g;			# 移除一些標記. # V1.83 這行不要了.
		
		$modify_stack{$ID} =~ s/，<.{1,2}>/，/g;			# 移除一些標記.
		$modify_stack{$ID} =~ s/^<.{1,2}>//g;				# 移除一些標記.

		$orig_stack{$ID} =~ s/【三】/&three_ver;/g;			# V1.93 第一層的【三】先換掉, 最後再換回來

		# V1.81 將日文略符改成 entity
		
		if($orig_stack{$ID} =~ /^$big5*?$jp0/)		# 這裡發現日文略符 "ュ"(C77D)
		{
			while($orig_stack{$ID} =~ /^$big5*?$jp0/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)$jp0/$1&M062403;/;
			}
		}		

		if($orig_stack{$ID} =~ /^$big5*?$jp1/)		# 這裡發現日文略符 "ゅ"(C6E9)
		{
			while($orig_stack{$ID} =~ /^$big5*?$jp1/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)$jp1/$1&M062303;/;
			}
		}

		if($orig_stack{$ID} =~ /^$big5*?ろ/)		# 這裡發現日文略符 "ろ"(C6F1)
		{
			while($orig_stack{$ID} =~ /^$big5*?ろ/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)ろ/$1&M062311;/;
			}
		}

		if($orig_stack{$ID} =~ /^$big5*?⑨/)		# 這裡發現日文略符 "⑨"(C7F1)
		{
			while($orig_stack{$ID} =~ /^$big5*?⑨/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)⑨/$1&M062485;/;
			}
		}

		if($modify_stack{$ID} =~ /^$big5*?$jp0/)		# 這裡發現日文略符 "ュ"(C77D)
		{
			while($modify_stack{$ID} =~ /^$big5*?$jp0/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)$jp0/$1&M062403;/;
			}
		}		

		if($modify_stack{$ID} =~ /^$big5*?$jp1/)		# 這裡發現日文略符 "ゅ"(C6E9)
		{
			while($modify_stack{$ID} =~ /^$big5*?$jp1/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)$jp1/$1&M062303;/;
			}
		}
		
		# V1.93 看到校勘中的「ろ」，就將它轉成 [ろ>⑨] 之勘誤形式
		if($modify_stack{$ID} =~ /^$big5*?ろ/)		# 這裡發現日文略符 "ろ"(C6F1)
		{
			while($modify_stack{$ID} =~ /^$big5*?ろ/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)ろ/$1<corr sic="&M062311;">&M062485;<\/corr>/;
			}
		}

		if($modify_stack{$ID} =~ /^$big5*?⑨/)		# 這裡發現日文略符 "⑨"(C7F1)
		{
			while($modify_stack{$ID} =~ /^$big5*?⑨/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)⑨/$1&M062485;/;
			}
		}

		$other_note = $note;
		$notenum = 0;
		$note_total{$ID} = 0;
		$note_stack_total{$ID} = 0;			# 加入最後的 note stack 的數量
		$foreign_stack_total{$ID} = 0;		# 加入最後的 foreign stack 的數量

		while($other_note)
		{
			if ($other_note =~ /^(<y>${big5}*?)，(<o{1,2}>${big5}*)$/)	# V1.80 , 因為 <y> 格式比較特別
			{
				$this_note = $1;
				$other_note = $2;
			}
			elsif ($other_note =~ /^(<y>${big5}*?)$/)	# V1.80 , 因為 <y> 格式比較特別
			{
				$this_note = $1;
				$other_note = "";
			}			
			elsif ($other_note =~ /^(${big5}*?)，(${big5}*)$/)
			{
				$this_note = $1;
				$other_note = $2;
			}
			else
			{
				$this_note = $other_note;
				$other_note = "";
			}
			$this_note =~ s/<,>/，/g;			# 還原 <,>
			$notenum++;
			$note_total{$ID} = $notenum;		# 判斷有幾組用的
			$subID = "${ID}_$notenum";

#=begin
			if ($ID eq "0695002")
			{
				my $debug_ = 1;
			}
#=end
#=cut

			# 若發現 <o> or <oo>, 則其後所有的東西都放到 orig 屬性之中
			
			if($this_note =~ /^<o{1,2}>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# 若發現 <c> , 則其後所有的東西都放到 orig 屬性之中
			
			if($this_note =~ /^<c>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# 若發現 <y> , 則其後所有的東西都放到 orig 屬性之中
			
			if($this_note =~ /^<y>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# 若是 <d> 開頭的, 依正常方式處理, 但要加入 desc 屬性中
			
			if ($this_note =~ /^<d>/)
			{
				$note_add_desc{$ID} = 1;
				$this_note =~ s/^<d>//;
			}

			# 若是 <k> 開頭的, 表示這一筆是額外加入的, 依正常方式處理, 但 <k> 之後的標記要加入 rdg 的 resp 屬性中
			
			if ($this_note =~ /^<k>/)
			{
				$this_note =~ s/^<k>//;
				if ($this_note =~ /^<([^>]*resp[^>]*)>/)
				{
					$note_add_resp{$subID} = $1;
					$this_note =~ s/^<[^>]*>//;
				}
			}
			
			# 若是 <mg> 開頭的, 要獨立處理
			# <mg><sic corr="長者子" resp="【明】" orig="明校[言*為]曰長者當作長者子">長者</sic>
			
			if ($this_note =~ /^<mg>/)
			{
				$this_note =~ s/^<mg>//;
				$this_note =~ s/ orig="(.*?)"//;
				$modify_stack{$ID} = $1;
				unless($orig_stack{$ID})
				{
					$orig_stack{$ID} = $modify_stack{$ID};
				}
				$sic_stack{$ID} = $this_note;
				$sic_stack{$ID} =~ s/<sic/<sic n="$ID"/;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			##################### 這些都是尾巴要加上 note 的東西 #####################

			# 格式 a. <m> 開頭的, 要加一筆 <note n="xxxxxx" place="foot" type="rest">

			if($this_note =~ /^<m>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<m>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"rest\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 a.a <cm> 開頭的, 要加一筆 <note n="xxxxxx" resp="CBETA" type="rest">

			if($this_note =~ /^<cm>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<cm>//;
				$note_stack{$subID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"rest\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 b. <e> 開頭的, 要加一筆 <note n="xxxxxx" place="foot" type="equivalent">

			if($this_note =~ /^<e>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<e>//;		#～符號可能還沒去除...結論: 不去除了
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"equivalent\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 c. <f> 開頭的, 要加一筆 <note n="xxxxxx" place="foot" type="cf.">

			if($this_note =~ /^<f>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<f>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"cf.\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 d. <l> 開頭的, 要加一筆 <note n="xxxxxx" place="foot" type="l">  # 暫時放在這裡

			if($this_note =~ /^<l>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<l>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"l\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 e. <g> 開頭的, 暫時與 <e> 等同, 實際上是要放到獨立 note 的 orig 之中....後來好像沒有 g 了...

			if($this_note =~ /^<g>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<g>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"g\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# 不算一組
				$notenum--;
				next;
			}

			# 格式 9. 無法處理的句子: 只要是 <x> 開頭的句子, 我就不處理, xml 會放入 note 中, 並含在 <todo> 當中(以前是:會在 xxxx 屬性註記)

			if($this_note =~ /^<x>(.*)$/ and $notenum == 1)		# 只限第一組出現
			{
				# 符合格式9

				$note_form{$subID} = 9;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_old{$subID} =~ s/^<x>//;
				$note_old{$ID} = "";
				last;
			}

			# 格式 10. 無法處理的句子: 只要是 <n> 開頭的句子, 我就不處理, xml 會放入 note 中, 且不會有 xxxx 屬性

			if($this_note =~ /^<n>(.*)$/ and $notenum == 1)		# 只限第一組出現
			{
				# 符合格式10

				$note_form{$subID} = 10;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_old{$subID} =~ s/^<n>//;
				$note{$ID} =~ s/^<n>//;
				$note_old{$ID} = "";
				last;
			}

			# 格式 11. 無法處理的句子: 只要是 <a> 開頭的句子, 我就不處理, xml 會放入 app 中, 會在 xxxx 屬性註記

			if($this_note =~ /^<a>(.*)$/ and $notenum == 1)		# 只限第一組出現
			{
				# 符合格式11

				$note_form{$subID} = 11;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_old{$subID} =~ s/^<a>//;
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}

			my $sp_word = "(?:不分卷)|(?:卷第$cnum+終)|(?:卷第$cnum+首)";
			if($this_note =~ /^(${sp_word})((?:\s*${manyver}\s*${notestar}*)+)${allspace}*$/ and $notenum == 1)
			{
				# 符合格式11

				$note_form{$subID} = 11;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}

			# 格式 12. <?> 開始的該組不處理: 阿修囉＝阿脩羅【三】＊，<?>修脩混用【明】

			if($this_note =~ /^<\?>(.*)$/)
			{
				$oldword = $1;

				# 符合格式12

				$note_form{$subID} = 12;
				$note_old{$subID} = $oldword;
				$note_add_desc{$ID} = 1;
				#$note_add_xxxx{$ID} .= "有部份校勘沒處理。";		# V1.72 取消
				$note_old{$ID} = "";
				next;
			}

			# 格式 13. <r>A. IX. 3. Meghiya. ==> <note n="0491004" type="resource">A. IX. 3. Meghiya.</note>

			if( $notenum == 1 and $this_note =~ /^<r>/)
			{
				# 符合格式13
				
				$note_form{$subID} = 13;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_old{$subID} =~ s/^<r>//;
				$note_old{$ID} = "";
				last;
			}

			# 格式 14. 無法處理的句子: 只要是 <u> 開頭的句子, 我就不處理, xml 會放入 tt 中, 會在 xxxx 屬性註記

			if($this_note =~ /^<u>(.*)$/ and $notenum == 1)		# 只限第一組出現
			{
				# 符合格式14

				$note_form{$subID} = 14;
				$note_old{$subID} = $note{$ID};		# 是全部喔!
				$note_old{$subID} =~ s/^<u>//;
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}
			
			# V1.63 先處理日文略符
			
			if($this_note =~ /^$big5*?$jp0/)		# 這裡發現
			{
				while($this_note =~ /^$big5*?$jp0/)
				{
					$this_note =~ s/^($big5*?)$jp0/$1/;
				}
				$has_japan0{$subID} = 1;	# 這裡有 $jp0 的略符
			}

			if($this_note =~ /^$big5*?$jp1/)		# 這裡發現
			{
				while($this_note =~ /^$big5*?$jp1/)
				{
					$this_note =~ s/^($big5*?)$jp1/$1/;
				}
				$has_japan1{$subID} = 1;	# 這裡有 $jp1 的略符
			}

			# V1.67 先處理日文略符
			
			if($this_note =~ /^$big5*?$jp2/)		# 這裡發現
			{
				while($this_note =~ /^$big5*?$jp2/)
				{
					$this_note =~ s/^($big5*?)$jp2/$1/;
				}
				$has_japan2{$subID} = 1;	# 這裡有 $jp2 的略符
			}

			if($this_note =~ /^$big5*?$big_jp/)		# V1.81 這裡發現不該出現的日文大寫略符
			{
				$xml_err_msg{$ID} .= "發現日文大寫略符,";
				print OUT "$note_line{$ID}: 發現日文大寫略符 [$ID] : $this_note\n";		#v1.33
			}

			# 格式 1. 換字: 21 騫茶＝騫荼【三】＊～Kha.n.daa.
			# 格式 1. 換字: 21 夾註（（騫茶））xx字 or 夾註＝夾註（（騫荼））xx字 or 夾註【三】＊～Kha.n.daa.

			if($this_note =~ /^(.+?)＝(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				#$star = $4;
				$spell = $4;
				$word_num = 0;	#先判為 0 , 等一下再檢查

				# 處理括號的特殊型式
				# 夾註（彼）xx字 or 夾註
				
				if($oldword =~ /^${allsmallnote}?(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}${allsmallnote}?(${cnum}*)(?:字)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$word_num = $2;
					$tmp = "($tmp)" if ($oldword =~ /${smallnote}/);		# 若有夾註則加上括號
					#$tmp = "<{$tmp}>" if ($oldword =~ /本文/);				# 若有本文則加上括號
					$oldword = $tmp;
				}

				if($newword =~ /^${allsmallnote}?(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# 若有夾註則加上括號
					$tmp = "<{$tmp}>" if ($newword =~ /本文/);				# 若有本文則加上括號
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# 記錄側註
					$newword = $tmp;
				}

				# 若標準，則處理下去

				if (($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/) and ($newword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/))
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword ＝ $newword\n";		#v1.33
				}
					
				# 符合格式1

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=1,old=$oldword,new=$newword,ver=$ver,star=$star,spell=$spell";
				
				$note_form{$subID} = 1;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;

				$note_old{$subID} = get_corr_right($note_old{$subID});		# V1.70 勘誤要先換才行

				if($notenum == 1)
				{
					$note_old{$ID} = $note_old{$subID};
					# 將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# 格式 2. 缺字: 14 夾註〔為〕xx字 or 夾註－【三】＊

			if($this_note =~ /^${allsmallnote}?〔(.+?)〕${allsmallnote}?(${cnum}*)(?:字)*${allsmallnote}?－((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$word_num = $2;
				$ver = $3;
				$spell = $4;

				if ($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/)
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword\n";
				}
				
				# 符合格式2

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				# 處理夾註
				if($this_note =~ /${smallnote}/) { $oldword = "($oldword)";}	# 加上括號

				#$note_form{"$ID_$notenum"} = "form=2,old=$oldword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 2;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = "";
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;
				
				$note_old{$subID} = get_corr_right($note_old{$subID});		# V1.70 勘誤要先換才行

				if($notenum == 1)
				{
					$note_old{$ID} = $note_old{$subID};
					#將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# 格式 3. 前加字: 12 夾註（彼）xx字 or 夾註＋放逸【三】＊

			if($this_note =~ /^${allsmallnote}?\Q（\E(.+?)\Q）\E${allsmallnote}?(${cnum}*)(?:字)*${allsmallnote}?＋(.*?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $3;
				$newword = $1;
				$word_num = $2;
				$ver = $4;
				$spell = $5;

				if (($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/) and ($newword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/))
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword ＋ $newword\n";
				}
				
				# 符合格式3

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				# 處理夾註, 別忘了判斷原來的是否也在夾註內
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# 加上括號
				if($this_note =~ /本文/) { $newword = "<{$newword}>";}			# 加上本文的記號
				$interlinear{$subID} = 1 if($this_note =~ /$interlinear_note/);	# 記錄側註
					
				#$note_form{"$ID_$notenum"} = "form=3,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 3;
					
				$oldword = get_corr_right($oldword);		# V1.70 勘誤要先換才行
					
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword . $oldword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# 格式 4. 後加字: 28 壁＋夾註（者）xx字 or 夾註【三】＊

			if($this_note =~ /^(.*?)＋${allsmallnote}?\Q（\E(.+?)\Q）\E${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				#$star = $4;
				$spell = $4;

				if (($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/) and ($newword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/))
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword ＋ $newword\n";
				}
				
				# 符合格式4

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				# 處理夾註, 別忘了判斷原來的是否也在夾註內
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# 加上括號
				if($this_note =~ /本文/) { $newword = "<{$newword}>";}			# 加上本文的記號
				$interlinear{$subID} = 1 if($this_note =~ /$interlinear_note/);	# 記錄側註
					
				#$note_form{"$ID_$notenum"} = "form=4,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 4;
					
				$oldword = get_corr_right($oldword);		# V1.70 勘誤要先換才行
					
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $oldword . $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
				}
				next;
			}

			# 格式 5. 純轉寫字: 12 舍衛～Saavatthii.
			#                   32 ～Vessava.na.

			if($this_note =~ /^(?:<z>)?(.*?)(${roma}(?:＊)?)${allspace}*$/)		# V1.83 讓 ＊ 也變成格式 5. 梵巴轉寫字的一部份
			{				
				$oldword = $1;
				$spell = $2;
				$word_num = 0;	#先判為 0 , 等一下再檢查
				
				if($this_note =~ /^<z>/)	# 要記錄下來 V1.49
				{
					$note_ztag{$ID} = "<z>";
				}

				# 處理括號的特殊型式
				# 夾註（彼）xx字 or 夾註
				
				if($oldword =~ /^(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}(${cnum}*)(?:字)*$/)
				{
					$oldword  = $1;
					$word_num = $2;
				}

				if ($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/)
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword\n";
				}
				
				# 符合格式5

				#$note_form{"$ID_$notenum"} = "form=5,old=$oldword,spell=$spell";
					
				if($oldword eq "")		# 若沒有中文, 則加入 foreign stack 裡面
				{
					$foreign_stack_total{$ID} = $foreign_stack_total{$ID}+1;
					my $subID = "${ID}_$foreign_stack_total{$ID}";
					$foreign_stack{$subID} = $spell;
					$foreign_stack{$subID} =~ s/^($sppattern)//;	# (?:(?:～)|(?:<[pP]>)|(?:<[sS]>)|(?:<~>))
					my $lang = $1;
						
					if($lang =~ /(?:～)|(?:<[pP]>)/)
					{
						$lang = "pli";
					}
					elsif($lang =~ /(?:<~>)/)
					{
						$lang = "unknown";
					}
					elsif($lang =~ /<[sS]>/)
					{
						$lang = "san";
					}
						
					# <foreign n="xxxxxxx" place="foot" lang="pli" resp="Taisho">……</foreign>
					# V1.49
					# 如果最後是 (?xxx) 或 (xxx?) 或 (?) 則上 cert="?"
					# 如果只有 ? 在最後, 則加上警告
						
					if($foreign_stack{$subID} =~ /(?:\(\?[^\)]*?\)\.?$)|(?:\([^\)]*?\?\)\.?$)/)
					{
						if($foreign_stack{$subID} =~ / /)	# 有空格就要警告
						{
							$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\" xxxx=\"梵巴文中有空格,可能是長句\">" . $foreign_stack{$subID} . "</foreign>";
							print OUT "$note_line{$ID}: 警告:梵巴文中有空格,可能是長句 [$ID] : $note{$ID}\n";
						}
						else
						{
							my $tmp = $foreign_stack{$subID};
							$tmp =~ s/\(\?\)(\.?)$/$1/;
							$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\">" . $tmp . "</foreign>";
						}
					}
					elsif($foreign_stack{$subID} =~ /\?\.?$/)
					{
						$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\" xxxx=\"?在梵巴文的最後\">" . $foreign_stack{$subID} . "</foreign>";
						print OUT "$note_line{$ID}: 警告:?在梵巴文的最後 [$ID] : $note{$ID}\n";
					}
					else
					{
						$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\">" . $foreign_stack{$subID} . "</foreign>";
					}
						
					$note_total{$ID}--;			# 不算一組
					$notenum--;
				}
				else
				{
					# 有中文及梵巴的校勘
						
					$note_form{$subID} = 5;
					$oldword = get_corr_right($oldword);		# V1.70 勘誤要先換才行
					$note_old{$subID} = $oldword;
					$note_spell{$subID} = $spell;
					$note_word_num{$subID} = $word_num;
				
					if($notenum == 1)
					{
						$note_old{$ID} = $oldword;
						#將…換成可比對的資料
						$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
						$note_word_num{$ID} = $word_num;
					}
				}
				next;
			}

			# 格式 6. 經文位置交換: 0379002 : 南無普德佛∞南無妙智佛【宋】【元】【宮】
			#			0379003 : 南無普德佛∞南無妙智佛【宋】【元】【宮】
			#			18 （南無勝…劫佛）十三字∞南無離劫佛【三】【宮】【中】 ~V0.4
			# 這種若有 ... 就難了, 要手動才行

			#if($this_note =~ /^(?:\Q（\E){0,2}(.+?)(?:\Q）\E){0,2}${cnum}*(?:字)*∞(?:\Q（\E){0,2}(.+?)(?:\Q）\E){0,2}${cnum}*(?:字)*((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			if($this_note =~ /^(.+?)∞(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				$spell = $4;

				# 處理括號的特殊型式
				# 夾註（彼）xx字 or 夾註

				if($oldword =~ /^${allsmallnote}?(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($oldword =~ /${smallnote}/);		# 若有夾註則加上括號
					$oldword = $tmp;
				}

				if($newword =~ /^${allsmallnote}?(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# 若有夾註則加上括號
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# 記錄側註
					$newword = $tmp;
				}

				# 若標準，則處理下去

				if (($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/) and ($newword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/))
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword ∞ $newword\n";
				}
				
				# 先行判斷此行有沒有出現過
				if($eight_note{$this_note})
				{
					my $tmp = $oldword;
					$oldword = $newword;
					$newword = $tmp;
					$eight_note{$this_note} = 0;
				}
				else {$eight_note{$this_note} = 1};
							
				# 符合格式6
				
				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}
				
				#$note_form{"$ID_$notenum"} = "form=6,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 6;
				$oldword = get_corr_right($oldword);		# V1.70 勘誤要先換才行
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#$note_new{$ID} = $newword;
					#將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
					#$note_new{$ID} = "" if $note_new{$ID} =~ /…/;
				}
				next;
			}

			# 格式 7. 複雜的換字: 06 （（展轉…決定 ））十字＝（（定展轉增上力二識成決 ））十字【元】

			# 應該沒用了, 被格式 1 合併了
			#if($this_note =~ /^\Q（（\E(.+?)\s*\Q））\E${cnum}*(?:字)*＝\Q（（\E(.+?)\s*\Q））\E${cnum}*(?:字)*((?:\s*【.*】\s*${notestar}*)+)(${roma}?)${allspace}*$/)
		 	#{
			#	$oldword = $1;
			#	$newword = $2;
			#	$ver = $3;
			#	#$star = $4;
			#	$spell = $4;

			#	if (($oldword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/) and ($newword !~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/))
			#	{
			#		# 符合格式7

			#		if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

					#$note_form{"$ID_$notenum"} = "form=7,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
			#		$note_form{$subID} = 7;
			#		$note_old{$subID} = $oldword;
			#		$note_new{$subID} = $newword;
			#		$note_ver{$subID} = $ver;
			#		$note_star{$subID} = $star;
			#		$note_spell{$subID} = $spell;

			#		if($notenum == 1)
			#		{
			#			$note_old{$ID} = $oldword;
			#			#將…換成可比對的資料
			#			$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
			#		}
			#		next;
			#	}
			#}

			# 格式 8. 特殊的句字: 不分卷【三】【宮】, 卷第一終【三】【宮】, 卷第二首【三】【宮】

			$sp_word = "(?:光明皇后願文)|(?:無夾註)|(?:不分卷)|(?:卷第$cnum+終)|(?:卷第$cnum+首)";
			if($this_note =~ /^(${sp_word})((?:\s*${manyver}\s*${notestar}*)+)${allspace}*$/)
			{
				$sp_note = $1;
				$ver = $2;
				#$star = $3;

				# 符合格式8

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=8,sp_note=$sp_note,ver=$ver,satr=$star";
				$note_form{$subID} = 8;
				$note_old{$subID} = $sp_note;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_old{$ID} = "";
				next;
			}

			#################### 第二層之後才會出現的 ##########################

			# 格式 100. 換字: 21 ＝夾註（（騫荼））xx字 或 夾註【三】＊～Kha.n.daa.

			if($this_note =~ /^＝(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$newword = $1;
				$ver = $2;
				#$star = $4;
				$spell = $3;

				# 處理括號的特殊型式
				# 夾註（彼）xx字 or 夾註
				
				if($newword =~ /^${allsmallnote}?(?:\Q（\E){1,2}(.+?)(?:\Q）\E){1,2}${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# 若有夾註則加上括號
					$tmp = "<{$tmp}>" if($newword =~ /本文/);			# 若有本文則加上記號
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# 記錄側註
					$newword = $tmp;
				}

				if ($newword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/)
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $newword\n";
				}
				
				# 符合格式 100

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=100,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 100;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				next;
			}

			# 格式 101. 缺字: 14 －【三】＊

			if($this_note =~ /^－((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$ver = $1;
				#$star = $3;
				$spell = $2;

				if ($oldword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/)
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $oldword\n";
				}
				
				# 符合格式 101

				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=101,old=$oldword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 101;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = "";
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#將…換成可比對的資料
					$note_old{$ID} = "" if $note_old{$ID} =~ /…/;
				}
				next;
			}

			# 格式 102. 雙括號的換字:  夾註（（騫荼））xx字 or 夾註【三】＊～Kha.n.daa.
			
			# 格式 103 , 加字的變形, 但沒有＋，也沒原來的字: 12 夾註（彼）xx字 or 夾註【三】＊
			# 後來要依據第一組的資料來確認是前加字或後加字

			if($this_note =~ /^${allsmallnote}?\Q（\E(.+?)\Q）\E${allsmallnote}?${cnum}*(?:字)*${allsmallnote}?((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$newword = $1;
				$ver = $2;
				$spell = $3;

				# 符合格式 102 or 103 (103 只有一層括號)
				if($newword =~ /^\Q（\E.+\Q）\E$/)
				{
					# 有二層括號, 型號 102 
					$newword =~ s/^\Q（\E(.+)\Q）\E$/$1/;
					$note_form{$subID} = 102;
				}
				else
				{
					$note_form{$subID} = 103;
				}

				if ($newword =~ /(\s*【.*】\s*)|(\Q）\E)|(〔)|(〕)|(～)|(＝)|(－)|(＋)/)
				{
					print OUT "$note_line{$ID}: 小心怪符號 [$ID] : $newword\n";
				}
				
				if($ver =~ /＊/) {$star = 1;} else {$star = 0;}

				# 處理夾註, 別忘了判斷原來的是否也在夾註內
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# 加上括號
				if($this_note =~ /本文/) { $newword = "<{$newword}>";}			# 加上本文的記號
				$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# 記錄側註

				#$note_form{"$ID_$notenum"} = "form=3,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";

				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				next;
			}

			# 格式 999, 無法分析的格式

			#$note_form{"$ID_$notenum"} = "form=999,sp_note=$this_note";
			$note_form{$subID} = 999;
			$note_old{$subID} = $this_note;
			if($notenum == 1)
			{
				$note_old{$ID} = "";
			}

			# push(@unknown_note, "$note_line{$ID}:無法直接分析的校勘: $ID : $note\n");
			# print OUT2 "$note_line{$ID}:無法直接分析的校勘: $ID : $note\n";
		}
	}
}

##############################################
# 將校勘做成 xml 格式
##############################################

sub make_xml_formate()
{
	local $_;
	my $ID;
	my $subID;
	my $note_total;
	my $errormessage;

	foreach $ID (sort(keys(%note)))
	{
		
#=begin
			if ($ID eq "0155018")
			{
				my $debug_ = 1;
			}
#=end
#=cut
		
		$note_xml{$ID} = "";
		$note_total = $note_total{$ID};		# 本條校勘的數目

		next if $note_total == 0;		# 可能是只有 note stack

		# 特例 5 , 檢查是不是單一的梵巴轉寫字

		if($note_form{"${ID}_1"} == 5 and $note_total == 1)
		{
			$subID = "${ID}_1";

			my $skpali = $note_spell{$subID};
=begin
			if ($note_old{$subID} eq "")	# 這一段格式會取消 V1.40
			{
				# 沒有相對應的漢文, XML格式是：<t n="000101" place="foot" lang="san">梵文</t>

				while($skpali =~ /^${sppattern}.*/)
				{
					my $now;

					$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
					$now = $1;

					if($now =~ /^(～)|(<p>)/i)
					{
						$now =~ s/^(～)|(<p>)//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"pli\">$now</t>";
					}
					elsif($now =~ /^<s>/i)
					{
						$now =~ s/^<s>//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"san\">$now</t>";
					}
					elsif($now =~ /^<~>/i)
					{
						$now =~ s/^<~>//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"unknown\">$now</t>";
					}
				}
				
				#if($orig_stack{$ID})		# V1.40 取消
				#{
				#	$note_xml{$ID} =~ s/place="foot"/place="foot" orig="$orig_stack{$ID}"/;
				#}
				
				if ($show_no_word_error)	# 是否要秀出沒有經文的梵文文字警告?
				{
					$xml_err_msg{$ID} = "第 1 組就找不到經文範圍。";
				}
			}
			else
=end
=cut			
			{
				# 有相對應的中文
				if($note_ztag{$ID} eq "<z>")
				{
					$note_xml{$ID} = "<t lang=\"chi\" resp=\"CBETA\">$note_old{$subID}</t>";
				}
				else
				{
					$note_xml{$ID} = "<t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_old{$subID}</t>";
				}
				
				while($skpali =~ /^${sppattern}.*/)
				{
					my $now;
					
					$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
					$now = $1;
					
					if($now =~ /^(～)|(<p>)/i)
					{
						$now =~ s/^(～)|(<p>)//i;
						$note_xml{$ID} .= "<t lang=\"pli\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
					elsif($now =~ /^<s>/i)
					{
						$now =~ s/^<s>//i;
						$note_xml{$ID} .= "<t lang=\"san\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
					elsif($now =~ /^<~>/i)
					{
						$now =~ s/^<~>//i;
						$note_xml{$ID} .= "<t lang=\"unknown\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
				}
				
				$note_xml{$ID} = "<tt n=\"$ID\" type=\"app\">" . $note_xml{$ID} . "</tt>";
				
				#if($orig_stack{$ID})		# V1.40 取消
				#{
				#	$note_xml{$ID} =~ s/type="app"/type="app" orig="$orig_stack{$ID}"/;
				#}
			}
			
			# 一些後處理的動作, 要處理的是 $note_xml
		
			last_process($ID);
			
			next;
		}

		# 特例 999 , 檢查第一組是不是就不通過了

		if($note_form{"${ID}_1"} == 999)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"第1組就有問題了\">$note{$ID}</note>";
			$xml_err_msg{$ID} .= "第1組就有問題了。";
			next;
		}

		# 特例 8 , 檢查第一組是不是就不通過了

		if($note_form{"${ID}_1"} == 8)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\">$note{$ID}</note>";
			next;
		}

		# 特例 9 , 使用者指定無法檢查的, 也就是以 <x> 開頭的字

		if($note_form{"${ID}_1"} == 9)
		{
			$note_xml{$ID} = "<todo><note n=\"$ID\" place=\"foot\">$note{$ID}</note></todo>";
			next;
		}

		# 特例 10 , 使用者指定無法檢查的, 以 <n> 開頭的字 , 所以沒有 xxxx 屬性

		if($note_form{"${ID}_1"} == 10)
		{
			my $tmp = $note{$ID};
			$tmp =~ s/，<[ocy]o?>.*$//;		# 移除後面的資料
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\">$tmp</note>";
			next;
		}
		
		# 格式 11. 無法處理的句子: 只要是 <a> 開頭的句子, 我就不處理, xml 會放入 note 中, 會在 xxxx 屬性註記

		if($note_form{"${ID}_1"} == 11)
		{
			#$note_xml{$ID} = "<app n=\"$ID\" desc=\"$note{$ID}\" xxxx=\"沒有處理的校勘\"><lem>???</lem><rdg wit=\"【???】\">???</rdg></app>";		# V1.61 取消
			#$note_xml{$ID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\"><todo type=\"a\"/>$note{$ID}</note>";
			$modify_stack{$ID} = "<todo type=\"a\"/>" . $modify_stack{$ID};
			next;
		}

		# 格式 13. 無法處理的句子: 只要是 <r> 開頭的句子, 我就不處理, xml 會放入 note 中, 註明 type="resource"

		#if($note_form{"${ID}_1"} == 13)
		#{
		#	$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" type=\"resource\">$note{$ID}</note>";
		#	next;
		#}

		# 格式 14. 無法處理的句子: 只要是 <u> 開頭的句子, 我就不處理, xml 會放入 note 中, 會在 xxxx 屬性註記

		if($note_form{"${ID}_1"} == 14)
		{
			# $note_xml{$ID} = "<tt n=\"$ID\" desc=\"$note{$ID}\" xxxx=\"沒有處理的校勘\"><t lang=\"chi\">???</t><t lang=\"unknown\">???</t><t lang=\"chi\" place=\"foot\">???</t></tt>";		# V1.61 取消
			#$note_xml{$ID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\"><todo type=\"u\"/>$note{$ID}</note>";
			$modify_stack{$ID} = "<todo type=\"u\"/>" . $modify_stack{$ID};
			next;
		}

		# 特例 100 以上的 , 不該出現在第一組, 

		if($note_form{"${ID}_1"} >= 100)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"第1組就有問題了\">$note{$ID}</note>";
			$xml_err_msg{$ID} .= "第1組就有問題了。";
			next;
		}

		# 其它各組的檢查

		for(my $i=1; $i<=$note_total; $i++)
		{
			$subID = "${ID}_$i";

			# 要先檢查 oldword

			# 格式 12. <?> 開始的該組不處理: 阿修囉＝阿脩羅【三】＊，<?>修脩混用【明】
			if($note_form{$subID} == 12)
			{
				next;	# 跳到下一組
			}

			if($i==1 and $note_form{$subID} != 12)		# 第一組要檢查的事
			{
				if($note_old{$subID} eq "" and $note_form{$subID} != 3 and $note_form{$subID} != 4)	# 格式 3, 4 是加字
				{
					$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"第 1 組就找不到經文範圍\">$note{$ID}</note>";
					$xml_err_msg{$ID} .= "第 1 組就找不到經文範圍。";
					next;
				}
			}

			if($i != 1)		# 第二組之後才檢查
			{
				my $tmp;
				if($note_old{$subID} ne $note_old{"${ID}_1"})
				{
					if($note_old{$subID} ne "")
					{
						# 若是換詞, 而且是原經文範圍的一部份, 則可以處理
						if($note_form{$subID} == 1 && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$tmp = $note_old{"${ID}_1"};
							$tmp =~ s/\Q$note_old{$subID}\E/$note_new{$subID}/;
							$note_new{$subID} = $tmp;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						# 若是刪除, 而且是原經文範圍的一部份, 則可以處理
						elsif($note_form{$subID} == 2 && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$note_new{$subID} = $note_old{"${ID}_1"};
							$note_new{$subID} =~ s/\Q$note_old{$subID}\E//;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						# 若是前(或後)加字, 而且是原經文範圍的一部份, 則可以處理
						elsif(($note_form{$subID} == 3 || $note_form{$subID} == 4) && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$tmp = $note_old{"${ID}_1"};
							$tmp =~ s/\Q$note_old{$subID}\E/$note_new{$subID}/;
							$note_new{$subID} = $tmp;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						elsif($note_form{$subID} == 999)
						{
							$xml_err_msg{$ID} .= "第 $i 組看不懂。";
						}
						else
						{
							$xml_err_msg{$ID} .= "第 $i 組的經文範圍與第一組不合。";
						}
					}
					else		# 雖然舊資料空白, 但要特別處理
					{
						# 要先將型號 103 處理成 型號 3 或 4
						if($note_form{$subID} == 103)
						{
							if($note_form{"${ID}_1"} == 3)
							{
								$note_form{$subID} = 3;
							}
							elsif($note_form{"${ID}_1"} == 4)
							{
								$note_form{$subID} = 4;
							}
							else
							{
								$xml_err_msg{$ID} .= "第 $i 組不知加字要加在前面或後面。";
							}
						}

						# 型號 102 (雙括號的換字) 一定要配合型號 1 (標準換字)
						if($note_form{$subID} == 102)
						{
							if($note_form{"${ID}_1"} != 1)
							{
								$xml_err_msg{$ID} .= "第 $i 組應該要配合換字(第1組應該是換字才對)。";
							}
						}
					
						# 前加字
						if($note_form{$subID} == 3 && $note_old{"${ID}_1"} ne "")
						{
							$note_new{$subID} = $note_new{$subID} . $note_old{"${ID}_1"};
							$note_old{$subID} = $note_old{"${ID}_1"};
						}

						# 後加字
						if($note_form{$subID} == 4 && $note_old{"${ID}_1"} ne "")
						{
							$note_new{$subID} = $note_old{"${ID}_1"} . $note_new{$subID};
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
					}
				}
			}

			# 這裡是終於通過了

			if($note_form{$subID} != 5)		# 不是單純的梵巴轉換
			{
				my $tmp = $note_new{$subID};
				my $add_resp = "";		# 預防有人要在 rdg 中加入 resp 及相關屬性, 這是為了 <k> 所設計的
				
				$tmp = "&lac;" if $tmp eq "";
				if($note_add_resp{$subID})
				{
					$add_resp = " $note_add_resp{$subID}";
				}
				
				if($note_ver{$subID} =~ /$manyver.+/)	# 星號或混同之類的東西要移到 desc 之中 , V1.42
				{
					my $tmp = "";
					my $tmp2 = $note_ver{$subID};
					
					while($tmp2 =~ /$manyver/)
					{
						$tmp2 =~ s/($manyver)//;
						$tmp .= $1;
					}
					$note_ver{$subID} = $tmp;
					if($tmp2 ne "")
					{
						$note_add_desc{$ID} = 1;		# V1.44
					}
				}	
				
				if($has_japan0{$subID})			# 有日本略符 V1.63
				{
					$note_xml{$ID} .= "<rdg wit=\"【？Ａ】\" resp=\"$note_ver{$subID}\"${add_resp}>$tmp</rdg>";
				}
				elsif($has_japan1{$subID})			# 有日本略符 V1.63
				{
					$note_xml{$ID} .= "<rdg wit=\"【？Ｂ】\" resp=\"$note_ver{$subID}\"${add_resp}>$tmp</rdg>";
				}
				elsif ($has_japan2{$subID})			# 有日本略符 V1.67, 而且這一種格式還要再做後處理
				{
					$tmp =~ s/<note place="inline">(.*?)<\/note>/\($1\)/g;	# 在 corr 中不可以有標記
					$tmp =~ s/<note place="interlinear">(.*?)<\/note>/\($1\)/g;	# 在 corr 中不可以有標記

					$note_xml{$ID} .= "<jap2sic corr=\"$tmp\" resp=\"$note_ver{$subID}\">";
				}
				else
				{
					$note_xml{$ID} .= "<rdg wit=\"$note_ver{$subID}\" resp=\"Taisho\"${add_resp}>$tmp</rdg>";
				}
			}
		}

		# 有一些特例要變成 <sic> , 例如版本是 ？ 的獨立單組校勘
		if($note_ver{"${ID}_1"} eq "？" and $note_total == 1)
		{
			#T44p0137 [11] 狹＝挾？
			#<sic n="xxxxxxx" resp="Taisho" cert="?" corr="挾">狹</sic>

			my $subID = "${ID}_1";
			$note_xml{$ID} =~ /<rdg [^>]*>(.*?)<\/rdg>/;
			my $tmp = $1;
			# 這裡有點危險, 因為將 sic 都當成是單組在處理
			$sic_stack{$ID} = "<sic n=\"$ID\" resp=\"Taisho\" cert=\"?\" corr=\"$tmp\">$note_old{$subID}</sic>";
			$note_xml{$ID} = "";
		}
		else
		{
			# 都處理完之後, 將最外層的 app 標上去
			# 加入要必要屬性
			
			my $tmp = "${ID}_1";
			my $has_attrib = "";

			#$has_attrib .= " desc=\"$note{$ID}\"" if $note_add_desc{$ID};		# V1.65 取消
			#$has_attrib .= " orig=\"$orig_stack{$ID}\"" if $orig_stack{$ID};    	# V1.40 取消
			$has_attrib .= " xxxx=\"$note_add_xxxx{$ID}\"" if $note_add_xxxx{$ID};
			$note_xml{$ID} = "<app n=\"$ID\"${has_attrib}><lem>$note_old{$tmp}</lem>" . $note_xml{$ID} . "</app>";
		}

		$note_xml{$ID} =~ s/<lem><\/lem>/<lem>&lac;<\/lem>/;		# 若第一筆沒資料

		# 檢查是不是有巴利文或梵文, 若有要將它包在 tt 標記中

		if(not $xml_err_msg{$ID})
		{
			my $gloss_count = 0;
			my $gloss_tmp = "";

			for(my $i=1; $i<=$note_total; $i++)
			{
				$subID = "${ID}_$i";
				if($note_spell{$subID})
				{
					my $skpali = $note_spell{$subID};
				
					while($skpali =~ /^${sppattern}.*/)
					{
						my $now;
					
						$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
						$now = $1;
					
						if($now =~ /^(～)|(<p>)/i)
						{
							$now =~ s/^(～)|(<p>)//i;
							$gloss_tmp .= "<t lang=\"pli\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
						elsif($now =~ /^<s>/i)
						{
							$now =~ s/^<s>//i;
							$gloss_tmp .= "<t lang=\"san\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
						elsif($now =~ /^<~>/i)
						{
							$now =~ s/^<~>//i;
							$gloss_tmp .= "<t lang=\"unknown\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
					}
					$gloss_count++;
				}	
			}

			if($gloss_count > 0)
			{
				# $note_xml{$ID} =~ s/<app n="$ID"/<app n="${ID}b"/;  	# 後來決定不用 abcd 了

				if($gloss_count == 1)			# 要剛好等於 1 才行.
				{
					if($note{$ID} =~ /<z>/)		# V1.75 , 當二組標記, 且有 <z> 時, 加上 xxxx 屬性的警告
					{
						$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\" xxxx=\"有 z 標記\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
					}
					else
					{
						$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
					}
				}
				else
				{
					$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\" xxxx=\"梵巴文字超過二組\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
				}

				#if($orig_stack{$ID})			# V1.40 取消
				#{
				#	$note_xml{$ID} =~ s/type="app"/type="app" orig="$orig_stack{$ID}"/;
				#}
			}
		}

		# 一些後處理的動作, 要處理的是 $note_xml

		last_process($ID);
	}

	######## 加上 stack  #######################

	foreach $ID (sort(keys(%note)))
	{
		my $all_stack = "";
		my $big5corr='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x5a]|\x5c|[\x5e-\x7f]))';

		# 加上 orig stack , 這是原始資料	V1.40
		$all_stack = "<note n=\"$ID\" resp=\"Taisho\" type=\"orig\" place=\"foot\">$orig_stack{$ID}</note>";

		# 有修改的資料放第二層的 Note	V1.63 , V1.65
		if(($orig_stack{$ID} ne $modify_stack{$ID}) or ($note_add_desc{$ID}==1))
		{
			$all_stack .= "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\">$modify_stack{$ID}</note>";
		}

		# 加上 foreign stack , <foreign> 標記	V1.40

		for(my $i=1; $i<=$foreign_stack_total{$ID}; $i++)
		{
			$subID = "${ID}_$i";
			$all_stack .= "$foreign_stack{$subID}";		# 加上 foreign stack
		}
		
		# 加上 sic stack , <sic> 標記	V1.40
		if($sic_stack{$ID})
		{
			$all_stack .= "$sic_stack{$ID}";
		}

		# 先將前面的 stack 加進去
		$note_xml{$ID} =  $all_stack . $note_xml{$ID};

		# 最後加上 note stack
		for(my $i=1; $i<=$note_stack_total{$ID}; $i++)
		{
			$subID = "${ID}_$i";
			$note_xml{$ID} .= $note_stack{$subID};
		}
	}
}

#################################################
#
# 一些後處理的動作, 要處理的是 $note_xml	V1.40
#
#################################################

sub last_process()
{
	my $ID = shift;

=begin
	1.T02p0181? 06 <z>沸沙須摩<~>Pu.syadharman.（沸沙達摩）
	
	<tt>
	    <t lang="chi">沸沙須摩</t>
	    <t lang="unknown">Pu.syadharman.（沸沙達摩）</t>
	</tt>	
	
    "※比照前例，中間那組羅馬文字也加進「place="foot"」，變成：
    
	<tt>
	    <t lang="chi">沸沙須摩</t>
	    <t lang="unknown" resp="Taisho" place="foot">Pu.syadharman</t>
	    <t lang="chi" resp="Taisho" place="foot">沸沙達摩</t>
	</tt>
=end
=cut

	while($note_xml{$ID} =~ /(.*?)<(t lang="[^c][^>]*)>(.*?)\Q（\E(.+?)\Q）\E<\/t>(.*)/)
	{
		my $head = $1;
		my $tag = $2;
		my $skpali = $3;
		my $chinese = $4;
		my $tail = $5;
		
		$note_xml{$ID} = $head . "<${tag} place=\"foot\">" . $skpali . "</t>" .
						 "<t lang=\"chi\" resp=\"Taisho\" place=\"foot\">" . $chinese . "</t>" . $tail;
	}

=begin
	2.T02p0635? 11 <z>頌～Udaana.(?xx) (或是沒有括號的問號)
	
	<tt n="0635011" type="app">
		<t lang="chi">頌</t>
		<t lang="pli" resp="Taisho">Ud&amacron;na.(?)</t>
	</tt>
	
	※現在要將 </todo> 拿掉，並加上「place="foot" cert="?"」的屬性，變成：
	
	<tt n="0635011" type="app">
		<t lang="chi">頌</t>
		<t lang="pli"  resp="Taisho" place="foot" cert="?">Ud&amacron;na.(?)</t>
	</tt>
	
	如果有梵巴文, 則要改成

    T02p0635? 11 <z>頌～Udaana.(xx?) (或是沒有括號的問號)
	
	<tt n="0635011" type="app">
		<t lang="chi">頌</t>
		<t lang="pli"  resp="Taisho" place="foot">Ud&amacron;na</t>
		<t lang="pli"  resp="Taisho" place="foot" cert="?">xx?</t>
	</tt>
	
	
=end
=cut

	#如果梵巴最後是 (?) , 則要加上 cert="?", 但 (?) 要移走
	$note_xml{$ID} =~ s/<(t lang="[^c][^>]*)>([^<]*?)\(\?\)(\.?<\/t>)/<$1 cert="?">$2$3/g;
	

	# 如果是 ? 沒有在 () 內, 則要有記錄
	if($note_xml{$ID} =~ /<t lang="[^c][^>]*>[^<]*?\?\.?<\/t>/)
	{
		$note_xml{$ID} =~ s/<(t lang="[^c][^>]*)>([^<]*?\?\.?)<\/t>/<$1 cert="?" xxxx="?在梵巴文的最後">$2<\/t>/g;
		print OUT "$note_line{$ID}: 警告:?在梵巴文的最後 [$ID] : $note{$ID}\n";
	}

	while($note_xml{$ID} =~ /(.*?)<(t lang="[^c][^>]*)>([^<]*?)\(((?:\?[^\)]+?)|(?:[^\)]+?\?))\)(\.?)<\/t>(.*)/)
	{
		my $head = $1;
		my $tag = $2;
		my $skpali = $3 . $5;
		my $another = $4;
		my $tail = $6;
		
		my $hasspace = "";
		
		if ($skpali =~ / /)
		{
			$hasspace = " xxxx=\"梵巴文中有空格,可能是長句\"";
			print OUT "$note_line{$ID}: 警告:梵巴文中有空格,可能是長句 [$ID] : $note{$ID}\n";
		}
		else
		{
			$skpali =~ s/\.$//;		# 最後的句點去除
		}
		
		$another =~ s/^\?//;
		$another =~ s/\?$//;	# 去除頭尾的 ? 問號 V1.66
		
		$note_xml{$ID} = $head . "<${tag}${hasspace}>" . $skpali . "</t>" .
						 "<${tag} cert=\"?\">" . $another . "</t>" . $tail;
	}

	# 將一些有 <note place="inline"> 卻沒資料的, 將它變成 &lac;
	$note_xml{$ID} =~ s#><note[^>]*?place="inline"[^>]*?></note><#>&lac;<#g;
	$note_xml{$ID} =~ s#><note[^>]*?place="interlinear"[^>]*?></note><#>&lac;<#g;

	# 將 <note place="inline">&lac;</note> 變成 &lac; 即可.
	$note_xml{$ID} =~ s#><note[^>]*?place="inline"[^>]*?>&lac;</note><#>&lac;<#g;
	$note_xml{$ID} =~ s#><note[^>]*?place="interlinear"[^>]*?>&lac;</note><#>&lac;<#g;

	$note_xml{$ID} =~ s#<note[^>]*?place="inline"[^>]*?>&lac;</note>##g;
	$note_xml{$ID} =~ s#<note[^>]*?place="interlinear"[^>]*?>&lac;</note>##g;
	
	# 警告版本是？的校勘　V1.42
	
	if($note_xml{$ID} =~ /<rdg\s+wit="？/)
	{
		$note_xml{$ID} =~ s/(<rdg\s+wit="？.*?)>/$1 xxxx="警告:有？的版本">/g;
		print OUT "$note_line{$ID}: 警告:有？的版本 [$ID] : $note{$ID}\n";
	}
	
	# 警告第二組經文有…符號的	V1.42
	if($note_xml{$ID} =~ /<rdg[^>]*>[^<]*?…/)
	{
		$note_xml{$ID} =~ s/(<rdg[^>]*)(>[^<]*?…)/$1 xxxx="警告:校勘含有…"$2/g;
		print OUT "$note_line{$ID}: 警告:校勘含有… [$ID] : $note{$ID}\n";
	}
	
	# 處理版本裡面的註解 V1.71
	# <rdg wit="【元】【明南藏】<resp="【明】">"...> 變成 <rdg wit="【元】>...<rdg wit="【明南藏】" resp="【明】"...>
	
	if($note_xml{$ID} =~ /<rdg wit="(?:【[^>]*?】)+【.*?】<resp="【.*?】">"[^>]*>.*?<\/rdg>/)
	{
		$note_xml{$ID} =~ s/(<rdg wit="(?:【[^>]*?】)+)(【.*?】)<(resp="【.*?】")>"([^>]*)(>.*?<\/rdg>)/$1"$4$5<rdg wit="$2" $3$5/g;
	}
	
	# 處理版本裡面的註解 V1.45
	# <rdg wit="【明南藏】<resp="【明】">"...> 變成 <rdg wit="【明南藏】" resp="【明】"...>
	
	if($note_xml{$ID} =~ /(<rdg wit="【.*?】)<(resp="【.*?】")>"([^>]*?)(resp="Taisho")?([^>]*?>)/)
	{
		$note_xml{$ID} =~ s/(<rdg wit="【.*?】)<(resp="【.*?】")>"([^>]*?)(resp="Taisho")?([^>]*?>)/$1" $2$3$5/g;
		$note_xml{$ID} =~ s/(resp=".*?") resp="Taisho"/$1/g;	# 不得已的協助.
	}	
	
	#if($note_xml{$ID} =~ /<rdg wit="(【.*?】){2,}<resp="【.*?】">"[^>]*>/)
	#{
	#	#有二組 【.*?】, 不符處理原則
	#	print OUT "$note_line{$ID}: 警告(可能誤判):有二組 【.*?】 : $note{$ID}\n";
	#}

	if($note_xml{$ID} =~ /<rdg wit="【.*?】<resp="【.*?】">[^"]+">/)
	{
		# <resp> 之後還有東西, 不符處理原則
		print OUT "$note_line{$ID}: 警告: <resp> 之後還有東西 : $note{$ID}\n";
	}



=begin

	V 1.67
	
	有日文 [力] 的, 之前我會先做成 類似 rdg , 但不是 rdg , 而是用 <jap2sic
	
	<jap2sic corr="xx" resp="【版本】">
	
	再時再處理單組或多組
	
	<sic corr="xx" resp="【版本】">yy</sic> 
	
	
	單組的:
	
	[者*見]＝覲[力]【甲】
	
	<sic corr="覲" resp="【甲】">[者*見]</sic>
	
	多組的:
	
	[者*見]＝觀[仁-二]，覲[力]【甲】

	<app>
    	<lem><sic corr="覲" resp="【甲】">[者*見]</sic></lem>
    	<rdg wit="?" resp="【甲】">觀</rdg>
	</app>
	
=end
=cut

	if($note_xml{$ID} =~ /<jap2sic/)
	{
		if($note_xml{$ID} =~ /<rdg/)
		{
			# 多組的
			$note_xml{$ID} =~ s/<lem>(.*?)<\/lem>(.*?)<jap2sic (.*?)>/<lem><sic $3>$1<\/sic><\/lem>$2/;
		}
		else
		{
			# 單組的
			$note_xml{$ID} =~ s/<app.*?(n=".*?").*?<lem>(.*?)<\/lem>.*?<jap2sic (.*?)>.*?<\/app>/<sic $1 $3>$2<\/sic>/;
		}
	}
}

##############################################
# 配合經文做簡單分析
# 檢查項目
# 1.經文頁次序不對者
# 2.校勘數字和前一個不合
# 3.校勘欄沒有對應的校勘資料
# 4.檢查校勘數字後的文字與校勘欄文字不合
##############################################

sub check_with_sutra()
{
	my $line_page;		# 該行的頁
	my $line_num;		# 該行校勘的編號
	my $linenum;		# 經文的行數
	my $line_pre_page=0;	# 上一個校勘的頁數
	my $line_pre_num=0;	# 上一個校勘的編號

	open SUTRA, $sutra || die "open $sutra error";
	@sutra = <SUTRA>;
	close SUTRA;

	for(my $i = 0; $i <= $#sutra; $i++)
	{
		# T01n0001_p0001a02X##[01]長阿含經序
		# T01n0001_p0001a19_##名。開[07]析修途。所記長遠。故以長為目。翫
		# T01n0001_p0001a20_##茲典者。長迷頓曉。邪正難[＊]辨。顯如晝夜。報

		$linenum = sprintf("%05d", $i+1);		# 經文的行數

		$line = $sutra[$i];

		$line_page = substr($line, 10, 4);
		if($line_page < $line_pre_page)
		{
			if($line !~ /T49/)
			{
				push (@sutra_err, "${linenum}:err4: 經文頁數小於前一行==> $line");
			}
			# print OUT "${linenum}:err4: 經文頁數小於前一行==> $line";
		}
		elsif ($line_page > $line_pre_page)
		{
			# 換頁了, 有些資料要重設
			$line_pre_page = $line_page;	# 上一個校勘的頁數
			$line_pre_num=0;				# 上一個校勘的編號
		}

		my $lineTmp = $line;			# 處理用的
		#$lineTmp =~ s/\[經\]/經/g;
		#$lineTmp =~ s/\[論\]/論/g;	
		#$lineTmp =~ s/【經】/經/g;
		#$lineTmp =~ s/【論】/論/g;
		$lineTmp =~ s/<no_nor>//g;
		$lineTmp = get_corr_right($lineTmp);	# 因為有些校勘數字會移位 [[xx]>>] , 所以要先處理

		while($lineTmp =~ /\[(\d{1,4})\]/)		#發現有數字
		{
			$line_num = $1;
			if($line_num != $line_pre_num + 1)
			{
				push (@sutra_err, "${linenum}:err5: 校勘數字不連續[$line_num]==> $line");
				#print OUT "${linenum}:err5: 校勘數字不連續[$line_num]==> $line";
			}
			$line_pre_num = $line_num;

			my $ID = $line_page . sprintf("%03d",$line_num);

			if($note{$ID})
			{
				# 有校勘資料, 檢查校勘下的文字合不合
				if ($note_old{$ID} and $lineTmp !~ /\Q[$line_num]$note_old{$ID}\E/)
				{
					# 有可能是有一部份在下二行, 所以要接起來檢查

					my $next_line = "";
					if($i < $#sutra)
					{
						$next_line = $sutra[$i+1];
						$next_line =~ s/^T.{19}(║)?//;	# 移除行首
						my $tmp = $line;
						chomp($tmp);
						$next_line = $tmp . $next_line;	# 接起來
						
						#判斷第二行
						
						if($i+1 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+2];
							$tmp =~ s/^T.{19}(║)?//;	# 移除行首
							chomp($next_line);
							$next_line = $next_line . $tmp;	# 接起來
						}
						
						#判斷第三行
						
						if($i+2 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+3];
							$tmp =~ s/^T.{19}(║)?//;	# 移除行首
							chomp($next_line);
							$next_line = $next_line . $tmp;	# 接起來
						}
								
						#判斷第四行
						
						if($i+3 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+4];
							$tmp =~ s/^T.{19}(║)?//;	# 移除行首
							chomp($next_line);
							$next_line = $next_line . $tmp;	# 接起來
						}
						
						#判斷第五行
						
						if($i+4 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+5];
							$tmp =~ s/^T.{19}(║)?//;	# 移除行首
							chomp($next_line);
							$next_line = $next_line . $tmp;	# 接起來
						}
						
						#判斷第六行
						
						if($i+5 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+6];
							$tmp =~ s/^T.{19}(║)?//;	# 移除行首
							chomp($next_line);
							$next_line = $next_line . $tmp;	# 接起來
						}
					}
					else
					{
						$next_line = $line;
					}

					$next_line =~ s/\[＊\]//g;
					$next_line =~ s/<no_nor>//g;
					$next_line =~ s/。//g;
					$next_line =~ s/．//g;
					$next_line =~ s/【◇】//g;		# 先將悉曇移除
					$next_line =~ s/$fullspace//g;
					
					#$next_line =~ s/\[經\]/經/g;
					#$next_line =~ s/\[論\]/論/g;
					#$next_line =~ s/【經】/經/g;
					#$next_line =~ s/【論】/論/g;
					
					$next_line =~ s/【圖】/&pic;/g;

					$next_line =~ s/【經】/&jing;/g;
					$next_line =~ s/【論】/&lum;/g;					
					
					
					while($next_line =~ /^$big5*?Ｐ/)
					{
						$next_line =~ s/^($big5*?)Ｐ/$1/;
					}
					while($next_line =~ /^$big5*?Ｒ/)
					{
						$next_line =~ s/^($big5*?)Ｒ/$1/;
					}					
					while($next_line =~ /^$big5*?◇/)		# 先將悉曇移除
					{
						$next_line =~ s/^($big5*?)◇/$1/;
					}
					#$next_line =~ s/\(//g;		# 會干擾組字式, 要拿掉
					#$next_line =~ s/\)//g;

					# 將其它的校勘 [xx] 也移開

					$next_line =~ s/\[$line_num\]\(?/<<>>/;
					$next_line =~ s/\[\d+?]//g;
					$next_line =~ s/<<>>/\[$line_num\]/;

					# 將勘誤換過來

					$next_line = get_corr_right($next_line);
					
					my $tmp_note_old = get_corr_right($note_old{$ID});	# 處理校勘
					$tmp_note_old =~ s/^\(//;							# 若一開始是夾註括號, 也去除, 以利比對

					if ($next_line !~ /\Q[$line_num]${tmp_note_old}\E/)
					{
						# 這是為了格式 6 所設計的, 因為有可能經文在另一個地方
						
						#my $tmp_note_new = get_corr_right($note_new{$ID});	# 處理校勘
						#$tmp_note_new =~ s/^\(//;							# 若一開始是夾註括號, 也去除, 以利比對
						#unless($note_new{$ID} and $next_line =~ /\Q[$line_num]${tmp_note_new}\E/)
						
						my $tmp1 = $next_line;
						my $tmp2 = $tmp_note_old;
						$tmp1 =~ s/[\(\)]//g;	# 暫時去除括號, 以利比對密教部的 (二合)(引)....
						$tmp2 =~ s/[\(\)]//g;
						while($tmp2 =~ /^$big5*?◇/)	# 先將悉曇移除
						{
							$tmp2 =~ s/^($big5*?)◇/$1/;
						}
						$tmp2 =~ s/&SD\-.*?;//g;		# 先將 &SD-CFC1; 這種悉曇字移除 V1.56

						if ($tmp1 !~ /\Q[$line_num]${tmp2}\E/)
						{
							# print OUT "$note_line{$ID}:err6:${linenum}: 校勘經文與校勘欄不合==> [$line_num\]$note_old{$ID} ==>  $next_line";
							push (@both_sutra_note_err, "$note_line{$ID}:err6: 校勘經文與校勘欄不合==> [$line_num\]$note_old{$ID}\n");
							push (@both_sutra_note_err, "$infile : found => \[\n");
							push (@both_sutra_note_err, "${linenum}:err6:: 校勘經文與校勘欄不合==> $next_line");
							push (@both_sutra_note_err, "$sutra : found => \[\n\n");
						}
					}
				}
			}
			else
			{
				# 沒有校勘資料
				push (@sutra_err, "${linenum}:err7: 校勘欄沒有對應的校勘資料[$line_num]==> $line");
				# print OUT "${linenum}:err7: 校勘欄沒有對應的校勘資料[$line_num]==> $line";
			}
			$has_note{$ID} = 1;			# 將此校勘做記錄

			$lineTmp =~ s/\[$line_num\]//;		# 處理過的就移除
		}
	}
}

##############################################
# 檢查有沒有校勘配不到經文的
# 檢查項目
# 1.校勘沒有出現在經文中
##############################################

sub check_lose_note()
{
	my $ID;

	foreach $ID (sort(keys(%note)))
	{
		unless ($has_note{$ID})
		{
			my $page = substr($ID, 0, 4);
			my $num = substr($ID, 4, 3);
			$num =~ s/^0//;
			print OUT "$note_line{$ID}:err8: 校勘沒有出現在經文中==> p$page, [$num] , $note{$ID}\n";
		}
	}
}

##############################################
# 將結果輸出
##############################################

sub other_output()
{
	local $_;
	my $ID;
	# 勘誤用的字型, 裡面沒有 [ ]
	my $big5corr='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x5a]|\x5c|[\x5e-\x7f]))';
	
	#print OUT "$infile : found => \[\n\n";

	# 無法分析的校勘條目

	#for(my $i=0; $i<= $#unknown_note; $i++)
	#{
	#	print OUT $unknown_note[$i];
	#}
	#print OUT "$infile : found => \[\n\n";

	# 印出 xml 版

	open XMLOUT ,">$xmlout";
	foreach $ID (sort(keys(%note_xml)))
	{
		last_proce($ID);			# 處理一些東西

		my $xmltmp = $note_xml{$ID};	# 暫時處理勘誤用的
		my $notetmp = $note{$ID};
		
		while($xmltmp =~ /^($big5*?)\[($big5corr*?)>($big5corr*?)\]/)
		{
			# <lem> 內的勘誤已被取代成經文的, 所以這裡只會換到 rdg 的
			$xmltmp =~ s/^($big5*?)\[($big5corr*?)>($big5corr*?)\](?:<[^>]*(resp[^>]*)>)?/$1<corr sic="$2" $4>$3<\/corr>/;
			$xmltmp =~ s/(<corr[^>]*") >/$1>/g;		# 去除 <corr xxx="..." > 最後的空格 (在 > 之前的)
		}
		while($xmltmp =~ /^($big5*?)☆/)
		{
			$xmltmp =~ s/^($big5*?)☆/$1/;		# 處理 todo
		}			
		while($xmltmp =~ /^($big5*?)◆/)
		{
			$xmltmp =~ s/^($big5*?)◆/$1<todo\/>/;	# 處理 todo
		}
		$xmltmp =~ s/【■】/【unknown】/g;
		while($xmltmp =~ /^($big5*?)■/)
		{
			$xmltmp =~ s/^($big5*?)■/$1&lac-space;/;		# 缺■：用&lac-space;表示 
		}
		while($xmltmp =~ /^($big5*?)●/)
		{
			$xmltmp =~ s/^($big5*?)●/$1&unrec;/;	# 模糊字●：用&unrec;表示
		}
		
		$xmltmp =~ s/<t>/<todo\/>/g;				# 處理 todo
		$xmltmp =~ s/<,>/，/g;						# 處理 <,>

		$xmltmp =~ s/&pic;/【圖】/g;
		$xmltmp =~ s/&manysk;/【◇】/g;

		$xmltmp =~ s/&jing;/【經】/g;
		$xmltmp =~ s/&lum;/【論】/g;
		
		$xmltmp =~ s/【三】/【宋】【元】【明】/g;	# V1.93 三變成宋元明
		$xmltmp =~ s/&three_ver;/【三】/g;	# V1.93 三變成宋元明,第一層的不變
		
		$notetmp =~ s/&pic;/【圖】/g;
		$notetmp =~ s/&manysk;/【◇】/g;

		$notetmp =~ s/&jing;/【經】/g;
		$notetmp =~ s/&lum;/【論】/g;
		
		$xmltmp =~ s/($big5)/&jap_rep($1)/eg;		# 將日文變成 entity V1.93 (by ray)
		$xmltmp = rm_attr_entity($xmltmp);			# 將屬性裡的 &xxx; 換成 xxx V1.71
		$xmltmp = mv_type_l($xmltmp);				# 將 <note type="l"> 移到 <lem> 後面 V1.71
		
		$xmltmp =~ s/<note/\n<note/g;				# 切出漂亮的換行
		$xmltmp =~ s/<sic/\n<sic/g;
		$xmltmp =~ s/<app/\n<app/g;
		$xmltmp =~ s/<foreign/\n<foreign/g;
		$xmltmp =~ s/<tt/\n<tt/g;
		
		#$xmltmp =~ s/\(\?\)/<todo\/>(?)/g;			# 處理 todo, V1.40 移除此行
		print XMLOUT "\n\n<ID>$ID</ID>\n<XML>${xmltmp}\n</XML>\n<source>\n\t$notetmp\n</source>\n";
		if ($xml_err_msg{$ID})
		{
			print XMLOUT "<error>\n\t<line>$note_line{$ID}</line>\n\t<message>$xml_err_msg{$ID} ==> $notetmp</message>\n</error>";
			#print XMLOUT "$note_line{$ID}: error: $notetmp\n";
			print OUT "$note_line{$ID}: err: $xml_err_msg{$ID} ==> $notetmp\n" ;
		}
	}
	# print XMLOUT "$infile : found => ，\n\n";
	print OUT "$infile : found => \[\n\n";
	close XMLOUT;

	# 和簡單標記版相關的經文錯誤

	for(my $i=0; $i<= $#sutra_err; $i++)
	{
		print OUT $sutra_err[$i];
	}
	print OUT "$sutra : found => \[\n\n";

	# 校勘與經文不吻合的問題

	for(my $i=0; $i<= $#both_sutra_note_err; $i++)
	{
		print OUT $both_sutra_note_err[$i];
	}

	# ∞ 符號的校勘沒有成對出現
	
	print OUT "\n\n★ 以下是這個符號∞的校勘沒有成對出現的問題(也可能和校勘編號有關) ★\n\n";
	foreach (keys(%eight_note))
	{
		print OUT "★ $_\n" if $eight_note{$_};
	}
	print OUT "\n★ == over == ★\n";
}

#######################################################################################
#
# 另一些後處理的動作, 要處理的是 $note_xml, 因為有些資料是要等 xml 原始資料查到後才能做
#
#######################################################################################

sub last_proce()
{
	my $ID = shift;

	# 處理一些和夾註與本文有關的問題.
	# 如果 <lem> 是由 <note> 所包起來的, 那麼 <rdg> 也要比照辦理, 除非有 "本文" , 它是 <{ }> 所括起來的
	# ... 真是很頭大的一個部份 .....
	
	if($note_xml{$ID} =~ /<lem[^>]*><note.*?<\/note><\/lem>/s)
	{
		while($note_xml{$ID} =~ /<rdg([^>]*>)(.*?)<\/rdg>/s)
		{
			my $rdg_head = $1;
			my $rdg_data = $2;
			my $rdg_data2 = $2;		# 第二組, 這一組是要將裡面的 note 移除, 因為有時會先有 note 在裡面
			
			$rdg_data2 =~ s/<note place="inline">(.*?)<\/note>/$1/g;	# 將已有的 note 先移除

			if($rdg_data2 =~ /^<{.*}>$/s)	# 全部是本文, 不要理它
			{
				$rdg_data2 =~ s/^<{(.*)}>$/$1/s;
			}
			else
			{
				if($rdg_data2 =~ /^(.+)<{(.*)}>$/s)		# 後半段是本文
				{
					$rdg_data2 = '<note place="inline">' . $1 . "</note>" . $2;
				}
				elsif ($rdg_data2 =~ /^<{(.*)}>(.+)$/s)		# 前半段是本文
				{
					$rdg_data2 = $1 . '<note place="inline">' . $2 . "</note>";
				}
				elsif ($rdg_data2 ne "&lac;")	# 沒有本文, 且不是 &lac;
				{
					$rdg_data2 = '<note place="inline">' . $rdg_data2 . "</note>";
				}
			}

			# 先將 rdg 換成 rrddgg , 以後再換回來.
			$note_xml{$ID} =~ s/<rdg\Q${rdg_head}${rdg_data}\E/<rrddgg${rdg_head}${rdg_data2}/;
		}
		$note_xml{$ID} =~ s/rrddgg/rdg/g;
	}
	$note_xml{$ID} =~ s/(<{)|(}>)//g;	# 最後還是要清掉比較好
}

#######################################################################################
#
# 將屬性裡的 &xxxx; 換成 xxxx 就好
#
#######################################################################################

sub rm_attr_entity()
{
	my $data = shift;
	my $big5_1='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x21])|(?:[\x23-\x7f]))';	# 略過 " 符號 \x22

	# 將屬性裡的 &xxxx; 變成 xxxx 就好. V1.71
	# V1.82 屬性中的 &xxxx; 改成 ＆xxxx；, 而原來若有＆則改成＆big-amp；

	my $head="";
	my $mid="";
	my $tail=$data;
	
	while($tail=~/^(.*?)<(.*?)>(.*)$/s)
	{
		$head .= $1;
		$mid = $2;
		$tail = $3;

		while($mid =~ /=\s*"${big5_1}*?＆/)			# V1.82 發現屬性中有 ＆ 的東西, 先換成 <&;>
		{
			$mid =~ s/(=\s*"${big5_1}*?)＆/$1<&;>/;
		}
		$mid =~ s/<&;>/＆big-amp；/g;				# 再將 <&;> 換成 ＆big-amp；

		while($mid =~ /=\s*"[^"]*?&[^"]*?;[^"]*?"/)	# 發現屬性中有 &xxx; 的東西
		{
			$mid =~ s/(=\s*"[^"]*?)&([^"]*?);([^"]*?")/$1＆$2；$3/;
		}

		$head = $head . "<" . $mid . ">";
	}

	$data = $head . $tail;
	return $data;
}

#######################################################################################
#
# <lem>...</lem>...<note .. type="l"> .... </note>
# 變成
# <lem><note .. type="l"> .... </note>...</lem>...
#
#######################################################################################

sub mv_type_l()
{
	my $data = shift;
	my $tmp = "";

	if($data =~ /type="l"/)
	{	
		$data =~ s/(<note[^>]*type="l".*?<\/note>)//;
		$tmp = $1;
		$data =~ s/<lem>/<lem>$tmp/;
	}

	return $data;
}

###############################################
# 取勘誤字串的右邊那一組
###############################################

sub get_corr_right()
{
	# 這一組容許數字, 因為缺字會換成 :1: :2:
	
	my $loseb5='(?:(?:[\x80-\xff][\x40-\xff])|(?:&.*?;)|[\x21-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
	my $data = shift;
	
	if($data =~ />/)
	{
		# 但要先換組字式
		
		while($data =~ /^$big5*?\[($losebig5+?)\]/)
		{
			 $data =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		
		#數字也要換啊  V1.30
		
		$data =~ s/\[(\d{2,3})\]/:1:$1:2:/g;
		
		$data =~ s/\[$loseb5*?>>($loseb5*?)\]/$1/g;
		$data =~ s/\[$loseb5*?>($loseb5*?)\](?:<[^>]*resp[^>]*>)?/$1/g;
		$data =~ s/:1:/\[/g;
		$data =~ s/:2:/\]/g;
	}
	
	return $data;
}

###############################################
# 取勘誤字串的左邊那一組, 因為要還原成原始的情況
###############################################

sub get_corr_left()
{
	# 這一組容許數字, 因為缺字會換成 :1: :2:
	
	my $loseb5='(?:(?:[\x80-\xff][\x40-\xff])|(?:&.*?;)|[\x21-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
	my $data = shift;
	
	if($data =~ />/)
	{
		# 但要先換組字式
		
		while($data =~ /^$big5*?\[($losebig5+?)\]/)
		{
			 $data =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		
		#數字也要換啊  V1.30
		
		$data =~ s/\[(\d{2,3})\]/:1:$1:2:/g;
		
		$data =~ s/\[($loseb5*?)>>$loseb5*?\]/$1/g;
		$data =~ s/\[($loseb5*?)>$loseb5*?\](?:<[^>]*resp[^>]*>)?/$1/g;
		$data =~ s/:1:/\[/g;
		$data =~ s/:2:/\]/g;
	}
	
	return $data;
}

###############################################
# 將校勘的梵巴文標準化
###############################################

sub sk_pali_normalize()
{
	foreach my $key (keys(%note_spell))
	{
		$note_spell{$key} = sp_pali_to_CB($note_spell{$key});
	}
}

###############################################
# 將梵巴文標準化
###############################################

sub sp_pali_to_CB()
{
	#$subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9（[0-9珠\]|[\'`Aa\.\^iu~][AadhilmnrstuS]|[\x00-\xff\n]';
	my $subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9（[0-9珠\]|aa|AA|ii|uu|\'s|[`\.\^~][AaDdhiLlmNnrSsTtu]|[\x00-\xff\n]';

	my @chars;	# 放資料的堆疊

	local $_ = shift;

	push(@chars, /$subpat/g);
	foreach my $var (@chars){
		$var = $s2ref{$var} if ($s2ref{$var} ne "");
	}
	return join("", @chars);
}

###############################################
# 將缺字資料讀入
###############################################

sub readGaiji()
{
	my $cb;
	my $zu;
	my $ent;
	#my $mojikyo;
	#my $uni;
	#my $ty;
	my %row;
	use Win32::ODBC;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow())
	{
		%row = $db->DataHash();

		$cb      = $row{"cb"};			# cbeta code
		#$mojikyo = $row{"mojikyo"};	# mojikyo code
		$zu      = $row{"des"};			# 組字式
		$ent     = $row{"entity"};		# 只用在通用詞 (CIxxxx)
		#$uni     = $row{"uni"};
		#$ty      = $row{"nor"};		# 通用字

		next if ($cb =~ /^#/);

		#$ty = "" if ($ty =~ /none/i);
		#$ty = "" if ($ty =~ /\x3f/);

		#die "ty=[$ty]" if ($ty =~ /\?/);

		#$gaiji_nr{$ent} = $ty;
		$gaiji_cb{$zu} = $cb;
		if($ent =~ /^CI\d+/)	# 表示這是通用詞
		{
			$gaiji_zu{$ent} = $zu;
		}
		#$gaiji_ent{$cb} = $ent;
	}
	$db->Close();
	print STDERR "ok\n";
}

###############################################
# 將校勘的缺字做成&CB碼標準格式
###############################################

sub note_gaiji_normalize()
{
	local $_ = shift;
	my $key;
	
	foreach $key (keys(%note))
	{
		$note{$key} = loseword_to_CB($note{$key});
	}
	foreach $key (keys(%note_old))
	{
		$note_old{$key} = loseword_to_CB($note_old{$key});
	}
	foreach $key (keys(%note_new))
	{
		$note_new{$key} = loseword_to_CB($note_new{$key});
	}
	foreach $key (keys(%modify_stack))
	{
		$modify_stack{$key} = loseword_to_CB($modify_stack{$key});
	}
	foreach $key (keys(%orig_stack))
	{
		$orig_stack{$key} = loseword_to_CB($orig_stack{$key});
	}
	foreach $key (keys(%note_stack))
	{
		$note_stack{$key} = loseword_to_CB($note_stack{$key});
	}
}

###############################################
# 將缺字換成 CB 碼
###############################################

sub loseword_to_CB()
{
	my $tail = shift;
	my $head = "";
	my $mid;

	# 處理通用詞

	$tail =~ s/髣髣\[髟\/弗\]\[髟\/弗\]/\&CI0013\;/g;		# 這個比較特別, 要先處理

	foreach my $key (keys(%gaiji_zu))
	{
		$tail =~ s/\Q$gaiji_zu{$key}\E/\&$key\;/g;
	}

	# 處理通用字

	$head = "";
	while($tail =~ /^($big5*?)(\[$losebig5+?\])(.*\n?)/)
	{
		$head .= $1;
		$mid = $2;
		$tail = $3;
		
		my $cb = $gaiji_cb{$mid};
		if ($cb eq "")
		{
			print OUT "組字式 $mid 沒有 CB 碼\n";
		}
		else
		{
			$mid = '&CB' . $cb . ';';
		}
		$head .= $mid;
	}
	$tail = $head . $tail;
	
	# 處理特殊的 Big5 字
	
	$head = "";
	while($tail =~ /^($big5*?)碁(.*\n?)/)
	{
		$head = $head . $1 . "&M024261;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)銹(.*\n?)/)
	{
		$head = $head . $1 . "&M040426;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)裏(.*\n?)/)
	{
		$head = $head . $1 . "&M034294;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)墻(.*\n?)/)
	{
		$head = $head . $1 . "&M005505;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)恒(.*\n?)/)
	{
		$head = $head . $1 . "&M010527;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)粧(.*\n?)/)
	{
		$head = $head . $1 . "&M026945;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)嫺(.*\n?)/)
	{
		$head = $head . $1 . "&M006710;";
		$tail = $2;
	}
	$tail = $head . $tail;

	return $tail;
}

###############################################
# 將小括號變成 <note place="inline">..</note>
###############################################

sub note_inline_normalize()
{
	local $_ = shift;
	my $key;
	my $purebig5='(?:(?:[\xa1-\xfe][\x40-\xfe])|(?:&[^;]*;)|(?:<[,t]>))';	# 中文, 缺字, <,>, <t>
	
	# print OUT "\n\n☆ 這底下的資料是有括號卻沒有變成 <note place=\"inline\"> 的格式 ☆\n\n";
	foreach $key (keys(%note))
	{
		$note{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		# print OUT "☆ $note{$key}\n" if $note{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	foreach $key (keys(%note_old))
	{
		$note_old{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		# print OUT "☆ $note_old{$key}\n" if $note_old{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	foreach $key (keys(%note_new))
	{
		if($interlinear{$key} == 1)		# 側註
		{
			$note_new{$key} =~ s/\(($purebig5*?)\)/<note place="interlinear">$1<\/note>/g;
		}
		else
		{
			$note_new{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		}
		
		# print OUT "☆ $note_new{$key}\n" if $note_new{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	# print OUT "\n☆ ==== over ==== ☆\n\n";
}

##############################################
# 配合 XML 經文來檢查看看
##############################################

sub check_with_xmls()
{
	my $file;
	my @files = <${xml_dir}*.xml>;
	
	$note_count = 0;				# 校勘數目
	$note_found_count = 0;			# 校勘能處理的數目
	$note_no_found_count = 0;		# 校勘不能處理的數目
	$note_star_count = 0;			# 星號數目
	$note_star_found_count = 0;		# 星號能處理的數目
	
	open XMLLOGOUT, ">$xmllogout" || die "open $xmllogout error!";
	foreach $file (sort(@files))
	{
		print "run $file\n" if $DEBUG;
		check_with_xml($file);
	}
	$note_found_count = $note_count - $note_no_found_count;
	print XMLLOGOUT "\n\n共有校勘 $note_count 個\n";
	print XMLLOGOUT "順利找到校勘 $note_found_count 個\n";
	# print XMLLOGOUT "校勘星號共有 $note_star_count 個\n";
	
	close XMLLOGOUT;
}

######################################################
# 資料結構很重要, 因為有點複雜
#
# xml 資料, 最多處理 5 行
#
# 第 $i   行: $pre_anchor <anchor...> $anchor_ok....($anchor_doing) $anchor_other
# 第 $i+1 行: ......
# .....
# 第 $i+5 行: 
#
# 比對用的資料
#
# xxx...xxx 
#
# $word_old_head, $word_old_tail; $word_old_mid 則是正在處理的 "字"
#
#	##################### 處理資料的變數
#	my @xmls;			# xml 全部經文
#	my $pre_anchor; 	# <anchor 標記之前的字
#	my $anchor_ok;		# <anchor 標記之後已確定的字
#	my $anchor_other;	# 還沒處理的資料
#	
#	my note_old_head;	# 校勘條目中, 原始經文的前半段
#	my note_old_tail;	# 校勘條目中, 原始經文的後半段
######################################################

sub check_with_xml()
{
	local $_;
	my $file = shift;

	my $n_x;	# 判斷是校勘數字或星號 (n 是數字, x 是星號)
	my $ID;		# 校勘的唯一編號
	
	open XMLIN, $file;
	@xmls = <XMLIN>;
	close XMLIN;

	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		if($xmls[$i] =~ /^\s*<!--\s*$/)
		{
			while($xmls[$i] !~ /^\s*-->\s*$/)
			{
				$i++
			}
			next;
		}
		
		# <lb n="0001a19"/>名。開<anchor id="fnT01p0001a07"/>析修途。所記長遠。故以長為目。翫
		# <lb n="0001a20"/>茲典者。長迷頓曉。邪正難<anchor id="fxT01p0001a1"/>辨。顯如晝夜。報
		# while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([nx])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/)

		while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([n])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/) 	# 先處理 n
		{
			$pre_anchor = $1;
			$n_x = $2;
			$ID = $3;

			my $IDtmp = $4;
			$anchor_other = $5;

			if ($n_x eq "n")		# 校勘
			{
				$note_count++;
				$IDtmp = "00".$IDtmp if length($IDtmp) == 1;
				$IDtmp = "0".$IDtmp if length($IDtmp) == 2;
				$ID = $ID.$IDtmp;
=begin
				if ($i >= 4990)
				{
					my $debug_ = 1;
				}
=end
=cut
				
#=begin
				if ($ID eq "0751001")
				{
					my $debug_ = 1;
				}
#=end
#=cut

				# 處理二個日文符號 V1.78

				if($file =~ /T21n1203/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T21n1205/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T21n1249/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T40n1816/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T40n1819/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T44n1840/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【Ａ】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【Ｂ】/g;
				}
				elsif($file =~ /T45n1898/)
				{
					$note_xml{$ID} =~ s/【？Ａ】/【？】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【麗】/g;
				}
				else
				{
					$note_xml{$ID} =~ s/【？Ａ】/【？】/g;
					$note_xml{$ID} =~ s/【？Ｂ】/【？】/g;
				}
				
				# V1.90 處理【經】【論】的餘毒
				
				$note_xml{$ID} =~ s/&jing;/【經】/g;
				$note_xml{$ID} =~ s/&lum;/【論】/g;	
				$note_old{"${ID}_1"} =~ s/&jing;/【經】/g;
				$note_old{"${ID}_1"} =~ s/&lum;/【論】/g;	
				
				# 先處理無法處理的, 也就是編號 8,9,10,11,13,14,999
				
				if($note_form{"${ID}_1"} == 8 || $note_form{"${ID}_1"} == 9 || $note_form{"${ID}_1"} == 10 || $note_form{"${ID}_1"} == 11 || $note_form{"${ID}_1"} == 13 || $note_form{"${ID}_1"} == 14 || $note_form{"${ID}_1"} == 999)
				{
					# 將經文的 <anchor> 標記換成 xml 版的校勘條目
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
					next;
				}
				
				# 處理校勘條目的經文
				
				$note_old_head = $note_old{"${ID}_1"};
				$note_old_tail = "";

				# 處理勘誤

				while($note_old_head =~ /^($big5*?)\[($big5*?)>($big5*?)\]/)
				{
					$note_old_head =~ s/^($big5*?)\[(?:$big5*?)>($big5*?)\](?:<[^>]*resp[^>]*>)?/$1$2/;		# 先不處理勘誤的資料
				}

				if($note_old_head =~ /^(.*?)…(.*)$/)
				{
					$note_old_head = $1;
					$note_old_tail = $2;
					if($note_old_tail eq "")	# 有些只有 ... 但沒有後面的資料 v1.39
					{
						$note_old_tail = "&noword;";		# 暫時用的
					}
				}
				
				### 開始找資料, 為了要將校勘條目插入 xml ######################################

				# 最標準的合格條件
				
				if($note_old_head eq "" and $note_old_tail eq "")	
				{
					# 沒有範圍 (可能是插入字), 就直接換成 xml 碼
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
					next;
				}
				elsif($anchor_other =~ /^(\Q$note_old_head\E)/ and $note_old_tail eq "")	
				{
					# 最簡單的一種, 一下就找到了.
					# 先判斷是不是梵巴
					
					if($note_xml{$ID} =~ /<sic/)		# sic 的版本 (因為 sic 會包在 lem 裡面, 所以要在前面)
					{
						$note_xml{$ID} =~ s/(<sic[^>]*>).*?<\/sic>/$1$note_old_head<\/sic>/;
					}					
					elsif($note_xml{$ID} =~ /<lem>/)	# 不是純梵巴
					{
						# 先將校勘條目的經文換成標準的
						$note_xml{$ID} =~ s/<lem>.*?<\/lem>/<lem>$note_old_head<\/lem>/;
					}
					else		# 遇到單純的梵巴轉換了
					{
						# 先將校勘條目的經文換成標準的
						$note_xml{$ID} =~ s/(<t lang="chi"[^>]*>).*?<\/t>/$1$note_old_head<\/t>/;
					}
					
					# 再換到 xml 經文中
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>\Q$note_old_head\E/$note_xml{$ID}/;
					next;
				}
				else			# 情況複雜了, 無法順利插入, 用絕招
				{					
=begin
					/* 這段放棄, 直接在 do_compare 處理
					
					# ahchor_other 先取回  n 行資料, 並設一些初值
					for(my $j = 1; $j<$max_line_xml; $j++)
					{
						if($i+$j <= $#xmls)
						{
							$anchor_other .= $xmls[$i+$j];
						}
					}
					*/
=end
=cut
					# 用這個副程式來比對, 傳回 1 表示都處理 ok 了
					# 要傳入目前在 xml 的行數
					
					$anchor_ok = "";
					$note_word_num{$ID} = cn2an($note_word_num{$ID});
					$note_word_num = $note_word_num{$ID};
					$xml_start_line = $i;
					$xml_now_line = $i;
					$xml_word_num = 0;			# 所取得的字數
					$xml_last_word_num = 0;		# 最後一次合格的字數, xml 所取出的數字, 配合 [xx...xx]xx字 的計算數字用的
					@xml_tag_stack = ();
					$xml_err_message = "";		# 放一些可允許錯誤訊息
					$xml_pure_data = "";		# 去除標記及雜質的純文字資料
					
					if(do_compare())			# 進行比對
					{
						# 找到了, 但不一定完備, 要檢查 $xml_err_message , 小問題會在這裡反應出來
						# 先判斷是不是梵巴
					
						if($note_xml{$ID} =~ /<sic/)		# sic 的版本, 在 lem 之前, 因為可能被包在 lem 之中
						{
							$note_xml{$ID} =~ s/(<sic[^>]*>).*?<\/sic>/$1$anchor_ok<\/sic>/;
							#加入輔助訊息
							if ($xml_err_message)
							{
								if($note_xml{$ID} =~ /xxxx=".*?"/)
								{
									$note_xml{$ID} =~ s/xxxx="(.*?)"/xxxx="$1; $xml_err_message"/;
								}
								else
								{
									$note_xml{$ID} =~ s/(<sic[^>]*)>/$1 xxxx="$xml_err_message">/;
								}
							}
						}
						elsif($note_xml{$ID} =~ /<lem>/)	# 不是純梵巴
						{
							# 先將校勘條目的經文換成標準的
							$note_xml{$ID} =~ s/<lem>.*?<\/lem>/<lem>$anchor_ok<\/lem>/;
							
							# 如果有 … 的符號, 則加上此校勘在經文的數目, 讓人可以判斷 V1.91
							if ($xml_word_num > 0 and $note_old_tail ne "")
							{
								$note_xml{$ID} =~ s/(<app[^>]*)>/$1 word-count="$xml_word_num">/;
							}
							
							#加入輔助訊息
							if ($xml_err_message)
							{
								if($note_xml{$ID} =~ /xxxx=".*?"/)
								{
									$note_xml{$ID} =~ s/xxxx="(.*?)"/xxxx="$1; $xml_err_message"/;
								}
								else
								{
									$note_xml{$ID} =~ s/(<app[^>]*)>/$1 xxxx="$xml_err_message">/;
								}
							}
						}
						else		# 遇到單純的梵巴轉換了
						{
							# 如果有 … 的符號, 則加上此校勘在經文的數目, 讓人可以判斷 V1.91
							if ($xml_word_num > 0 and $note_old_tail ne "")
							{
								$note_xml{$ID} =~ s/(<tt [^>]*)>/$1 word-count="$xml_word_num">/;
							}
								
							# 先將校勘條目的經文換成標準的
							if ($xml_err_message)
							{
								# 要加一些輔助訊息
								$note_xml{$ID} =~ s/(<t lang="chi"[^>]*)>.*?<\/t>/$1 xxxx="$xml_err_message">$anchor_ok<\/t>/;
							}
							else
							{
								$note_xml{$ID} =~ s/(<t lang="chi"[^>]*>).*?<\/t>/$1$anchor_ok<\/t>/;
							}
						}
						
						# 再將處理好的 n 行放回去 xml 中
						
						$anchor_ok = $pre_anchor . $note_xml{$ID} . $anchor_other;
						for(my $j = 0; $j<$max_line_xml; $j++)
						{
							if($anchor_ok =~ s/^(.*\n)//)
							{
								$xmls[$i+$j] = $1;
							}
						}
						
						next;
					}
					else
					{
						# 實在找不到匹配的地方
						if($note_xml{$ID} =~ /<sic/)		# sic 的版本, 在 lem 之前, 因為可能被包在 lem 之中
						{
							$note_xml{$ID} =~ s/(<sic[^>]*)>/$1 xxxx="無法在 xml 檔找到正確的範圍; $xml_err_message">/;
						}
						elsif($note_xml{$ID} =~ /<lem>/)
						{
							$note_xml{$ID} =~ s/(<app n=".*?"[^>]*)/$1 xxxx="無法在 xml 檔找到正確的範圍; $xml_err_message"/;
						}
						else
						{
							$note_xml{$ID} =~ s/(<tt n=".*?" type="app"[^>]*)/$1 xxxx="無法在 xml 檔找到正確的範圍; $xml_err_message"/;
						}
						$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
						# 並輸出錯誤報告
						print XMLLOGOUT "$ID: $note_old_head <==> $xmls[$i]";
						$note_no_found_count++;
					}
				}
			}
			else		# 校勘數字
			{
				$note_star_count++;
			}
			# $xmls[$i] =~ s/anchor//;		# 清除本校勘
		}
	}
}

########################
# 失敗就傳回 0
########################

sub do_compare()
{
	my $note_old_head1 = "";
	my $note_old_head2 = $note_old_head;
	my $note_old_tail1 = "";
	my $note_old_tail2 = $note_old_tail;
	my $note_old_mid = "";

	# 先比前面的那一組

	while($note_old_head2 ne "")
	{
		# 取一個字(或 patten )放入 anchor_doing 中, 自己也會減少
		$note_old_mid = get_a_pattern(\$note_old_head2);
		$note_old_head1 .= $note_old_mid;
		
		# 若找不到 pattern 就傳回 0
		return 0 if(!find_the_pattern($note_old_mid));
	}

	# 若沒第二組, 則結束
	if($note_old_tail eq "")
	{
		# 先判斷一下是否有結尾用的標記
		
		if($#xml_tag_stack >= 0)	# 還有標記要取出來
		{
			get_other_tag();
		}
		return 1 ;
	}
	
	# 至此表示有第二組
	
	return 0 if(!do_compare_tail());	# 若找不到尾則失敗

	# 至此, 成功了
	# 先判斷一下是否有結尾用的標記, 
	if($#xml_tag_stack >= 0)	# 還有標記要取出來
	{
		get_other_tag();
	}
	return 1 ;
}

#####################################################

sub do_compare_tail
{
	#my $note_old_mid = shift;
	my $anchor_doing = "";
	my $pattern = '(?:(?:【圖】)|(?:【經】)|(?:【論】)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:。|．|　|\xa1\x5d|\xa1\x5e|\n)';	# 標點及換行可以通過　　# V1.83（ (a15d) 或 ）(a15e) 不算字
	my $tag = '(?:<[^>]*>)';		# 標記, 可以通過
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# 頭標記
	#my $tag_tail = '(?:<\/[^>]*>)';		# 尾標記
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# 表示還沒結束
	{
		while($anchor_other eq "")	# 沒資料了, 往下補
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				$xml_err_message .= "沒有資料了; ";
				return 0;	# 沒資料了, 不能玩了
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# 取一組 pattern 出來
		$anchor_doing = $1;

		if($anchor_doing =~ /$pass/)			# 不重要的字就沒關係, 跳過去
		{
			$anchor_ok .= $anchor_doing;
		}
		elsif($anchor_doing =~ /$tag/)			# 遇到了標記
		{
			# V1.38 取消這一種的
			#if($multi_anchor == 0 and $anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.35 + V1.36
			#{
			#	$xml_err_message .= "遇到下一組的 anchor, 所以結束; ";
			#	return 0;
			#}

			$anchor_ok .= $anchor_doing;

			if($anchor_doing =~ /<[^>]*\/>/)	# 遇到了獨立標記
			{ #不管它
			}
			elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# 遇到了起始標記
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# 將標記推入堆疊
			}
			elsif($anchor_doing =~ /<\/([^>]*)>/)	# 遇到了結尾標記
			{
				my $tmp = $1;
				my $tmp2 = pop(@xml_tag_stack);		# 取出標記比對
				if($tmp ne $tmp2)				# 有問題, tag 沒有成對
				{
					if($tmp2)
					{
						$xml_err_message .= "應該是</$tmp2>卻遇到</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "多了一組</$tmp>; ";
					}
				}
			}
		}
		else	# 取到了一般的字
		{
=begin
			檢查方法
			1.字數合, 資料對, 一切 ok.
			2.字數太多, 資料不對, 失敗
			3.字數太多, 資料對, 記錄並失敗
			4.字數太少, 資料不對, 繼續
			5.字數太少, 資料對, 記錄並繼續
			6.無字數, 資料對, ok
			7.無字數, 超過 n 字, 失敗
=end
=cut

			#my $tmp_anchor_ok = $anchor_ok . $anchor_doing;
			#my $tmp_pure_data = $xml_pure_data . $anchor_doing;
			
			$anchor_ok .= $anchor_doing;
			$xml_pure_data .= $anchor_doing;
			if($anchor_doing eq "&CI0013;")		# &CI0013; = 髣髣[髟/弗][髟/弗], 四個字.
			{
				$xml_word_num = $xml_word_num + 4;
			}
			elsif($anchor_doing =~ /&CI.*?;/)	# 組合字
			{
				$xml_word_num = $xml_word_num + 2;
			}
			#elsif($anchor_doing !~ /\xa1[\x5d\x5e]/)	# V1.83（ (a15d) 或 ）(a15e) 不算字
			else
			{
				$xml_word_num++;
			}
			my $note_old_tail2 = $note_old_tail;
			$note_old_tail2 =~ s/<\/note>$//;
			
			if($note_word_num == 0)		# 沒記錄字數
			{
				if($xml_pure_data =~ /\Q${note_old_tail2}\E$/)	# 吻合, 有些資料會有 </note> 結尾
				{	
					$xml_err_message .= "找到了,符合字數為$xml_word_num,請檢查; ";
					return 1;
				}
				else	# 繼續努力吧, 若超過某字數要停, 就寫在這裡
				{
					if($xml_word_num >= 200)
					{
						$xml_err_message .= "超過$xml_word_num字了還找不到尾端; ";
						return 0;
					}
				}
			}
			else		# 有記錄字數
			{
				if(($note_word_num == $xml_word_num) and ($note_old_tail2 eq "&noword;"))
				{
					return 1;					# 特例, 有 ... 但沒有最後的字, 只有字數. V1.39
				}
				elsif($xml_pure_data =~ /\Q${note_old_tail2}\E$/)	# 有記錄字數, 且資料吻合
				{
					if($note_word_num == $xml_word_num)			# 最標準的
					{
						return 1;
					}
					elsif($note_word_num > $xml_word_num)		# 找到了, 但字數不足, 繼續
					{
						$xml_last_word_num = $xml_word_num;
					}
					else		# 找到了, 但字數超過, 記錄吧
					{
						$xml_err_message .= "找到了,但字數是$xml_word_num,理論上應該是$note_word_num; ";
						return 1;
					}
				}
				else				# 有記錄字數, 但還沒資料吻合
				{
					if($note_word_num <= $xml_word_num-20 )			# 如果超過字數太多, 就停止吧!
					{
						if($xml_last_word_num)
						{
							$xml_err_message .= "應該是$note_word_num,但我已超過$xml_word_num了,還找不到,不過在$xml_last_word_num字卻有符合的資料,請手動處理; ";
						}
						else
						{
							$xml_err_message .= "應該是$note_word_num,但我已超過$xml_word_num了,還找不到,請手動處理; ";
						}
						return 0;
					}
				}
			}
		}
	}
	$xml_err_message .= "沒有資料了; ";
	return 0;	# 沒資料了; 怎麼玩下去?
}

#####################################################
# 取出最後的標記, 因為有些標記的尾巴也要取出來
#####################################################

sub get_other_tag
{
	#my $note_old_mid = shift;
	my $anchor_doing;
	my $pattern = '(?:(?:【圖】)|(?:【經】)|(?:【論】)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:。|．|　|\xa1\x5d|\xa1\x5e|\n)';	# 標點及換行可以通過　　# V1.83（ (a15d) 或 ）(a15e) 不算字
	my $tag = '(?:<[^>]*>)';				# 標記, 可以通過
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# 頭標記
	#my $tag_tail = '(?:<\/[^>]*>)';		# 尾標記
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# 表示還沒結束
	{
		while($anchor_other eq "")	# 沒資料了, 往下補
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				$xml_err_message .= "沒有資料了,但還缺標記; ";
				return 1;	# 沒資料了, 不能玩了 (因為只是欠標記, 所以還是傳回 1)
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# 取一組 pattern 出來
		$anchor_doing = $1;

		if($anchor_doing =~ /$pass/)			# 不重要的字就沒關係, 跳過去
		{
			$anchor_ok .= $anchor_doing;
		}
		elsif($anchor_doing =~ /$tag/)			# 遇到了標記
		{
			if($anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.35 + V1.36 + V1.38	(只有在 get other tag 時, 若遇到 anchor 才停止
			{
				$xml_err_message .= "遇到下一組的 anchor, 所以結束; ";
				return 0;
			}
			$anchor_ok .= $anchor_doing;
			
			if($anchor_doing =~ /<[^>]*\/>/)	# 遇到了獨立標記
			{ #不管它
			}
			elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# 遇到了起始標記
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# 將標記推入堆疊
			}
			elsif($anchor_doing =~ /<\/([^>]*)>/)	# 遇到了結尾標記
			{
				my $tmp = $1;
				my $tmp2 = pop(@xml_tag_stack);		# 取出標記比對
				if($tmp ne $tmp2)				# 有問題, tag 沒有成對
				{
					if($tmp2)
					{
						$xml_err_message .= "應該是</$tmp2>卻遇到</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "多了一組</$tmp>; ";
					}
				}
				
				return 1 if ($#xml_tag_stack < 0);
			}
		}
		else	# 取到了一般的字
		{
			my $tmp2 = pop(@xml_tag_stack);
			$xml_err_message .= "少了標記</$tmp2>; ";
			return 1; 	#(因為只是欠標記, 所以還是傳回 1)
		}
	}
	$xml_err_message .= "沒有資料了,但還缺標記; ";
	return 1;	# 沒資料了; 怎麼玩下去? (因為只是欠標記, 所以還是傳回 1)
}

#####################################################

sub get_a_pattern()
{
	my $note_old = shift;		# 小心, 傳入的是指標
	my $pattern = '(?:[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|[\x00-\xff\n])'; 	# 缺字要處理
	
	$$note_old =~ s/^($pattern)//;
	return $1;
}

#####################################################
#
# 在 anchor_other 找資料. 找到的會放在 anchor_ok 之中
#
#####################################################

sub find_the_pattern()
{
	my $note_old_mid = shift;
	my $anchor_doing;
	my $pattern = '(?:(?:【圖】)|(?:【經】)|(?:【論】)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:。|．|　|\xa1\x5d|\xa1\x5e|\n)';	# 標點及換行可以通過　　# V1.83（ (a15d) 或 ）(a15e) 不算字
	my $tag = '(?:<[^>]*>)';				# 標記, 可以通過
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# 頭標記
	#my $tag_tail = '(?:<\/[^>]*>)';		# 尾標記
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# 表示還沒結束
	{
		while($anchor_other eq "")	# 沒資料了, 往下補
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				return 0;	# 沒資料了, 不能玩了
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# 取一組 pattern 出來
		$anchor_doing = $1;

		if($anchor_doing eq $note_old_mid)		# bingo
		{
			$anchor_ok .= $anchor_doing;
			if($anchor_doing =~ /<note place="(?:(?:inline)|(?:interlinear))">/)		# 有可能是 <note place="inline">
			{
				push(@xml_tag_stack, "note");
			}
			elsif($anchor_doing =~ /<\/note>/)		# 有可能是 </note>	v1.32
			{
				my $tmp = "note";
				my $tmp2 = pop(@xml_tag_stack);		# 取出標記比對
				if($tmp ne $tmp2)				# 有問題, tag 沒有成對
				{
					if($tmp2)
					{
						$xml_err_message .= "應該是</$tmp2>卻遇到</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "多了一組</$tmp>; ";
					}
				}
			}
			else
			{
				$xml_pure_data .= $anchor_doing;
				if($anchor_doing eq "&CI0013;")		# &CI0013; = 髣髣[髟/弗][髟/弗], 四個字.
				{
					$xml_word_num = $xml_word_num + 4;
				}
				elsif($anchor_doing =~ /&CI.*?;/)	# 組合字
				{
					$xml_word_num = $xml_word_num + 2;
				}
				#elsif($anchor_doing !~ /\xa1[\x5d\x5e]/)	# V1.83（ (a15d) 或 ）(a15e) 不算字
				else
				{
					$xml_word_num++;
				}
			}
			return 1;
		}
		elsif ($anchor_doing =~ /<figure/i and $note_old_mid eq "&pic;")		# V1.65 處理圖型的部份(一)
		{
			$anchor_ok .= $anchor_doing;
			if($anchor_doing =~ /<([^>]*[^\/])>/)	# 遇到了非獨立標記, 因為 figure 有獨立與非獨立
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# 將標記推入堆疊				
			}
			return 1;
		}
		elsif ($anchor_doing eq "【圖】" and $note_old_mid eq "&pic;")		# V1.65 處理圖型的部份(二)
		{
			$anchor_ok .= $anchor_doing;
			# $xml_word_num = $xml_word_num+3;
			$xml_pure_data .= $anchor_doing;
			return 1;
		}		
		else
		{
			if($anchor_doing =~ /$pass/)			# 不重要的字就沒關係, 跳過去
			{
				$anchor_ok .= $anchor_doing;
			}
			elsif($anchor_doing =~ /$tag/)			# 遇到了標記
			{
				# V1.38 取消這一種的
				#if($multi_anchor == 0 and $anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.33 + V1.36
				#{
				#	$xml_err_message .= "遇到下一組的 anchor, 所以結束; ";
				#	return 0;
				#}
				$anchor_ok .= $anchor_doing;
				
				if($anchor_doing =~ /<[^>]*\/>/)	# 遇到了獨立標記
				{ #不管它
				}
				elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# 遇到了起始標記
				{
					my $tmp = $1;
					$tmp =~ s/(\S*)\s*.*/$1/;
					push(@xml_tag_stack, $tmp);		# 將標記推入堆疊
				}
				elsif($anchor_doing =~ /<\/([^>]*)>/)	# 遇到了結尾標記
				{
					my $tmp = $1;
					my $tmp2 = pop(@xml_tag_stack);		# 取出標記比對
					if($tmp ne $tmp2)				# 有問題, tag 沒有成對
					{
						if($tmp2)
						{
							$xml_err_message .= "應該是</$tmp2>卻遇到</$tmp>; ";
							push(@xml_tag_stack, $tmp2);	
						}
						else
						{
							$xml_err_message .= "多了一組</$tmp>; ";
						}
					}
				}
			}
			else
			{
				$anchor_other = $anchor_doing . $anchor_other;
				$xml_err_message .= "資料不符,不應該是'$anchor_doing'; ";
				# $xml_word_num++;	# 取出的字數加一
				return 0;
			}
		}
	}
	$xml_err_message .= "沒有資料了; ";
	return 0;	# 沒資料了, 怎麼玩下去?
}

######################################################
# 中文數字 -> 阿拉伯數字
# created by Ray 2000/2/21 04:39PM
######################################################

sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    "○",0,
    "一",1,
 	  "二",2,
 	  "三",3,
 	  "四",4,
 	  "五",5,
 	  "六",6,
 	  "七",7,
 	  "八",8,
 	  "九",9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old="";
	my $c=0;
	foreach $c (@chars) {
		if ($c eq "千") {
			if ($n==0) { $result+=1000; } else { $result += $n*1000; $n=0;}
		} elsif ($c eq "百") { 
			# $result += $n*100; $n=0;
			if ($n==0) { $result+=100; } else { $result += $n*100; $n=0;}
		} elsif ($c eq "十") { 
			if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
			if (($n%10) != 0 or $old eq "○") { $n *= 10; }
			$n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=""; }
	else { $result="$result"; }
	return $result;
}

######################################################
# V1.94 比較原始校勘和研發組校勘
# 如果不同, 傳回 "" , 如果相同, 傳回新的 maha 版
######################################################

sub diff
{
	my $patten='(?:(?:&.*?;)|(?:【◇】)|(?:【■】)|(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
	my $fullspace = '　';
	
	my $str1 = shift;		# 研發組的
	my $str2 = shift;		# maha 的原始校勘條目
	
	return $str2 if($str1 eq $str2);	# 二話不說, 傳回 maha 版
	
	my @str1;
	my @str2;

	push(@str1, $str1 =~ /$patten/g);
	push(@str2, $str2 =~ /$patten/g);
	
	my $i = -1;
	#for my $j (0 .. $#str2)
	for (my $j=0; $j<=$#str2; $j++)
	{
		$i++;
		
		next if($str1[$i] eq $str2[$j]);
		next if(($str1[$i] eq " ") and (($str2[$j] eq "。") or ($str2[$j] eq "，") or
		       ($str2[$j] eq ",") or ($str2[$j] eq ".")));	# 半型空白對上一些符號
		next if((($str2[$j] eq " ")or($str2[$j] eq ",")or($str2[$j] eq ".")or($str2[$j] eq ";")or($str2[$j] eq "；")) and ($str1[$i] eq "，"));	# 半型空白對上一些符號

		# 這裡不太相同了...
		
		if(($str1[$i] eq "＝") or ($str1[$i] eq "◆") or ($str1[$i] eq "，") or ($str1[$i] eq " "))		# 略去不重要的, 就會相等了
		{
			$i++;
		}

		next if($str1[$i] eq $str2[$j]);

		if(($str1[$i] eq "＝") or ($str1[$i] eq "◆") or ($str1[$i] eq "，") or ($str1[$i] eq " "))		# 略去不重要的, 就會相等了
		{
			$i++;
		}

		next if($str1[$i] eq $str2[$j]);

		if(($str2[$j] eq "，")or($str2[$j] eq " "))		# 略去不重要的, 就會相等了
		{
			$j++;
		}

		next if($str1[$i] eq $str2[$j]);

		if($str2[$j] eq $fullspace)		# 一個悉曇字
		{
			if(($str1[$i] eq '【■】') or ($str1[$i] eq '■'))
			{
				next;
			}
		}
				
		if($str2[$j] eq "◇")		# 一個悉曇字
		{
			if($str1[$i] =~ /&.*?;/)
			{
				$str2[$j] = $str1[$i];		# 採用研發組的
				next;
			}
		}

		if($str2[$j] eq "□")		# 一個悉曇字
		{
			if($str1[$i] =~ /&.*?;/)
			{
				$str2[$j] = $str1[$i];		# 採用研發組的
				next;
			}
		}
	
		if($str2[$j] eq "【◇】")		# 一堆悉曇字
		{
			if(($str1[$i] =~ /&.*?;/) or ($str1[$i] eq "◇"))
			{
				my $tmp = $str1[$i];
				$i++;
				while(($str1[$i] =~ /&.*?;/) or ($str1[$i] eq "◇"))
				{
					$tmp .= $str1[$i];
					$i++;
				}
				$i--;
				
				$str2[$j] = $tmp;		# 採用研發組的
				next;
			}
		}
		
		return "";	# 不相同
	}
	
	if($i == $#str1)
	{
		my $tmp = join("",@str2);	# 組成我們需要的原始校勘版
		return $tmp;	# 成功過關
	}
	else
	{
		# 如果研發組的還有, 依然不能過關
		
		if($i+1 == $#str1)		# 若最後一組是空白的, 一樣可過關
		{
			if(($str1[$i+1] eq '【■】') or ($str1[$i+1] eq '■'))
			{
				my $tmp = join("",@str2);	# 組成我們需要的原始校勘版
				return $tmp;	# 成功過關
			}
		}
		
		return "";
	}
}

########### wrote by ray #######################################

sub read_jap_ent {
	
	local *I;

	open I, $jap_ent_file or die "open $jap_ent_file error!";

	while (<I>) {
		chomp;
		if (/ENTITY (\S*?) .*big5=【(.*?)】/) {
			$jap{$2}=$1;
		}
	}
	close I;
}

sub jap_rep 
{
	my $s=shift;
	if (not exists $jap{$s}) {
		return $s;
	}
	return "&" . $jap{$s} . ";";
}

############### end #######################

