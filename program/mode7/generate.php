<?php
	define(WHITE,'#ffffff');
	define(RED,'#ff0000');
	define(GREEN,'#00ff00');
	define(BLUE,'#0000ff');
	define(YELLOW,'#ffff00');
	define(BLACK,'#000000');
	define(MAGENTA,'#ff00ff');
	define(CYAN,'#00ffff');
	
	define(NEW_LINE_HTML,"</tr>\r\n\t<!-- mode7 row --><tr>");
	
	$collookup[WHITE]='w';
	$collookup[RED]='r';
	$collookup[GREEN]='g';
	$collookup[BLUE]='b';
	$collookup[YELLOW]='y';
	$collookup[BLACK]='bk';
	$collookup[MAGENTA]='m';
	$collookup[CYAN]='c';

	define(JUST_TEXT,0);
	define(NEC_GRAPHICS,1);
	define(FULL_GRAPHICS,2);

	$displaymode=JUST_TEXT;
	$charwidth=16;
	$charheight=24;

	# Functions used for text-only symbols
	require('symbol_html.php');
	$lookup=createlookup();
		
	$linebreak=0;
	$textcolour=WHITE;
	$prevtextcolour=WHITE;
	$backgroundcolour=BLACK;
	$graphics=0;
	$textdheight=false;
	$textdstate=1;
	$textdused=false;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?=$_GET['title']?></title>
  <style type="text/css">
    body {
	    background-color: black;
	    text-align: center;
    }
    
    body img {
	    width: <?= $charwidth-2 ?>px;
	    height: <?= $charheight-3 ?>px;
	    display: block;
    }
    
    table {
	    color: white;
	    font: <?= $charheight ?>px "ModeSeven", "Courier New", "Courier", "Monotype";
	    text-align: left;
	    border: 0px;
	    border-collapse: collapse;
	    margin-left: auto;
	    margin-right: auto;
    }
    
<?php
	function colclass($colour,$class,$type) {
		echo "\t.".$class." { ".$type."color: ".$colour."; }\n";
	}
	
	colclass(WHITE,'fw','');
	colclass(RED,'fr','');
	colclass(GREEN,'fg','');
	colclass(BLUE,'fb','');
	colclass(YELLOW,'fy','');
	colclass(BLACK,'fbk','');
	colclass(MAGENTA,'fm','');
	colclass(CYAN,'fc','');
	
	colclass(WHITE,'bw','background-');
	colclass(RED,'br','background-');
	colclass(GREEN,'bg','background-');
	colclass(BLUE,'bb','background-');
	colclass(YELLOW,'by','background-');
	colclass(BLACK,'bbk','background-');
	colclass(MAGENTA,'bm','background-');
	colclass(CYAN,'bc','background-');
