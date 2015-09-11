<?php
	abstract class convert {
		protected $html='';
		
		public function gethtml() {
			return $this->html;
		}
		
		public function showhtml() {
			echo $this->html;
		}
	}
?>
