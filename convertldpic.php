<?php
	require_once 'convert.php';
	
	class convertldpic extends convert {
		private $sourcename;
		
		public function convertldpic($filename, $issue, $title) {
			$this->sourcename = $filename;
			$this->html=file_get_contents('temp/header.html');
			
			$this->html=str_replace('%navcontent%', generatenav(), $this->html);
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%stylesheetpath%', '/common/styles/infopage.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$this->html.='<div><img src="'.rawurlencode(basename($filename)).'.png" alt="'.htmlspecialchars($title).'" width="640" height="512"></div>';
			
			copy($filename, $filename.'.bbg.');
			exec('bin\Beebview.exe --save "'.str_replace('/', '\\', $filename).'.bbg"', $output, $return);
			
			if($return != 0):
				echo 'Problem converting LdPic image to bitmap';
				exit($return);
			endif;
			
			$this->html.=file_get_contents('templates/footer.html');
		}
		
		public function savehtml($filename) {
			# Convert the bmp produced by Beebview into a png in the output folder
			exec('convert "'.$this->sourcename.'.bmp" "'.$filename.'.png"', $output, $return);
			
			if($return != 0):
				echo 'Problem converting bitmap to png';
				exit($return);
			endif;
			
			return parent::savehtml($filename);
		}
	}
?>