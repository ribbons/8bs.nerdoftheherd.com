<?php
	include 'filehandlers.inc.php';

	# Empty a directory
	function destroy($dir) {
	    $mydir = opendir($dir);
	    while(false !== ($file = readdir($mydir))) {
	        if($file != "." && $file != "..") {
	            chmod($dir.$file, 0777);
	            if(is_dir($dir.$file)) {
	                chdir('.');
	                destroy($dir.$file.'/');
	                rmdir($dir.$file) or DIE("couldn't delete $dir$file<br />");
	            }
	            else
	                unlink($dir.$file) or DIE("couldn't delete $dir$file<br />");
	        }
	    }
	    closedir($mydir);
	}
	
	function fixfilepath($dir, $file) {
		if (substr($dir,1,1)=='.'):
			return substr($dir,0,1).'/'.substr($dir,2,1).$file;
		else:
			return $dir.'/$'.$file;
		endif;
	}
	
	function GetData() {
		global $colours;
		
		$handle=fopen('temp\0\$!Boot.txt','r');

		$returned=fgets($handle,5000);

		while($returned<>''):
			# Menu Colour Data
			if(substr($returned,4,5)==":REM "):
				$colours[]=substr($returned,0,4);
			endif;
			
			# Menu Data
			if(substr($returned,0,5)=="DATA "):
				$splitdata[]=split(',',substr($returned, 5));
			endif;

			$returned=fgets($handle,5000);
		endwhile;

		fclose($handle);
		
		return $splitdata;
	}
	
	function TransCols($colours) {
		$coltr[1]='red';
		$coltr[2]='lime';
		$coltr[3]='yellow';
		$coltr[4]='blue';
		$coltr[5]='magenta';
		$coltr[6]='cyan';
		$coltr[7]='white';
		
		foreach($colours as $colour):
			$collook[substr($colour,0,1)]=$coltr[substr($colour,3,1)];
		endforeach;
		
		return $collook;
	}
	
	function GetDescript($id) {
		$descriptions[0]='Runs Code'; # Guess
		$descriptions[-1]='80 Column Text';
		$descriptions[-2]='40 Column Text';
		$descriptions[-3]='Archive'; # Guess
		$descriptions[-4]='Basic Program';
		$descriptions[-5]='Loads BASIC'; # Guess
		$descriptions[-6]='Lists Basic'; # Guess
		$descriptions[-7]='Uses LDPIC'; # Guess
		$descriptions[-8]='*RUN';
		
		if(isset($descriptions[$id])):
			$descript=$descriptions[$id];
		else:
			$descript='Another menu';
		endif;
		
		return $descript;
	}
	
	function LinkTo($id, $file, $thisissue, $title) {
		switch($id):
			case -1:
				getscrolltext($file, $thisissue, '0', $title);
				return 'content/'.$file.'.html';
				break;
			case -2:
				getscrolltext($file, $thisissue, '7', $title);
				return 'content/'.$file.'.html';
				break;
			case -4:
				getbasic($file, $thisissue, '7', $title);
				return 'content/'.$file.'.html';
				break;
			case -8:
				getrun($file, $thisissue, $title);
				return 'content/'.$file.'.html';
				break;
			case 0:
			case -3:
			case -5:
			case -6:
			case -7:
				echo 'Action not defined for '.$id.' - Aborting.';
				exit;
				break;
			default:
				return str_replace('menu1','index','menu'.$id).'.html';
		endswitch;
	}
	
	function FlOutput($text,$indent) {
		echo '<span style="margin-left: '.($indent*10).'px">'.$text.'</span><br />';
		ob_flush( );
		flush();
	}
	
	# Empty the temp folder
	if(is_dir('temp\0\\')):
		destroy('temp\0\\');
	endif;
	
	if(is_dir('temp\2\\')):
		destroy('temp\2\\');
	endif;
	
	$thisissue='8BS64';
	
	floutput('Issue '.$thisissue,0);
	
	floutput('Extracting Side 0',1);
	
	exec('bin\dconv.com -d source\\'.$thisissue.'.dsd -o temp\0 -side 0 -interleave track', $output, $return);
	
	if($return<>0):
		echo 'Problem extracting files from DFS disk image (side 0)';
		exit;
	endif;
	
	floutput('Extracting Side 2',1);
	
	exec('bin\dconv.com -d source\\'.$thisissue.'.dsd -o temp\2 -side 1 -interleave track', $output, $return);
	
	if($return<>0):
		echo 'Problem extracting files from DFS disk image (side 2)';
		exit;
	endif;
	
	exec('bin\bas2txt.exe /n temp\0\$!Boot', $output, $return);
	
	if($return<>0):
		echo 'Problem converting !boot file to text';
		exit;
	endif;
	
	$splitdata=GetData();
	$collook=TransCols($colours);
	$menu=implode('', file('pages/menutemplate.html'));
	
	$menu=str_replace('%iss%', $splitdata[0][0], $menu);
	$menu=str_replace('%issdte%', $splitdata[0][1], $menu);
	
	$letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	$menupagenum=1;
	$curline=1;
	
	floutput('Creating Structures',1);
	
	if(is_dir('../'.$thisissue)):
		destroy('../'.$thisissue.'/');
		rmdir('../'.$thisissue);
	endif;	
	
	mkdir('../'.$thisissue);
	mkdir('../'.$thisissue.'/styles');
	mkdir('../'.$thisissue.'/content');
	mkdir('../'.$thisissue.'/content/0');
	mkdir('../'.$thisissue.'/content/2');
	
	while($curline < count($splitdata)):
		$menuitems='';
		$scriptitems='';
		$menuline=0;
		
		floutput('Generating menu "'.$splitdata[$curline][0].'"',1);
		
		$thismenu=str_replace('%menutitle%', $splitdata[$curline][0], $menu);
		$stopline=$curline+$splitdata[$curline][1];
		$curline++;
		
		while($curline <= $stopline):
			$menuitems.="\t".'<tr><td>&nbsp;</td><td class="bord">&nbsp;</td><td colspan="2">&nbsp;</td><td colspan="33" class="menuline" id="line'.$menuline.'"><a href="'.LinkTo(trim($splitdata[$curline][3]),fixfilepath(substr($splitdata[$curline][1],1),$splitdata[$curline][2]),$thisissue, $splitdata[$curline][0]).'" onmouseover="linehl(\'line'.$menuline.'\'); desctxt(\''.GetDescript(trim($splitdata[$curline][3])).'\');">&nbsp;&nbsp;<span class="letters">'.$letters[$menuline].'</span><span class="gt">&gt;</span>'.$splitdata[$curline][0].'</a></td><td>&nbsp;</td><td class="fc">&nbsp;</td><td class="bord">&nbsp;</td></tr>'."\r\n";
			$scriptitems.="document.getElementById('line".$menuline."').className = 'menuline';\n";
			
			if($menuline==1):
				$firstdesc=GetDescript(trim($splitdata[$curline][3]));
			endif;
			
			$curline++;
			$menuline++;
		endwhile;
		
		while($menuline < 15):
			$menuitems.="	<tr><td>&nbsp;</td><td class=\"bord\">&nbsp;</td><td colspan=\"37\">&nbsp;</td><td class=\"bord\">&nbsp;</td></tr>\r\n";
			$menuline++;
		endwhile;
		
		$thismenu=str_replace('%menuitems%', $menuitems, $thismenu);
		$thismenu=str_replace('%scriptitems%', $scriptitems, $thismenu);
		$thismenu=str_replace('%firstdesc%', $firstdesc, $thismenu);
		
		$handle=fopen('../'.$thisissue.str_replace('menu1','index','/menu'.$menupagenum).'.html','w');
		fputs($handle, $thismenu);
		fclose($handle);
		$menupagenum++;
	endwhile;
	
	floutput('Creating CSS',1);
	
	$css=implode('', file('pages/styles/menu.css'));
	
	$css=str_replace('%id%', $collook['i'], $css);
	$css=str_replace('%dteiss%', $collook['r'], $css);
	$css=str_replace('%title%', $collook['q'], $css);
	$css=str_replace('%menutt%', $collook['s'], $css);
	$css=str_replace('%border%', $collook['p'], $css);
	$css=str_replace('%letters%', $collook['t'], $css);
	$css=str_replace('%highlight%', $collook['w'], $css);
	$css=str_replace('%items%', $collook['u'], $css);
	$css=str_replace('%descript%', $collook['d'], $css);
	$css=str_replace('%helptxt%', $collook['v'], $css);
	
	$handle=fopen('../'.$thisissue.'/styles/menu.css','w');
	fputs($handle, $css);
	fclose($handle);
	
	echo '<br />Finished';
?>
