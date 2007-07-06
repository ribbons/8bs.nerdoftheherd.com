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
	$text=implode('',file($_GET['file']));
	
	$text=str_replace('  ','&nbsp;&nbsp;',$text);
	$text=str_replace("\r","<br />\r",$text);
	
	echo $text;
?>
    </td></tr></table>
  </body>
</html>