<?php
	function makecharacter($character, $height, $width, $backcol, $textcol, $dheight) {
		$origimg = ImageCreateFromGIF('font/'.$character.'.gif');

		#Unsure how to unset transparency, so add new pallete colour and make that transparent
		ImageColorAllocate($origimg, 0, 0, 0);
		ImageColorTransparent($origimg, 2);

		#Set Proper Colours for Letter
		ImageColorSet($origimg, 0, hexdec(substr($backcol,1,2)), hexdec(substr($backcol,3,2)), hexdec(substr($backcol,5,2)));
		ImageColorSet($origimg, 1, hexdec(substr($textcol,1,2)), hexdec(substr($textcol,3,2)), hexdec(substr($textcol,5,2)));

		$sourcewidth = ImageSx($origimg);
		$sourceheight = ImageSy($origimg);

		$sizedimg = ImageCreateTrueColor($width, $height);

		ImageCopyResampled($sizedimg, $origimg, 0, 0, 0, 0, $width, $height, $sourcewidth, $sourceheight);

		if($dheight):
			$finalimg = ImageCreateTrueColor($width,$height);
			if($dheight==1):
				$hoffset=0;
			else:
				$hoffset=($height/2)-1;
			endif;
			ImageCopyResampled($finalimg, $sizedimg, 0, 0, 0, $hoffset, $width, $height, $width, ($height/2)-1);
		else:
			$finalimg=$sizedimg;
		endif;

		return $finalimg;
	}
	
	$image=makecharacter($_GET['character'], $_GET['height'], $_GET['width'], $_GET['backcol'], $_GET['textcol'], $_GET['dheight']);
	header('Content-Type: image/png');
	ImagePNG($image);
?>