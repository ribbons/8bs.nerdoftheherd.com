<?php
	require 'menu.php';
	require 'convertmode0.php';
	require 'convertmode7.php';
	require 'convertbasic.php';
	require 'convertrunnable.php';
	
	function indentecho($text,$indent) {
		echo str_repeat("\t", $indent).$text."\n";
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
	
	indentecho('Preparing templates', 1);
	
	$header=file_get_contents('templates/header.html');
	$header=str_replace('%title%', '8BS%iss%: %title%', $header);
	$handle=fopen('temp/header.html','w');
	fputs($handle, $header);
	fclose($handle);
	
	$menu=new menu($thisissue);
	
	indentecho('Fetching menu data',1);
	$convertitems = $menu->fetchmenudata();
	
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
	
	foreach($convertitems as $convitem):
		switch($convitem->itemtype):
			case itemdata::MODE0:
				indentecho('Converting Mode 0 text "'.$convitem->title.'"',1);
				$convert=new convertmode0('temp/extracted/'.$thisissue.'/'.$convitem->path, $menu->issuenum, $convitem->title);
				break;
			case itemdata::MODE7:
				indentecho('Converting Mode 7 text "'.$convitem->title.'"',1);
				$convert=new convertmode7('temp/extracted/'.$thisissue.'/'.$convitem->path, $menu->issuenum, $convitem->title, true, true);
				break;
			case itemdata::BASIC:
				indentecho('Converting basic file "'.$convitem->title.'"',1);
				$convert=new convertbasic('temp/extracted/'.$thisissue.'/'.$convitem->path, $menu->issuenum, $convitem->title);
				break;
			case itemdata::STARRUN:
				indentecho('Adding placeholder for *RUNnable file "'.$convitem->title.'"',1);
				$convert=new convertrunnable($convitem->path, $menu->issuenum, $convitem->title);
				break;
			default:
				echo 'Unknown item type of '.$convitem->itemtype.' - aborting.';
				exit(1);
				break;
		endswitch;
		
		$convert->savehtml('temp/web/'.$thisissue.'/content/'.$convitem->path.'.html');
		$convitem->convpath='content/'.$convitem->path.'.html';
	endforeach;
	
	indentecho('Generating menus',1);
	$menu->generatemenus();
	
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