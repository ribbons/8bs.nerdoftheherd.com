<?php
	function GetScrollText($file, $thisissue, $mode, $title) {
		FlOutput('Converting Mode '.$mode.' text "'.substr($file,2).'"',2);
		
		$handle=fopen('http://127.0.0.1'.$_SERVER['REQUEST_URI'].'mode'.$mode.'/?file=../temp/'.$file.'&title='.rawurlencode($title).'&type=scroll','r');
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
		
		exec('bin\bas2txt.exe /i temp/'.$file, $output, $return);
		
		if($return<>0):
			echo 'Problem converting basic file to text';
			exit;
		endif;
		
		$converted=implode('',file('http://127.0.0.1'.$_SERVER['REQUEST_URI'].'mode7/?file=../temp/'.$file.'.txt&title='.rawurlencode($title).'&type=nonscroll'));
		
		$whandle=fopen('../'.$thisissue.'/content/'.$file.'.html','w');
		fputs($whandle, $converted);
		fclose($whandle);
	}
	
	function GetRun($file, $thisissue, $title) {
		FlOutput('Adding placeholder for *RUNnable file "'.substr($file,2).'"',2);
		
		$handle=fopen('http://127.0.0.1'.$_SERVER['REQUEST_URI'].'starrun.php?file=temp/'.$file.'&title='.rawurlencode($title),'r');
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