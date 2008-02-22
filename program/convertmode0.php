<?php
	class convertmode0 extends convert {
		public function convertmode0($filename, $title) {
			$this->html=implode('', file('temp/header.html'));
			
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%commonrel%', '../../', $this->html);
			$this->html=str_replace('%stylesheetpath%', '../../../common/mode0.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$text=implode('',file($filename));
			
			$text=str_replace('&','&amp;',$text);
			$text=str_replace('  ','&nbsp;&nbsp;',$text);
			$text=str_replace("\r","<br />\r",$text);
			
			$this->html.='<div class="centralcol mode0">';
			$this->html.=$text;
			$this->html.='</div>';
			
			$this->html.=implode('', file('pages/footer.html'));
		}
	}
?>