<?php
	class menudata {
		public $title;
		public $items;
		
		public function menudata($title) {
			$this->title=$title;
		}
	}
	
	class itemdata {
		const MENU = 0;
		const MODE0 = 1;
		const MODE7 = 2;
		const BASIC = 3;
		const STARRUN = 4;
		
		public $itemtype;
		public $title;
		public $description;
		public $menuid;
		public $path;
		public $convpath;
		
		public function itemdata($itemtype, $title) {
			$this->itemtype=$itemtype;
			$this->title=$title;
		}
	}
	
	class menu {
		private $thisissue;
		public $issuenum;
		public $issuedate;
		private $menus;
		private $colours;
		
		function convertfilepath($dir, $file) {
			if(preg_match('/^:([02]).([A-Z%])$/',$dir,$matches)): #eg :0.S
				$drive=$matches[1];
				$dir=$matches[2];
			elseif(preg_match('/^:([02])$/',$dir,$matches)): #eg :0
				$drive=$matches[1];
				$dir='$';
			elseif(preg_match('/^([[A-Z%])$/',$dir,$matches)): #eg S
				$drive=0;
				$dir=$matches[1];
			else:
				echo 'Unexpected directory format: "'.$dir.'" - aborting';
				exit(1);
			endif;
			
			return $drive.'/'.$dir.$file;
		}
		
		function colnumtoname($colour) {
			switch($colour):
				case 1:
					return 'red';
				case 2:
					return 'lime';
				case 3:
					return 'yellow';
				case 4:
					return 'blue';
				case 5:
					return 'fuchsia';
				case 6:
					return 'aqua';
				case 7:
					return 'white';
				default:
					echo 'Unknown colour value '.$colour.' - aborting';
					exit(1);
			endswitch;
		}
		
		public function menu($thisissue) {
			$this->thisissue=$thisissue;
		}
		
		public function fetchmenudata() {
			exec('bin\bas2txt.exe /n temp\extracted\\'.$this->thisissue.'\0\$!Boot', $output, $return);
			
			if($return<>0):
				echo 'Problem converting !boot file to text';
				exit($return);
			endif;
			
			$fetchdata=file('temp\extracted\\'.$this->thisissue.'\0\$!Boot.txt', FILE_IGNORE_NEW_LINES);
			$readitems=0;
			
			foreach($fetchdata as $dataline):
				if(substr($dataline,0,5)=="DATA "): # Menu Data
					$splitdata = split(',',substr($dataline, 5));
					
					if(!isset($this->issuenum)):
						$this->issuenum = $splitdata[0];
						$this->issuedate = $splitdata[1];
					elseif($readitems > 0):
						if($splitdata[3] > 0):
							$thisitem=new itemdata(itemdata::MENU, $splitdata[0]);
							$thisitem->menuid=$splitdata[3];
							$thisitem->description='Another menu';
							$thisitem->convpath='/'.$this->thisissue.'/'.str_replace('menu1.html','','menu'.$splitdata[3].'.html');
						else:
							switch($splitdata[3]):
								case -1:
								#case 'MODE3':
								#case 'TEXT':
									$itemtype=itemdata::MODE0;
									$itemdesc='80 Column Text';
									break;
								case -2:
								#case 'MODE7':
								#case 'TTXT':
									$itemtype=itemdata::MODE7;
									$itemdesc='40 Column Text';
									break;
								#case -3:
								#case 'ARCHI':
									# 'Archive' ?
								case -4:
								#case 'CHAIN':
								#case 'BASIC':
									$itemtype=itemdata::BASIC;
									$itemdesc='Basic Program';
									break;
								#case -5:
								#case 'LOAD':
									# 'Loads BASIC' ?
								#case -6:
								#case 'LIST':
									# 'Lists Basic' ?
								#case -7:
									# 'Uses LDPIC' ?
								case -8:
									$itemtype=itemdata::STARRUN;
									$itemdesc='*RUN';
									break;
								default:
									$itemdesc='Runs Code';
									
									if(strtoupper($splitdata[3]) == '*RUN'):
										$itemtype=itemdata::STARRUN;
									else:
										echo 'Unknown action \''.$splitdata[3].'\' - aborting.';
										exit(1);
									endif;
									
									break;
							endswitch;
							
							$thisitem=new itemdata($itemtype, $splitdata[0]);
							$thisitem->path=$this->convertfilepath($splitdata[1], $splitdata[2]);
							$thisitem->description=$itemdesc;
						endif;
						
						$thismenu->items[]=$thisitem;
						$readitems--;
					else:
						$thismenu=new menudata($splitdata[0]);
						$readitems=$splitdata[1];
						$this->menus[]=$thismenu;
					endif;
				elseif(preg_match('/^([a-z])%=([0-9])/', $dataline, $matches)): # Colour Data
					$this->colours[$matches[1]]=$matches[2];
				endif;
			endforeach;
			
			# Return a flat array of all of the items to be converted
			foreach($this->menus as $menu):
				foreach($menu->items as $convitem):
					if($convitem->itemtype != itemdata::MENU):
						$convertitems[]=$convitem;
					endif;
				endforeach;
			endforeach;
			
			return $convertitems;
		}
		
		public function generatemenus() {
			$menuhtml=file_get_contents('temp/header.html').file_get_contents('templates/menu.html').file_get_contents('templates/footer.html');
			
			$menuhtml=str_replace('%stylesheetpath%', 'styles/menu.css', $menuhtml);
			$menuhtml=str_replace('%includejs%', '<script src="/common/script/menu.js" type="text/javascript"></script>', $menuhtml);
			$menuhtml=str_replace('%issdte%', $this->issuedate, $menuhtml);
			$menuhtml=str_replace('%titlecol%', $this->colours['q'], $menuhtml);
			
			$letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
			
			foreach($this->menus as $menunum => $menu):
				$thismenuhtml=str_replace('%navcontent%', generatenav($menunum == 0 ? 'discmenu' : ''), $menuhtml);
				$thismenuhtml=str_replace('%iss%', $this->issuenum, $thismenuhtml);
				$thismenuhtml=str_replace(array('%title%', '%menutitle%'), $menu->title, $thismenuhtml);
				
				$menuitemshtml='';
				
				foreach($menu->items as $menuitemnum => $menuitem):
					$menuitemshtml.= '<div><a href="'.$menuitem->convpath.'" title="'.$menuitem->description.'">  <span class="letters">'.$letters[$menuitemnum].'</span><span class="gt">&gt;</span>'.$menuitem->title.'</a></div>';
				endforeach;
				
				$thismenuhtml=str_replace('%menuitems%', $menuitemshtml, $thismenuhtml);
				
				$handle=fopen('temp/web/'.$this->thisissue.'/'.str_replace('menu1','index','menu'.($menunum + 1)).'.html','w');
				fputs($handle, $thismenuhtml);
				fclose($handle);
			endforeach;
			
			# Generate the css file for this issue's menus
			$css=file_get_contents('templates/styles/menu.css');
			
			$css=str_replace('%id%', $this->colnumtoname($this->colours['i']), $css);
			$css=str_replace('%dteiss%', $this->colnumtoname($this->colours['r']), $css);
			$css=str_replace('%title%',$this->colnumtoname($this->colours['q']), $css);
			$css=str_replace('%menutt%', $this->colnumtoname($this->colours['s']), $css);
			$css=str_replace('%border%', $this->colnumtoname($this->colours['p']), $css);
			$css=str_replace('%letters%', $this->colnumtoname($this->colours['t']), $css);
			$css=str_replace('%highlight%', $this->colnumtoname($this->colours['w']), $css);
			$css=str_replace('%items%', $this->colnumtoname($this->colours['u']), $css);
			$css=str_replace('%descript%', $this->colnumtoname($this->colours['d']), $css);
			$css=str_replace('%helptxt%', $this->colnumtoname($this->colours['v']), $css);
			
			$handle=fopen('temp/web/'.$this->thisissue.'/styles/menu.css','w');
			fputs($handle, $css);
			fclose($handle);
		}
	}
?>