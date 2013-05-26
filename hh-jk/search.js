var xx,yy;

if (window.Event)
  document.captureEvents(Event.CLICK);document.onclick = doit;

myLinkCss();

// 顯示校勘符號
function showAnchor() {
	var col=document.getElementsByTagName('span');
	var s;
	var n;
	for (i=0; i<col.length; i++) {
		var nt=col[i];

		var temp=nt.getAttribute('type');
		if (temp=="star") {
			nt.innerHTML="<font face='新細明體'>[＊]</font>";
		}

		var id=nt.id;
		if (id=='') {
			continue;
		}
		if (id.substr(0,1)=="n") {
			//s=id.substr(1);
			//s="[<span href=\"\" onClick=\"return aOnClick('" + s + "')\">";
			s="";
			n=id.substr(6);
			n=n.replace(/^0*(.*)$/, "$1");
			if (n=='') {
				n='0';
			}
			s += "<font color='blue'>[" + n + "]</font>";
			nt.innerHTML = s;
		}
	}
}

function myLinkCss() {
	var loc=document.location.href;
	var q=loc.lastIndexOf('chm::');
	if (q==-1){
	 var q2=loc.lastIndexOf("/");
	} else {
	 var q2=loc.lastIndexOf("\\",q);
	}
	
	var p=loc.indexOf("Store:");
	
	if (p==-1) {
	 var loc2=loc.substring(0,q2)+"/";
	} else {
	 p=p+6;
	 var loc2="file:///"+loc.substring(p,q2)+"/";
	}
	
	document.write('<LINK href="'+loc2+'cbeta.css" type="text/css" rel="stylesheet">');
}

function doit()
{
 xx = window.event.screenX;
 yy = window.event.screenY;
}

function showpic(name)
{
  var ff = "width=30,height=25,scrollbars,resizable";
  
  ff += ",left=" + xx ;
  
  if ( yy > (window.screen.height/2) ) { ff += ",top=" + (yy-150) ; }
  else {ff += ",top=" + (yy+10) ;}

  window.open(name,"pic",ff);
}