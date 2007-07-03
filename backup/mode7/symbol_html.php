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
		$html='<table style="display: inline;"><tr><td>';

		$symboldesc=$lookup[$symbol];

		
		if(($symboldesc-32)>=0):
			
			#ImageFilledRectangle($imgsym,$width/2,($height/3)*2,$width,$height,$fgcol);
			$symboldesc=$symboldesc-32;
		endif;
		
		$html.='</td><td>';
		
		if(($symboldesc-16)>=0):
			#ImageFilledRectangle($imgsym,0,($height/3)*2,$width/2,$height,$fgcol);
			$symboldesc=$symboldesc-16;
		endif;
		
		$html.='</td></tr><tr><td>';
		
		if(($symboldesc-8)>=0):
			#ImageFilledRectangle($imgsym,$width/2,$height/3,$width,($height/3)*2,$fgcol);
			$symboldesc=$symboldesc-8;
		endif;
		
		$html.='</td><td>';
		
		if(($symboldesc-4)>=0):
			#ImageFilledRectangle($imgsym,0,$height/3,$width/2,($height/3)*2,$fgcol);
			$symboldesc=$symboldesc-4;
		endif;
		
		$html.='</td></tr><tr><td>';
		
		if(($symboldesc-2)>=0):
			#ImageFilledRectangle($imgsym,$width/2,0,$width,$height/3,$fgcol);
			$symboldesc=$symboldesc-2;
		endif;
		
		$html.='</td><td>';
		
		if(($symboldesc-1)>=0):
			#ImageFilledRectangle($imgsym,0,0,$width/2,$height/3,$fgcol);
			$symboldesc=$symboldesc-1;
		endif;
				
		$html.='</td></tr></table>';
		
		return $html;
	}
?>