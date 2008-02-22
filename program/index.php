<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>8BS to HTML conversion</title>
	</head>
	
	<body>
<?php
	require 'convert.php';
	require 'convertmode0.php';
	require 'convertmode7.php';
	require 'convertbasic.php';
	require 'convertrunnable.php';
	
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
		if($id > 0):
			return str_replace('menu1','index','menu'.$id).'.html';
		else:
			switch($id):
				case -1:
					floutput('Converting Mode 0 text "'.substr($file,2).'"',2);
					$convert=new convertmode0('temp//'.$file, $title);
					break;
				case -2:
					floutput('Converting Mode 7 text "'.substr($file,2).'"',2);
					$convert=new convertmode7('temp//'.$file, $title, true, true);
					break;
				case -4:
					floutput('Converting basic file "'.substr($file,2).'"',2);
					$convert=new convertbasic('temp//'.$file, $title);
					break;
				case -8:
					floutput('Adding placeholder for *RUNnable file "'.substr($file,2).'"', 2);
					$convert=new convertrunnable($file, $title);
					break;
				default:
					echo 'Action not defined for '.$id.' - Aborting.';
					exit;
					break;
			endswitch;
			
			$convert->savehtml('../'.$thisissue.'/content/'.$file.'.html');
			return 'content/'.$file.'.html';
		endif;
	}
	
	function floutput($text,$indent) {
		echo '<div style="margin-left: '.$indent.'em">'.$text.'</div>';
		ob_flush( );
		flush();
	}
	
	# Set up the temp folders
	if(is_dir('temp\0\\')):
		destroy('temp\0\\');
	else:
		mkdir('temp\0');
	endif;
	
	if(is_dir('temp\2\\')):
		destroy('temp\2\\');
	else:
		mkdir('temp\2');
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
	
	$header=implode('', file('pages/header.html'));
	$handle=fopen('temp/header.html','w');
	fputs($handle, $header);
	fclose($handle);
	
	$collook=TransCols($colours);
	$menu=implode('', file('temp/header.html')).implode('', file('pages/menu.html')).implode('', file('pages/footer.html'));
	
	$menu=str_replace('%commonrel%', '', $menu);
	$menu=str_replace('%stylesheetpath%', 'styles/menu.css', $menu);
	$menu=str_replace('%includejs%', '<script src="../common/menu.js" type="text/javascript"></script>', $menu);
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
		$menuline=0;
		
		floutput('Generating menu "'.$splitdata[$curline][0].'"',1);
		
		$thismenu=str_replace('%title%', $splitdata[$curline][0], $menu);
		$stopline=$curline+$splitdata[$curline][1];
		$curline++;
		
		while($curline <= $stopline):
			$menuitems.="\t".'<tr><td>&nbsp;</td><td class="bord">&nbsp;</td><td colspan="2">&nbsp;</td><td colspan="33" class="menuline" id="line'.$menuline.'"><a href="'.LinkTo(trim($splitdata[$curline][3]),fixfilepath(substr($splitdata[$curline][1],1),$splitdata[$curline][2]),$thisissue, $splitdata[$curline][0]).'" title="'.GetDescript(trim($splitdata[$curline][3])).'">&nbsp;&nbsp;<span class="letters">'.$letters[$menuline].'</span><span class="gt">&gt;</span>'.$splitdata[$curline][0].'</a></td><td>&nbsp;</td><td class="fc">&nbsp;</td><td class="bord">&nbsp;</td></tr>'."\r\n";
			
			$curline++;
			$menuline++;
		endwhile;
		
		while($menuline < 15):
			$menuitems.="	<tr><td>&nbsp;</td><td class=\"bord\">&nbsp;</td><td colspan=\"37\">&nbsp;</td><td class=\"bord\">&nbsp;</td></tr>\r\n";
			$menuline++;
		endwhile;
		
		$thismenu=str_replace('%menuitems%', $menuitems, $thismenu);
		
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
	
	echo '<p>Finished</p>';
?>
	</body>
</html>