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
	
	function convtoclass($colour) {
		switch($colour):
			case '#ffffff':
				return 'bw';
				break;
			case '#ff0000':
				return 'br';
				break;
			case '#00ff00':
				return 'bg';
				break;
			case '#0000ff':
				return 'bb';
				break;
			case '#ffff00':
				return 'by';
				break;
			case '#000000':
				return 'bbk';
				break;
			case '#ff00ff':
				return 'bm';
				break;
			case '#00ffff':
				return 'bc';
				break;
		endswitch;
	}
	
	function makesymbol($symbol, $width, $height, $backcol, $textcol, $lookup) {
		$symboldesc=$lookup[$symbol];
		
		$textcol=convtoclass($textcol);
		
		if($symboldesc==0):
			return '';
		endif;
		
		$parts[1][2]=(($symboldesc-32)>=0);
		if(($symboldesc-32)>=0) $symboldesc=$symboldesc-32;
		
		$parts[0][2]=(($symboldesc-16)>=0);
		if(($symboldesc-16)>=0) $symboldesc=$symboldesc-16;
		
		$parts[1][1]=(($symboldesc-8)>=0);
		if(($symboldesc-8)>=0) $symboldesc=$symboldesc-8;
		
		$parts[0][1]=(($symboldesc-4)>=0);
		if(($symboldesc-4)>=0) $symboldesc=$symboldesc-4;
		
		$parts[1][0]=(($symboldesc-2)>=0);
		if(($symboldesc-2)>=0) $symboldesc=$symboldesc-2;
		
		$parts[0][0]=(($symboldesc-1)>=0);
		if(($symboldesc-1)>=0) $symboldesc=$symboldesc-1;
		
		echo '<table><tr><td';
		
		if($parts[0][0]):
			echo ' class="'.$textcol.'"';
		endif;
		
		echo '></td><td';
		
		if($parts[1][0]):
			echo ' class="'.$textcol.'"';
		endif;
		
		echo '></td></tr><tr><td';
		
		if($parts[0][1]):
			echo ' class="'.$textcol.'"';
		endif;
		
		echo '></td><td';
		
		if($parts[1][1]):
			echo ' class="'.$textcol.'"';
		endif;
		
		echo '></td></tr><tr><td';
		
		if($parts[0][2]):
			echo ' class="'.$textcol.'"';
		endif;
		
		echo '></td><td';
		
		if($parts[1][2]):
			echo ' class="'.$textcol.'"';
		endif;
				
		echo '></td></tr></table>';
	}
?>