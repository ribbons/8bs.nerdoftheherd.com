<?php
	require_once 'convert.php';
	
	class convertmode0 extends convert {
		public function convertmode0($filename, $issue, $title) {
			$this->html=file_get_contents('temp/header.html');
			
			$this->html=str_replace('%navcontent%', generatenav(), $this->html);
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/mode0.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$text=file_get_contents($filename);
			
			$disptext='';
			$thisline='';
			
			$row=0;
			$column=0;
			
			$underline=false;
			
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
					case 10:
						# Line feed
						if($column == 0):
							$column=79;
						else:
							echo "Implement line feeds not at the start of a line\n";
							exit(1);
						endif;
						break;
					case 13:
						# Carriage return
						# This displays as a line feed as well unless there has just
						# been one, in which case it has no effect
						if($convert == 0 || ord($text[$convert - 1]) != 10):
							$column=79;
						else:
							$column--;
						endif;
						break;
					case 28:
						if($underline):
							$thisline.= '</span>';
							$underline=false;
						else:
							$thisline.= '<span class="uline">';
							$underline=true;
						endif;
						
						break;
					case 29:
						$convert++;
						$column--;
						
						switch($text[$convert]):
							case 'B':
								$thisline.= '<b>';
								break;
							case 'b':
								$thisline.= '</b>';
								break;
							case 'I':
								$thisline.= '<i>';
								break;
							case 'i':
								$thisline.= '</i>';
								break;
							case 'S':
								$thisline.= '<span class="super">';
								break;
							case 'W':
								$thisline.= '<span class="wide">';
								break;
							case 'Y':
								$thisline.= '<span class="subs">';
								break;
							case 's':
							case 'w':
							case 'y':
								$thisline.= '</span>';
								break;
							case '*':
								$thisline.= '<span class="inv">*</span>';
								break;
							default:
								echo 'Unknown control character: '.$text[$convert]."\n";
								exit(1);
						endswitch;
						
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
					case ($charcode >= 93 && $charcode <= 95):
						# ]^_
						$thisline.= $text[$convert];
						break;
					case 96:
						$thisline.= '£';
						break;
					case ($charcode >= 97 && $charcode <= 126):
						# a-z{|}~
						$thisline.= $text[$convert];
						break;
					# Chars 128-254 display as spaces in the Micro, but are populated
					# with special characters by default in the Master.
					# As the Micro was more popular, display these as spaces.
					case ($charcode >= 128 && $charcode <= 254):
						$thisline.= ' ';
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