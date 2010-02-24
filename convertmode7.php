<?php
	require_once 'convert.php';
	
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
		const GRHOLD_RELEASE=0;
		const GRHOLD_HOLD=1;
		
		const CHAR_WIDTH=16;
		const CHAR_HEIGHT=24;
		
		private $flashs;
		private $tokenised;
		private $graphmodes;
		private $textheights;
		private $textcolours;
		private $bkgdcolours;
		private $images;
		private $textonlylines;
		private $colspans;
		private $blanklines;
		
		public function convertmode7($filename, $issue, $title, $trimscroller, $headerandfooter) {
			if($headerandfooter):
				$this->html=file_get_contents('temp/header.html');
				
				$this->html=str_replace('%navcontent%', generatenav(), $this->html);
				$this->html=str_replace('%iss%', $issue, $this->html);
				$this->html=str_replace('%title%', $title, $this->html);
				$this->html=str_replace('%stylesheetpath%', '/common/styles/mode7.css', $this->html);
				$this->html=str_replace('%includejs%', '<script src="/common/script/mode7.js" type="text/javascript"></script>', $this->html);
			endif;
			
			$this->tokeniseinput($filename, $trimscroller);
			$this->findtextonlylines();
			$this->buildgraphics();
			$this->builddbltext();
			$this->findblanklines();
			$this->findcolspans();
			$this->generatehtml();
			
			if($headerandfooter):
				$this->html.=file_get_contents('templates/footer.html');
			endif;
		}
		
		private function fillrestofrow($row, $column, $forecolour, $backcolour, $mode) {
			for($fillcol=$column; $fillcol<40; $fillcol++):
				$this->textcolours[$row][$fillcol]=$forecolour;
				$this->bkgdcolours[$row][$fillcol]=$backcolour;
				$this->graphmodes[$row][$fillcol]=$mode;
				$this->tokenised[$row][$fillcol]='CHAR_SPACE';
				$this->textheights[$row][$fillcol]=convertmode7::TXHEIGHT_STD;
				$this->flashs[$row][$fillcol]=convertmode7::FLASH_STATIC;
			endfor;
		}
		
		private function controlchar($row, $column, $graphicshold) {
			if($graphicshold == convertmode7::GRHOLD_RELEASE):
				$this->tokenised[$row][$column] = 'CHAR_SPACE';
			else:
				$this->tokenised[$row][$column] = $this->tokenised[$row][$column - 1];
				echo 'Held graphics mode would have affected ouput at line '.$row.' column '.$column.".\nPlease remove this message and validate that it works.\n";
				exit(1);
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
			$graphicshold=convertmode7::GRHOLD_RELEASE;
			
			$file=file_get_contents($filename);
			
			for($filepos=$startpos; $filepos < strlen($file); $filepos++):
				switch(ord($file[$filepos])):
					case 0:
						# Null byte - assume that the end of the file has been reached
						break 2;
					case 13:
						$this->fillrestofrow($row, $column, $forecolour, $backcolour, $mode);
						$column=39;
						break;
					case 138:
					case 139:
					case 142:
					case 143:
						# 'Nothing' in the user guide - displays as a space
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
						$this->tokenised[$row][$column]='CHAR_½';
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
							$this->tokenised[$row][$column]='CHAR_¼';
						else:
							$this->tokenised[$row][$column]='GRAP_59';
						endif;
						break;
					case 124:
					case 252:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_|';
						else:
							$this->tokenised[$row][$column]='GRAP_60';
						endif;
						break;
					case 125:
					case 253:
						if($mode==convertmode7::MODE_TEXT):
							$this->tokenised[$row][$column]='CHAR_¾';
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
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_RED;
						break;
					case 130:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_GREEN;
						break;
					case 131:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_YELLOW;
						break;
					case 132:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_BLUE;
						break;
					case 133:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_MAGENTA;
						break;
					case 134:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_CYAN;
						break;
					case 135:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_TEXT;
						$forecolour=convertmode7::COL_WHITE;
						break;
					case 136:
						$this->controlchar($row, $column, $graphicshold);
						$flash=convertmode7::FLASH_FLASH;
						break;
					case 137:
						$this->controlchar($row, $column, $graphicshold);
						$flash=convertmode7::FLASH_STATIC;
						break;
					case 140:
						$this->controlchar($row, $column, $graphicshold);
						$currentheight=convertmode7::TXHEIGHT_STD;
						break;
					case 141:
						$this->controlchar($row, $column, $graphicshold);
						$currentheight=convertmode7::TXHEIGHT_DBL;
						break;
					case 145:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_RED;
						break;
					case 146:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_GREEN;
						break;
					case 147:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_YELLOW;
						break;
					case 148:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_BLUE;
						break;
					case 149:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_MAGENTA;
						break;
					case 150:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_CYAN;
						break;
					case 151:
						$this->controlchar($row, $column, $graphicshold);
						$mode=convertmode7::MODE_GRAPHICS;
						$forecolour=convertmode7::COL_WHITE;
						break;
					case 153:
						$this->controlchar($row, $column, $graphicshold);
						$graphicsmode=convertmode7::MODE_CONTIG;
						break;
					case 154:
						$this->controlchar($row, $column, $graphicshold);
						$graphicsmode=convertmode7::MODE_SEPERA;
						break;
					case 156:
						$this->controlchar($row, $column, $graphicshold);
						$backcolour=convertmode7::COL_BLACK;
						break;
					case 157:
						$this->controlchar($row, $column, $graphicshold);
						$backcolour=$forecolour;
						break;
					case 158:
						$this->controlchar($row, $column, $graphicshold);
						$graphicshold=convertmode7::GRHOLD_HOLD;
						break;
					case 159:
						$this->controlchar($row, $column, $graphicshold);
						$graphicshold=convertmode7::GRHOLD_RELEASE;
						break;
					default:
						echo 'Unknown character value '.ord($file[$filepos]).' at line '.$row.' column '.$column." - aborting\n";
						exit(1);
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
					$graphicshold=convertmode7::GRHOLD_RELEASE;
				endif;
			endfor;
			
			if($column > 0):
				$this->fillrestofrow($row, $column, $forecolour, $backcolour, $mode);
			endif;
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
						$convchars[0][0][2] = $this->graphmodes[$lnkey][$colkey];
						$flashmode = $this->flashs[$lnkey][$colkey];
						$bgcolour = $this->bkgdcolours[$lnkey][$colkey];
						$grapwidth = 1;
						$grapheight = 1;
						$trimmed = false;
						
						# First work out how wide the block is
						while($colkey + $grapwidth < 40 && (substr($this->tokenised[$lnkey][$colkey + $grapwidth], 0, 5) == 'GRAP_' || $this->tokenised[$lnkey][$colkey + $grapwidth] == 'CHAR_SPACE') && $this->bkgdcolours[$lnkey][$colkey + $grapwidth] == $bgcolour && $this->flashs[$lnkey][$colkey + $grapwidth] == $flashmode):
							$convchars[0][$grapwidth][0] = substr($this->tokenised[$lnkey][$colkey + $grapwidth], 5);
							$convchars[0][$grapwidth][1] = $this->textcolours[$lnkey][$colkey + $grapwidth];
							$convchars[0][$grapwidth][2] = $this->graphmodes[$lnkey][$colkey + $grapwidth];
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
										$convchars[$grapheight][$addrow][2] = $this->graphmodes[$lnkey + $grapheight][$colkey + $addrow];
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
											# Tuning of the algorithm for box shapes - if we are at the bottom of a 8 or more line
											# block, allow it to ignore a 2 char border, or at the bottom of a 4 or more line block,
											# then allow it to ignore a 1 char border.
											if(($grapheight > 3 && $checkcol > $grapheight - 2) || ($grapheight > 7 && $checkcol > $grapheight - 3)):
												if($colkey + $grapwidth > 39 || substr($this->tokenised[$lnkey + $checkcol][$colkey + $grapwidth], 0, 5) != 'GRAP_'):
													$colblank = false;
													break;
												endif;
											else:
												$colblank = false;
												break;
											endif;
										endif;
									endfor;
									
									if($colblank):
										$rowokay = true;
										$grapwidth--;
										
										for($revertcol = 0; $revertcol < $grapheight; $revertcol++):
											if($convchars[$revertcol][$grapwidth][0] == 'SPACE'):
												$this->tokenised[$lnkey + $revertcol][$colkey + $grapwidth] = 'CHAR_SPACE';
											else:
												$this->tokenised[$lnkey + $revertcol][$colkey + $grapwidth] = 'GRAP_'.$convchars[$revertcol][$grapwidth][0];
											endif;
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
										# Tuning of the algorithm for box shapes - if we are at the bottom of a 8 or more line
										# block, allow it to ignore a 2 char border, or at the bottom of a 4 or more line block,
										# then allow it to ignore a 1 char border.
										if(($grapheight > 3 && $testcol > $grapheight - 2) || ($grapheight > 7 && $testcol > $grapheight - 3)):
											if($colkey - ($searchleft + 2) < 0 || substr($this->tokenised[$lnkey + $testcol][$colkey - ($searchleft + 2)], 0, 5) != 'GRAP_'):
												$sepcol = false;
											endif;
										else:
											$sepcol = false;
										endif;
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
									$leftconvchars[$fetchcol][$searchleft][2] = $this->graphmodes[$lnkey + $fetchcol][$colkey - ($searchleft + 1)];
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
						
						# Remove any blank lines from the bottom of the graphics block
						$blankrow = true;
						
						while($blankrow):
							for($testrow = 0; $testrow < $grapwidth; $testrow ++):
								if($convchars[$grapheight - 1][$testrow][0] != 'SPACE'):
									$blankrow = false;
									break;
								endif;
							endfor;
							
							if($blankrow):
								for($revertrow = 0; $revertrow < $grapwidth; $revertrow ++):
									$this->tokenised[$lnkey + ($grapheight - 1)][$colkey + $revertrow] = 'CHAR_SPACE';
								endfor;
								
								$grapheight--;
							endif;
						endwhile;
						
						if($grapwidth > 13):
							$alttext = 'Block Graphics';
						else:
							$alttext = '*';
						endif;
						
						$this->tokenised[$lnkey][$colkey] = 'IMAGE';
						$this->images[$lnkey][$colkey - $searchleft] = array($this->buildsymbolblock($convchars, $grapwidth, $grapheight, $bgcolour), $grapwidth, $grapheight, $alttext);
					endif;
				endforeach;
			endforeach;
		}
		
		private function builddbltext() {
			foreach($this->tokenised as $lnkey => $line):
				foreach($line as $colkey => $character):
					if(substr($this->tokenised[$lnkey][$colkey], 0, 5)=='CHAR_' && $this->textheights[$lnkey][$colkey]==convertmode7::TXHEIGHT_DBL):
						unset($convchars);
						$convchars[0][0][0] = $this->tokenised[$lnkey][$colkey];
						$convchars[0][0][1] = $this->textcolours[$lnkey][$colkey];
						$convchars[0][0][2] = $this->bkgdcolours[$lnkey][$colkey];
						$alttext = substr($this->tokenised[$lnkey][$colkey], 5);
						$flashmode = $this->flashs[$lnkey][$colkey];
						$bgcolour = $this->bkgdcolours[$lnkey][$colkey];
						$grapwidth = 1;
						$grapheight = 1;
						
						# Work out how wide the row of text is
						while($colkey + $grapwidth < 40 && ((substr($this->tokenised[$lnkey][$colkey + $grapwidth], 0, 5) == 'CHAR_' && $this->textheights[$lnkey][$colkey + $grapwidth]==convertmode7::TXHEIGHT_DBL) || $this->tokenised[$lnkey][$colkey + $grapwidth] == 'CHAR_SPACE') && $this->bkgdcolours[$lnkey][$colkey + $grapwidth] == $bgcolour && $this->flashs[$lnkey][$colkey + $grapwidth] == $flashmode):
							$convchars[0][$grapwidth][0] = $this->tokenised[$lnkey][$colkey + $grapwidth];
							$convchars[0][$grapwidth][1] = $this->textcolours[$lnkey][$colkey + $grapwidth];
							$convchars[0][$grapwidth][2] = $this->bkgdcolours[$lnkey][$colkey + $grapwidth];
							
							if($this->tokenised[$lnkey][$colkey + $grapwidth] == 'CHAR_SPACE'):
								$alttext.= ' ';
							else:
								$alttext.= substr($this->tokenised[$lnkey][$colkey + $grapwidth], 5);
							endif;
							
							$this->tokenised[$lnkey][$colkey + $grapwidth] = 'IMAGE';
							$grapwidth++;
						endwhile;
						
						# Trim any trailing spaces from the end of the row
						while($convchars[0][$grapwidth - 1][0] == 'CHAR_SPACE'):
							$grapwidth--;
							$this->tokenised[$lnkey][$colkey + $grapwidth] = $convchars[0][$grapwidth][0];
						endwhile;
						
						$alttext = rtrim($alttext);
						
						# See if the row below is double height text too
						$addnext = true;
						
						for($checknext = 0; $checknext < $grapwidth; $checknext++):
							if((substr($this->tokenised[$lnkey + 1][$colkey + $checknext], 0, 5) != 'CHAR_' || $this->textheights[$lnkey + 1][$colkey + $checknext]!=convertmode7::TXHEIGHT_DBL) && $this->tokenised[$lnkey + 1][$colkey + $checknext] != 'CHAR_SPACE'):
								$addnext = false;
								break;
							endif;
						endfor;
						
						if($addnext):
							for($addrow = 0; $addrow < $grapwidth; $addrow++):
								$convchars[1][$addrow][0] = $this->tokenised[$lnkey + 1][$colkey + $addrow];
								$convchars[1][$addrow][1] = $this->textcolours[$lnkey + 1][$colkey + $addrow];
								$convchars[1][$addrow][2] = $this->bkgdcolours[$lnkey + 1][$colkey + $addrow];
								$this->tokenised[$lnkey + 1][$colkey + $addrow] = 'IMAGE';
							endfor;
							
							$grapheight++;
						endif;
						
						$this->tokenised[$lnkey][$colkey] = 'IMAGE';
						$this->images[$lnkey][$colkey] = array($this->builddbltextblock($convchars, $grapwidth, $grapheight, $bgcolour), $grapwidth, $grapheight, $alttext);
					endif;
				endforeach;
			endforeach;
		}
		
		private function findblanklines() {
			foreach($this->tokenised as $lnkey => $line):
				$blankline = true;
				
				foreach($line as $colkey => $character):
					if($character != 'CHAR_SPACE'):
						$blankline = false;
						break;
					endif;
				endforeach;
				
				$this->blanklines[$lnkey] = $blankline;
			endforeach;
		}
		
		private function findcolspans() {
			$anchoringrow = true;
			
			# Make the text colour of spaces the same if possible, to allow the most merging
			foreach($this->tokenised as $lnkey => $line):
				for($colkey = 39; $colkey >= 0; $colkey--):
					if($colkey < 39):
						if($this->textcolours[$lnkey][$colkey] != $lastcolour && $this->tokenised[$lnkey][$colkey] == 'CHAR_SPACE' && $this->bkgdcolours[$lnkey][$colkey] == $lastbgcolour):
							$this->textcolours[$lnkey][$colkey] = $lastcolour;
						endif;
					endif;
					
					$lastcolour = $this->textcolours[$lnkey][$colkey];
					$lastbgcolour = $this->bkgdcolours[$lnkey][$colkey];
				endfor;
				
				foreach($line as $colkey => $character):
					if($colkey > 0):
						if($this->textcolours[$lnkey][$colkey] != $lastcolour && $character=='CHAR_SPACE' && $this->bkgdcolours[$lnkey][$colkey] == $lastbgcolour):
							$this->textcolours[$lnkey][$colkey] = $lastcolour;
						endif;
					endif;
					
					$lastcolour=$this->textcolours[$lnkey][$colkey];
					$lastbgcolour = $this->bkgdcolours[$lnkey][$colkey];
				endforeach;
			endforeach;
			
			# Calculate the column sizes
			foreach($this->tokenised as $lnkey => $line):
				$colspan = 1;
				$startcell = 0;
				
				foreach($line as $colkey => $character):
					if((!$anchoringrow || !$this->textonlylines[$lnkey]) && $colkey < count($line) - 1 && substr($character, 0, 5)=='CHAR_' && substr($this->tokenised[$lnkey][$colkey+1], 0, 5)=='CHAR_' && $this->textcolours[$lnkey][$colkey]==$this->textcolours[$lnkey][$colkey+1] && $this->bkgdcolours[$lnkey][$colkey]==$this->bkgdcolours[$lnkey][$colkey+1] && $this->flashs[$lnkey][$colkey]==$this->flashs[$lnkey][$colkey+1]):
						$colspan++;
					else:
						$this->colspans[$lnkey][$startcell] = $colspan;
						
						$colspan = 1;
						$startcell = $colkey + 1;
					endif;
				endforeach;
				
				$this->colspans[$lnkey][$startcell] = $colspan;
				
				if($anchoringrow && $this->textonlylines[$lnkey]):
					$anchoringrow = false;
				endif;
			endforeach;
			
			# Change the text colour of blank rows to allow the most merging
			for($lnkey = count($this->tokenised) - 2; $lnkey >= 0; $lnkey--):
				if($this->textonlylines[$lnkey] && $this->textonlylines[$lnkey + 1] && $this->colspans[$lnkey][0] == 40 && $this->colspans[$lnkey + 1][0] == 40 && $this->blanklines[$lnkey]):
					for($changecol = 0; $changecol < 40; $changecol++):
						$this->textcolours[$lnkey][$changecol] = $this->textcolours[$lnkey + 1][0];
					endfor;
				endif;
			endfor;
			
			for($lnkey = 1; $lnkey < count($this->tokenised); $lnkey++):
				if($this->textonlylines[$lnkey] && $this->textonlylines[$lnkey - 1] && $this->colspans[$lnkey][0] == 40 && $this->colspans[$lnkey - 1][0] == 40 && $this->blanklines[$lnkey]):
					for($changecol = 0; $changecol < 40; $changecol++):
						$this->textcolours[$lnkey][$changecol] = $this->textcolours[$lnkey - 1][0];
					endfor;
				endif;
			endfor;
		}
		
		private function generatehtml() {
			$this->html.='<table class="mode7 centralcol">';
			
			$mergerows = false;
			
			foreach($this->tokenised as $lnkey => $line):
				if(!$mergerows):
					$this->html.='<tr>';
				endif;
				
				foreach($line as $colkey => $character):
					if(substr($character, 0, 5)=='CHAR_'):
						if(isset($this->colspans[$lnkey][$colkey])):
							$cellcontents = '';
							
							for($fetchchars = 0; $fetchchars < ($this->colspans[$lnkey][$colkey]); $fetchchars++):
								switch($this->tokenised[$lnkey][$colkey + $fetchchars]):
									case 'CHAR_SPACE':
										$cellcontents.=' ';
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
										$cellcontents.=substr($this->tokenised[$lnkey][$colkey + $fetchchars], 5);
								endswitch;
							endfor;
							
							# Replace a cell just full of spaces with a single non-breaking space
							if(trim($cellcontents) == ''):
								$cellcontents = ' ';
							else:
								# Remove multiple spaces from the ends of cells
								$cellcontents=rtrim($cellcontents);
								# Replace a space at the start of a cell with a non-breaking space
								if(substr($cellcontents, 0, 1) == ' '):
									$cellcontents = ' '.substr($cellcontents, 1);
								endif;
								# Alternate standard and non-breaking spaces
								$cellcontents=str_replace('  ', '  ', $cellcontents);
							endif;
							
							$willmergerows = ($colkey == 0 && isset($this->tokenised[$lnkey + 1]) && $this->textonlylines[$lnkey] && $this->textonlylines[$lnkey + 1] && $this->colspans[$lnkey][0] == 40 && $this->colspans[$lnkey + 1][0] == 40 && $this->textcolours[$lnkey][0] == $this->textcolours[$lnkey + 1][0] && $this->bkgdcolours[$lnkey][0] == $this->bkgdcolours[$lnkey + 1][0] && $this->flashs[$lnkey][0] == $this->flashs[$lnkey + 1][0]);
							
							if(!$mergerows):
								$classes='';
								$this->html.='<td';
								
								if($this->textcolours[$lnkey][$colkey]!=convertmode7::COL_WHITE && ($cellcontents!=' ' || $willmergerows)):
									$classes.='t'.$this->textcolours[$lnkey][$colkey];
								endif;
								
								if($this->bkgdcolours[$lnkey][$colkey]!=convertmode7::COL_BLACK):
									$classes.=' b'.$this->bkgdcolours[$lnkey][$colkey];
								endif;
								
								if($this->flashs[$lnkey][$colkey]==convertmode7::FLASH_FLASH):
									$classes.=' flash';
								endif;
								
								if($classes != ''):
									$this->html.=' class="'.trim($classes).'"';
								endif;
								
								if($this->colspans[$lnkey][$colkey] > 1):
									$this->html.=' colspan="'.$this->colspans[$lnkey][$colkey].'"';
								endif;
								
								$this->html.='>';
							endif;
							
							$mergerows = $willmergerows;
							
							$this->html.=$cellcontents;
							
							if($mergerows):
								$this->html.="<br>\n";
							else:
								$this->html.='</td>';
							endif;
						endif;
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
							
							if($this->textcolours[$lnkey][$colkey]!=convertmode7::COL_WHITE):
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
							
							$this->html.= '><img src="'.$this->images[$lnkey][$colkey][0].'" alt="'.htmlspecialchars($this->images[$lnkey][$colkey][3]).'"></td>';
						endif;
					else:
						echo '<p>Unknown token '.$character.'</p>';
					endif;
				endforeach;
				
				if(!$mergerows):
					$this->html.="</tr>\n";
				endif;
			endforeach;
			
			$this->html.='</table>';
		}
		
		private function saveimage($image, $prefix, $suffix) {
			static $hashlookup;
			static $filenum;
			
			if(!isset($filenum[$prefix.$suffix])):
				$filenum[$prefix.$suffix] = 0;
			endif;
			
			if(!isset($hashlookup[$prefix.$suffix])):
				foreach(glob($prefix.'????'.$suffix) as $foundfile) {
					$hashlookup[$prefix.$suffix][hash_file('sha1', $foundfile)] = $foundfile;
				}
			endif;
			
			while(file_exists($prefix.str_pad($filenum[$prefix.$suffix], 4, '0', STR_PAD_LEFT).$suffix)):
				$filenum[$prefix.$suffix]++;
			endwhile;
			
			$savename = $prefix.str_pad($filenum[$prefix.$suffix], 4, '0', STR_PAD_LEFT).$suffix;
			
			ImagePNG($image, $savename);
			$imagehash = hash_file('sha1', $savename);
			
			if(isset($hashlookup[$prefix.$suffix][$imagehash])):
				unlink($savename);
				$savename = $hashlookup[$prefix.$suffix][$imagehash];
			else:
				$hashlookup[$prefix.$suffix][$imagehash] = $savename;
			endif;
			
			return $savename;
		}
		
		private function buildsymbolblock($symbols, $width, $height, $bgcolour) {
			$imgsym = ImageCreate(convertmode7::CHAR_WIDTH * $width, convertmode7::CHAR_HEIGHT * $height);
			
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
				$yoffset = $row * convertmode7::CHAR_HEIGHT;
				
				foreach($symbrow as $col => $symbol):
					$xoffset = $col * convertmode7::CHAR_WIDTH;
					
					if($symbol[0] == 'SPACE'):
						$symbol[0] = 0;
					endif;
					
					if($symbol[0] > 0):
						$colused[$symbol[1]] = true;
					endif;
					
					$firstcolx1 = $xoffset;
					$firstcolx2 = ($xoffset + convertmode7::CHAR_WIDTH / 2) - 1;
					$secondcolx1 = $xoffset + convertmode7::CHAR_WIDTH / 2;
					$secondcolx2 = ($xoffset + convertmode7::CHAR_WIDTH) -1;
					
					$firstrowy1 = $yoffset;
					$firstrowy2 = ($yoffset + convertmode7::CHAR_HEIGHT / 3) -1;
					$secondrowy1 = $yoffset + convertmode7::CHAR_HEIGHT / 3;
					$secondrowy2 = ($yoffset + (convertmode7::CHAR_HEIGHT / 3 ) * 2) - 1;
					$thirdrowy1 = $yoffset + (convertmode7::CHAR_HEIGHT / 3) * 2;
					$thirdrowy2 = ($yoffset + convertmode7::CHAR_HEIGHT) - 1;
					
					if($symbol[2] == convertmode7::MODE_SEPERA):
						$firstcolx1 += 2;
						$secondcolx1 += 2;
						$firstrowy2 -= 2;
						$secondrowy2 -= 2;
						$thirdrowy2 -= 2;
					endif;
					
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
			
			$savename = $this->saveimage($imgsym, 'temp/web/common/mode7/graph', '.png');
			imagedestroy($imgsym);
			
			return substr($savename, 8);
		}
		
		private function setimagecolour($image, $index, $colour) {
			switch($colour) {
				case convertmode7::COL_BLACK:
					ImageColorSet($image, $index, 0, 0, 0);
					break;
				case convertmode7::COL_RED:
					ImageColorSet($image, $index, 255, 0, 0);
					break;
				case convertmode7::COL_GREEN:
					ImageColorSet($image, $index, 0, 255, 0);
					break;
				case convertmode7::COL_YELLOW:
					ImageColorSet($image, $index, 255, 255, 0);
					break;
				case convertmode7::COL_BLUE:
					ImageColorSet($image, $index, 0, 0, 255);
					break;
				case convertmode7::COL_MAGENTA:
					ImageColorSet($image, $index, 255, 0, 255);
					break;
				case convertmode7::COL_CYAN:
					ImageColorSet($image, $index, 0, 255, 255);
					break;
				case convertmode7::COL_WHITE:
					ImageColorSet($image, $index, 255, 255, 255);
					break;
			}
		}
		
		private function builddbltextblock($characters, $width, $height, $bgcolour) {
			$imgchars = ImageCreateTrueColor(convertmode7::CHAR_WIDTH * $width, convertmode7::CHAR_HEIGHT * $height);
			
			foreach($characters as $row => $charrow):
				$yoffset = $row * convertmode7::CHAR_HEIGHT;
				$rowtype = $row % 2;
				
				foreach($charrow as $col => $character):
					$xoffset = $col * convertmode7::CHAR_WIDTH;
					
					if($character[0] == 'CHAR_SPACE'):
						$charcode = 32;
					else:
						$charcode = ord(substr($character[0], 5));
					endif;
					
					$srcimg = ImageCreateFromGIF('font/'.$charcode.'.gif');
					
					$this->setimagecolour($srcimg, 0, $character[2]);
					$this->setimagecolour($srcimg, 1, $character[1]);
					
					ImageCopyResampled($imgchars, $srcimg, $xoffset, $yoffset, 0, $rowtype * (ImageSy($srcimg) / 2), convertmode7::CHAR_WIDTH, convertmode7::CHAR_HEIGHT, ImageSx($srcimg) - 1, (ImageSy($srcimg) / 2) - 1);
					
					imagedestroy($srcimg);
				endforeach;
			endforeach;
			
			$savename = $this->saveimage($imgchars, 'temp/web/common/mode7/dbltxt', '.png');
			imagedestroy($imgchars);
			
			return substr($savename, 8);
		}
	}
?>