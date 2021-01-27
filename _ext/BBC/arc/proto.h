/*
 * On 15 Sep 2003 Thom Henderson, the original author of arc, agreed to put
 * arc under a free license. On 7 Oct 2003 Howard Chu, the maintainer of the
 * unix version of arc decided to put it under the GNU General Public License
 */

u_int	getbuf PROTO ((FILE *f));
u_int	getb_ucr PROTO ((FILE *f));
u_int	getb_usq PROTO ((FILE *f));
u_int	getb_unp PROTO ((FILE *f));
VOID	hufb_tab PROTO ((u_char *buf, u_int len));
VOID	 lzw_buf PROTO ((u_char *buf, u_int len, FILE *f));
VOID	putb_unp PROTO ((u_char *buf, u_int len, FILE *f));
VOID	putb_ncr PROTO ((u_char *buf, u_int len, FILE *f));
VOID	putb_pak PROTO ((u_char *buf, u_int len, FILE *f));
VOID	upper PROTO ((char *string));
int		move PROTO ((char *oldnam, char *newnam));
int		crcbuf PROTO ((int, u_int, u_char *));
FILE *	tmpopen PROTO ((char *path));
