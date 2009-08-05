<?php
	class convertmode0 extends convert {
		public function convertmode0($filename, $issue, $title) {
			$this->html=implode('', file('temp/header.html'));
			
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/mode0.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$text=implode('',file($filename));
			$disptext='';
			
			for($convert = 0; $convert < strlen($text); $convert++):
				switch(ord($text[$convert])):
					case 13:
						$disptext.= "<br>\r";
						break;
					case 38:
						$disptext.= '&amp;';
						break;
					case 96:
						$disptext.= '£';
						break;
					default:
						$disptext.= $text[$convert];
				endswitch;
			endfor;
			
			$disptext=str_replace('  ','  ',$disptext);
			
			$this->html.='<div class="centralcol mode0">';
			$this->html.=$disptext;
			$this->html.='</div>';
			
			$this->html.=implode('', file('pages/footer.html'));
		}
	}
?>