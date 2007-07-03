<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?=$_GET['title']?></title>
  <style type="text/css">
    body {
	    background-color: black;
	    text-align: center;
    }
    
    table {
	    color: white;
	    font: 15px "Courier New", "Courier", monospace;
	    text-align: left;
	    border: 0px;
	    border-collapse: collapse;
	    margin-left: auto;
	    margin-right: auto;
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
	$handle=fopen($_GET['file'],'r');
	
	$returned=fread($handle,5000);
	
	while($returned<>''):
		$text.=$returned;
		$returned=fread($handle,5000);
	endwhile;
	
	echo str_replace(chr(13),'<br />'.chr(13),$text);
?>
    </td></tr></table>
  </body>
</html>