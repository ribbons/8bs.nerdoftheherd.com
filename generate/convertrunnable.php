<?php
	class convertrunnable extends convert {
		public function convertrunnable($filename, $issue, $title) {
			$this->html=implode('', file('temp/header.html'));
			$this->html.=implode('', file('pages/runnable.html'));
			$this->html.=implode('', file('pages/footer.html'));
			
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/runnable.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
		}
	}
?>