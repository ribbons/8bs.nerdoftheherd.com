<?php
	require_once 'convert.php';
	
	class convertrunnable extends convert {
		public function convertrunnable($filename, $issue, $title) {
			$this->html=file_get_contents('temp/header.html');
			$this->html.=file_get_contents('templates/runnable.html');
			$this->html.=file_get_contents('templates/footer.html');
			
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/runnable.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
		}
	}
?>