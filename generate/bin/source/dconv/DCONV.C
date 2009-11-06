/* Convert BBC disk image -> archive format
   supply name of image, dest. directory
   If dest directory does not exist it will be created.
   If dest directory is not specified then CWD will be used.

*/
#define STRICT                  // Enable strict type checking
#define WIN32_LEAN_AND_MEAN     // Exclude rarely-used stuff from Windows headers

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <windows.h>
#include <stdarg.h>
#include <direct.h>

#define INLINE

/* These are used for the decoding of the disk image */
typedef unsigned char byte;
typedef unsigned short int word;
typedef unsigned long int dword;
/* These are for where the size makes a difference */
typedef signed char int8;
typedef signed short int int16;
typedef signed long int int32;

/* Characters which can't be used in MS-DOS filenames. They will be replaced
   with '_'. */
char *InvalidCharacters={"%\"*?^+:;/<>.[],`="};

char *ConvertResults[]={"OK","Image open error","Image read error"};

int DoHelp=0;

/* First 4 sectors of disk, holding catalogue (2 for Acorn DFS) */
byte SectorCache[256];
int SectorCache_Track=-1,SectorCache_Sector=-1,SectorCache_Side=-1;
FILE *DiskImageHandle;

char *InputFilename=NULL;
char *OutputPath=NULL;

/* Interleave modes */
/* Track interleave -- most common, required by BeebEm */
#define TRACK 0
/* Sector interleave -- not sure if these exist */
#define SECTOR 1
/* Side interleave -- one side after the other. */
#define SIDE 2

/* Details about the disk */
unsigned int NumTracks=0;		/* # tracks on the disk, if specified */
int InterleaveMode=-1;	 		/* Interleave mode for double-sided disks */
int Side=-1;					/* Side to convert */
int DoubleSided=0;				/* Flag: double-sided or not */
int NumFiles=0;					/* Specified # of files */

struct _BBCfile {
	char dir;							/* 1-character directory */
	char name[8];						/* name on BBC */
	dword exec;							/* 32-bit execution address */
	dword length;						/* 32-bit length */
	dword load;							/* 32-bit load address */
	int locked;							/* 1=locked, 0=not */
	int startsector;					/* Start sector */
	char PCfilename[9];					/* Filename on PC */
}files[62];

int Nextfile=0;

void err(int errcode,char *fmt,...) {
	va_list j;

	va_start(j,fmt);
	vprintf(fmt,j);
	va_end(j);
	exit(errcode);
}

struct _BBCfile *FindFilename(char *file2find) {
	int j = 0;

	while(j<Nextfile && _stricmp(files[j].PCfilename,file2find)!=0) {
		j++;
	}
	if(j>=Nextfile) {
		return(NULL);
	} else {
		return(&files[j]);
	}
}

INLINE void *xmalloc(size_t s) {
	void *tmp;

	tmp=malloc(s);
	if(tmp==NULL) {
		printf("Error allocating %u bytes\n",s);
		exit(1);
	}
	return(tmp);
}

/* Returns 1 if the character 'c' is invalid in MS-DOS names. */
int isinvalid(char c) {
    return(strchr(InvalidCharacters,c)!=NULL);
}

/* PC files are one character dir+seven character filename, with any invalid
   MS-DOS characters turned into '_'. */
void ConverttoPC(char *destPC,char BBCdir,char *BBCname) {
	unsigned int j;

	destPC[0]=BBCdir;
	strcpy(destPC+1,BBCname);
	for(j=0;j<strlen(destPC);j++) {
		if(isinvalid(destPC[j])) {
			destPC[j]='_';
		}
	}
}

