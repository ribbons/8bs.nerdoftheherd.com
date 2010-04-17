<?php
	abstract class convert {
		protected $html='';
		
		public function gethtml() {
			return $this->html;
		}
		
		public function showhtml() {
			echo $this->html;
		}
		
		public function savehtml($filename) {
			$handle=fopen($filename.'.html','w');
			fputs($handle, $this->html);
			fclose($handle);
			
			return '.html';
		}
	}
?>