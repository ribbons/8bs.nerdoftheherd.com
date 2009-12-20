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
			$thisline='';
			$row=0;
			$column=0;
			
			for($convert = 0; $convert < strlen($text); $convert++):
				$charcode = ord($text[$convert]);
				
				switch($charcode):
					case 9:
						# Tab - conv to spaces in the same way as the 80 col scroller
						do {
							if($column > 79):
								$disptext.= rtrim($thisline)."<br>\r";
								$thisline='';
								$row++;
								$column=0;
							endif;
							
							$thisline.=' ';
							$column++;
						} while(($column + 1) % 8 != 0);
						
						$column--;
						break;
					case 13:
						# Line break
						$column=79;
						break;
					case 28:
						echo "Control character? 28\n";
						$thisline.= ' ';
						break;
					case 29:
						echo "Control character? 29\n";
						$thisline.= ' ';
						break;
					case ($charcode >= 32 && $charcode <= 37):
						# {space}!"#$%
						$thisline.= $text[$convert];
						break;
					case 38:
						$thisline.= '&amp;';
						break;
					case ($charcode >= 39 && $charcode <= 59):
						# '()*+,-./0-9:;
						$thisline.= $text[$convert];
						break;
					case 60:
						$thisline.= '&lt;';
						break;
					case 61:
						# =
						$thisline.= $text[$convert];
						break;
					case 62:
						$thisline.= '&gt;';
						break;
					case ($charcode >= 63 && $charcode <= 91):
						# ?@A-Z[
						$thisline.= $text[$convert];
						break;
					case 93:
						# ]
						$thisline.= $text[$convert];
						break;
					case 95:
						# _
						$thisline.= $text[$convert];
						break;
					case 96:
						$thisline.= '£';
						break;
					case ($charcode >= 97 && $charcode <= 122):
						# a-z
						$thisline.= $text[$convert];
						break;
					case 124:
						# |
						$thisline.= $text[$convert];
						break;
					case 126:
						# ~
						$thisline.= $text[$convert];
						break;
					default:
						echo 'Unknown character value '.$charcode.' at line '.$row.' column '.$column." - aborting\n";
						exit(1);
				endswitch;
				
				$column++;
				
				if($column > 79):
					$disptext.= rtrim($thisline)."<br>\r";
					$thisline='';
					$row++;
					$column=0;
				endif;
			endfor;
			
			$disptext.= rtrim($thisline);
			$disptext=str_replace("\r ","\r ",$disptext);
			$disptext=str_replace('  ','  ',$disptext);
			
			$this->html.='<div class="centralcol mode0">';
			$this->html.=$disptext;
			$this->html.='</div>';
			
			$this->html.=file_get_contents('templates/footer.html');
		}
	}
?>