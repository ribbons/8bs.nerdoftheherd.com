<?php
	require 'convertmode0.php';
	require 'convertmode7.php';
	require 'convertbasic.php';
	require 'convertrunnable.php';
	
	function fixfilepath($dir, $file) {
		if (substr($dir,1,1)=='.'):
			return substr($dir,0,1).'/'.substr($dir,2,1).$file;
		else:
			return $dir.'/$'.$file;
		endif;
	}
	
	function GetData($thisissue) {
		global $colours;
		
		$handle=fopen('temp\extracted\\'.$thisissue.'\0\$!Boot.txt','r');

		$returned=fgets($handle,5000);

		while($returned<>''):
			# Menu Colour Data
			if(substr($returned,4,5)==":REM "):
				$colours[substr($returned,0,1)]=substr($returned,3,1);
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
	
	function transcols($colours) {
		$coltr[1]='red';
		$coltr[2]='lime';
		$coltr[3]='yellow';
		$coltr[4]='blue';
		$coltr[5]='fuchsia';
		$coltr[6]='aqua';
		$coltr[7]='white';
		
		foreach($colours as $key => $colour):
			$colstrans[$key]=$coltr[$colour];
		endforeach;
		
		return $colstrans;
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
	
	function LinkTo($id, $file, $thisissue, $issuenum, $title) {
		if($id > 0):
			return str_replace('menu1','index','menu'.$id).'.html';
		else:
			switch($id):
				case -1:
					indentecho('Converting Mode 0 text "'.substr($file,2).'"',2);
					$convert=new convertmode0('temp/extracted/'.$thisissue.'/'.$file, $issuenum, $title);
					break;
				case -2:
					indentecho('Converting Mode 7 text "'.substr($file,2).'"',2);
					$convert=new convertmode7('temp/extracted/'.$thisissue.'/'.$file, $issuenum, $title, true, true);
					break;
				case -4:
					indentecho('Converting basic file "'.substr($file,2).'"',2);
					$convert=new convertbasic('temp/extracted/'.$thisissue.'/'.$file, $issuenum, $title);
					break;
				case -8:
					indentecho('Adding placeholder for *RUNnable file "'.substr($file,2).'"', 2);
					$convert=new convertrunnable($file, $issuenum, $title);
					break;
				default:
					echo 'Action not defined for '.$id.' - Aborting.';
					exit(1);
					break;
			endswitch;
			
			$convert->savehtml('temp/web/'.$thisissue.'/content/'.$file.'.html');
			return 'content/'.$file.'.html';
		endif;
	}
	
	function indentecho($text,$indent) {
		echo str_repeat("\t", $indent).$text."\n";
		flush();
	}
	
	$issuesindexlist = '';
	$thisissue='8BS64';
	
	indentecho('Issue '.$thisissue,0);
	indentecho('Extracting Side 0',1);
	
	if(!is_dir('temp/extracted/'.$thisissue.'/0')):
		mkdir('temp/extracted/'.$thisissue.'/0', 0777, true);
	endif;
	
	exec('bin\dconv -d source\\'.$thisissue.'.dsd -o temp\extracted\\'.$thisissue.'\0 -side 0 -interleave track', $output, $return);
	
	if($return<>0):
		echo 'Problem extracting files from DFS disk image (side 0)';
		exit($return);
	endif;
	
	indentecho('Extracting Side 2',1);
	
	if(!is_dir('temp/extracted/'.$thisissue.'/2')):
		mkdir('temp/extracted/'.$thisissue.'/2');
	endif;
	
	exec('bin\dconv -d source\\'.$thisissue.'.dsd -o temp\extracted\\'.$thisissue.'\2 -side 1 -interleave track', $output, $return);
	
	if($return<>0):
		echo 'Problem extracting files from DFS disk image (side 2)';
		exit($return);
	endif;
	
	indentecho('Fetching menu data',1);
	
	exec('bin\bas2txt.exe /n temp\extracted\\'.$thisissue.'\0\$!Boot', $output, $return);
	
	if($return<>0):
		echo 'Problem converting !boot file to text';
		exit($return);
	endif;
	
	$splitdata=GetData($thisissue);
	
	$header=file_get_contents('templates/header.html');
	$header=str_replace('%title%', '8BS%iss%: %title%', $header);
	$handle=fopen('temp/header.html','w');
	fputs($handle, $header);
	fclose($handle);
	
	$colstrans=transcols($colours);
	$menu=file_get_contents('temp/header.html').file_get_contents('templates/menu.html').file_get_contents('templates/footer.html');
	
	$menu=str_replace('%stylesheetpath%', 'styles/menu.css', $menu);
	$menu=str_replace('%includejs%', '<script src="/common/script/menu.js" type="text/javascript"></script>', $menu);
	$menu=str_replace('%iss%', $splitdata[0][0], $menu);
	$menu=str_replace('%issdte%', $splitdata[0][1], $menu);
	
	$letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	$menupagenum=1;
	$curline=1;
	
	indentecho('Creating Structures',1);
	
	if(!is_dir('temp/web/'.$thisissue.'/content/0')):
		mkdir('temp/web/'.$thisissue.'/content/0', 0777, true);
	endif;
	
	if(!is_dir('temp/web/'.$thisissue.'/content/2')):
		mkdir('temp/web/'.$thisissue.'/content/2');
	endif;
	
	if(!is_dir('temp/web/'.$thisissue.'/styles')):
		mkdir('temp/web/'.$thisissue.'/styles');
	endif;
	
	while($curline < count($splitdata)):
		$menuitems='';
		$menuline=0;
		
		indentecho('Generating menu "'.$splitdata[$curline][0].'"',1);
		
		$thismenu=str_replace('%titlecol%', $colours['q'], $menu);
		$thismenu=str_replace('%title%', $splitdata[$curline][0], $thismenu);
		$thismenu=str_replace('%menutitle%', $splitdata[$curline][0], $thismenu);
		$stopline=$curline+$splitdata[$curline][1];
		$curline++;
		
		while($curline <= $stopline):
			$menuitems.= '<div><a href="'.LinkTo(trim($splitdata[$curline][3]),fixfilepath(substr($splitdata[$curline][1],1),$splitdata[$curline][2]),$thisissue,$splitdata[0][0],$splitdata[$curline][0]).'" title="'.GetDescript(trim($splitdata[$curline][3])).'">  <span class="letters">'.$letters[$menuline].'</span><span class="gt">&gt;</span>'.$splitdata[$curline][0].'</a></div>';
			
			$curline++;
			$menuline++;
		endwhile;
		
		$thismenu=str_replace('%menuitems%', $menuitems, $thismenu);
		
		$handle=fopen('temp/web/'.$thisissue.str_replace('menu1','index','/menu'.$menupagenum).'.html','w');
		fputs($handle, $thismenu);
		fclose($handle);
		$menupagenum++;
	endwhile;
	
	indentecho('Creating CSS',1);
	
	$css=file_get_contents('templates/styles/menu.css');
	
	$css=str_replace('%id%', $colstrans['i'], $css);
	$css=str_replace('%dteiss%', $colstrans['r'], $css);
	$css=str_replace('%title%', $colstrans['q'], $css);
	$css=str_replace('%menutt%', $colstrans['s'], $css);
	$css=str_replace('%border%', $colstrans['p'], $css);
	$css=str_replace('%letters%', $colstrans['t'], $css);
	$css=str_replace('%highlight%', $colstrans['w'], $css);
	$css=str_replace('%items%', $colstrans['u'], $css);
	$css=str_replace('%descript%', $colstrans['d'], $css);
	$css=str_replace('%helptxt%', $colstrans['v'], $css);
	
	$handle=fopen('temp/web/'.$thisissue.'/styles/menu.css','w');
	fputs($handle, $css);
	fclose($handle);
	
	$issuesindexlist.= '<li><a href="/'.$thisissue.'/">Issue '.substr($thisissue, 3).'</a></li>';
	
	indentecho('Generating site level pages', 0);
	indentecho('About page', 1);
	
	$aboutpage = file_get_contents('templates/header.html').file_get_contents('templates/about.html').file_get_contents('templates/footer.html');
	$aboutpage = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $aboutpage);
	$aboutpage = str_replace('%includejs%', '', $aboutpage);
	$aboutpage = str_replace('%title%', 'About this conversion', $aboutpage);
	
	$handle = fopen('temp/web/about.html', 'w');
	fputs($handle, $aboutpage);
	fclose($handle);
	
	indentecho('Magazines index', 1);
	
	$mainindex = file_get_contents('templates/header.html').file_get_contents('templates/index.html').file_get_contents('templates/footer.html');
	$mainindex = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $mainindex);
	$mainindex = str_replace('%includejs%', '', $mainindex);
	$mainindex = str_replace('%title%', '8-Bit Software Magazines Index', $mainindex);
	$mainindex = str_replace('%issueslist%', $issuesindexlist, $mainindex);
	
	$handle = fopen('temp/web/index.html', 'w');
	fputs($handle, $mainindex);
	fclose($handle);
?>