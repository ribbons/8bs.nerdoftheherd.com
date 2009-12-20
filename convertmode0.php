<?php
	require_once 'convert.php';
	
	class convertmode0 extends convert {
		public function convertmode0($filename, $issue, $title) {
			$this->html=file_get_contents('temp/header.html');
			
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/mode0.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$text=file_get_contents($filename);
			$disptext='';
			$row=0;
			$column=0;
			
			for($convert = 0; $convert < strlen($text); $convert++):
				$charcode = ord($text[$convert]);
				
				switch($charcode):
					case 9:
						echo "Control character? 9\n";
						$disptext.= ' ';
						break;
					case 13:
						# Line break
						$column=79;
						break;
					case 28:
						echo "Control character? 28\n";
						$disptext.= ' ';
						break;
					case 29:
						echo "Control character? 29\n";
						$disptext.= ' ';
						break;
					case ($charcode >= 32 && $charcode <= 37):
						# {space}!"#$%
						$disptext.= $text[$convert];
						break;
					case 38:
						$disptext.= '&amp;';
						break;
					case ($charcode >= 39 && $charcode <= 59):
						# '()*+,-./0-9:;
						$disptext.= $text[$convert];
						break;
					case 60:
						$disptext.= '&lt;';
						break;
					case 61:
						# =
						$disptext.= $text[$convert];
						break;
					case 62:
						$disptext.= '&gt;';
						break;
					case ($charcode >= 63 && $charcode <= 91):
						# ?@A-Z[
						$disptext.= $text[$convert];
						break;
					case 93:
						# ]
						$disptext.= $text[$convert];
						break;
					case 95:
						# _
						$disptext.= $text[$convert];
						break;
					case 96:
						$disptext.= '£';
						break;
					case ($charcode >= 97 && $charcode <= 122):
						# a-z
						$disptext.= $text[$convert];
						break;
					case 124:
						# |
						$disptext.= $text[$convert];
						break;
					case 126:
						# ~
						$disptext.= $text[$convert];
						break;
					default:
						echo 'Unknown character value '.$charcode.' at line '.$row.' column '.$column." - aborting\n";
						#$disptext.= ' ';
						exit(1);
				endswitch;
				
				$column++;
				
				if($column > 79):
					$disptext.= "<br>\r";
					$row++;
					$column=0;
				endif;
			endfor;
			
			$disptext=str_replace('  ','  ',$disptext);
			
			$this->html.='<div class="centralcol mode0">';
			$this->html.=$disptext;
			$this->html.='</div>';
			
			$this->html.=file_get_contents('templates/footer.html');
		}
	}
?>