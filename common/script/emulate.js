(function () {
	"use strict";

	$(document).ready(function() {
		if(!testSupport())
		{
			$('#need-to-have').html('a more <a href="http://browsehappy.com/">recent browser</a>');
			return;
		}

		var container = $('#emulator');
		var imagePath = container.data('imagePath');

		container.html('<iframe src="/jsbeeb/?embed&disc=../../' + imagePath +
		               '&autoboot" width=921 height=733 frameborder=0></iframe>');

		$('#emulator > iframe').load(function() {
			this.contentWindow.focus();
		});

		$('#content').hide();
	});

	function testSupport()
	{
		// Check if the current browser has <canvas> support
		var testCanvas = document.createElement('canvas');

		if(!testCanvas.getContext || !testCanvas.getContext('2d'))
		{
			return false;
		}

		// Some browsers (e.g. IE9 & 10) return the wrong object type from createImageData()
		if(!testCanvas.getContext('2d').createImageData(1, 1).data.buffer)
		{
			return false;
		}

		return true;
	}
}());