INLINE byte GetDiskByte(int side,int track,int sector,int offset) {
	size_t r;
    long int new_offset;

	if(SectorCache_Track<0 || SectorCache_Sector<0) {
        DiskImageHandle=fopen(InputFilename,"rb");
        if(DiskImageHandle==NULL) {
            err(1,"Unable to initialise disk image %s",InputFilename);
        }
    }
	if((DoubleSided && side!=SectorCache_Side) || track!=SectorCache_Track || sector!=SectorCache_Sector) {
        if(DoubleSided) {
			switch(InterleaveMode) {
				case SECTOR:
                    new_offset=2*sector+20*track+side;
                    break;
                case TRACK:
                    new_offset=sector+20*track+side*10;
                    break;
                case SIDE:
                    new_offset=sector+10*track+(side*(NumTracks*10));
                    break;
                default:
                    err(1,"This error shouldn't happen: Unrecognised interleave mode");
                    break;
            }
        } else {
            new_offset=sector+10*track;
        }
        fseek(DiskImageHandle,new_offset*256,SEEK_SET);
        r=fread(SectorCache,256,1,DiskImageHandle);
        if(r!=1) {
            char sidetext[10];

            if(DoubleSided) {
				sprintf(sidetext,"side %d ");
			} else {
				strcpy(sidetext,"");
            }
            err(1,"Error reading disk image, %strack %d sector %d",sidetext);
        }
        SectorCache_Track=track;
        SectorCache_Sector=sector;
        SectorCache_Side=side;
    }
	return(SectorCache[offset & 0xFF]);
}

