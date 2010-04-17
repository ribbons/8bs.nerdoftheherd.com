<?php
	require_once 'convert.php';
	
	class convertbasic extends convert {
		private $infohtml='';
		private $listonly;
		
		public function convertbasic($filename, $issue, $title, $listonly) {
			$this->listonly = $listonly;
			$this->html=file_get_contents('temp/header.html');
			
			$this->html=str_replace('%navcontent%', generatenav(), $this->html);
			$this->html=str_replace('%iss%', $issue, $this->html);
			
			if($this->listonly):
				$this->html=str_replace('%title%', $title, $this->html);
			else:
				$this->html=str_replace('%title%', $title.' Listing', $this->html);
			endif;
			
			$this->html=str_replace('%stylesheetpath%', '/common/styles/mode7.css', $this->html);
			$this->html=str_replace('%includejs%', '<script src="/common/script/mode7.js" type="text/javascript"></script>', $this->html);
			
			exec('bin\bas2txt.exe /i '.$filename, $output, $return);
			
			if($return<>0):
				echo 'Problem converting basic file to text';
			else:
				# Strip ascii character 10s from the file, as these aren't used on the BBC.
				$basicfile=file_get_contents($filename.'.txt');
				$basicfile=str_replace("\n", '', $basicfile);
				$handle=fopen($filename.'.txt','w');
				fputs($handle, $basicfile);
				fclose($handle);
				
				$convert=new convertmode7($filename.'.txt', $issue, $title, false, false);
				$this->html.=$convert->gethtml();
			endif;
			
			$this->html.=file_get_contents('templates/footer.html');
			
			if(!$this->listonly):
				# Generate an information page about this basic file
				$this->infohtml=file_get_contents('temp/header.html');
				$this->infohtml.=file_get_contents('templates/basic.html');
				$this->infohtml.=file_get_contents('templates/footer.html');
				
				$this->infohtml=str_replace('%navcontent%', generatenav(), $this->infohtml);
				$this->infohtml=str_replace('%iss%', $issue, $this->infohtml);
				$this->infohtml=str_replace('%title%', $title, $this->infohtml);
				$this->infohtml=str_replace('%stylesheetpath%', '/common/styles/infopage.css', $this->infohtml);
				$this->infohtml=str_replace('%includejs%', '', $this->infohtml);
				$this->infohtml=str_replace('%listinglink%', rawurlencode(basename($filename).'-list.html'), $this->infohtml);
			endif;
		}
		
		public function savehtml($filename) {
			$handle=fopen($filename.'-list.html','w');
			fputs($handle, $this->html);
			fclose($handle);
			
			if($this->listonly):
				return '-list.html';
			else:
				$handle=fopen($filename.'.html','w');
				fputs($handle, $this->infohtml);
				fclose($handle);
				
				return '.html';
			endif;
		}
	}
?>