<?php
	set_time_limit(0);
	
	require 'convert.php';
	require 'convertmode7.php';
	
	define('HEIGHT', 24);
	define('WIDTH', 16);
	
	$backcolours=array(convertmode7::COL_BLACK, convertmode7::COL_RED, convertmode7::COL_GREEN, convertmode7::COL_YELLOW, convertmode7::COL_BLUE, convertmode7::COL_MAGENTA, convertmode7::COL_CYAN, convertmode7::COL_WHITE);
	$forecolours=array(convertmode7::COL_RED, convertmode7::COL_GREEN, convertmode7::COL_YELLOW, convertmode7::COL_BLUE, convertmode7::COL_MAGENTA, convertmode7::COL_CYAN, convertmode7::COL_WHITE);
	
	foreach($backcolours as $backcolour):
		foreach($forecolours as $forecolour):
			for($genchars=32; $genchars<127; $genchars++):
				makecharacter($genchars, $backcolour, $forecolour, 1);
				makecharacter($genchars, $backcolour, $forecolour, 2);
			endfor;
		endforeach;
	endforeach;
	
	function getcolourhex($colourid) {
		switch($colourid):
			case convertmode7::COL_BLACK:
				return '000000';
			case convertmode7::COL_RED:
				return 'ff0000';
			case convertmode7::COL_GREEN:
				return '00ff00';
			case convertmode7::COL_YELLOW:
				return 'ffff00';
			case convertmode7::COL_BLUE:
				return '0000ff';
			case convertmode7::COL_MAGENTA:
				return 'ff00ff';
			case convertmode7::COL_CYAN:
				return '00ffff';
			case convertmode7::COL_WHITE:
				return 'ffffff';
		endswitch;
	}
	
	function makecharacter($character, $backcol, $textcol, $dheight) {
		$origimg = ImageCreateFromGIF('font/'.$character.'.gif');
	
		#Unsure how to unset transparency, so add new pallete colour and make that transparent
		ImageColorAllocate($origimg, 0, 0, 0);
		ImageColorTransparent($origimg, 2);
	
		#Set Proper Colours for Letter
		//echo '<p>'.hexdec(substr(getcolourhex($textcol),1,2)).'</p>';
		ImageColorSet($origimg, 0, hexdec(substr(getcolourhex($backcol),0,2)), hexdec(substr(getcolourhex($backcol),2,2)), hexdec(substr(getcolourhex($backcol),4,2)));
		ImageColorSet($origimg, 1, hexdec(substr(getcolourhex($textcol),0,2)), hexdec(substr(getcolourhex($textcol),2,2)), hexdec(substr(getcolourhex($textcol),4,2)));
	
		$sourcewidth = ImageSx($origimg);
		$sourceheight = ImageSy($origimg);
	
		$sizedimg = ImageCreateTrueColor(WIDTH, HEIGHT);
	
		ImageCopyResampled($sizedimg, $origimg, 0, 0, 0, 0, WIDTH, HEIGHT, $sourcewidth, $sourceheight);
	
		if($dheight):
			$finalimg = ImageCreateTrueColor(WIDTH, HEIGHT);
			if($dheight==1):
				$hoffset=0;
			else:
				$hoffset=(HEIGHT/2)-1;
			endif;
			ImageCopyResampled($finalimg, $sizedimg, 0, 0, 0, $hoffset,WIDTH, HEIGHT, WIDTH, (HEIGHT/2)-1);
		else:
			$finalimg=$sizedimg;
		endif;
		
		ImagePNG($finalimg, '../common/chars/'.$character.'_'.$backcol.'_'.$textcol.'_'.$dheight.'.png');
	}
?>