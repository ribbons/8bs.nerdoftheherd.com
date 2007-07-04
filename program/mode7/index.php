<?php
	# Load the HTML created by create.php, and do cleanup and size reduction
	define('CHAR_CELL', '<td class="');
	
	function processrows($contents) {
		$contentlines = explode("\r\n", $contents);
		$contents='';
		
		foreach($contentlines as $key => $line):
			if(substr($line, 1, 18) == '<!-- mode7 row -->'):
				$contentlines[$key] = mergecells($contentlines[$key]);
			endif;
		endforeach;
		
		return implode("\r\n", $contentlines);
	}
	
	function mergecells($row) {
		global $firstrow;
		
		# Go through the row and convert all of the cells into two arrays, one with the cell classes, and one with the contents.
		# A cell is assumed to be able to contain a non breaking space, an image, a table, a single character or nothing.
		preg_match_all('/<td class="([^"]*)">(&nbsp;|<img .*?\/>|<table>.*?<\/table>|.|)<\/td>/', $row, $matches, PREG_PATTERN_ORDER);
		
		$oldrow=$row;
		$row='	<tr>';
		
		$lastclass=false;
		$skipcell=0;
		
		foreach($matches[1] as $key => $classes):
			$classes=trim($classes);
			
			if(substr($matches[2][$key],0,1)=='<'):
				$skipcell=2;
			endif;
			
			if($lastclass===$classes && $skipcell==0):
				$colspan++;
			else:
				if(isset($colspan)):
					$row=addmergedrow($row,$colspan,$lastclass,$cellcontents);
				endif;
				
				if($skipcell>0):
					$skipcell--;
				endif;
				
				$colspan=1;
				$cellcontents='';
				$lastclass=$classes;
			endif;
				
			$cellcontents.=$matches[2][$key];
		endforeach;
		
		if(isset($colspan)):
			$row=addmergedrow($row,$colspan,$lastclass,$cellcontents);
		endif;
		
		$row.='</tr>';
		#$oldrow."\r\n".
		return $row;
	}
	
	function addmergedrow($row,$colspan,$class,$cellcontents) {
		$row.='<td class="'.$class.'"';
		
		if($colspan>1):
			$row.=' colspan="'.$colspan.'"';
		endif;
		
		$row.='>'.$cellcontents.'</td>';
		return $row;
	}
	
	function SimplifyDivs($contents) {
		# Convert fudged background change in a DIV to a real change in the parent TD
		$contents = preg_replace('/<td class="([^"]*)"><div class="([^"]*)">/', '<td class="\2">', $contents);
		$contents = str_replace('</div>','',$contents);
		return $contents;
	}
	
	function simplifysymbols($contents) {
		# Replace symbol tables which are all one colour with an empty cell of the same colour.
		$contents=preg_replace('/<td class="(?:[^"]*)"><table><tr><td class="([^"]*)"><\/td><td class="\1"><\/td><\/tr><tr><td class="\1"><\/td><td class="\1"><\/td><\/tr><tr><td class="\1"><\/td><td class="\1"><\/td><\/tr><\/table><\/td>/', '<td class="\1">&nbsp;</td>', $contents);
		return $contents;
	}
	
	function GetTeletext($file, $title) {
		$pos=strpos($_SERVER['REQUEST_URI'],'?');
		$pathto=substr($_SERVER['REQUEST_URI'],0,$pos);
	
		$complete=file('http://127.0.0.1'.$pathto.'generate.php?file='.rawurlencode($file).'&title='.rawurlencode($title));
		return implode('',$complete);
	}
	
	$firstrow='';
	
	# Don't forget 
	#  * HTML entity escaping
	#  * Most common colours of row
	#  * Simplify symbol tables
	
	$contents = GetTeletext($_GET['file'],$_GET['title']);
	$contents = SimplifyDivs($contents);
	$contents = simplifysymbols($contents);
	$contents = processrows($contents);
	
	$contents = str_replace(' class=""','',$contents); # Remove empty class definiton attributes
	
	echo $contents;
?>