int Convert(void) {
	int cat,j,j2;
	FILE *oh;
    int NumCatalogues;
	char AutoDetectBuf[8],CompareBuf[8]={0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA};

	printf("Converting disk %s, into %s\n",InputFilename,OutputPath);
	if(NumFiles==31) {
		NumCatalogues=1;
	} else if(NumFiles==62) {
		NumCatalogues=2;
	} else {
		/* Auto-detect number of catalogues */
		/* Check side X, track 0, sector 2. First 8 bytes are 0xAA if the
		disk is a 62-file job. Of course this might lead to misdetection,
		which is the reason for the command-line parameter.
		*/
		int j;

		for(j=0;j<8;j++) {
            AutoDetectBuf[j]=GetDiskByte(Side,0,2,j);
        }
        if(memcmp(AutoDetectBuf,CompareBuf,8)==0) {
            NumCatalogues=2;
        } else {
			NumCatalogues=1;
		}
	}
	/* now go through the catalogue */
	/* For Watford DFs, there are two: one in sectors 0+1, one in sectors 2+3.
	   They appear to be pretty much separate. */
	printf("This disk has %d catalogues\n",NumCatalogues);
	for(cat=0;cat<NumCatalogues;cat++) {
		int names,infos;
		int numfiles;

		/* Catalogue sectors */
		names=cat*2;
		infos=cat*2+1;
		numfiles=GetDiskByte(Side,0,infos,5)>>3;
		for(j=0;j<numfiles;j++) {
			int ko,namedone=0;
			char tfilename[10]; /* X.1234567<0> */
			byte ExtraByte;		/* Extra fiddly catalogue byte */

			ko=8+j*8;
			memset(tfilename,0,10);
            tfilename[0]=GetDiskByte(Side,0,names,ko+7) & 0x7F;
			tfilename[1]='.';
			files[Nextfile].dir=tfilename[0];
			for(j2=0;j2<7 && !namedone;j2++) {
				if(GetDiskByte(Side,0,names,ko+j2)==32) {
					namedone=1;
				} else {
                    tfilename[2+j2]=GetDiskByte(Side,0,names,ko+j2);
				}
			}
			/* copy it into the list of files */
			strcpy(files[Nextfile].name,tfilename+2);
			/* First the load address */
            files[Nextfile].load=GetDiskByte(Side,0,infos,ko);
			files[Nextfile].load|=((long)GetDiskByte(Side,0,infos,ko+1))<<8;
			ExtraByte=GetDiskByte(Side,0,infos,ko+6);
            if(ExtraByte & (128+64)) {
				files[Nextfile].load|=(unsigned long int)0xFFFF0000;
			}
			/* Now the execution address */
            files[Nextfile].exec=GetDiskByte(Side,0,infos,ko+2);
            files[Nextfile].exec|=(long)GetDiskByte(Side,0,infos,ko+3)<<8;
            if(ExtraByte & (8+4)) {
				files[Nextfile].exec|=(unsigned long int)0xFFFF0000;
			}
			/* Now the length */
            files[Nextfile].length=GetDiskByte(Side,0,infos,ko+4);
            files[Nextfile].length|=(long)GetDiskByte(Side,0,infos,ko+5)<<8;
            files[Nextfile].length|=((((long)GetDiskByte(Side,0,infos,ko+6))>>4) & 3)<<16L;
			/* And the start sector */
            files[Nextfile].startsector=GetDiskByte(Side,0,infos,ko+7);
			files[Nextfile].startsector|=(((long)ExtraByte) & 3)<<8;
			/* Locked? */
            files[Nextfile].locked=(GetDiskByte(Side,0,names,ko+7) & 0x80)>0;
			/* Convert to PC format -- duplicates will be fixed later */
			ConverttoPC(files[Nextfile].PCfilename,files[Nextfile].dir,files[Nextfile].name);
			Nextfile++;
		}
	}
	/* now scan through, making the PC names and checking for any
	   duplicates. Start from the last file, and check all those before
	   it. The check ignores directories. */
	/*
		Start at last filename
		Repeat
			Search for current filename in table
			If it exists then
				Alter current filename
			.
		Until at first filename
		Stop
	*/
	for(j=Nextfile-1;j<0;j--) {
		struct _BBCfile *r;

		/* is this one already there? */
		r=FindFilename(files[j].PCfilename);
		if(r!=NULL) {
			char tmpPCname[9],tmpnum[3];
			int npos,NumericTail=0;

			/* Current record needs sorting out */
			strcpy(tmpPCname,files[j].PCfilename);
			npos=strlen(tmpPCname);
			if(npos>6) {
				npos=6;
			}
			while(FindFilename(tmpPCname)!=NULL) {
				sprintf(tmpnum,"%02d",NumericTail);
				tmpPCname[npos]=tmpnum[0];
				tmpPCname[npos+1]=tmpnum[1];
				tmpPCname[npos+2]=0;
				NumericTail++;
			}
			/* Done! */
			strcpy(files[j].PCfilename,tmpPCname);
		}
	}
	/* Now write out the files */
	for(j=0;j<Nextfile;j++) {
		unsigned int byt;
		char INFfile[MAX_PATH],DATfile[MAX_PATH];
		unsigned int CurrentTrack,CurrentSector,sector;

		INFfile[0] = 0;
		DATfile[0] = 0;

		strcpy(INFfile,OutputPath);
		strcat(INFfile, "\\");
		strcat(INFfile,files[j].PCfilename);
		strcat(INFfile,".inf");

		strcpy(DATfile,OutputPath);
		strcat(DATfile, "\\");
		strcat(DATfile,files[j].PCfilename);

		/* Print out some information to keep the user happy */
		printf("%c.%-8s %c %08lX %08lX %08lX %03X -> %s\n",files[j].dir,files[j].name,files[j].locked?'L':' ',files[j].load,
			files[j].exec,files[j].length,files[j].startsector,files[j].PCfilename);

		/* now write it out */
		oh=fopen(INFfile,"w");
		if(oh==NULL) {
			err(1,"Failed attempt to open %s",INFfile);
		}
		fprintf(oh,"%c.%s %08lX %08lX %08lX %c\n",files[j].dir,files[j].name,
			files[j].load,files[j].exec,files[j].length,files[j].locked?'L':' ');
		fclose(oh);
		oh=fopen(DATfile,"wb");
		if(oh==NULL) {
			err(1,"Failed attempt to open %s",DATfile);
		}
		CurrentTrack=files[j].startsector/10;
		CurrentSector=files[j].startsector % 10;
		if((files[j].length/256)>0) {
			for(sector=0;sector<(files[j].length/256);sector++) {
				/* copy one sector */
				for(byt=0;byt<256;byt++) {
					int tmp;

					tmp=GetDiskByte(Side,CurrentTrack,CurrentSector,byt);
					fputc(tmp,oh);
				}
				CurrentSector++;
				if(CurrentSector>=10) {
					CurrentSector=0;
					CurrentTrack++;
					if(NumTracks==40 || NumTracks==80) {
						if(CurrentTrack>=NumTracks) {
							err(1,"File ran off end of disk!");
						}
					}
				}
			}
		}
		/* write out the end bit */
		byt=0;
		while(byt<(files[j].length % 256)) {
			int tmp;

			tmp=GetDiskByte(Side,CurrentTrack,CurrentSector,byt);
			fputc(tmp,oh);
			byt++;
		}
		fclose(oh);
	}
	return(0);
}

