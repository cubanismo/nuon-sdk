
include $(VMLABS)/util/nuon_build_tools.mk

###############################

DEFINES =
CFLAGS = -g -Os -Wall $(DEFINES)
LDFLAGS = 
OBJ = playmidi.o


NUON.CD: playmidi.cof
	vmstrip -F -o foo.cof playmidi.cof
	CreateNuonCD foo.cof
	$(RM) foo.cof 
	
playmidi.cof: $(OBJ)
	$(CC) -o $@ $(OBJ) -lcdn50x -lsynth -lmutil -lterm -mpe3 -mrom

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
