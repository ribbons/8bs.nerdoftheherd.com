<?php
	# Load the HTML created by create.php, and do cleanup and size reduction
	
	function MergeCells($contents) {
		$contentlines = explode("\r\n", $contents);
		$contents='';
		
		foreach($contentlines as $key => $line):
			if(substr($line, 1, 18) == '<!-- mode7 row -->'):
				$contentlines[$key] = MergeRows($contentlines[$key]);
			endif;
		endforeach;
		
		return implode("\r\n", $contentlines);
	}
	
	function MergeRows($row) {
		
		return $row;
	}
	
	function SimplifyDivs($contents) {
		# Convert fudged background change in a DIV to a real change in the parent TD
		$contents = preg_replace('/<td class="([^"]*)"><div class="([^"]*)">/', '<td class="\2">', $contents);
		$contents = str_replace('</div>','',$contents);
		return $contents;
	}
	
	function GetTeletext($file, $title) {
		$pos=strpos($_SERVER['REQUEST_URI'],'?');
		$pathto=substr($_SERVER['REQUEST_URI'],0,$pos);
	
		$handle=fopen('http://127.0.0.1'.$pathto.'generate.php?file='.rawurlencode($file).'&title='.rawurlencode($title),'r');
				
		$returned=fgets($handle,50000);
		
		while($returned<>''):
			$complete.=$returned;			
			$returned=fgets($handle,5000);
		endwhile;
		
		fclose($handle);
		
		return $complete;
	}
	
	# Don't forget 
	#  * HTML entity escaping
	#  * Most common colours of row
	#  * Simplify symbol tables
	#  * Combine blank columns
	
	$contents = GetTeletext($_GET['file'],$_GET['title']);
	$contents = SimplifyDivs($contents);
	$contents = MergeCells($contents);

	
	#$contents = str_replace(' class=" "','',$contents); # Remove empty class definiton attributes
	
	echo $contents;
?>