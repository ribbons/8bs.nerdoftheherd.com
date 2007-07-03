<?php
	function GetScrollText($file, $thisissue, $mode, $title) {
		FlOutput('Converting Mode '.$mode.' text "'.substr($file,2).'"',2);
		
		$handle=fopen('http://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'].'mode'.$mode.'/?file=../temp/'.$file.'&title='.rawurlencode($title),'r');
		$whandle=fopen('../'.$thisissue.'/content/'.$file.'.html','w');
		
		$returned=fread($handle,5000);
		
		while($returned<>''):
			fputs($whandle, $returned);	

			$returned=fread($handle,5000);
		endwhile;
		
		fclose($handle);
		fclose($whandle);
	}

	function GetBasic($file, $thisissue, $mode, $title) {
		FlOutput('Converting basic file "'.substr($file,2).'"',2);

		$handle=fopen('http://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'].'basic.php?file=temp/'.$file.'&title='.rawurlencode($title),'r');
		$whandle=fopen('../'.$thisissue.'/content/'.$file.'.html','w');
		
		$returned=fread($handle,5000);
		
		while($returned<>''):
			fputs($whandle, $returned);	

			$returned=fread($handle,5000);
		endwhile;
		
		fclose($handle);
		fclose($whandle);
	}
	
	function GetRun($file, $thisissue, $title) {
		FlOutput('Adding placeholder for *RUNnable file "'.substr($file,2).'"',2);
		
		$handle=fopen('http://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'].'starrun.php?file=temp/'.$file.'&title='.rawurlencode($title),'r');
		$whandle=fopen('../'.$thisissue.'/content/'.$file.'.html','w');
		
		$returned=fread($handle,5000);
		
		while($returned<>''):
			fputs($whandle, $returned);	

			$returned=fread($handle,5000);
		endwhile;
		
		fclose($handle);
		fclose($whandle);
	}
?>