<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?php echo $_GET['title']; ?></title>
  <style type="text/css">
    body {
	    background-color: black;
	    text-align: center;
    }
    
    table {
	    color: white;
	    font: 30px "ModeSeven", "Courier New", "Courier", monospace;
	    text-align: left;
	    border: 0px;
	    border-collapse: collapse;
	    margin-left: auto;
	    margin-right: auto;
	    width: 760px;
    }
    
    td {
    	margin: 0px;
    	padding: 0px;
    }
  </style>
  </head>
  
  <body>
    <table><tr><td>
<?php
	# Output a basic program as if it had been LISTO 7'd in Mode 7
	# Colour could be implemented
	# Mode 1 / mode 0 version needed?

	exec('bin\bas2txt.exe /i '.$_GET['file'], $output, $return);
	
	if($return<>0):
		echo 'Problem converting basic file to text';
		exit;
	endif;

	$handle=fopen($_GET['file'].'.txt','r');
	$returned=fgets($handle,5000);
	$text='';
	
	while($returned<>''):
		# Add a space in after the line number
		$returned=substr_replace($returned, " ", 5, 0);
	
		while(strlen($returned)>40):
			$text.=substr($returned,0,40)."\r\n";
			$returned=substr($returned,40);
		endwhile;
		
		$text.=$returned;
		$returned=fgets($handle,5000);
	endwhile;
	
	$text=str_replace("\r\n ","\r\n&nbsp;",$text);
	$text=str_replace("  ","&nbsp;&nbsp;",$text);
	echo str_replace("\r\n",'<br />'."\r\n",$text);
?>
    </td></tr></table>
  </body>
</html>