<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">
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
	function emptydir($dir) {
		foreach(glob($dir.'\*') as $foundfile) {
			if(is_dir($foundfile)):
				emptydir($foundfile);
				rmdir($foundfile);
			else:
				unlink($foundfile);
			endif;
		}
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
					floutput('Converting Mode 0 text "'.substr($file,2).'"',2);
					$convert=new convertmode0('temp//'.$file, $issuenum, $title);
					break;
				case -2:
					floutput('Converting Mode 7 text "'.substr($file,2).'"',2);
					$convert=new convertmode7('temp//'.$file, $issuenum, $title, true, true);
					break;
				case -4:
					floutput('Converting basic file "'.substr($file,2).'"',2);
					$convert=new convertbasic('temp//'.$file, $issuenum, $title);
					break;
				case -8:
					floutput('Adding placeholder for *RUNnable file "'.substr($file,2).'"', 2);
					$convert=new convertrunnable($file, $issuenum, $title);
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
	
	# Remove the previously generated issues
	foreach(glob('../8BS??') as $foundfolder) {
		emptydir($foundfolder);
		rmdir($foundfolder);
	}
	
	# Remove the contents of the mode 7 graphics folder
	foreach(glob('..\common\mode7\*.png') as $foundfile) {
		unlink($foundfile);
	}
	
	$issuesindexlist = '';
	$thisissue='8BS64';
	
	floutput('Issue '.$thisissue,0);
	
	# Set up the temp folders
	if(is_dir('temp\0')):
		emptydir('temp\0');
	else:
		mkdir('temp\0');
	endif;
	
	if(is_dir('temp\2')):
		emptydir('temp\2');
	else:
		mkdir('temp\2');
	endif;
	
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
	
	$header=file_get_contents('pages/header.html');
	$header=str_replace('%title%', '8BS%iss%: %title%', $header);
	$handle=fopen('temp/header.html','w');
	fputs($handle, $header);
	fclose($handle);
	
	$colstrans=transcols($colours);
	$menu=file_get_contents('temp/header.html').file_get_contents('pages/menu.html').file_get_contents('pages/footer.html');
	
	$menu=str_replace('%stylesheetpath%', 'styles/menu.css', $menu);
	$menu=str_replace('%includejs%', '<script src="/common/script/menu.js" type="text/javascript"></script>', $menu);
	$menu=str_replace('%iss%', $splitdata[0][0], $menu);
	$menu=str_replace('%issdte%', $splitdata[0][1], $menu);
	
	$letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	$menupagenum=1;
	$curline=1;
	
	floutput('Creating Structures',1);
	
	mkdir('../'.$thisissue);
	mkdir('../'.$thisissue.'/styles');
	mkdir('../'.$thisissue.'/content');
	mkdir('../'.$thisissue.'/content/0');
	mkdir('../'.$thisissue.'/content/2');
	
	while($curline < count($splitdata)):
		$menuitems='';
		$menuline=0;
		
		floutput('Generating menu "'.$splitdata[$curline][0].'"',1);
		
		$thismenu=str_replace('%titlecol%', $colours['q'], $menu);
		$thismenu=str_replace('%title%', $splitdata[$curline][0], $thismenu);
		$thismenu=str_replace('%menutitle%', $splitdata[$curline][0], $thismenu);
		$stopline=$curline+$splitdata[$curline][1];
		$curline++;
		
		while($curline <= $stopline):
			$menuitems.= '<div class="menuline" id="line'.$menuline.'"><a href="'.LinkTo(trim($splitdata[$curline][3]),fixfilepath(substr($splitdata[$curline][1],1),$splitdata[$curline][2]),$thisissue,$splitdata[0][0],$splitdata[$curline][0]).'" title="'.GetDescript(trim($splitdata[$curline][3])).'">  <span class="letters">'.$letters[$menuline].'</span><span class="gt">&gt;</span>'.$splitdata[$curline][0].'</a></div>';
			
			$curline++;
			$menuline++;
		endwhile;
		
		$thismenu=str_replace('%menuitems%', $menuitems, $thismenu);
		
		$handle=fopen('../'.$thisissue.str_replace('menu1','index','/menu'.$menupagenum).'.html','w');
		fputs($handle, $thismenu);
		fclose($handle);
		$menupagenum++;
	endwhile;
	
	floutput('Creating CSS',1);
	
	$css=file_get_contents('pages/styles/menu.css');
	
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
	
	$handle=fopen('../'.$thisissue.'/styles/menu.css','w');
	fputs($handle, $css);
	fclose($handle);
	
	$issuesindexlist.= '<li><a href="/'.$thisissue.'/">Issue '.substr($thisissue, 3).'</a></li>';
	
	floutput('Generating site level pages', 0);
	floutput('About page', 1);
	
	$aboutpage = file_get_contents('pages/header.html').file_get_contents('pages/about.html').file_get_contents('pages/footer.html');
	$aboutpage = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $aboutpage);
	$aboutpage = str_replace('%includejs%', '', $aboutpage);
	$aboutpage = str_replace('%title%', 'About this conversion', $aboutpage);
	
	$handle = fopen('../about.html', 'w');
	fputs($handle, $aboutpage);
	fclose($handle);
	
	floutput('Magazines index', 1);
	
	$mainindex = file_get_contents('pages/header.html').file_get_contents('pages/index.html').file_get_contents('pages/footer.html');
	$mainindex = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $mainindex);
	$mainindex = str_replace('%includejs%', '', $mainindex);
	$mainindex = str_replace('%title%', '8-Bit Software Magazines Index', $mainindex);
	$mainindex = str_replace('%issueslist%', $issuesindexlist, $mainindex);
	
	$handle = fopen('../index.html', 'w');
	fputs($handle, $mainindex);
	fclose($handle);
	
	echo '<p>Finished</p>';
?>
	</body>
</html>