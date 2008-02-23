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
	toggletags(false);
}

function toggletags(togglestate) {
	blinkTags=getElementsByClassName(document, "td", "flash");
	var found=false;
	
	for(var makeBlink=0;makeBlink < blinkTags.length; makeBlink++) {
		if(togglestate==false) {
			blinkTags[makeBlink].className+=" flashoff";
			found=true;
		} else {
			var curclass=blinkTags[makeBlink].className;
			if(curclass.substring(curclass.length-9)==" flashoff") {
				blinkTags[makeBlink].className=curclass.substring(0, curclass.length-9);
				found=true;
			}
		}
	}
	
	if(found) {
		if(togglestate) {
			window.setTimeout('toggletags(false);', 600);
		} else {
			window.setTimeout('toggletags(true);', 300);
		}
	}
}