function getElementsByClassName(oElm, strTagName, oClassNames){
	var arrElements = (strTagName == "*" && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);
	var arrReturnElements = new Array();
	var arrRegExpClassNames = new Array();
	if(typeof oClassNames == "object"){
		for(var i=0; i<oClassNames.length; i++){
			arrRegExpClassNames.push(new RegExp("(^|\\s)" + oClassNames[i].replace(/\-/g, "\\-") + "(\\s|$)"));
		}
	}
	else{
		arrRegExpClassNames.push(new RegExp("(^|\\s)" + oClassNames.replace(/\-/g, "\\-") + "(\\s|$)"));
	}
	var oElement;
	var bMatchesAll;
	for(var j=0; j<arrElements.length; j++){
		oElement = arrElements[j];
		bMatchesAll = true;
		for(var k=0; k<arrRegExpClassNames.length; k++){
			if(!arrRegExpClassNames[k].test(oElement.className)){
				bMatchesAll = false;
				break;
			}
		}
		if(bMatchesAll){
			arrReturnElements.push(oElement);
		}
	}
	return (arrReturnElements)
}

window.onload=function() {
	menuobjs=getElementsByClassName(document, "td", "menuline");
	
	for(var sethandlers=0; sethandlers < menuobjs.length; sethandlers++) {
		menuobjs[sethandlers].getElementsByTagName("a")[0].onmouseover = new Function("setselecteditem(\""+menuobjs[sethandlers].id+"\");");
	}
	
	setselecteditem("line0");
}

function setselecteditem(obj) {
	hlobjs=getElementsByClassName(document, "td", "menuline");
	
	for(var clearhl=0; clearhl < hlobjs.length; clearhl++) {
		hlobjs[clearhl].className="menuline";
	}
	
	document.getElementById(obj).className = "menuline menulinehl";
	document.getElementById("descript").innerHTML = document.getElementById(obj).getElementsByTagName("a")[0].getAttribute("title");
}

function desctxt(newtext) {
	document.getElementById("descript").innerHTML = newtext;
}