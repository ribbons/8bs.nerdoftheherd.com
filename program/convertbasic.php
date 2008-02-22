<?php
	class convertbasic extends convert {
		public function convertbasic($filename, $title) {
			$this->html=implode('', file('temp/header.html'));
			
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%commonrel%', '../../', $this->html);
			$this->html=str_replace('%stylesheetpath%', '../../../common/mode7.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			exec('bin\bas2txt.exe /i '.$filename, $output, $return);
			
			if($return<>0):
				echo 'Problem converting basic file to text';
			else:
				# Strip ascii character 10s from the file, as these aren't used on the BBC.
				$basicfile=implode('', file($filename.'.txt'));
				$basicfile=str_replace("\n", '', $basicfile);
				$handle=fopen($filename.'.txt','w');
				fputs($handle, $basicfile);
				fclose($handle);
				
				$convert=new convertmode7($filename.'.txt', $title, false, false);
				$this->html.=$convert->gethtml();
			endif;
			
			$this->html.=implode('', file('pages/footer.html'));
		}
	}
?>