<?php
	class convertmode7 extends convert {
		private $tokenised;
		private $textcolours;
		private $bkgdcolours;
		
		public function convertmode7($filename, $title, $trimscroller) {
			$this->html=implode('', file('temp/header.html'));
			
			$this->html=str_replace('%title%', $title, $this->html);
			$this->html=str_replace('%commonrel%', '../../', $this->html);
			$this->html=str_replace('%stylesheetpath%', '../../../common/mode7.css', $this->html);
			$this->html=str_replace('%includejs%', '', $this->html);
			
			$this->tokeniseinput($filename, $trimscroller);
			$this->generatehtml();
			
			$this->html.=implode('', file('pages/footer.html'));
		}
		
		private function tokeniseinput($filename, $trimscroller) {
			define('MODE_TEXT', 1);
			define('MODE_GRAPHICS', 2);
			define('COL_BLACK', 1);
			define('COL_RED', 2);
			define('COL_GREEN', 3);
			define('COL_YELLOW', 4);
			define('COL_BLUE', 5);
			define('COL_MAGENTA', 6);
			define('COL_CYAN', 7);
			define('COL_WHITE', 8);
			
			if($trimscroller):
				$startpos=256;
			else:
				$startpos=0;
			endif;
			
			$row=0;
			$column=0;
			$mode=MODE_TEXT;
			$forecolour=COL_WHITE;
			$backcolour=COL_BLACK;
			
			$file=implode('', file($filename));
			
			for($filepos=$startpos; $filepos < strlen($file); $filepos++):
				switch(ord($file[$filepos])):
					case 32:
					case 160:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						break;
					case 33:
					case 161:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_!';
						else:
							$this->tokenised[$row][$column]='GRAP_1';
						endif;
						break;
					case 34:
					case 162:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_"';
						else:
							$this->tokenised[$row][$column]='GRAP_2';
						endif;
						break;
					case 35:
					case 163:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_£';
						else:
							$this->tokenised[$row][$column]='GRAP_3';
						endif;
						break;
					case 36:
					case 164:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_$';
						else:
							$this->tokenised[$row][$column]='GRAP_4';
						endif;
						break;
					case 37:
					case 165:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_%';
						else:
							$this->tokenised[$row][$column]='GRAP_5';
						endif;
						break;
					case 38:
					case 166:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_&';
						else:
							$this->tokenised[$row][$column]='GRAP_6';
						endif;
						break;
					case 39:
					case 167:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_\'';
						else:
							$this->tokenised[$row][$column]='GRAP_7';
						endif;
						break;
					case 40:
					case 168:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_(';
						else:
							$this->tokenised[$row][$column]='GRAP_8';
						endif;
						break;
					case 41:
					case 169:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_)';
						else:
							$this->tokenised[$row][$column]='GRAP_9';
						endif;
						break;
					case 42:
					case 170:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_*';
						else:
							$this->tokenised[$row][$column]='GRAP_10';
						endif;
						break;
					case 43:
					case 171:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_+';
						else:
							$this->tokenised[$row][$column]='GRAP_11';
						endif;
						break;
					case 44:
					case 172:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_,';
						else:
							$this->tokenised[$row][$column]='GRAP_12';
						endif;
						break;
					case 45:
					case 173:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_-';
						else:
							$this->tokenised[$row][$column]='GRAP_13';
						endif;
						break;
					case 46:
					case 174:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_.';
						else:
							$this->tokenised[$row][$column]='GRAP_14';
						endif;
						break;
					case 47:
					case 175:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_/';
						else:
							$this->tokenised[$row][$column]='GRAP_15';
						endif;
						break;
					case 48:
					case 176:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_0';
						else:
							$this->tokenised[$row][$column]='GRAP_16';
						endif;
						break;
					case 49:
					case 177:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_1';
						else:
							$this->tokenised[$row][$column]='GRAP_17';
						endif;
						break;
					case 50:
					case 178:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_2';
						else:
							$this->tokenised[$row][$column]='GRAP_18';
						endif;
						break;
					case 51:
					case 179:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_3';
						else:
							$this->tokenised[$row][$column]='GRAP_19';
						endif;
						break;
					case 52:
					case 180:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_4';
						else:
							$this->tokenised[$row][$column]='GRAP_20';
						endif;
						break;
					case 53:
					case 181:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_5';
						else:
							$this->tokenised[$row][$column]='GRAP_21';
						endif;
						break;
					case 54:
					case 182:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_6';
						else:
							$this->tokenised[$row][$column]='GRAP_22';
						endif;
						break;
					case 55:
					case 183:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_7';
						else:
							$this->tokenised[$row][$column]='GRAP_23';
						endif;
						break;
					case 56:
					case 184:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_8';
						else:
							$this->tokenised[$row][$column]='GRAP_24';
						endif;
						break;
					case 57:
					case 185:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_9';
						else:
							$this->tokenised[$row][$column]='GRAP_25';
						endif;
						break;
					case 58:
					case 186:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_:';
						else:
							$this->tokenised[$row][$column]='GRAP_26';
						endif;
						break;
					case 59:
					case 187:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_;';
						else:
							$this->tokenised[$row][$column]='GRAP_27';
						endif;
						break;
					case 60:
					case 188:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_<';
						else:
							$this->tokenised[$row][$column]='GRAP_28';
						endif;
						break;
					case 61:
					case 189:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_=';
						else:
							$this->tokenised[$row][$column]='GRAP_29';
						endif;
						break;
					case 62:
					case 190:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_>';
						else:
							$this->tokenised[$row][$column]='GRAP_30';
						endif;
						break;
					case 63:
					case 191:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_?';
						else:
							$this->tokenised[$row][$column]='GRAP_31';
						endif;
						break;
					case 64:
					case 192:
						$this->tokenised[$row][$column]='CHAR_@';
						break;
					case 65:
					case 193:
						$this->tokenised[$row][$column]='CHAR_A';
						break;
					case 66:
					case 194:
						$this->tokenised[$row][$column]='CHAR_B';
						break;
					case 67:
					case 195:
						$this->tokenised[$row][$column]='CHAR_C';
						break;
					case 68:
					case 196:
						$this->tokenised[$row][$column]='CHAR_D';
						break;
					case 69:
					case 197:
						$this->tokenised[$row][$column]='CHAR_E';
						break;
					case 70:
					case 198:
						$this->tokenised[$row][$column]='CHAR_F';
						break;
					case 71:
					case 199:
						$this->tokenised[$row][$column]='CHAR_G';
						break;
					case 72:
					case 200:
						$this->tokenised[$row][$column]='CHAR_H';
						break;
					case 73:
					case 201:
						$this->tokenised[$row][$column]='CHAR_I';
						break;
					case 74:
					case 202:
						$this->tokenised[$row][$column]='CHAR_J';
						break;
					case 75:
					case 203:
						$this->tokenised[$row][$column]='CHAR_K';
						break;
					case 76:
					case 204:
						$this->tokenised[$row][$column]='CHAR_L';
						break;
					case 77:
					case 205:
						$this->tokenised[$row][$column]='CHAR_M';
						break;
					case 78:
					case 206:
						$this->tokenised[$row][$column]='CHAR_N';
						break;
					case 79:
					case 207:
						$this->tokenised[$row][$column]='CHAR_O';
						break;
					case 80:
					case 208:
						$this->tokenised[$row][$column]='CHAR_P';
						break;
					case 81:
					case 209:
						$this->tokenised[$row][$column]='CHAR_Q';
						break;
					case 82:
					case 210:
						$this->tokenised[$row][$column]='CHAR_R';
						break;
					case 83:
					case 211:
						$this->tokenised[$row][$column]='CHAR_S';
						break;
					case 84:
					case 212:
						$this->tokenised[$row][$column]='CHAR_T';
						break;
					case 85:
					case 213:
						$this->tokenised[$row][$column]='CHAR_U';
						break;
					case 86:
					case 214:
						$this->tokenised[$row][$column]='CHAR_V';
						break;
					case 87:
					case 215:
						$this->tokenised[$row][$column]='CHAR_W';
						break;
					case 88:
					case 216:
						$this->tokenised[$row][$column]='CHAR_X';
						break;
					case 89:
					case 137:
						$this->tokenised[$row][$column]='CHAR_Y';
						break;
					case 90:
					case 218:
						$this->tokenised[$row][$column]='CHAR_Z';
						break;
					case 91:
					case 219:
						$this->tokenised[$row][$column]='CHAR_[';
						break;
					case 92:
					case 220:
						$this->tokenised[$row][$column]='CHAR_\\';
						break;
					case 93:
					case 221:
						$this->tokenised[$row][$column]='CHAR_]';
						break;
					case 94:
					case 222:
						$this->tokenised[$row][$column]='CHAR_^';
						break;
					case 95:
					case 223:
						$this->tokenised[$row][$column]='CHAR__';
						break;
					case 96:
					case 224:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_#';
						else:
							$this->tokenised[$row][$column]='GRAP_32';
						endif;
						break;
					case 97:
					case 225:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_a';
						else:
							$this->tokenised[$row][$column]='GRAP_33';
						endif;
						break;
					case 98:
					case 226:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_b';
						else:
							$this->tokenised[$row][$column]='GRAP_34';
						endif;
						break;
					case 99:
					case 227:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_c';
						else:
							$this->tokenised[$row][$column]='GRAP_35';
						endif;
						break;
					case 100:
					case 228:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_d';
						else:
							$this->tokenised[$row][$column]='GRAP_36';
						endif;
						break;
					case 101:
					case 229:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_e';
						else:
							$this->tokenised[$row][$column]='GRAP_37';
						endif;
						break;
					case 102:
					case 230:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_f';
						else:
							$this->tokenised[$row][$column]='GRAP_38';
						endif;
						break;
					case 103:
					case 231:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_g';
						else:
							$this->tokenised[$row][$column]='GRAP_39';
						endif;
						break;
					case 104:
					case 232:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_h';
						else:
							$this->tokenised[$row][$column]='GRAP_40';
						endif;
						break;
					case 105:
					case 233:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_i';
						else:
							$this->tokenised[$row][$column]='GRAP_41';
						endif;
						break;
					case 106:
					case 234:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_j';
						else:
							$this->tokenised[$row][$column]='GRAP_42';
						endif;
						break;
					case 107:
					case 235:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_k';
						else:
							$this->tokenised[$row][$column]='GRAP_43';
						endif;
						break;
					case 108:
					case 236:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_l';
						else:
							$this->tokenised[$row][$column]='GRAP_44';
						endif;
						break;
					case 109:
					case 237:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_m';
						else:
							$this->tokenised[$row][$column]='GRAP_45';
						endif;
						break;
					case 110:
					case 238:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_n';
						else:
							$this->tokenised[$row][$column]='GRAP_46';
						endif;
						break;
					case 111:
					case 239:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_o';
						else:
							$this->tokenised[$row][$column]='GRAP_47';
						endif;
						break;
					case 112:
					case 240:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_p';
						else:
							$this->tokenised[$row][$column]='GRAP_48';
						endif;
						break;
					case 113:
					case 241:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_q';
						else:
							$this->tokenised[$row][$column]='GRAP_49';
						endif;
						break;
					case 114:
					case 242:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_r';
						else:
							$this->tokenised[$row][$column]='GRAP_50';
						endif;
						break;
					case 115:
					case 243:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_s';
						else:
							$this->tokenised[$row][$column]='GRAP_51';
						endif;
						break;
					case 116:
					case 244:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_t';
						else:
							$this->tokenised[$row][$column]='GRAP_52';
						endif;
						break;
					case 117:
					case 245:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_u';
						else:
							$this->tokenised[$row][$column]='GRAP_53';
						endif;
						break;
					case 118:
					case 246:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_v';
						else:
							$this->tokenised[$row][$column]='GRAP_54';
						endif;
						break;
					case 119:
					case 247:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_w';
						else:
							$this->tokenised[$row][$column]='GRAP_55';
						endif;
						break;
					case 120:
					case 248:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_x';
						else:
							$this->tokenised[$row][$column]='GRAP_56';
						endif;
						break;
					case 121:
					case 249:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_y';
						else:
							$this->tokenised[$row][$column]='GRAP_57';
						endif;
						break;
					case 122:
					case 250:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_z';
						else:
							$this->tokenised[$row][$column]='GRAP_58';
						endif;
						break;
					case 123:
					case 251:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_{';
						else:
							$this->tokenised[$row][$column]='GRAP_59';
						endif;
						break;
					case 124:
					case 252:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_:';
						else:
							$this->tokenised[$row][$column]='GRAP_60';
						endif;
						break;
					case 125:
					case 253:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_}';
						else:
							$this->tokenised[$row][$column]='GRAP_61';
						endif;
						break;
					case 126:
					case 254:
						if($mode==MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_~';
						else:
							$this->tokenised[$row][$column]='GRAP_62';
						endif;
						break;
					case 255:
						$this->tokenised[$row][$column]='GRAP_63';
						break;
					case 129:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_RED;
						break;
					default:
					case 130:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_GREEN;
						break;
					default:
					case 131:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_YELLOW;
						break;
					default:
					case 132:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_BLUE;
						break;
					default:
					case 133:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_MAGENTA;
						break;
					default:
					case 134:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_CYAN;
						break;
					default:
					case 135:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_TEXT;
						$forecolour=COL_WHITE;
						break;
					case 145:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_RED;
						break;
					default:
					case 146:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_GREEN;
						break;
					default:
					case 147:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_YELLOW;
						break;
					default:
					case 148:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_BLUE;
						break;
					default:
					case 149:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_MAGENTA;
						break;
					default:
					case 150:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_CYAN;
						break;
					default:
					case 151:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=MODE_GRAPHICS;
						$forecolour=COL_WHITE;
						break;
					case 156:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$backcolour=COL_BLACK;
						break;
					case 157:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$backcolour=$forecolour;
						break;
					default:
						echo '<p>Unknown character value '.ord($file[$filepos]).' - unable to tokenise.</p>';
						$this->tokenised[$row][$column]='CHAR_SPACE';
				endswitch;
				
				$this->textcolours[$row][$column]=$forecolour;
				$this->bkgdcolours[$row][$column]=$backcolour;
				
				$column++;
				
				if($column>39):
					$column=0;
					$row++;
					$mode=MODE_TEXT;
					$forecolour=COL_WHITE;
					$backcolour=COL_BLACK;
				endif;
			endfor;
		}
		
		private function generatehtml() {
			$this->html.='<table class="mode7">';
			
			foreach($this->tokenised as $lnkey => $line):
				$this->html.='<tr>';
				
				foreach($line as $colkey => $character):
					$this->html.='<td style="color: '.$this->translatecolour($this->textcolours[$lnkey][$colkey]);
					$this->html.='; background-color: '.$this->translatecolour($this->bkgdcolours[$lnkey][$colkey]).';">';
					
					if(substr($character, 0, 5)=='CHAR_'):
						switch($character):
							case 'CHAR_!':
								$this->html.='!';
								break;
							case 'CHAR_"':
								$this->html.='"';
								break;
							case 'CHAR_#':
								$this->html.='#';
								break;
							case 'CHAR_$':
								$this->html.='$';
								break;
							case 'CHAR_%':
								$this->html.='%';
								break;
							case 'CHAR_&':
								$this->html.='&';
								break;
							case 'CHAR_\'':
								$this->html.='\'';
								break;
							case 'CHAR_(':
								$this->html.='(';
								break;
							case 'CHAR_)':
								$this->html.=')';
								break;
							case 'CHAR_*':
								$this->html.='*';
								break;
							case 'CHAR_+':
								$this->html.='+';
								break;
							case 'CHAR_,':
								$this->html.=',';
								break;
							case 'CHAR_-':
								$this->html.='-';
								break;
							case 'CHAR_.':
								$this->html.='.';
								break;
							case 'CHAR_/':
								$this->html.='/';
								break;
							case 'CHAR_0':
								$this->html.='0';
								break;
							case 'CHAR_1':
								$this->html.='1';
								break;
							case 'CHAR_2':
								$this->html.='2';
								break;
							case 'CHAR_3':
								$this->html.='3';
								break;
							case 'CHAR_4':
								$this->html.='4';
								break;
							case 'CHAR_5':
								$this->html.='5';
								break;
							case 'CHAR_6':
								$this->html.='6';
								break;
							case 'CHAR_7':
								$this->html.='7';
								break;
							case 'CHAR_8':
								$this->html.='8';
								break;
							case 'CHAR_9':
								$this->html.='9';
								break;
							case 'CHAR_:':
								$this->html.=':';
								break;
							case 'CHAR_;':
								$this->html.=';';
								break;
							case 'CHAR_<':
								$this->html.='<';
								break;
							case 'CHAR_=':
								$this->html.='=';
								break;
							case 'CHAR_>':
								$this->html.='>';
								break;
							case 'CHAR_?':
								$this->html.='?';
								break;
							case 'CHAR_@':
								$this->html.='@';
								break;
							case 'CHAR_A':
								$this->html.='A';
								break;
							case 'CHAR_B':
								$this->html.='B';
								break;
							case 'CHAR_C':
								$this->html.='C';
								break;
							case 'CHAR_D':
								$this->html.='D';
								break;
							case 'CHAR_E':
								$this->html.='E';
								break;
							case 'CHAR_F':
								$this->html.='F';
								break;
							case 'CHAR_G':
								$this->html.='G';
								break;
							case 'CHAR_H':
								$this->html.='H';
								break;
							case 'CHAR_I':
								$this->html.='I';
								break;
							case 'CHAR_J':
								$this->html.='J';
								break;
							case 'CHAR_K':
								$this->html.='K';
								break;
							case 'CHAR_L':
								$this->html.='L';
								break;
							case 'CHAR_M':
								$this->html.='M';
								break;
							case 'CHAR_N':
								$this->html.='N';
								break;
							case 'CHAR_O':
								$this->html.='O';
								break;
							case 'CHAR_P':
								$this->html.='P';
								break;
							case 'CHAR_Q':
								$this->html.='Q';
								break;
							case 'CHAR_R':
								$this->html.='R';
								break;
							case 'CHAR_S':
								$this->html.='S';
								break;
							case 'CHAR_T':
								$this->html.='T';
								break;
							case 'CHAR_U':
								$this->html.='U';
								break;
							case 'CHAR_V':
								$this->html.='V';
								break;
							case 'CHAR_W':
								$this->html.='W';
								break;
							case 'CHAR_X':
								$this->html.='X';
								break;
							case 'CHAR_Y':
								$this->html.='Y';
								break;
							case 'CHAR_Z':
								$this->html.='Z';
								break;
							case 'CHAR_[':
								$this->html.='[';
								break;
							case 'CHAR_\\':
								$this->html.='\\';
								break;
							case 'CHAR_]':
								$this->html.=']';
								break;
							case 'CHAR_^':
								$this->html.='^';
								break;
							case 'CHAR__':
								$this->html.='_';
								break;
							case 'CHAR_£':
								$this->html.='&pound;';
								break;
							case 'CHAR_a':
								$this->html.='a';
								break;
							case 'CHAR_b':
								$this->html.='b';
								break;
							case 'CHAR_c':
								$this->html.='c';
								break;
							case 'CHAR_d':
								$this->html.='d';
								break;
							case 'CHAR_e':
								$this->html.='e';
								break;
							case 'CHAR_f':
								$this->html.='f';
								break;
							case 'CHAR_g':
								$this->html.='g';
								break;
							case 'CHAR_h':
								$this->html.='h';
								break;
							case 'CHAR_i':
								$this->html.='i';
								break;
							case 'CHAR_j':
								$this->html.='j';
								break;
							case 'CHAR_k':
								$this->html.='k';
								break;
							case 'CHAR_l':
								$this->html.='l';
								break;
							case 'CHAR_m':
								$this->html.='m';
								break;
							case 'CHAR_n':
								$this->html.='n';
								break;
							case 'CHAR_o':
								$this->html.='o';
								break;
							case 'CHAR_p':
								$this->html.='p';
								break;
							case 'CHAR_q':
								$this->html.='q';
								break;
							case 'CHAR_r':
								$this->html.='r';
								break;
							case 'CHAR_s':
								$this->html.='s';
								break;
							case 'CHAR_t':
								$this->html.='t';
								break;
							case 'CHAR_u':
								$this->html.='u';
								break;
							case 'CHAR_v':
								$this->html.='v';
								break;
							case 'CHAR_w':
								$this->html.='w';
								break;
							case 'CHAR_x':
								$this->html.='x';
								break;
							case 'CHAR_y':
								$this->html.='y';
								break;
							case 'CHAR_z':
								$this->html.='z';
								break;
							case 'CHAR_{':
								$this->html.='{';
								break;
							case 'CHAR_:':
								$this->html.=':';
								break;
							case 'CHAR_}':
								$this->html.='}';
								break;
							case 'CHAR_~':
								$this->html.='~';
								break;
							case 'CHAR_SPACE':
								$this->html.='&nbsp;';
								break;
							default:
								echo '<p>Unknown character token '.$character.'</p>';
						endswitch;
					elseif(substr($character, 0, 5)=='GRAP_'):
						$graphicid=substr($character, 5);
						$this->html.=$this->makesymbol($graphicid, $this->translatecolour($this->textcolours[$lnkey][$colkey]));
					else:
						echo '<p>Unknown token '.$character.'</p>';
					endif;
					
					$this->html.='</td>';
				endforeach;
				
				$this->html.='</tr>';
			endforeach;
			
			$this->html.='</table>';
		}
		
		private function makesymbol($symbol, $colour) {
			$symboloutput='';
			
			$parts[1][2]=(($symbol-32)>=0);
			if(($symbol-32)>=0) $symbol-=32;
			
			$parts[0][2]=(($symbol-16)>=0);
			if(($symbol-16)>=0) $symbol-=16;
			
			$parts[1][1]=(($symbol-8)>=0);
			if(($symbol-8)>=0) $symbol-=8;
			
			$parts[0][1]=(($symbol-4)>=0);
			if(($symbol-4)>=0) $symbol-=4;
			
			$parts[1][0]=(($symbol-2)>=0);
			if(($symbol-2)>=0) $symbol-=2;
			
			$parts[0][0]=(($symbol-1)>=0);
			if(($symbol-1)>=0) $symbol-=1;
			
			$symboloutput.='<table><tr><td';
			
			if($parts[0][0]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td><td';
			
			if($parts[1][0]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td></tr><tr><td';
			
			if($parts[0][1]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td><td';
			
			if($parts[1][1]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td></tr><tr><td';
			
			if($parts[0][2]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td><td';
			
			if($parts[1][2]):
				$symboloutput.=' style="background-color:'.$colour.'"';
			endif;
			
			$symboloutput.='></td></tr></table>';
			
			# If there are two cells next to each other which are the same, then combine them.
			#$symboloutput=str_replace('<td class="'.$textcol.'"></td><td class="'.$textcol.'"></td>', '<td class="'.$textcol.'" colspan="2"></td>', $symboloutput);
			
			return $symboloutput;
		}
		
		private function translatecolour($colour) {
			switch($colour):
				case COL_RED:
					return 'red';
					break;
				case COL_GREEN:
					return '#00ff00';
					break;
				case COL_YELLOW:
					return 'yellow';
					break;
				case COL_BLUE:
					return 'blue';
					break;
				case COL_MAGENTA:
					return 'magenta';
					break;
				case COL_CYAN:
					return 'cyan';
					break;
				case COL_WHITE:
					return 'white';
					break;
			endswitch;
		}
	}
?>