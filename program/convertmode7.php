<?php
	class convertmode7 extends convert {
		private $tokenised;
		private $textcolours;
		private $bkgdcolours;
		
		public function convertmode7($filename, $title, $trimscroller) {
			echo '<p>TODO: Mode 7 conversion</p>';
			$this->html='mode7 conversion';
			
			$this->tokeniseinput($filename, $trimscroller);
			$this->generatehtml();
		}
		
		private function tokeniseinput($filename, $trimscroller) {
			if($trimscroller):
				$startpos=255;
			else:
				$startpos=0;
			endif;
			
			$row=0;
			$column=0;
			
			$file=implode('', file($filename));
			
			for($filepos=$startpos; $filepos < strlen($file); $filepos++):
				switch(ord($file[$filepos])):
					case 32:
						$this->tokenised[$row][$column]="CHAR_SPACE";
						break;
					case 65:
					case 193:
						$this->tokenised[$row][$column]="CHAR_A";
						break;
					case 66:
					case 194:
						$this->tokenised[$row][$column]="CHAR_B";
						break;
					case 67:
					case 195:
						$this->tokenised[$row][$column]="CHAR_C";
						break;
					case 68:
					case 196:
						$this->tokenised[$row][$column]="CHAR_D";
						break;
					case 69:
					case 197:
						$this->tokenised[$row][$column]="CHAR_E";
						break;
					case 70:
					case 198:
						$this->tokenised[$row][$column]="CHAR_F";
						break;
					case 71:
					case 199:
						$this->tokenised[$row][$column]="CHAR_G";
						break;
					case 72:
					case 120:
						$this->tokenised[$row][$column]="CHAR_H";
						break;
					case 73:
					case 121:
						$this->tokenised[$row][$column]="CHAR_I";
						break;
					case 74:
					case 122:
						$this->tokenised[$row][$column]="CHAR_J";
						break;
					case 75:
					case 123:
						$this->tokenised[$row][$column]="CHAR_K";
						break;
					case 76:
					case 124:
						$this->tokenised[$row][$column]="CHAR_L";
						break;
					case 77:
					case 125:
						$this->tokenised[$row][$column]="CHAR_M";
						break;
					case 78:
					case 126:
						$this->tokenised[$row][$column]="CHAR_N";
						break;
					case 79:
					case 127:
						$this->tokenised[$row][$column]="CHAR_O";
						break;
					case 80:
					case 128:
						$this->tokenised[$row][$column]="CHAR_P";
						break;
					case 81:
					case 129:
						$this->tokenised[$row][$column]="CHAR_Q";
						break;
					case 82:
					case 130:
						$this->tokenised[$row][$column]="CHAR_R";
						break;
					case 83:
					case 131:
						$this->tokenised[$row][$column]="CHAR_S";
						break;
					case 84:
					case 132:
						$this->tokenised[$row][$column]="CHAR_T";
						break;
					case 85:
					case 133:
						$this->tokenised[$row][$column]="CHAR_U";
						break;
					case 86:
					case 134:
						$this->tokenised[$row][$column]="CHAR_V";
						break;
					case 87:
					case 135:
						$this->tokenised[$row][$column]="CHAR_W";
						break;
					case 88:
					case 136:
						$this->tokenised[$row][$column]="CHAR_X";
						break;
					case 89:
					case 137:
						$this->tokenised[$row][$column]="CHAR_Y";
						break;
					case 90:
					case 138:
						$this->tokenised[$row][$column]="CHAR_Z";
						break;
					case 97:
					case 225:
						$this->tokenised[$row][$column]="CHAR_a";
						break;
					case 98:
					case 226:
						$this->tokenised[$row][$column]="CHAR_b";
						break;
					case 99:
					case 227:
						$this->tokenised[$row][$column]="CHAR_c";
						break;
					case 100:
					case 228:
						$this->tokenised[$row][$column]="CHAR_d";
						break;
					case 101:
					case 229:
						$this->tokenised[$row][$column]="CHAR_e";
						break;
					case 102:
					case 230:
						$this->tokenised[$row][$column]="CHAR_f";
						break;
					case 103:
					case 231:
						$this->tokenised[$row][$column]="CHAR_g";
						break;
					case 104:
					case 232:
						$this->tokenised[$row][$column]="CHAR_h";
						break;
					case 105:
					case 233:
						$this->tokenised[$row][$column]="CHAR_i";
						break;
					case 106:
					case 234:
						$this->tokenised[$row][$column]="CHAR_j";
						break;
					case 107:
					case 235:
						$this->tokenised[$row][$column]="CHAR_k";
						break;
					case 108:
					case 236:
						$this->tokenised[$row][$column]="CHAR_l";
						break;
					case 109:
					case 237:
						$this->tokenised[$row][$column]="CHAR_m";
						break;
					case 110:
					case 238:
						$this->tokenised[$row][$column]="CHAR_n";
						break;
					case 111:
					case 239:
						$this->tokenised[$row][$column]="CHAR_o";
						break;
					case 112:
					case 240:
						$this->tokenised[$row][$column]="CHAR_p";
						break;
					case 113:
					case 241:
						$this->tokenised[$row][$column]="CHAR_q";
						break;
					case 114:
					case 242:
						$this->tokenised[$row][$column]="CHAR_r";
						break;
					case 115:
					case 243:
						$this->tokenised[$row][$column]="CHAR_s";
						break;
					case 116:
					case 244:
						$this->tokenised[$row][$column]="CHAR_t";
						break;
					case 117:
					case 245:
						$this->tokenised[$row][$column]="CHAR_u";
						break;
					case 118:
					case 246:
						$this->tokenised[$row][$column]="CHAR_v";
						break;
					case 119:
					case 247:
						$this->tokenised[$row][$column]="CHAR_w";
						break;
					case 120:
					case 248:
						$this->tokenised[$row][$column]="CHAR_x";
						break;
					case 121:
					case 249:
						$this->tokenised[$row][$column]="CHAR_y";
						break;
					case 122:
					case 250:
						$this->tokenised[$row][$column]="CHAR_z";
						break;
					default:
						echo '<p>Unknown character value '.ord($file[$filepos]).' - unable to tokenise.</p>';
						$this->tokenised[$row][$column]="CHAR_SPACE";
				endswitch;
				
				$column++;
				
				if($column>39):
					$column=0;
					$row++;
				endif;
			endfor;
		}
		
		private function generatehtml() {
			$this->html.='<table>';
			
			foreach($this->tokenised as $line):
				$this->html.='<tr>';
				
				foreach($line as $character):
					$this->html.='<td>';
					
					switch($character):
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
						case 'CHAR_SPACE':
							$this->html.='&nbsp;';
							break;
						default:
							echo '<p>Unknown token '.$character.'</p>';
					endswitch;
					
					$this->html.='</td>';
				endforeach;
				
				$this->html.='</tr>';
			endforeach;
			
			$this->html.='</table>';
		}
	}
?>