/*
	tool.js
	Copyright (C) 2003 Ray Chou (ray.chou@url.com.tw)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
	
	v0.1, 2002/11/27 06:29PM by Ray
	v0.2, 針對 Netscape 7.0, Mozilla 1.2 修改, 2002/11/30 03:44PM by Ray
	v0.3, 2002/12/16 03:50PM by Ray
	v0.4, 2002/12/16 04:24PM by Ray
	v0.5, 切換版本後清除校勘欄, 2002/12/16 05:24PM by Ray
	v0.6, 加版本標題, 2002/12/19 11:54AM by Ray
	v0.7, 2002/12/23 06:04PM by Ray
*/

winParent = window.parent;

var verHeading = new Object();
verHeading["000"] = "CBETA電子版";
verHeading["010"] = "大正新脩大藏經";
verHeading["020"] = "宋本（南宋思溪藏）(The 'Sung Edition' A. D. 1239)";
verHeading["030"] = "元本（元大普寧寺藏）(The 'Yuan Edition' A. D. 1290)";
verHeading["040"] = "明本（明方冊藏）(The 'Ming Edition' A. D. 1601)";
verHeading["050"] =  "麗本（高麗海印寺本）(The 'Kao-Li Edition' A. D. 1151)";
verHeading["051"] =  "麗本別刷 (Another print of the Kao-Li Edition)";
verHeading["060"] =  "正院聖語藏本（天平寫經）(The Tempyoo Mss. [A. D. 729-] and the Chinese Mss. of the Sui [A. D. 581-617] and Tang [A. D. 618-822] dynasities, belonging ot the Imperial Treasure House Shoosoo-in at Nara, specially called Shoogo-zoo)";
verHeading["061"] =  "正倉院聖語藏本別寫 (Another copy of the same)";
verHeading["070"] =  "宮內省圖書寮本（舊宋本）(The Old Sung Edition [A. D. 1104-1148] belonging to the Library of the Imperial Household)";
verHeading["080"] =  "大德寺本(The Tempyoo Mss. of the monastery 'Daitoku-ji')";
verHeading["090"] =  "萬德寺本(The Tempyoo Mss. of the monastery 'Mantoku-ji')";
verHeading["100"] =  "石山寺本(The Tempyoo Mss. of the monastery 'Ishiyama-dera')";
verHeading["110"] =  "知恩院本(The Tempyoo Mss. of the monastery 'Chion-in')";
verHeading["120"] =  "醍醐寺本(The Tempyoo Mss. of the monastery 'Daigo-ji')"; 
verHeading["130"] =  "仁和寺藏本(Ninnaji Mss. by Kuukai and others. C. 800. A. D.)";
verHeading["140"] =  "東大寺本(The Tempyoo Mss. of the monastery 'Toodai-ji')";
verHeading["150"] =  "中村不折氏藏本(Mr. Nakamura's Mss. from Tun-huang)";
verHeading["160"] =  "久原文庫本(The Tempyoo Mss. belonging to the Kuhara Library)";
verHeading["170"] =  "森田清太郎氏藏本(The Tempyoo Ms. owned by Mr. Seitaro Morita)";
verHeading["180"] =  "敦煌本（敦煌出土藏經）(Stein Mss. from Tun-huang)";
verHeading["181"] =  "敦煌本（敦煌出土藏經）(Stein Mss. from Tun-huang)";
verHeading["182"] =  "敦煌本（敦煌出土藏經）(Stein Mss. from Tun-huang)";
verHeading["190"] =  "西福寺本(The Tempyoo Mss. of the monastery 'Saifuku-ji')";
verHeading["191"] =  "西福寺本(The Tempyoo Mss. of the monastery 'Saifuku-ji')";
verHeading["200"] =  "東京帝室博物館本(The Chinese Mss. of the Tang dynasty belonging to the Imperial Museum of Tokyo)";
verHeading["210"] =  "縮刷本（縮刷大藏經）Tokyo edition (small typed)";
verHeading["220"] =  "金剛藏本(The Mss. preserved in the Kongoo-zoo Library, Tooji, Kyoto)" 
verHeading["230"] =  "高野版本(The Edition of Kooya-san, C. 1250 A. D.)" 

var currentVer="000";
var anchorFlag=true;