?>
    
    td {
    	margin: 0px;
    	padding: 0px;
    	letter-spacing: 2px;
    	width: <?= $charwidth ?>px;
    	line-height: <?= $charheight ?>px;
    	border: 1px solid green;
    }
    
    td table {
    	width: 100%;
    }
    
    td table td {
    	height: 0.33em;
    }
  </style>
  </head>
  
  <body>
    <table>
	<!-- mode7 row --><tr><?php
	
	function correctmap($charval) {
		switch($charval):
			case 35:
				return 163; # Correct # -> £
				break;
			default:
				return $charval;
		endswitch;
	}
	
	function setcolour($colour,$newline=false, $graphicset=false) {
		global $textcolour;
		global $prevtextcolour;
		global $backgroundcolour;
		global $graphics;
		global $textdheight;
		global $textdused;
		global $textdstate;
		
		if($newline):
			$prevtextcolor=WHITE;
			$backgroundcolour=BLACK;
			$textdheight=false;
			if($textdused==true):
				$textdstate++;
				if($textdstate>2):
					$textdstate=1;
				endif;
				$textdused=false;
			endif;
		endif;
		
		if($graphicset):
			$graphics=1;
		else:
			$graphics=0;
		endif;
		
		$prevtextcolour=$textcolour;
		$textcolour=$colour;
		
		if(!$newline):
			echo '&nbsp;';
		endif;
	}
	
	function setbgcolour($blackbg=false) {
			global $textcolour;
			global $prevtextcolour;
			global $backgroundcolour;
			global $collookup;
			
			if($blackbg):
				$backgroundcolour=BLACK;
			else:
				$backgroundcolour=$textcolour;
				$prevtextcolour=WHITE;
				$textcolour=$prevtextcolour;
			endif;
			
			echo '<div class="b'.$collookup[$backgroundcolour].'">&nbsp;</div>';
			
	}
	
	function nonletterchars($charval) {
		global $linebreak;
		global $textcolour;
		global $prevtextcolour;
		global $textdheight;
		global $textdused;
		
		switch ($charval):
			# -----------------------------
			#  Line Break
			# -----------------------------						
			case 13:
				echo NEW_LINE_HTML;
				setcolour(WHITE,true);
				$linebreak=-1;
				break;

			# -----------------------------
			#  Spaces
			# -----------------------------						
			case 32:
			case 160:
				echo '&nbsp;';
				break;

			# -----------------------------
			#  Text Colours
			# -----------------------------
			case 129:
				setcolour(RED);
				break;
			case 130:
				setcolour(GREEN);
				break;
			case 131:
				setcolour(YELLOW);
				break;						
			case 132:
				setcolour(BLUE);
				break;
			case 133:
				setcolour(MAGENTA);
				break;
			case 134:
				setcolour(CYAN);
				break;
			case 135:
				setcolour(WHITE);
				break;

			# -----------------------------
			# Text Height
			# -----------------------------
			
			case 140:
				$textdheight=false;
				echo '&nbsp';
				break;
			case 141:
				$textdheight=true;
				$textdused=true;
				echo '&nbsp';
				break;

			# -----------------------------
			#  Graphical Colours
			# -----------------------------
			case 145:
				setcolour(RED,false,true);
				break;
			case 146:
				setcolour(GREEN,false,true);
				break;
			case 147:
				setcolour(YELLOW,false,true);
				break;						
			case 148:
				setcolour(BLUE,false,true);
				break;
			case 149:
				setcolour(MAGENTA,false,true);
				break;
			case 150:
				setcolour(CYAN,false,true);
				break;
			case 151:
				setcolour(WHITE,false,true);
				break;

			# -----------------------------
			#  Background Colours
			# -----------------------------
			case 156:
				setbgcolour(true);
				break;
			
			case 157:
				setbgcolour();
				break;

			# -----------------------------
			#  Currently Unhandled Code
			# -----------------------------
			default:
				echo '('.$charval.')';
		endswitch;
	}
	
	function teletextchar($charval) {
		global $textcolour;
		global $backgroundcolour;
		global $charwidth;
		global $charheight;
		global $lookup;
		
		if($display==JUST_TEXT):
			echo makesymbol($charval, $charwidth, $charheight, $backgroundcolour, $textcolour, $lookup);
		else:
			echo '<img src="symbol.php?textcol='.rawurlencode($textcolour).'&backcol='.rawurlencode($backgroundcolour).'&width='.$charwidth.'&height='.$charheight.'&symbol='.($charval).'" />';
		endif;
	}
	
	function graphicschars($charval) {
		# -----------------------------
		#  Handled Elsewhere
		# -----------------------------
		if(($charval>31 && $charval<64) || ($charval>94 && $charval<127) || ($charval>159 && $charval<192) || ($charval>223 && $charval<256)):
			teletextchar($charval);
		else:
			switch($charval):
				case 13:
				case 129:
				case 130:
				case 131:
				case 132:
				case 133:
				case 134:
				case 135:
				case 145:
				case 146:
				case 147:
				case 148:
				case 149:
				case 150:
				case 151:
				case 156:
				case 157:
					nonletterchars($charval);
					break;

				# -----------------------------
				#  Currently Unhandled Code
				# -----------------------------
				default:
					echo '('.$charval.')';			
			endswitch;
		endif;
	}
	
	function outputletter($charval) {
		global $textdheight;
		global $textdstate;
		global $textcolour;
		global $backgroundcolour;
		global $charheight;
		global $charwidth;
		global $displaymode;
		
		if($textdheight):
			echo '<img src="character.php?textcol='.rawurlencode($textcolour).'&amp;backcol='.rawurlencode($backgroundcolour).'&amp;width='.$charwidth.'&amp;height='.$charheight.'&amp;character='.($charval).'&amp;dheight='.$textdstate.'" alt="'.chr($charval).'" />';
		else:
			if($displaymode==FULL_GRAPHICS):
				echo '<img src="character.php?textcol='.rawurlencode($textcolour).'&backcol='.rawurlencode($backgroundcolour).'&width='.($charwidth-2).'&height='.($charheight-3).'&character='.($charval).'" />';
			else:
				echo chr($charval);
			endif;
		endif;
	}
	
	function parseline ($line) {
		$linelen=strlen($line);
		
		static $discard=2;
		global $linebreak;
		global $graphics;
		
		global $textcolour;
		global $backgroundcolour;
		
		global $collookup;
		
		for($analyse=0; $analyse<$linelen; $analyse++):
			if($discard==0):
				$charval=ord(substr($line,$analyse,1));
				
				echo '<td class="';
				if ($backgroundcolour<>BLACK):
					echo 'b'.$collookup[$backgroundcolour];
				endif;
				echo ' ';
				if ($textcolour<>WHITE):
					echo 'f'.$collookup[$textcolour];
				endif;
				echo '">';
				
				if($graphics==0):
					if($charval>32 && $charval<127):
						outputletter(correctmap($charval));
					elseif($charval>159 && $charval<255):
						outputletter(correctmap($charval)-160+32);
					else:
						nonletterchars($charval);
					endif;
				else:
					graphicschars($charval);
				endif;
				
				echo '</td>';
				
				$linebreak=$linebreak+1;
				if($linebreak>39):
					echo NEW_LINE_HTML;
					setcolour(WHITE,true);
					$linebreak=0;
				endif;
			else:
				 if(substr($line,$analyse,2)=='|M'):
				 	$discard--;
				 	$analyse+=2;
				 endif;
			endif;
		endfor;
	}
	
	$file=$_GET['file'];	
	
	$handle=fopen($file,'r');
	
	$returned=fread($handle,5000);
	
	while($returned<>''):
		parseline($returned);
		$returned=fread($handle,5000);
	endwhile;
	
	fclose($handle);
?></tr>
    </table>
  </body>
</html>