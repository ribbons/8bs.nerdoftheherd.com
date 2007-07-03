<?php
	function createlookup() {
		#35 shown as # in user guide - appears to be wrong
		#36 shown as 8 in user guide - out of sequence and appears to be wrong
		for($putlookup=32; $putlookup<64; $putlookup++):
			$lookup[$putlookup]=$putlookup-32;
		endfor;
		
		$lookup[95]=32;

		#96 shown as 3 in the user guide - appears to be wrong
		for($putlookup=96; $putlookup<127; $putlookup++):
			$lookup[$putlookup]=$putlookup-64;
		endfor;

		for($putlookup=160; $putlookup<192; $putlookup++):
			$lookup[$putlookup]=$putlookup-160;
		endfor;

		for($putlookup=224; $putlookup<256; $putlookup++):
			$lookup[$putlookup]=$putlookup-224+32;
		endfor;
		
		return $lookup;
	}
	
	function makesymbol($symbol, $width, $height, $backcol, $textcol, $lookup) {
		$finwidth=$width;
		$finheight=$height;
		$height=$height*3;
		$width=$width*3;
		
		$imgsym = ImageCreate($width,$height);
		$bgcol = ImageColorAllocate($imgsym,hexdec(substr($backcol,1,2)),hexdec(substr($backcol,3,2)),hexdec(substr($backcol,5,2)));
		$fgcol = ImageColorAllocate($imgsym,hexdec(substr($textcol,1,2)),hexdec(substr($textcol,3,2)),hexdec(substr($textcol,5,2)));

		$symboldesc=$lookup[$symbol];

		if(($symboldesc-32)>=0):
			ImageFilledRectangle($imgsym,$width/2,($height/3)*2,$width,$height,$fgcol);
			$symboldesc=$symboldesc-32;
		endif;

		if(($symboldesc-16)>=0):
			ImageFilledRectangle($imgsym,0,($height/3)*2,$width/2,$height,$fgcol);
			$symboldesc=$symboldesc-16;
		endif;

		if(($symboldesc-8)>=0):
			ImageFilledRectangle($imgsym,$width/2,$height/3,$width,($height/3)*2,$fgcol);
			$symboldesc=$symboldesc-8;
		endif;

		if(($symboldesc-4)>=0):
			ImageFilledRectangle($imgsym,0,$height/3,$width/2,($height/3)*2,$fgcol);
			$symboldesc=$symboldesc-4;
		endif;

		if(($symboldesc-2)>=0):
			ImageFilledRectangle($imgsym,$width/2,0,$width,$height/3,$fgcol);
			$symboldesc=$symboldesc-2;
		endif;

		if(($symboldesc-1)>=0):
			ImageFilledRectangle($imgsym,0,0,$width/2,$height/3,$fgcol);
			$symboldesc=$symboldesc-1;
		endif;
		
		$sizedimg = ImageCreateTrueColor($finwidth, $finheight);
		ImageCopyResampled($sizedimg, $imgsym, 0, 0, 0, 0, $finwidth, $finheight, $width, $height);
		
		return $sizedimg;
	}
	
	$lookup=createlookup();
	$image=makesymbol($_GET['symbol'], $_GET['width'], $_GET['height'], $_GET['backcol'], $_GET['textcol'], $lookup);
	
	header('Content-Type: image/png');
	ImagePNG($image);
?>