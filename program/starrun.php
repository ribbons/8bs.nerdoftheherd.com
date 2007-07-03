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
		font: 30px "ModeSeven", "Courier New", "Courier", monospace;
		text-align: left;
		border: 0px;
		border-collapse: collapse;
		margin-left: auto;
		margin-right: auto;
		width: 760px;
	}

	.yellow {
		color: yellow;
	}

	.red {
		color: red;
	}

	.cyan {
		color: cyan;
	}

	.green {
		color: #00ff00;
	}

	td {
		margin: 0px;
		padding: 0px;
	}
  </style>
  </head>
  
  <body>
    <table><tr><td>
      <p class="yellow">The file <span class="red"><?=$_GET['title']?></span> is a binary machine code file designed to run on a BBC.</p>
      <p class="cyan">Unfortunately there is no sensible way of representating it on the internet at the moment.</p>
      <p class="green">To view it, you will need to download the disk image of this issue, and either view
        it on a real BBC or on an emulator.</p>
    </td></tr></table>
  </body>
</html>