/*
   Specify on command line:
	-d <file>       Name of disk image
	-o <path>       Where to put everything
	-40|80          Select 40- or 80-track disk
	-31             Force 31-file DFS           \ Default is to
	-62             Force 62-file Watford DFS   / auto-detect
	-side <side>    Selects side, 0 or 1. This implies double-sided image.
    -interleave <track|side|sector>
					Sides are interleaved, one after the other, tracks from
					alternate sides, sectors from alternate sides.
                    (Default: track)
*/
void ProcessCommandline(int argc,char *argv[]) {
	int j=1;

	while(j<argc) {
		if(_stricmp(argv[j],"-side")==0) {
			j++;
			if(j<argc) {
				if((argv[j][0]=='0' || argv[j][0]=='1') && argv[j][1]==0) {
					Side=argv[j][0]-'0';
					DoubleSided=1;
				} else {
					err(1,"Error in -side parameter");
				}
			} else {
				err(1,"Error in -side parameter");
			}
		} else if(_stricmp(argv[j],"-d")==0 || _stricmp(argv[j],"-disk")==0) {
			j++;
			if(j<argc) {
				InputFilename=xmalloc(strlen(argv[j])+1);
				strcpy(InputFilename,argv[j]);
			} else {
				err(1,"Error in -disk parameter");
			}
		} else if(_stricmp(argv[j],"-o")==0) {
			j++;
			if(j<argc) {
				OutputPath=xmalloc(strlen(argv[j])+1);
				strcpy(OutputPath,argv[j]);
			} else {
				err(1,"Error in -o parameter");
			}
		} else if(_stricmp(argv[j],"-interleave")==0) {
			j++;
			if(j<argc) {
				if(_stricmp(argv[j],"track")==0) {
					InterleaveMode=TRACK;
				} else if(_stricmp(argv[j],"sector")==0) {
					InterleaveMode=SECTOR;
				} else if(_stricmp(argv[j],"side")==0) {
					InterleaveMode=SIDE;
				} else {
					err(1,"Unrecognised type in -interleave parameter");
				}
			} else if(_stricmp(argv[j],"-help")==0 || _stricmp(argv[j],"-h")==0) {
				DoHelp=1;
			} else {
				err(1,"Error in -interleave parameter");
			}
		} else if(_stricmp(argv[j],"-31")==0 || _stricmp(argv[j],"-62")==0) {
            NumFiles=(_stricmp(argv[j],"-31")==0)?31:62;
        } else if(_stricmp(argv[j],"-40")==0 || _stricmp(argv[j],"-80")==0) {
            NumTracks=(_stricmp(argv[j],"-40")==0)?40:80;
        } else {
            err(1,"Unrecognised parameter %s",argv[j]);
        }
		j++;
	}
}

