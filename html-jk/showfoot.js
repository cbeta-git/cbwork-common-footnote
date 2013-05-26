/*
	showfoot.js
	v0.1, 2003/1/7 04:14PM by Ray
*/
var ss='lightblue';
var sr='lightpink';
var c_f_b='white';
//var xr='yellow';
var xr='';

function showFoot() {
	var winParent = window.parent;
	var docFoot = winParent.frames.foot.document;
	var docTool = winParent.frames.tool.document;
	var docText = winParent.frames.text.document;

	var jk_ver=docTool.getElementById('jk_ver');
	var currentVer=jk_ver.value;
	docFoot.open("text/html; charset=big5", "replace")
	var col=docText.getElementsByTagName('SPAN');
	var s;
	docFoot.write('<script src="../script/foot.js"></script>¡i®Õ°ÉÄæ¡j<br>');
	for (i=0; i<col.length; i++) {
		nt=col[i];
		var id=nt.id;
		if (id.substr(0,1)=="n") {
			var desc="";
			if (currentVer=="000") {
				desc=nt.getAttribute('mod');
				if (desc!=null) {
					desc=dia(desc,id);
				}
			}
			if (desc=="" || desc==null) {
				desc=nt.getAttribute('orig');
				desc=dia(desc,id);
			}
			desc=desc.replace(/FigT00(\w{4})/g, "<img src='../sd-gif/SD-$1.gif'>");
			desc=desc.replace(/FigT(\d{8})/g, "<img src='../figures/$1.gif'>");
			desc=desc.replace(/\{\{(.*?)\}\}/g, "<font color='red'>$1</font>");

			id=id.substr(1);
			s = "[<a id=f" + id;
			s += " href='' onClick='return footOnClick(\"" + id + "\")'";
			s += " onfocus='abc(\"f" + id + '","' + ss + "\")'";
			s += " onblur ='abc(\"f" + id + '","' + c_f_b+ "\")'";
			s += '>';
			s += id + "</a>] "+desc+"<br>";
			docFoot.write(s);
		}
	}
	docFoot.close();
}

function dia(s, id) {
	if (s==null) {
		alert("id:"+id);
	}
	s=s.replace(/<font face='siddam'>/g, "¡Õ¢û¢ñ¢ì¢ì¢é¢õ¡Ö");
	s=s.replace(/<\/font>/g, "¡Õ¡þ¢î¢÷¢ö¢ü¡Ö");
	s=s.replace(/([0-9a-zA-Z`%&#;\.\(\)\?\/!\^\~]+)/g, "<font face='Lucida Sans Unicode'>$1</font>");
	s=s.replace(/([aeiou])\^/g, "$1&#x0302;");
	s=s.replace(/\.([dDhlLmnNrsStT])/g, "$1&#x0323;");
	s=s.replace(/aa/g, "a&#x0304;");
	s=s.replace(/#AA/g, "A&#x0304;");
	s=s.replace(/ii/g, "i&#x0304;");
	s=s.replace(/uu/g, "u&#x0304;");
	s=s.replace(/%%([mn])/g, "$1&#x0307;");
	s=s.replace(/\~([n])/g, "$1&#x0303;");
	s=s.replace(/`([sS])/g, "$1&#x0301;");
	s=s.replace(/¡Õ¢û¢ñ¢ì¢ì¢é¢õ¡Ö/g, "<font face='siddam'>");
	s=s.replace(/¡Õ¡þ¢î¢÷¢ö¢ü¡Ö/g, "</font>");
	return s;	
}
