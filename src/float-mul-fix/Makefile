########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES = -DC_VERSION=0
CFLAGS = -O2 $(DEFINES) -Wall
LDFLAGS =
LIBS = -lrombios

########################

OBJ = float-mul-test.o

float-mul-test.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o float-mul-test.cof $(OBJ) $(LIBS)

########################

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) float-mul-test
	-$(RM) libgcc.a