/*
   Specify on command line:
    -d <file>       Name of disk image
    -o <path>       Where to put everything
    -40|80          Select 40- or 80-track disk
    -31             Force 31-file DFS           \ Default is to
    -62             Force 62-file Watford DFS   / auto-detect
	-side <side>    Selects side, 0 or 1.
					This implies double-sided image.
	-interleave <track|side|sector>
					Sides are interleaved, one after the other, tracks from
					alternate sides, sectors from alternate sides.
					(Default: track)
*/
int main(int argc,char *argv[]) {
	int r;
	HANDLE hFind;
	WIN32_FIND_DATA fi;

	printf("Disk Image Converter, v2.0\n");
	ProcessCommandline(argc,argv);
	if(argv[1]==NULL || DoHelp) {
		printf("This utility will convert a DFS disk image into Wouter Scholten's archive\n");
		printf("format. Images can be 40- or 80-track, single- or double-sided and may\n");
		printf("have either 31 (Acorn) or 62 (Watford) file spaces in the catalogue.\n");
		printf("\nPossible parameters:\n");
		printf("\t-d <file> *Obligatory*\n");
		printf("\t\tSpecifies the name of the disk image to convert.\n");
		printf("\t-o <path>\n");
		printf("\t\tSpecifies the output path for the converted files. If the\n");
		printf("\t\tdirectory you specify does not exist, it will be created.\n");
		printf("\t\tIf you specify the destination directory as \"*\", the\n");
		printf("\t\tdisk image will be converted into a new directory with\n");
		printf("\t\tthe name of the disk image without its extension.\n");
		printf("\t\tIf no output path is specified, the current directory will\n");
		printf("\t\tbe used.\n");
		printf("\t-40|80\n");
		printf("\t\tSpecifies the number of tracks on the disk.\n");
		printf("\t-31|62\n");
		printf("\t\tForces the number of files in the catalogue. This will\n");
		printf("\t\tbe autodetected by default.\n");
		printf("\t-side <side>\n");
		printf("\t\tIndicates the side to convert. This implies that the disk\n");
		printf("\t\tis double-sided -- don't use with single-sided images.\n");
		printf("\t-interleave <track|side|sector>\n");
        printf("\t\tSpecifies the interleave type. Use with the -side parameter\n");
        printf("\t\tonly. 'track' indicates that tracks come from alternating\n");
        printf("\t\tsides -- this is a BeebEm-style disk image. 'side' indicates\n");
        printf("\t\tthat the sides are stored one after the other, side 0 first.\n");
        printf("\t\t'sector' indicates that the sectors come from alternating\n");
		printf("\t\tsides.\n");
        printf("\n");
        printf("Any problems, send e-mail to T.W.Seddon@ncl.ac.uk and I'll try to help.\n");
        exit(1);
    }
	/* Input file specified? */
	if(InputFilename==NULL) {
		err(1,"No disk image specified on command-line");
	}
	/* Options compatible? */
	if(NumTracks==0 && InterleaveMode==SIDE) {
		err(1,"Cannot have side interleave without specifying the number of tracks\n");
	}
	if(!DoubleSided) {
		if(InterleaveMode!=-1) {
			err(1,"Cannot have an interleave type with a single-sided image");
		}
	} else {
		if(InterleaveMode==-1) {
			InterleaveMode=TRACK;
		}
	}

	/* Now do everything */
	if(OutputPath==NULL) {
		OutputPath=xmalloc(MAX_PATH+1);
		_getcwd(OutputPath,MAX_PATH);
	} else {
		if(_stricmp(OutputPath,"*")==0) {
			/* Dest. dir is filename w/o extension */
			if(strlen(InputFilename) > 0) {
				char *pPos = "";

				// Check if the input filename contains a slash
				if (strchr(InputFilename, '\\') == NULL)
				{
					// Copy the whole input filename
					strcpy(OutputPath, InputFilename);
				}
				else
				{
					// Copy just the filename
					char *tempTitle = strrchr(InputFilename, '\\') + 1;
					strcpy(OutputPath, tempTitle);
				}

				// Get a pointer to the dot
				pPos = strrchr(OutputPath, '.');

				if(pPos != NULL) {
					// Trim off the extension by setting the dot to null
					*pPos = '\0';
				}
			}
		}
	}

	// check for existence of destination directory
	hFind = FindFirstFile(OutputPath, &fi);
	if(hFind == INVALID_HANDLE_VALUE) {
		// Folder does not exist, so create it
		int r = _mkdir(OutputPath);

		if(r < 0) {
			perror("mkdir error:");
			return(1);
		}
	} else {
		if(!(fi.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
			// dest exists but is a file 
            err(1,"Destination is a file!");
		}
	}

	/* Everything should be hunkydory now */
	r=Convert();
	printf("Result: %s\n",ConvertResults[r]);
	return(0);
}
