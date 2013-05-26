/*
	foot.js
	Copyright (C) 2003 Ray Chou (ray.chou@url.com.tw)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
*/

function footOnClick (n) {
	winParent = window.parent;
	docText = winParent.frames.text.document;
	var nt=docText.getElementById('a'+n);
	if (nt != null) {
		nt.focus();
		window.status="";
	} else {
		window.status="Error in foot.js Line 18: Footnote anchor not found!";
	}
	return false;
}

function abc(n,state){
	var nt=document.getElementById(n);
	nt.style.backgroundColor=state;
}