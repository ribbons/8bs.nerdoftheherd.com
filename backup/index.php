<?php
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
	
	function GetScrollText($file, $thisissue, $mode, $title) {
		FlOutput('Converting Mode '.$mode.' text "'.substr($file,2).'"',2);
		
		$handle=fopen('http://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'].'mode'.$mode.'/?file=../temp/'.str_replace('/','/$',$file).'&title='.rawurlencode($title),'r');
		$whandle=fopen('../'.$thisissue.'/content/'.$file.'.html','w');
		
		$returned=fread($handle,5000);
		
		while($returned<>''):
			fputs($whandle, $returned);	
			
			$returned=fread($handle,5000);
		endwhile;
		
		fclose($handle);
		fclose($whandle);
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
	
	function GetTemplate($filename) {
		$handle=fopen($filename,'r');
		$returned=fgets($handle,5000);

		while($returned<>''):
			$template.=$returned;
			$returned=fgets($handle,5000);
		endwhile;

		fclose($handle);
		return $template;
	}
	
	function GetDescript($id) {
		$descriptions[-99]='Runs Code';
		$descriptions[-1]='80 Column Text';
		$descriptions[-2]='40 Column Text';
		$descriptions[-99]='Archive';
		$descriptions[-4]='Basic Program';
		$descriptions[-99]='Loads BASIC';
		$descriptions[-99]='Lists Basic';
		$descriptions[-99]='Uses LDPIC';
		$descriptions[-99]='*RUN';
		
		if($descriptions[$id]):
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
				return '#" onclick="return false;';
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
	
	# empty the temp folder
	destroy('temp\\');
	mkdir('temp\0');
	mkdir('temp\2');
	
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
	$menu=GetTemplate('pages/menutemplate.html');
	
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
			$menuitems.='<div style="padding-left: 40px;"><span id="line'.$menuline.'"><a href="'.LinkTo(trim($splitdata[$curline][3]),substr($splitdata[$curline][1],1).'/'.$splitdata[$curline][2],$thisissue, $splitdata[$curline][0]).'" onmouseover="linehl(\'line'.$menuline.'\'); desctxt(\''.GetDescript(trim($splitdata[$curline][3])).'\');" onmousedown="linegt(\'line'.$menuline.'\');">&nbsp;&nbsp;'.$letters[$menuline].'<span id="gtline'.$menuline.'" class="menugt">&gt;</span><span id="txtline'.$menuline.'" class="menurow">'.str_replace("\t", '&nbsp;', str_pad($splitdata[$curline][0], 31, "\t")).'</span></span></a></div>'."\n";
			$scriptitems.="document.getElementById('line".$menuline."').className = '';\n";
			$scriptitems.="document.getElementById('gtline".$menuline."').className = 'menugt';\n";
			$scriptitems.="document.getElementById('txtline".$menuline."').className = 'menurow';\n";
			
			if($menuline==1):
				$firstdesc=GetDescript(trim($splitdata[$curline][3]));
			endif;
			
			$curline++;
			$menuline++;
		endwhile;
		
		while($menuline < 13):
			$menuitems.="<br />\n";
			$menuline++;
		endwhile;
		
		$thismenu=str_replace('%menuitems%', $menuitems, $thismenu);
		$thismenu=str_replace('%scriptitems%', $scriptitems, $thismenu);
		$thismenu=str_replace('%descript%', $firstdesc, $thismenu);
		
		$handle=fopen('../'.$thisissue.str_replace('menu1','index','/menu'.$menupagenum).'.html','w');
		fputs($handle, $thismenu);
		fclose($handle);
		$menupagenum++;
	endwhile;
	
	floutput('Creating CSS',1);
	
	$css=GetTemplate('pages/styles/menu.css');
	
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