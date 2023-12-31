#include <nuon/dma.h>
#include <nuon/bios.h>
#include <nuon/mutil.h>
#include <nuon/mml2d.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define SCREENWIDTH 			(720)
#define SCREENHEIGHT 			(480)

#define OVL_SCREENWIDTH 		(360)
#define OVL_SCREENHEIGHT 		(240)

#define MAIN_PIXFORMAT			e888Alpha
#define MAIN_BACKGROUND 		(0x30808000)	/* grey */

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


#if 1					 	// e888Alpha for overlay

#define OVERLAY_BITS			(32)
#define OVERLAY_PIXFORMAT		e888Alpha
#define OVERLAY_BACKGROUND		(0x108080ff)	/* black with $FF alpha */
#define OVERLAY_TEXTCOLOR		(0xc0808000)

#else 						// e655 for overlay

#define OVERLAY_BITS			(16)
#define OVERLAY_PIXFORMAT		e655
#define OVERLAY_BACKGROUND		(0x108080ff)	/* OVERLAY transparent value */
#define OVERLAY_TEXTCOLOR		((0x3F<<10)|(0x04<<5)|(0x04))

#endif

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define DEFAULT_BORDER_COLOR	(0x10808000)	/* black */

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

extern mmlGC			gl_gc;
extern mmlSysResources 	gl_sysRes;
extern mmlDisplayPixmap	gl_screenbuffers[3];

extern int				gl_drawbuffer;
extern int				gl_displaybuffer;
extern int				gl_overlaybuffer;

extern int screenwidth, screenheight, linewidths, videofilter;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void test_controller(void);
void ClearScreen(mmlDisplayPixmap *scrn, mmlColor clr);
void ClearLines(mmlDisplayPixmap *scrn, mmlColor clr, int y_start, int y_end);
int adjust_screen_size(void);
void create_display(mmlDisplayPixmap *draw, mmlDisplayPixmap *ovl);


