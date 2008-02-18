<?php
	abstract class convert {
		protected $html='';
		
		public function showhtml() {
			echo $this->html;
		}
		
		public function savehtml($filename) {
			$handle=fopen($filename,'w');
			fputs($handle, $this->html);
			fclose($handle);
		}
	}
?>