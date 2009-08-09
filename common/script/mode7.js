function toggletags(togglestate) {
	$("td.flash").toggleClass("flashoff", togglestate);
	
	if(togglestate) {
		window.setTimeout('toggletags(false);', 300);
	} else {
		window.setTimeout('toggletags(true);', 600);
	}
}

$(document).ready(function() {
	if($("td.flash").length > 0) {
		toggletags(true);
	}
});