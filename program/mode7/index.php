<?php
	# Load the HTML created by create.php, and do cleanup and size reduction
	define('CHAR_CELL', '<td class="');
	
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
		$restofline=$row;
		$row='';
		$lastclasses=false;
		
		$nextpos=strpos($restofline, CHAR_CELL);
		
		while(!$nextpos===false):
			$nextpos+=strlen(CHAR_CELL);
			$thisclasses=substr($restofline,$nextpos,strpos(substr($restofline,$nextpos),'"'));
			$nextpos+=strlen($thisclasses)+1;
			
			if(substr($restofline,$nextpos+1,7)=='<table>'):
				$lastclasses=false;
			endif;
			
			if($thisclasses==$lastclasses):
				$colspan++;
			else:
				if(isset($colspan)):
					$row.=$lastrow;
					$row.=' colspan="'.$colspan.'"';
				endif;
				
				$colspan=1;
				$lastrow=substr($restofline,0,$nextpos);
				
				$lastclasses=$thisclasses;
			endif;
			
			$restofline=substr($restofline,$nextpos);
			
			$nextpos=strpos($restofline, CHAR_CELL);
		endwhile;
		
		$row.=$restofline;
		
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
	
		$complete=file('http://127.0.0.1'.$pathto.'generate.php?file='.rawurlencode($file).'&title='.rawurlencode($title));
		return implode('',$complete);
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