#if !defined(NUONRASTERBASE_H)
#define NUONRASTERBASE_H

#ifndef WIN32
#include <nuon/mml2d.h>
#endif

#include "hsGRasterDevice.h"

class NuonRasterBase : public hsGRasterDevice {
public:
#ifndef WIN32
    virtual mmlDisplayPixmap* GetDisplayPixmapP(void) = 0;
	virtual void* GetLocalRamAdr(void) = 0;
#endif
};

#endif /* NUONRASTERBASE_H */
