<?php
	class convertmode7 extends convert {
		const MODE_TEXT=1;
		const MODE_GRAPHICS=2;
		const TXHEIGHT_STD=1;
		const TXHEIGHT_DBL=2;
		const COL_BLACK=0;
		const COL_RED=1;
		const COL_GREEN=2;
		const COL_YELLOW=3;
		const COL_BLUE=4;
		const COL_MAGENTA=5;
		const COL_CYAN=6;
		const COL_WHITE=7;
		const MODE_CONTIG=1;
		const MODE_SEPERA=2;
		const FLASH_STATIC=1;
		const FLASH_FLASH=2;
		
		private $flashs;
		private $tokenised;
		private $graphmodes;
		private $textheights;
		private $textcolours;
		private $bkgdcolours;
		private $images;
		private $textonlylines;
		
		public function convertmode7($filename, $issue, $title, $trimscroller, $headerandfooter) {
			if($headerandfooter):
				$this->html=implode('', file('temp/header.html'));
				
				$this->html=str_replace('%iss%', $issue, $this->html);
				$this->html=str_replace('%title%', $title, $this->html);
				$this->html=str_replace('%stylesheetpath%', '/common/styles/mode7.css', $this->html);
				$this->html=str_replace('%includejs%', '<script src="/common/script/mode7.js" type="text/javascript"></script>', $this->html);
			endif;
			
			$this->tokeniseinput($filename, $trimscroller);
			$this->findtextonlylines();
			$this->buildgraphics();
			$this->generatehtml();
			
			if($headerandfooter):
				$this->html.=implode('', file('pages/footer.html'));
			endif;
		}
		
		private function tokeniseinput($filename, $trimscroller) {
			if($trimscroller):
				$startpos=256;
			else:
				$startpos=0;
			endif;
			
			$row=0;
			$column=0;
			$mode=convertmode7::MODE_TEXT;
			$flash=convertmode7::FLASH_STATIC;
			$forecolour=convertmode7::COL_WHITE;
			$backcolour=convertmode7::COL_BLACK;
			$graphicsmode=convertmode7::MODE_CONTIG;
			$currentheight=convertmode7::TXHEIGHT_STD;
			
			$file=implode('', file($filename));
			
			for($filepos=$startpos; $filepos < strlen($file); $filepos++):
				switch(ord($file[$filepos])):
					case 13:
						for($fillcol=$column; $fillcol<40; $fillcol++):
							$this->textcolours[$row][$fillcol]=$forecolour;
							$this->bkgdcolours[$row][$fillcol]=$backcolour;
							$this->tokenised[$row][$fillcol]='CHAR_SPACE';
							$this->textheights[$row][$fillcol]=convertmode7::TXHEIGHT_STD;
							$this->flashs[$row][$fillcol]=convertmode7::FLASH_STATIC;
						endfor;
						$column=39;
						break;
					case 32:
					case 160:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						break;
					case 33:
					case 161:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_!';
						else:
							$this->tokenised[$row][$column]='GRAP_1';
						endif;
						break;
					case 34:
					case 162:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_"';
						else:
							$this->tokenised[$row][$column]='GRAP_2';
						endif;
						break;
					case 35:
					case 163:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_£';
						else:
							$this->tokenised[$row][$column]='GRAP_3';
						endif;
						break;
					case 36:
					case 164:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_$';
						else:
							$this->tokenised[$row][$column]='GRAP_4';
						endif;
						break;
					case 37:
					case 165:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_%';
						else:
							$this->tokenised[$row][$column]='GRAP_5';
						endif;
						break;
					case 38:
					case 166:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_&';
						else:
							$this->tokenised[$row][$column]='GRAP_6';
						endif;
						break;
					case 39:
					case 167:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_\'';
						else:
							$this->tokenised[$row][$column]='GRAP_7';
						endif;
						break;
					case 40:
					case 168:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_(';
						else:
							$this->tokenised[$row][$column]='GRAP_8';
						endif;
						break;
					case 41:
					case 169:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_)';
						else:
							$this->tokenised[$row][$column]='GRAP_9';
						endif;
						break;
					case 42:
					case 170:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_*';
						else:
							$this->tokenised[$row][$column]='GRAP_10';
						endif;
						break;
					case 43:
					case 171:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_+';
						else:
							$this->tokenised[$row][$column]='GRAP_11';
						endif;
						break;
					case 44:
					case 172:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_,';
						else:
							$this->tokenised[$row][$column]='GRAP_12';
						endif;
						break;
					case 45:
					case 173:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_-';
						else:
							$this->tokenised[$row][$column]='GRAP_13';
						endif;
						break;
					case 46:
					case 174:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_.';
						else:
							$this->tokenised[$row][$column]='GRAP_14';
						endif;
						break;
					case 47:
					case 175:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_/';
						else:
							$this->tokenised[$row][$column]='GRAP_15';
						endif;
						break;
					case 48:
					case 176:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_0';
						else:
							$this->tokenised[$row][$column]='GRAP_16';
						endif;
						break;
					case 49:
					case 177:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_1';
						else:
							$this->tokenised[$row][$column]='GRAP_17';
						endif;
						break;
					case 50:
					case 178:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_2';
						else:
							$this->tokenised[$row][$column]='GRAP_18';
						endif;
						break;
					case 51:
					case 179:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_3';
						else:
							$this->tokenised[$row][$column]='GRAP_19';
						endif;
						break;
					case 52:
					case 180:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_4';
						else:
							$this->tokenised[$row][$column]='GRAP_20';
						endif;
						break;
					case 53:
					case 181:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_5';
						else:
							$this->tokenised[$row][$column]='GRAP_21';
						endif;
						break;
					case 54:
					case 182:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_6';
						else:
							$this->tokenised[$row][$column]='GRAP_22';
						endif;
						break;
					case 55:
					case 183:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_7';
						else:
							$this->tokenised[$row][$column]='GRAP_23';
						endif;
						break;
					case 56:
					case 184:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_8';
						else:
							$this->tokenised[$row][$column]='GRAP_24';
						endif;
						break;
					case 57:
					case 185:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_9';
						else:
							$this->tokenised[$row][$column]='GRAP_25';
						endif;
						break;
					case 58:
					case 186:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_:';
						else:
							$this->tokenised[$row][$column]='GRAP_26';
						endif;
						break;
					case 59:
					case 187:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_;';
						else:
							$this->tokenised[$row][$column]='GRAP_27';
						endif;
						break;
					case 60:
					case 188:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_<';
						else:
							$this->tokenised[$row][$column]='GRAP_28';
						endif;
						break;
					case 61:
					case 189:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_=';
						else:
							$this->tokenised[$row][$column]='GRAP_29';
						endif;
						break;
					case 62:
					case 190:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_>';
						else:
							$this->tokenised[$row][$column]='GRAP_30';
						endif;
						break;
					case 63:
					case 191:
						if($mode==convertmode7::MODE_TEXT):
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
					case 217:
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
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_#';
						else:
							$this->tokenised[$row][$column]='GRAP_32';
						endif;
						break;
					case 97:
					case 225:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_a';
						else:
							$this->tokenised[$row][$column]='GRAP_33';
						endif;
						break;
					case 98:
					case 226:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_b';
						else:
							$this->tokenised[$row][$column]='GRAP_34';
						endif;
						break;
					case 99:
					case 227:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_c';
						else:
							$this->tokenised[$row][$column]='GRAP_35';
						endif;
						break;
					case 100:
					case 228:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_d';
						else:
							$this->tokenised[$row][$column]='GRAP_36';
						endif;
						break;
					case 101:
					case 229:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_e';
						else:
							$this->tokenised[$row][$column]='GRAP_37';
						endif;
						break;
					case 102:
					case 230:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_f';
						else:
							$this->tokenised[$row][$column]='GRAP_38';
						endif;
						break;
					case 103:
					case 231:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_g';
						else:
							$this->tokenised[$row][$column]='GRAP_39';
						endif;
						break;
					case 104:
					case 232:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_h';
						else:
							$this->tokenised[$row][$column]='GRAP_40';
						endif;
						break;
					case 105:
					case 233:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_i';
						else:
							$this->tokenised[$row][$column]='GRAP_41';
						endif;
						break;
					case 106:
					case 234:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_j';
						else:
							$this->tokenised[$row][$column]='GRAP_42';
						endif;
						break;
					case 107:
					case 235:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_k';
						else:
							$this->tokenised[$row][$column]='GRAP_43';
						endif;
						break;
					case 108:
					case 236:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_l';
						else:
							$this->tokenised[$row][$column]='GRAP_44';
						endif;
						break;
					case 109:
					case 237:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_m';
						else:
							$this->tokenised[$row][$column]='GRAP_45';
						endif;
						break;
					case 110:
					case 238:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_n';
						else:
							$this->tokenised[$row][$column]='GRAP_46';
						endif;
						break;
					case 111:
					case 239:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_o';
						else:
							$this->tokenised[$row][$column]='GRAP_47';
						endif;
						break;
					case 112:
					case 240:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_p';
						else:
							$this->tokenised[$row][$column]='GRAP_48';
						endif;
						break;
					case 113:
					case 241:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_q';
						else:
							$this->tokenised[$row][$column]='GRAP_49';
						endif;
						break;
					case 114:
					case 242:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_r';
						else:
							$this->tokenised[$row][$column]='GRAP_50';
						endif;
						break;
					case 115:
					case 243:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_s';
						else:
							$this->tokenised[$row][$column]='GRAP_51';
						endif;
						break;
					case 116:
					case 244:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_t';
						else:
							$this->tokenised[$row][$column]='GRAP_52';
						endif;
						break;
					case 117:
					case 245:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_u';
						else:
							$this->tokenised[$row][$column]='GRAP_53';
						endif;
						break;
					case 118:
					case 246:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_v';
						else:
							$this->tokenised[$row][$column]='GRAP_54';
						endif;
						break;
					case 119:
					case 247:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_w';
						else:
							$this->tokenised[$row][$column]='GRAP_55';
						endif;
						break;
					case 120:
					case 248:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_x';
						else:
							$this->tokenised[$row][$column]='GRAP_56';
						endif;
						break;
					case 121:
					case 249:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_y';
						else:
							$this->tokenised[$row][$column]='GRAP_57';
						endif;
						break;
					case 122:
					case 250:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_z';
						else:
							$this->tokenised[$row][$column]='GRAP_58';
						endif;
						break;
					case 123:
					case 251:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_{';
						else:
							$this->tokenised[$row][$column]='GRAP_59';
						endif;
						break;
					case 124:
					case 252:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_:';
						else:
							$this->tokenised[$row][$column]='GRAP_60';
						endif;
						break;
					case 125:
					case 253:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_}';
						else:
							$this->tokenised[$row][$column]='GRAP_61';
						endif;
						break;
					case 126:
					case 254:
						if($mode==convertmode7::MODE_TEXT):
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
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_RED;
						break;
					default:
					case 130:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_GREEN;
						break;
					default:
					case 131:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_YELLOW;
						break;
					default:
					case 132:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_BLUE;
						break;
					default:
					case 133:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_MAGENTA;
						break;
					default:
					case 134:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_CYAN;
						break;
					default:
					case 135:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_WHITE;
						break;
					case 136:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$flash=convertmode7::FLASH_FLASH;
						break;
					case 137:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$flash=convertmode7::FLASH_STATIC;
						break;
					case 141:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$currentheight=convertmode7::TXHEIGHT_DBL;
						break;
					case 145:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_RED;
						break;
					default:
					case 146:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_GREEN;
						break;
					default:
					case 147:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_YELLOW;
						break;
					default:
					case 148:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_BLUE;
						break;
					default:
					case 149:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_MAGENTA;
						break;
					default:
					case 150:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_CYAN;
						break;
					default:
					case 151:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_WHITE;
						break;
					case 153:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$graphicsmode=convertmode7::MODE_CONTIG;
						break;
					case 154:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$graphicsmode=convertmode7::MODE_SEPERA;
						break;
					case 156:
						$this->tokenised[$row][$column]='CHAR_SPACE';
						$backcolour=convertmode7::COL_BLACK;
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
				$this->graphmodes[$row][$column]=$graphicsmode;
				$this->flashs[$row][$column]=$flash;
				
				if($this->tokenised[$row][$column]=='CHAR_SPACE'):
					$this->textheights[$row][$column]=convertmode7::TXHEIGHT_STD;
				else:
					$this->textheights[$row][$column]=$currentheight;
				endif;
				
				$column++;
				
				if($column>39):
					$column=0;
					$row++;
					$mode=convertmode7::MODE_TEXT;
					$flash=convertmode7::FLASH_STATIC;
					$forecolour=convertmode7::COL_WHITE;
					$backcolour=convertmode7::COL_BLACK;
					$graphicsmode=convertmode7::MODE_CONTIG;
					$currentheight=convertmode7::TXHEIGHT_STD;
				endif;
			endfor;
		}
		
		private function findtextonlylines() {
			foreach($this->tokenised as $lnkey => $line):
				$textonly = true;
				
				foreach($line as $colkey => $character):
					if(substr($character, 0, 5) != 'CHAR_' || $this->textheights[$lnkey][$colkey] == convertmode7::TXHEIGHT_DBL):
						$textonly = false;
						break;
					endif;
				endforeach;
				
				$this->textonlylines[$lnkey] = $textonly;
			endforeach;
		}
		
		private function buildgraphics() {
			foreach($this->tokenised as $lnkey => $line):
				foreach($line as $colkey => $character):
					if(substr($this->tokenised[$lnkey][$colkey], 0, 5)=='GRAP_'):
						unset($convchars);
						$convchars[0][0][0] = substr($this->tokenised[$lnkey][$colkey], 5);
						$convchars[0][0][1] = $this->textcolours[$lnkey][$colkey];
						$flashmode = $this->flashs[$lnkey][$colkey];
						$bgcolour = $this->bkgdcolours[$lnkey][$colkey];
						$grapwidth = 1;
						$grapheight = 1;
						$trimmed = false;
						
						# First work out how wide the block is
						while($colkey + $grapwidth < 40 && (substr($this->tokenised[$lnkey][$colkey + $grapwidth], 0, 5) == 'GRAP_' || $this->tokenised[$lnkey][$colkey + $grapwidth] == 'CHAR_SPACE') && $this->bkgdcolours[$lnkey][$colkey + $grapwidth] == $bgcolour && $this->flashs[$lnkey][$colkey + $grapwidth] == $flashmode):
							$convchars[0][$grapwidth][0] = substr($this->tokenised[$lnkey][$colkey + $grapwidth], 5);
							$convchars[0][$grapwidth][1] = $this->textcolours[$lnkey][$colkey + $grapwidth];
							$this->tokenised[$lnkey][$colkey + $grapwidth] = 'IMAGE';
							$grapwidth++;
						endwhile;
						
						# Now find if there are any more rows to be added on
						do {
							$rowokay = true;
							
							if(isset($this->textonlylines[$lnkey + $grapheight]) && $this->textonlylines[$lnkey + $grapheight]):
								# End the block of graphics if a row of only text is found
								$rowokay = false;
							else:
								for($testrow = 0; $testrow < $grapwidth; $testrow++):
									if(!isset($this->tokenised[$lnkey + $grapheight][$colkey + $testrow]) || (substr($this->tokenised[$lnkey + $grapheight][$colkey + $testrow], 0, 5) != 'GRAP_' && $this->tokenised[$lnkey + $grapheight][$colkey + $testrow] != 'CHAR_SPACE') || $this->bkgdcolours[$lnkey + $grapheight][$colkey + $testrow] != $bgcolour || $this->flashs[$lnkey + $grapheight][$colkey + $testrow] != $flashmode):
										$rowokay = false;
									endif;
								endfor;
								
								if($rowokay):
									for($addrow = 0; $addrow < $grapwidth; $addrow++):
										$convchars[$grapheight][$addrow][0] = substr($this->tokenised[$lnkey + $grapheight][$colkey + $addrow], 5);
										$convchars[$grapheight][$addrow][1] = $this->textcolours[$lnkey + $grapheight][$colkey + $addrow];
										$this->tokenised[$lnkey + $grapheight][$colkey + $addrow] = 'IMAGE';
									endfor;
									
									$grapheight++;
								endif;
							endif;
							
							if(!$rowokay && !$trimmed):
								# Chop off any columns of spaces from the right hand side of the
								# block of graphics, the first time the next row doesn't fit.
								$trimmed = true;
								$colblank = true;
								
								while($colblank):
									for($checkcol = 0; $checkcol < $grapheight; $checkcol++):
										if($convchars[$checkcol][$grapwidth - 1][0] != 'SPACE'):
											$colblank = false;
											break;
										endif;
									endfor;
									
									if($colblank):
										$rowokay = true;
										$grapwidth--;
										
										for($revertcol = 0; $revertcol < $grapheight; $revertcol++):
											$this->tokenised[$lnkey + $revertcol][$colkey + $grapwidth] = 'CHAR_SPACE';
										endfor;
									endif;
								endwhile;
							endif;
						} while($rowokay);
						
						# Now search across to the left to see if there are any more columns
						# that should be included in this block, but start part way down.
						$searchleft = 0;
						$foundcol = true;
						unset($leftconvchars);
						
						while($foundcol):
							$sepcol = true;
							
							if($colkey - ($searchleft + 1) < 0):
								$foundcol = false;
							else:
								for($testcol = 0; $testcol < $grapheight; $testcol++):
									if((substr($this->tokenised[$lnkey + $testcol][$colkey - ($searchleft + 1)], 0, 5) != 'GRAP_' && $this->tokenised[$lnkey + $testcol][$colkey - ($searchleft + 1)] != 'CHAR_SPACE') || $this->bkgdcolours[$lnkey + $testcol][$colkey - ($searchleft + 1)] != $bgcolour || $this->flashs[$lnkey + $testcol][$colkey - ($searchleft + 1)] != $flashmode):
										$foundcol = false;
										break;
									endif;
									
									if($sepcol && $this->tokenised[$lnkey + $testcol][$colkey - ($searchleft + 1)] != 'CHAR_SPACE'):
										$sepcol = false;
									endif;
								endfor;
							endif;
							
							if($sepcol):
								$foundcol = false;
							endif;
							
							if($foundcol):
								for($fetchcol = 0; $fetchcol < $grapheight; $fetchcol++):
									$leftconvchars[$fetchcol][$searchleft][0] = substr($this->tokenised[$lnkey + $fetchcol][$colkey - ($searchleft + 1)], 5);
									$leftconvchars[$fetchcol][$searchleft][1] = $this->textcolours[$lnkey + $fetchcol][$colkey - ($searchleft + 1)];
									$this->tokenised[$lnkey + $fetchcol][$colkey - ($searchleft + 1)] = 'IMAGE';
								endfor;
								
								$searchleft++;
							endif;
						endwhile;
						
						if($searchleft > 0):
							for($joinrows = 0; $joinrows < $grapheight; $joinrows++):
								$leftconvchars[$joinrows] = array_reverse($leftconvchars[$joinrows]);
								$convchars[$joinrows] = array_merge($leftconvchars[$joinrows], $convchars[$joinrows]);
							endfor;
							
							$grapwidth = $grapwidth + $searchleft;
						endif;
						
						$searchleft=0;
						
						$this->tokenised[$lnkey][$colkey - $searchleft] = 'IMAGE';
						$this->images[$lnkey][$colkey - $searchleft] = array($this->buildsymbolblock($convchars, $grapwidth, $grapheight, $bgcolour), $grapwidth, $grapheight, '*');
					endif;
				endforeach;
			endforeach;
		}
		
		private function generatehtml() {
			$this->html.='<table class="mode7 centralcol">';
			
			foreach($this->tokenised as $lnkey => $line):
				foreach($line as $colkey => $character):
					# If a cell contains a 'fully on' graphics character, convert this to an empty cell
					# with the character colour as the background colour (only for contiguous graphics)
					if($character=='GRAP_63' && $this->graphmodes[$lnkey][$colkey]==convertmode7::MODE_CONTIG):
						$this->tokenised[$lnkey][$colkey] = $line[$colkey] = $character = 'CHAR_SPACE';
						$this->bkgdcolours[$lnkey][$colkey]=$this->textcolours[$lnkey][$colkey];
					endif;
					
					# Make the text colour of spaces the same as much as possible, to allow as much
					# merging as possible
					if($colkey > 0):
						if($this->textcolours[$lnkey][$colkey]!=$lastcolour && $character=='CHAR_SPACE'):
							$this->textcolours[$lnkey][$colkey]=$lastcolour;
						endif;
					endif;
					
					$lastcolour=$this->textcolours[$lnkey][$colkey];
				endforeach;
				
				$this->html.='<tr>';
				
				$cellcontents='';
				$colspan=1;
				
				foreach($line as $colkey => $character):
					if(substr($character, 0, 5)=='CHAR_'):
						if($this->textheights[$lnkey][$colkey]==convertmode7::TXHEIGHT_DBL):
							if($lnkey==0 || $this->textheights[$lnkey-1][$colkey]==convertmode7::TXHEIGHT_STD):
								$dblpart=1;
							else:
								$dblpart=2;
							endif;
							
							$cellcontents.='<img src="/common/chars/'.ord(substr($character, 5)).'_'.$this->bkgdcolours[$lnkey][$colkey].'_'.$this->textcolours[$lnkey][$colkey].'_'.$dblpart.'.png" alt="'.substr($character, 5).'" />';
						else:
							switch($character):
								case 'CHAR_SPACE':
									$cellcontents.='&nbsp;';
									break;
								case 'CHAR_£':
									$cellcontents.='&pound;';
									break;
								case 'CHAR_<':
									$cellcontents.='&lt;';
									break;
								case 'CHAR_>':
									$cellcontents.='&gt;';
									break;
								case 'CHAR_&':
									$cellcontents.='&amp;';
									break;
								default:
									$cellcontents.=substr($character, 5);
							endswitch;
						endif;
					elseif(substr($character, 0, 5)=='GRAP_'):
						$graphicid=substr($character, 5);
						$cellcontents.=$this->makesymbol($graphicid, $this->textcolours[$lnkey][$colkey], $this->bkgdcolours[$lnkey][$colkey], $this->graphmodes[$lnkey][$colkey]);
					elseif($character == 'IMAGE'):
						if(isset($this->images[$lnkey][$colkey])):
							$this->html.= '<td';
							
							if($this->images[$lnkey][$colkey][1] > 1):
								$this->html.= ' colspan="'.$this->images[$lnkey][$colkey][1].'"';
							endif;
							
							if($this->images[$lnkey][$colkey][2] > 1):
								$this->html.= ' rowspan="'.$this->images[$lnkey][$colkey][2].'"';
							endif;
							
							$classes='';
							
							if($this->bkgdcolours[$lnkey][$colkey]!=convertmode7::COL_BLACK):
								$classes.='b'.$this->bkgdcolours[$lnkey][$colkey];
							endif;
							
							if($this->flashs[$lnkey][$colkey]==convertmode7::FLASH_FLASH):
								$classes.=' flash';
							endif;
							
							if($classes!=''):
								$this->html.=' class="'.trim($classes).'"';
							endif;
							
							$this->html.= '><img src="'.$this->images[$lnkey][$colkey][0].'" alt="'.$this->images[$lnkey][$colkey][3].'" /></td>';
						endif;
					else:
						echo '<p>Unknown token '.$character.'</p>';
					endif;
					
					if($character != 'IMAGE'):
						if($lnkey > 0 && $colkey<count($line)-1 && substr($character, 0, 5)=='CHAR_' && substr($this->tokenised[$lnkey][$colkey+1], 0, 5)=='CHAR_' && $this->textheights[$lnkey][$colkey]==convertmode7::TXHEIGHT_STD && $this->textheights[$lnkey][$colkey+1]==convertmode7::TXHEIGHT_STD && $this->textcolours[$lnkey][$colkey]==$this->textcolours[$lnkey][$colkey+1] && $this->bkgdcolours[$lnkey][$colkey]==$this->bkgdcolours[$lnkey][$colkey+1] && $this->flashs[$lnkey][$colkey]==$this->flashs[$lnkey][$colkey+1]):
							$colspan++;
						else:
							# Replace a cell full of only non-breaking spaces, with a single non-breaking space
							if(str_replace('&nbsp;', '', $cellcontents)==''):
								$cellcontents='&nbsp;';
							endif;
							# Replace non-breaking spaces between word with spaces
							$cellcontents=preg_replace('/([^; ])&nbsp;([^& ])/', '\1 \2', $cellcontents);
							# Remove multiple non breaking spaces from the ends of cells with other contents
							$cellcontents=preg_replace('/\A(.+?)(?:&nbsp;)+\z/', '\1', $cellcontents);
							# Alternate non-breaking and standard spaces
							$cellcontents=str_replace('&nbsp;&nbsp;', '&nbsp; ', $cellcontents);
							
							$classes='';
							$this->html.='<td';
							
							if($this->textcolours[$lnkey][$colkey]!=convertmode7::COL_WHITE && $cellcontents!='&nbsp;' && substr($character, 0, 5)!='GRAP_'):
								$classes.='t'.$this->textcolours[$lnkey][$colkey];
							endif;
							
							if($this->bkgdcolours[$lnkey][$colkey]!=convertmode7::COL_BLACK):
								$classes.=' b'.$this->bkgdcolours[$lnkey][$colkey];
							endif;
							
							if($this->flashs[$lnkey][$colkey]==convertmode7::FLASH_FLASH):
								$classes.=' flash';
							endif;
							
							if($classes!=''):
								$this->html.=' class="'.trim($classes).'"';
							endif;
							
							if($colspan>1):
								$this->html.=' colspan="'.$colspan.'"';
							endif;
							
							$this->html.='>'.$cellcontents;
							$this->html.='</td>';
							
							$cellcontents='';
							$colspan=1;
						endif;
					endif;
				endforeach;
				
				$this->html.="</tr>\n";
			endforeach;
			
			$this->html.='</table>';
		}
		
		private function findfreename($prefix, $suffix) {
			static $filenum = 0;
			
			while(file_exists($prefix.str_pad($filenum, 4, '0', STR_PAD_LEFT).$suffix)):
				$filenum++;
			endwhile;
			
			return $prefix.str_pad($filenum, 4, '0', STR_PAD_LEFT).$suffix;
		}
		
		private function buildsymbolblock($symbols, $width, $height, $bgcolour) {
			$charwidth=16;
			$charheight=24;
			
			$imgsym = ImageCreate($charwidth * $width, $charheight * $height);
			
			switch($bgcolour):
				case convertmode7::COL_BLACK:
					$bgcol = ImageColorAllocate($imgsym, 0, 0, 0);
					break;
				case convertmode7::COL_RED:
					$bgcol = ImageColorAllocate($imgsym, 255, 0, 0);
					break;
				case convertmode7::COL_GREEN:
					$bgcol = ImageColorAllocate($imgsym, 0, 255, 0);
					break;
				case convertmode7::COL_YELLOW:
					$bgcol = ImageColorAllocate($imgsym, 255, 255, 0);
					break;
				case convertmode7::COL_BLUE:
					$bgcol = ImageColorAllocate($imgsym, 0, 0, 255);
					break;
				case convertmode7::COL_MAGENTA:
					$bgcol = ImageColorAllocate($imgsym, 255, 0, 255);
					break;
				case convertmode7::COL_CYAN:
					$bgcol = ImageColorAllocate($imgsym, 0, 255, 255);
					break;
				case convertmode7::COL_WHITE:
					$bgcol = ImageColorAllocate($imgsym, 255, 255, 255);
					break;
			endswitch;
			
			$colours[convertmode7::COL_BLACK] = ImageColorAllocate($imgsym, 0, 0, 0);
			$colours[convertmode7::COL_RED] = ImageColorAllocate($imgsym, 255, 0, 0);
			$colours[convertmode7::COL_GREEN] = ImageColorAllocate($imgsym, 0, 255, 0);
			$colours[convertmode7::COL_YELLOW] = ImageColorAllocate($imgsym, 255, 255, 0);
			$colours[convertmode7::COL_BLUE] = ImageColorAllocate($imgsym, 0, 0, 255);
			$colours[convertmode7::COL_MAGENTA] = ImageColorAllocate($imgsym, 255, 0, 255);
			$colours[convertmode7::COL_CYAN] = ImageColorAllocate($imgsym, 0, 255, 255);
			$colours[convertmode7::COL_WHITE] = ImageColorAllocate($imgsym, 255, 255, 255);
			
			$colused[convertmode7::COL_BLACK] = false;
			$colused[convertmode7::COL_RED] = false;
			$colused[convertmode7::COL_GREEN] = false;
			$colused[convertmode7::COL_YELLOW] = false;
			$colused[convertmode7::COL_BLUE] = false;
			$colused[convertmode7::COL_MAGENTA] = false;
			$colused[convertmode7::COL_CYAN] = false;
			$colused[convertmode7::COL_WHITE] = false;
			
			foreach($symbols as $row => $symbrow):
				foreach($symbrow as $col => $symbol):
					$xoffset = $col * $charwidth;
					$yoffset = $row * $charheight;
					
					if($symbol[0] == 'SPACE'):
						$symbol[0] = 0;
					endif;
					
					if($symbol[0] > 0):
						$colused[$symbol[1]] = true;
					endif;
					
					$firstcolx1 = $xoffset;
					$firstcolx2 = ($xoffset + $charwidth / 2) - 1;
					$secondcolx1 = $xoffset + $charwidth / 2;
					$secondcolx2 = ($xoffset + $charwidth) -1;
					
					$firstrowy1 = $yoffset;
					$firstrowy2 = ($yoffset + $charheight / 3) -1;
					$secondrowy1 = $yoffset + $charheight / 3;
					$secondrowy2 = ($yoffset + ($charheight / 3 ) * 2) - 1;
					$thirdrowy1 = $yoffset + ($charheight / 3) * 2;
					$thirdrowy2 = ($yoffset + $charheight) - 1;
					
					if(($symbol[0]-32) >= 0):
						ImageFilledRectangle($imgsym, $secondcolx1, $thirdrowy1, $secondcolx2, $thirdrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-32;
					endif;
					
					if(($symbol[0]-16) >= 0):
						ImageFilledRectangle($imgsym, $firstcolx1, $thirdrowy1, $firstcolx2, $thirdrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-16;
					endif;
					
					if(($symbol[0]-8) >= 0):
						ImageFilledRectangle($imgsym, $secondcolx1, $secondrowy1, $secondcolx2, $secondrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-8;
					endif;
					
					if(($symbol[0]-4) >= 0):
						ImageFilledRectangle($imgsym, $firstcolx1, $secondrowy1, $firstcolx2, $secondrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-4;
					endif;
					
					if(($symbol[0]-2) >= 0):
						ImageFilledRectangle($imgsym, $secondcolx1, $firstrowy1, $secondcolx2, $firstrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-2;
					endif;
					
					if(($symbol[0]-1) >= 0):
						ImageFilledRectangle($imgsym, $firstcolx1, $firstrowy1, $firstcolx2, $firstrowy2, $colours[$symbol[1]]);
						$symbol[0]=$symbol[0]-1;
					endif;
				endforeach;
			endforeach;
			
			if(!$colused[convertmode7::COL_BLACK]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_BLACK]);
			endif;
			
			if(!$colused[convertmode7::COL_RED]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_RED]);
			endif;
			
			if(!$colused[convertmode7::COL_GREEN]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_GREEN]);
			endif;
			
			if(!$colused[convertmode7::COL_YELLOW]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_YELLOW]);
			endif;
			
			if(!$colused[convertmode7::COL_BLUE]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_BLUE]);
			endif;
			
			if(!$colused[convertmode7::COL_MAGENTA]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_MAGENTA]);
			endif;
			
			if(!$colused[convertmode7::COL_CYAN]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_CYAN]);
			endif;
			
			if(!$colused[convertmode7::COL_WHITE]):
				imagecolordeallocate($imgsym, $colours[convertmode7::COL_WHITE]);
			endif;
			
			$debugborder = ImageColorAllocate($imgsym, 255, 138, 0);
			ImageRectangle($imgsym, 0, 0, $charwidth * $width - 1, $charheight * $height - 1, $debugborder);
			
			$savename = $this->findfreename('../common/mode7/graph', '.png');
			
			ImagePNG($imgsym, $savename);
			imagedestroy($imgsym);
			
			return substr($savename, 2);
		}
	}
?>