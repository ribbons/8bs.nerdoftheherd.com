<?php
	require 'menu.php';
	require 'convertmode0.php';
	require 'convertmode7.php';
	require 'convertbasic.php';
	require 'convertldpic.php';
	require 'convertrunnable.php';
	
	function indentecho($text,$indent) {
		echo str_repeat("\t", $indent).$text."\n";
	}
	
	function generatenav($page = '') {
		$navhtml = '<div id="about">';
		
		if($page == 'about'):
			$navhtml.= '<span class="current">';
		else:
			$navhtml.= '<a href="/about.html" title="About This Conversion">';
		endif;
		
		$navhtml.= 'About';
		
		if($page == 'about'):
			$navhtml.= '</span>';
		else:
			$navhtml.= '</a>';
		endif;
		
		$navhtml.= '</div><div id="crumb">';
		
		if($page == 'index'):
			$navhtml.= '<span class="current">';
		else:
			$navhtml.= '<a href="/" title="8BS Magazines Index">';
		endif;
		
		$navhtml.='Index';
		
		if($page == 'index'):
			$navhtml.= '</span>';
		else:
			$navhtml.='</a>';
		endif;
		
		if($page == '' || $page == 'discmenu'):
			$navhtml.=' &gt; ';
			
			if($page == 'discmenu'):
				$navhtml.= '<span class="current">';
			else:
				$navhtml.='<a href="/8BS%iss%/">';
			endif;
			
			$navhtml.='8BS%iss%';
			
			if($page == 'discmenu'):
				$navhtml.= '</span>';
			else:
				$navhtml.='</a> &gt; <span class="current">%title%</span>';
			endif;
		endif;
		
		$navhtml.= '</div>';
		
		return $navhtml;
	}
	
	$issuesindexlist = '';
	
	$convertissues=array('8BS66', '8BS65', '8BS64', '8BS63', '8BS62', '8BS61', '8BS60', '8BS59','8BS58','8BS57-2','8BS57-1',
	                     '8BS56-2', '8BS56-1', '8BS55-2', '8BS55-1', '8BS54-2', '8BS54-1', '8BS53-2', '8BS53-1');
	
	foreach($convertissues as $thisissue):
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
			$filepath='temp/extracted/'.$thisissue.'/'.$convitem->path;
			
			if(!file_exists($filepath)):
				echo 'File "'.$filepath.'" does not exist - aborting.';
				exit(1);
			endif;
			
			switch($convitem->itemtype):
				case itemdata::MODE0:
					indentecho('Converting Mode 0 text "'.$convitem->title.'"',1);
					$convert=new convertmode0($filepath, $menu->issuenum, $convitem->title);
					break;
				case itemdata::MODE7:
					indentecho('Converting Mode 7 text "'.$convitem->title.'"',1);
					$convert=new convertmode7($filepath, $menu->issuenum, $convitem->title, true, true);
					break;
				case itemdata::RUNBASIC:
					indentecho('Converting basic file "'.$convitem->title.'"',1);
					$convert=new convertbasic($filepath, $menu->issuenum, $convitem->title, false);
					break;
				case itemdata::LISTBASIC:
					indentecho('Converting basic file "'.$convitem->title.'"',1);
					$convert=new convertbasic($filepath, $menu->issuenum, $convitem->title, true);
					break;
				case itemdata::LDPIC:
					indentecho('Converting LdPic image "'.$convitem->title.'"',1);
					$convert=new convertldpic($filepath, $menu->issuenum, $convitem->title);
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
			
			$linkext = $convert->savehtml('temp/web/'.$thisissue.'/content/'.$convitem->path);
			$convitem->convpath='content/'.str_replace('%2F', '/', rawurlencode($convitem->path)).$linkext;
		endforeach;
		
		indentecho('Generating menus',1);
		$menu->generatemenus();
		
		$issuesindexlist = '<li><a href="/'.$thisissue.'/">Issue '.$menu->issuenum.'</a> - '.$menu->issuedate.'</li>'.$issuesindexlist;
	endforeach;
	
	indentecho('Generating site level pages', 0);
	indentecho('About page', 1);
	
	$aboutpage = file_get_contents('templates/header.html').file_get_contents('templates/about.html').file_get_contents('templates/footer.html');
	$aboutpage = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $aboutpage);
	$aboutpage = str_replace('%includejs%', '', $aboutpage);
	$aboutpage = str_replace('%title%', 'About this conversion', $aboutpage);
	$aboutpage = str_replace('%navcontent%', generatenav('about'), $aboutpage);
	
	$handle = fopen('temp/web/about.html', 'w');
	fputs($handle, $aboutpage);
	fclose($handle);
	
	indentecho('Magazines index', 1);
	
	$mainindex = file_get_contents('templates/header.html').file_get_contents('templates/index.html').file_get_contents('templates/footer.html');
	$mainindex = str_replace('%stylesheetpath%', '/common/styles/infopage.css', $mainindex);
	$mainindex = str_replace('%includejs%', '', $mainindex);
	$mainindex = str_replace('%title%', '8-Bit Software Magazines Index', $mainindex);
	$mainindex = str_replace('%navcontent%', generatenav('index'), $mainindex);
	$mainindex = str_replace('%issueslist%', $issuesindexlist, $mainindex);
	
	$handle = fopen('temp/web/index.html', 'w');
	fputs($handle, $mainindex);
	fclose($handle);
?>