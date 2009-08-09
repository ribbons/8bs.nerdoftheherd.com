function setselecteditem(item) {
	// Remove the selection from the currently selected line
	$("#menulines div.selectedline").removeClass("selectedline");
	
	// Select the new line and update the description text to show the link title
	item.addClass("selectedline");
	$("#descript").text(item.find("a").attr("title"));
}

function processkey(event) {
	if(event.which > 96 && event.which < 111) {
		// Find the menu item for the key that was pressed
		var keyitem = $("#menulines div:eq(" + (event.which - 97) + ")");
		
		// If the item exists, set it as selected
		if(keyitem.length > 0) {
			setselecteditem(keyitem);
		}
	} else if(event.which == 13) {
		// Navigate to the value of the href of the link for the selected item
		document.location = $("#menulines div.selectedline:first a").attr("href");
	}
}

$(document).ready(function() {
	// Select the first item in the menu
	setselecteditem($("#menulines div:first"));
	
	// Add a mouseover event to call setselecteditem to each of the menu links
	$("#menulines div a").mouseover(function() {
		setselecteditem($(this).parent());
	});
	
	// Add the processkey handler to document keypress for keyboard navigation
	$(document).keypress(processkey);
});