function selectDiBen(x) {
	selectVer(x);
	var jk_ver=document.getElementById('jk_ver');
	jk_ver.value=x; // 底本

	// 顯示卷尾校勘
	if (x=="000" || x=="010") { // cbeta版 或 大正藏版
		showFoot();
	}

	// 視需要做校勘轉換
	var obj = document.getElementById('vv');
	if (x=="000" && obj.value=="010") {
		obj.value=x;
		return;
	}
	if (x=="010" && obj.value=="000") {
		obj.value=x;
		return;
	}
	selectVer(obj.value);
}

function selectVer(x) {
	window.status="切換版本中...";
	docText = winParent.frames.text.document;

	var jk_ver=document.getElementById('jk_ver');
	
	var vers=docText.getElementById('vers');
	vers.childNodes[0].nodeValue=verHeading[x];
	var col=docText.getElementsByTagName('SPAN');
	var s1, s2;
	for (i=0; i<col.length; i++) {
		nt=col[i];
		var id=nt.id;
		var att_mod=nt.getAttribute('mod');
		if (id.substr(0,1)=="n" || id.substr(0,1)=="c") {
			var ver=nt.getAttribute('ver');
			if (typeof(ver)!='undefined' && ver!=null){
				s1 = nt.innerHTML;
				s1=s1.replace(/^((\[<a.*?a>\])?).*$/i, "$1");
				var searchResult;
				eval('searchResult=ver.search(/' + x + '/);');
				if (searchResult>-1) {
					s=nt.getAttribute('v'+x);
					s=transAtt(s);
					s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
					nt.innerHTML=s1+s;
					if (x=="000" || x=="010") { // cbeta版 或 大正藏版
						if (nt.getAttribute('v000')!=nt.getAttribute('v010')) {
							nt.style.color = "red";
						}
					} else {
						nt.style.color = "";
					}
				} else if (jk_ver.value=="000") {
					s = nt.getAttribute('v000');
					s=transAtt(s);
					nt.innerHTML = s1 + s;
				} else {
					s = nt.getAttribute('v010');
					s=transAtt(s);
					nt.innerHTML = s1 + s;
				}
			}
		}
	}
	currentVer=x;
	
	// 清除校勘欄
	docJK = winParent.frames.jk.document;
	docJK.open();
	docJK.clear();
	docJK.close();
	window.status="完成";
}

function switchAnchor() {
	var o=document.getElementById('show2');
	if (anchorFlag) {
		hideAnchor();
		o.value='顯示校勘符號';
	} else {
		showAnchor();
		o.value='隱藏校勘符號';
	}
	anchorFlag = !anchorFlag;
}

function hideAnchor() {
	docText = winParent.frames.text.document;
	var col=docText.getElementsByTagName('span');
	for (i=0; i<col.length; i++) {
		nt=col[i];
		id=nt.id;
		if (id.substr(0,1)=="n") {
			var s="";
			var wit=nt.getAttribute('ver');
			if (wit != null) {
				if (wit.indexOf(currentVer)>-1){
					s=nt.getAttribute('v'+currentVer);
				} else {
					s=nt.getAttribute('v000');
				}
			}
			s=transAtt(s);
			nt.innerHTML=s;
		}
	}
}

function showAnchor() {
	docText = winParent.frames.text.document;
	var col=docText.getElementsByTagName('span');
	var s;
	var n;
	var html;
	for (i=0; i<col.length; i++) {
		nt=col[i];
		id=nt.id;
		if (id.substr(0,1)=="n") {
			s=id.substr(1);
			html="[<a id=\"a" + s + "\" href=\"\" onClick=\"return aOnClick('" + s + "')\"";
			html+=" onfocus='abc(\"n" + s + "\",sr)' onblur='abc(\"n" + s + "\",xr)'";
			html+=">";
			n=id.substr(6);
			n=n.replace(/^0*(.*)$/, "$1");
			if (n=="") {
				n="0";
			}
			html += n + "</a>]";
			var wit=nt.getAttribute('ver');
			if (wit!=null) {
				if (wit.indexOf(currentVer)>-1){
					html+=nt.getAttribute('v'+currentVer);
				} else {
					html+=nt.getAttribute('v000');
				}
			}
			html=transAtt(html);
			nt.innerHTML = html;
		}
	}
}

function transAtt(s) {
	s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
	s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");						
	return s;
}