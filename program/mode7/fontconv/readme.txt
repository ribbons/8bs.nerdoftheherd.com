SHORT NOTICE:
A/ demo
B/ install
C/ post-install (mouse menu)
D/ info

                *********** EBDJPG ***********

before installing (with install.bat),
you could try ebdjpg.exe whith the included pictures: PICT*

A)----------------------------------------------
demo: launch demo.bat
*****
1/ that will create a subdirectory (_ebdjpg_2p4) 
   with the resized pictures.
	ebdjpg -max 480 -dir .  -nocp "(c)ebdjpg"
  (or ebdjpg -max 480 <files> -nocp "(c)ebdjpg" )
  "cp" is used for copyright...

2/ that will make a web presentation: "_ebdjpg_2p4/ebdjpg.htm"
	ebdjpg -album 4x0+640x0 -dir _ebdjpg_2p4

you can try by yourself, in the DOS Command 

B)----------------------------------------------
install: launch install.bat
********
that will install ebdjpg.exe and the needed files 
	(cygwin1.dll and cygjpeg6b.dll, and cyg*.dll) in the Windows directory
	(copy only ebdjpg.exe, if you have cygwin installed)
Unfortunately, there's no remover/uninstall; 
you'll have to do it by yourself...

C)----------------------------------------------
post-install: mouse-menu.
*************
in order to have quick access to ebdjpg under windows explorer, 
	you can launch 
	- "ebdjpgxp.reg", if you are under winxp
	- "ebdjpg2K.reg", if you are under win2000
	- "ebdjpg98.reg", if you are under win98
You will be able to run ebdjpg under the explorer of Windows,
	by right-clicking on your mouse, then typing "1" or "2"
Unfortunately, you'll have to launch regedit manually, in order
	to remove these shortcuts. (and search "_ebdjpg")

D)----------------------------------------------
info:
*****
EBDJPG is ABSOLUTELY FREE. 
I take no garanty of any files on your own computer. 
****************************************************
Although this program should not erase files/pictures on your disk, there may left some bugs on it; 
It has not been tested on every Windows OS. So, don't forget to make backups of your original pictures. 
USE EBDJPG AT YOUR OWN RISK. 

E. Baud.