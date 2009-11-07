<?php
	class convertbasic extends convert {
		public function convertbasic($filename, $issue, $title) {
			$this->html=file_get_contents('temp/header.html');
			
			$this->html=str_replace('%iss%', $issue, $this->html);
			$this->html=str_replace('%title%', $title, $this->html);
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
		}
	}
?>