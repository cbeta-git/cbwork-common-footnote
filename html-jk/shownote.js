/*
	shownote.js
	Copyright (C) 2003 Ray Chou (ray.chou@url.com.tw)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
	
	v0.1, 2002/11/27 06:28PM by Ray
	v0.2, 針對 Netscape 7.0, Mozilla 1.2 修改, 2002/11/30 03:44PM by Ray
	v0.3, 轉寫字的呈現, 2002/12/11 11:34AM by Ray
	v0.4, 一條校勘兩個某本, 2002/12/16 05:06PM by Ray
	v0.5, 【Ａ】【Ｂ】, 2002/12/16 06:05PM by Ray
	v0.6, 某本，某本Ｂ, 2002/12/20 02:52PM by Ray
	v0.7, 悉曇字以 TTF 呈現, 2002/12/20 06:07PM by Ray
	v0.8, 2002/12/23 04:11PM by Ray
	v0.9, 2003/1/2 11:14AM by Ray
*/

var verName = new Object();
verName["000"] = "CBETA"  ;
verName["010"] = "大"     ; 
verName["020"] = "宋"     ; 
verName["030"] = "元"     ; 
verName["040"] = "明"     ;
verName["041"] = "明異"   ;
verName["050"] = "麗"     ;
verName["051"] = "麗乙"   ;
verName["060"] = "聖"     ;
verName["061"] = "聖乙"   ;
verName["062"] = "聖丙"   ;
verName["070"] = "宮"     ;
verName["071"] = "宮乙"   ;
verName["080"] = "德"     ;
verName["090"] = "万"     ;
verName["100"] = "石"     ;
verName["110"] = "知"     ;
verName["120"] = "醍"     ;
verName["130"] = "和"     ;
verName["140"] = "東"     ;
verName["150"] = "中"     ;
verName["160"] = "久"     ;
verName["170"] = "森"     ;
verName["180"] = "敦"     ;
verName["181"] = "敦乙"   ;
verName["182"] = "敦丙"   ;
verName["183"] = "敦方"   ;
verName["190"] = "福"     ;
verName["191"] = "福乙"   ;
verName["200"] = "博"     ;
verName["210"] = "縮"     ;
verName["220"] = "金"     ;
verName["230"] = "高"     ;
verName["240"] = "原"     ;
verName["250"] = "甲"     ;
verName["251"] = "乙"     ;
verName["252"] = "丙"     ;
verName["253"] = "丁"     ;
verName["254"] = "戊"     ;
verName["255"] = "己"     ;
verName["a04"] = "內"     ;
verName["a06"] = "西"     ;
verName["a07"] = "別"     ;
verName["a09"] = "南"     ;
verName["b00"] = "Ａ"     ;
verName["b01"] = "Ｂ"     ;
verName["b03"] = "大曆"   ;
verName["b04"] = "日光"   ;
verName["b05"] = "北藏"   ;
verName["b09"] = "南藏"   ;
verName["b10"] = "流布本" ;
verName["b11"] = "某本"   ;
verName["b12"] = "某本Ｂ" ;
verName["b13"] = "獅谷"   ;
verName["zzz"] = "闕略"   ;


function aOnClick (n) {
	var temp;
	var fn="f"+n;
	
	var winParent = window.parent;
	var docFoot = winParent.frames.foot.document;
	var docJK = winParent.frames.jk.document;
	var docTool = winParent.frames.tool.document;
	
	var nt=docFoot.getElementById(fn);
	if (nt == null) {
		window.status="Error in shownote.js Line 90: Footnote object not found!";
		return false;
	}
	nt.scrollIntoView();
	nt.focus();

	n="n"+n;
	nt=document.getElementById(n);

	docJK.open("text/html; charset=big5", "replace")
	docJK.write("【單項校勘】<br>");

	var pb=n.substr(1,4);
	pb=pb.replace(/^0*/g, "");
	var strPage="p. "+pb;

	var jk=n.substr(5);
	jk=jk.replace(/^0*(.*)$/, "$1");
	if (jk=='') {
		jk="0";
	}
	strPage+=", [" + jk + "] ";

	var docTool = winParent.frames.tool.document;
	temp=docTool.getElementById('jk_ver');
	var jk_ver = temp.value;
	
	s="";
	if (jk_ver == "000") {
		s=nt.getAttribute('mod');
		if (s!=null) {
			//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
			s=dia(s);
			s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
			s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
			s=s.replace(/\{\{(.*?)\}\}/g, "<font color='red'>$1</font>");
		}
	}
	if (s=="" || s==null) {
		s = nt.getAttribute('orig');
		//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
		s=dia(s);
		s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
		s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
	}

	if (s!='') {
		docJK.write(strPage);
		docJK.write(s);
	}
	
	var ver=nt.getAttribute('ver');
	if (ver!=null && s!=''){
		var tb=nt.getAttribute('table');
		if ((tb==null) || (tb!="0")) {
			docJK.write("<table border=1 cellpadding=5 cellspacing=0>");
			//docJK.write('<tr><th colspan="2">異本用字</th>');
			var tempArray=ver.split(" ");
			tempArray=tempArray.sort();
			for (i=0;i<tempArray.length;i++){
				va=tempArray[i];
				if (va=='') {
					continue;
				}
				docJK.write("<TR><TD class=menulines>");
				s=nt.getAttribute("v"+va);
				s=s.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
				s=s.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
				//s=s.replace(/&SD(.*?);/g, "<font face='siddam'>$1</font>");
				// <td> 沒有內容的時候, 框線也會不見, 所以放一個全形空白
				if (s=='') {
					s="　";
				}
				if (verName[va]!="某本" && verName[va]!="某本Ｂ" && va!="zzz") {
					docJK.write("【");
				}
				docJK.write(verName[va]);
				if (verName[va]!="某本" && verName[va]!="某本Ｂ" && va!="zzz") {
					docJK.write("】");
				}
				docJK.write("<td>" + s + "</TD></TR>");
			}
			docJK.write("</table>");
		}
	}
	
	docJK.close();

	return false;
}


function abc(n,state){
	var nt=document.getElementById(n);
	nt.style.backgroundColor=state;
}