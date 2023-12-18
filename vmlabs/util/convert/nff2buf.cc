//
// nff2buf: convert a WorldToolKit 
// NFF file into an MML draw buffer
//
// Copyright (c) 1996-1998 VM Labs, Inc.
// All rights reserved.
// Confidential and Proprietary Information
// of VM Labs, Inc.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "tri.h"

#ifndef PI
#define PI 3.1415926
#endif

#define GLOBAL_SCALE 1.0

int flip_flag = 0;		// flip ordering of vertices?

// texture scale & rotation stuff
double rotatex, rotatey, rotatez;	// rotation angles for texture
double offsetx, offsety, offsetz;	// offsets for texture
double texrot[3][3];				// matrix

// global scale factor
double scale = 1.0;

double minu, maxu;
double minv, maxv;

// Global variables (yes, this sucks, but I'm in a hurry)
Triangle *GL_Tris;
Point *GL_Points;
int numpoints, numtris;

double dabs(double x)
{
	if (x < 0.0) x = -x;
	return x;
}

void
Usage(void)
{
	fprintf(stderr, "Usage: nff2buf [-flip][-scale size][-rx angle][-ry angle][-rz angle][+x dist][+y dist][+z dist] inputfile outputfile\n");
	exit(2);
}

#define THRESHOLD 0.00001

Point *
FindPoint(double x, double y, double z, double nx, double ny, double nz)
{
	int i;
	Point *P;

	for (i = 0; i < numpoints; i++) {
		P = &GL_Points[i];
		if (dabs(x-P->x)+dabs(y-P->y)+dabs(z-P->z) < THRESHOLD) {
			// see if the normals are "close" (i.e. dot product
			// is between 1.0 and 0.70)
			if ( (nx*P->nx + ny*P->ny + nz*P->nz) > 0.70 )
				return P;
		}
	}
	return (Point *)0;
}

Point *
BuildPoint(double x, double y, double z, double nx, double ny, double nz)
{
	Point *P;

	P = FindPoint(x,y,z,nx,ny,nz);
	if (P) {
		double numuses;

		// average the new normal into the old
		numuses = (double)P->numuses;
		P->nx = (numuses*P->nx + nx)/(numuses+1.0);
		P->ny = (numuses*P->ny + ny)/(numuses+1.0);
		P->nz = (numuses*P->nz + nz)/(numuses+1.0);
		P->numuses++;
	} else {
		P = &GL_Points[numpoints];
		numpoints++;
		P->numuses = 1;
		P->x = x; P->y = y; P->z = z;
		P->nx = nx; P->ny = ny; P->nz = nz;

		// texture coordinates are calculated from global coordinates by
		// applying the texrot matrix

		P->u = texrot[0][0]*(x-offsetx) + texrot[0][1]*(y-offsety) + texrot[0][2]*(z-offsetz);
		P->v = texrot[1][0]*(x-offsetx) + texrot[1][1]*(y-offsety) + texrot[1][2]*(z-offsetz);
		if (P->u < minu)
		    minu = P->u;
		if (P->u > maxu)
		    maxu = P->u;
		if (P->v < minv)
		    minv = P->v;
		if (P->v > maxv)
		    maxv = P->v;
	}
	return P;
}


struct vec3 {
    double x, y, z;
};


char *
nextword(char **wordptr)
{
    char *s, *ret;

    s = *wordptr;
    while (isspace(*s))
	s++;
    if (!*s) {
	return NULL;
    }
    ret = s;
    while (*s && !isspace(*s))
	s++;
    if (*s)
	*s++ = 0;
    *wordptr = s;
    return ret;
}

#define READ_BUFSIZ 512

int
ReadWtkNffFile(char *filename)
{
	FILE *f;
	Triangle *tri;
	int c;
	static char buf[READ_BUFSIZ];

	// open the file
	f = fopen(filename, "r");
	if (!f) {
		perror(filename);
		return 0;
	}

	// first, find out just how many triangles there could
	// be in this file; this is at most the number of lines
	// in the file
	numtris = 0;
	for(;;) {
		c = fgetc(f);
		if (c < 0) break;
		if (c == '\n') numtris++;
	}

	// allocate the triangle object
	if (numtris == 0) {
		fprintf(stderr, "%s: empty file\n", filename);
		fclose(f);
		return 0;
	}

	GL_Tris = tri = (Triangle *)malloc(numtris*sizeof(Triangle));
	GL_Points = (Point *)malloc(3*numtris*sizeof(Point));

	if (!GL_Tris || !GL_Points) {
		fprintf(stderr, "Insufficient memory!\n");
		fclose(f);
		return 0;
	}

	// now rewind the file and actually read the triangles
	rewind(f);
	numtris = 0;

	// skip lines until we see one starting with a digit
	for(;;) {
	    if (!fgets(buf, READ_BUFSIZ, f)) {
		fprintf(stderr, "EOF while looking for # of vertices\n");
		exit(2);
	    }
	    if (isdigit(buf[0]))
		break;
	}

	// read in the vertex array
	int i, numvertices;
	struct vec3 *vertexlist;

	double ax, ay, az, bx, by, bz, cx, cy, cz;
	double nx, ny, nz, norm;

	if (sscanf(buf, "%i\n", &numvertices) != 1) {
	    fprintf(stderr, "Couldn't read # of vertices from <%s>\n", buf);
	    exit(1);
	}

	vertexlist = (struct vec3 *)malloc(numvertices*sizeof(vec3));
	if (!vertexlist) {
	    fprintf(stderr, "Out of memory\n");
	    exit(2);
	}

	for (i = 0; i < numvertices; i++) {
		int r;

		if (feof(f)) {
		    fprintf(stderr, "Unexpected EOF while reading vertices\n");
		    exit(1);
		}

		r = fscanf(f, "%lf %lf %lf\n", &ax, &ay, &az);
		if (r != 3) {
		    fprintf(stderr, "Unable to read 3 points for vertex\n");
		    exit(1);
		}

		// flip the Y coordinate
		ay = -ay;

		// scale the point
		ax *= scale;
		ay *= scale;
		az *= scale;

		// save this point
		vertexlist[i].x = ax;
		vertexlist[i].y = ay;
		vertexlist[i].z = az;
	}

	// now read the polygons
	// skip lines until we see one starting with a digit
	for(;;) {
	    if (!fgets(buf, READ_BUFSIZ, f)) {
		fprintf(stderr, "EOF while looking for # of vertices\n");
		exit(2);
	    }
	    if (isdigit(buf[0]))
		break;
	}

	// read number of polygons
	int numpolys, numpts, ka, kb, kc;
	int firsttri;

	if (sscanf(buf, "%i\n", &numpolys) != 1) {
	    fprintf(stderr, "Unable to read number of polygons in: <%s>\n", buf);
	    exit(2);
	}


	for (i = 0; i < numpolys; i++) {
	    char *s, *sptr;
	    if (!fgets(buf, READ_BUFSIZ, f)) {
		fprintf(stderr, "Unexpected EOF while reading polygons\n");
		exit(2);
	    }
	    sptr = buf;
	    s = nextword(&sptr);
	    if (!s) {
		fprintf(stderr, "Unable to get # of points in polygon\n");
		exit(2);
	    }
	    numpts = strtol(s, (char **)0, 0);
	    if (numpts < 3) {
		fprintf(stderr, "Bad # of points (%d)\n", numpts);
		exit(2);
	    }

	    // get the first point
	    s = nextword(&sptr);
	    if (!s) {
		fprintf(stderr, "can't read first point index\n");
		exit(2);
	    }
	    ka = strtol(s, (char **)0, 0);

	    // get the second point
	    s = nextword(&sptr);
	    if (!s) {
		fprintf(stderr, "can't read second point index\n");
		abort();
	    }
	    kb = strtol(s, (char **)0, 0);

	    numpts -= 2;
	    // now get the triangles
	    firsttri = numtris;

	    while (numpts-- > 0) {
		s = nextword(&sptr);
		if (!s) {
		    fprintf(stderr, "can't read third or later point index\n");
		    exit(2);
		}
		kc = strtol(s, (char **)0, 0);

		// retrieve the vertices
		// if the flip_flag is set, switch points b and c to convert
		// from right-handed to left-handed coordinates

		if (flip_flag) {
		    ax = vertexlist[ka].x; ay = vertexlist[ka].y; az = vertexlist[ka].z;
		    bx = vertexlist[kc].x; by = vertexlist[kc].y; bz = vertexlist[kc].z;
		    cx = vertexlist[kb].x; cy = vertexlist[kb].y; cz = vertexlist[kb].z;
		} else {
		    ax = vertexlist[ka].x; ay = vertexlist[ka].y; az = vertexlist[ka].z;
		    bx = vertexlist[kb].x; by = vertexlist[kb].y; bz = vertexlist[kb].z;
		    cx = vertexlist[kc].x; cy = vertexlist[kc].y; cz = vertexlist[kc].z;
		}

		// calculate face normal
		nx  = (ay-by)*(az-cz) - (az-bz)*(ay-cy);
		ny  = (az-bz)*(ax-cx) - (ax-bx)*(az-cz);
		nz  = (ax-bx)*(ay-cy) - (ay-by)*(ax-cx);
		norm = sqrt(nx*nx + ny*ny + nz*nz);
		nx /= norm;
		ny /= norm;
		nz /= norm;

		tri[numtris].pt[0] = BuildPoint(ax, ay, az, nx, ny, nz);
		tri[numtris].pt[1] = BuildPoint(bx, by, bz, nx, ny, nz);
		tri[numtris].pt[2] = BuildPoint(cx, cy, cz, nx, ny, nz);

		tri[numtris].fx = nx;
		tri[numtris].fy = ny;
		tri[numtris].fz = nz;
		tri[numtris].fd = -(nx*ax+ny*ay+nz*az);

		numtris++;

		// move to next triangle in the polygon
		kb = kc;
	    }

	    // finally, set the materials for the triangles
	    s = nextword(&sptr);
	    if (!s) {
		s = "default";
	    }
	    s = strdup(s);
	    for (int kk = firsttri; kk < numtris; kk++) {
		tri[kk].material = s;
	    }
	}

	fclose(f);
	return numtris;
}

//
// write out a nice .s file for merlin
//
/* buffer entry types */
#define M3D_POLY_ENTRY 1

#define round(d) (floor(d+0.5))

#define FIX16(d) (((int)round(d*(double)(1<<16))))
#define FIX24(d) (((int)round(d*(double)(1<<24))))
#define FIX30(d) (((int)round(d*(double)(1<<30))))

void
WriteIFile(char *filename, int numtris)
{
	FILE *f;
	int i;
	int numentries;
	double uscale, vscale;

	uscale = (maxu - minu);
	vscale = (maxv - minv);
	if (uscale < 0.0001)
	    uscale = 1.0;
	if (vscale < 0.0001)
	    vscale = 1.0;

	f = fopen(filename, "w");
	if (!f) {
		perror(filename);
		return;
	}

	/* each triangle will contain 2 entries per point, plus 1 entry overall */
	numentries = numtris * 7;

	fprintf(f, "\t.dc.s\t%d\t; maxentries\n", numentries);
	fprintf(f, "\t.dc.s\t%d\t; number of entries\n", numentries);
	fprintf(f, "\t.dc.s\t0\t; state\n");
	fprintf(f, "\t.dc.s\t0\t; current polygon\n");

	fprintf(f, "\t.dc.s\t0, 0, 0\t; nx, ny, nz\n");
	fprintf(f, "\t.dc.s\t0, 0\t; tu, tv\n");
	fprintf(f, "\t.dc.s\t0\t; current material\n");

	fprintf(f, "\t.dc.s\ttridata\t; pointer to entries\n");
	fprintf(f, "\n\t.align.v\n");
	fprintf(f, "tridata:\n");

	for (i = 0; i < numtris; i++) {
		Triangle *T;
		Point *P;
		int j;
		
		T = &GL_Tris[i];

		// output triangle header
		fprintf(f, "\t.dc.s\t3,_material_%s,0,%d\n", T->material, M3D_POLY_ENTRY);

		// output the points
		for (j = 0; j < 3; j++) {
			P = T->pt[j];
			fprintf(f, "\t.dc.s\t$%x, $%x, $%x, $%x\n",
				FIX16(P->x), FIX16(P->y), FIX16(P->z),
				FIX24((P->u - minu)/uscale));
			fprintf(f, "\t.dc.s\t$%x, $%x, $%x, $%x\n",
				FIX30(P->nx), FIX30(P->ny), FIX30(P->nz),
				FIX24((P->v - minv)/vscale));
		}
	}
}


double
Angle2Radians(double degrees)
{
	return degrees*PI/180.0;
}

int
main(int argc, char **argv)
{
	int numtris;
	double texscale;

	texscale = 0.0;
	argv++;	argc--;		// skip program name
	while (argc > 0 && (*argv[0] == '-' || *argv[0] == '+')) {
		if (!strcmp(*argv, "-flip"))
			flip_flag = 1;
		else if (!strcmp(*argv, "-rx")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			rotatex = atof(*argv);
			if (rotatex == 0.0) Usage();
			rotatex = Angle2Radians(rotatex);
		} else if (!strcmp(*argv, "-ry")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			rotatey = atof(*argv);
			if (rotatey == 0.0) Usage();
			rotatey = Angle2Radians(rotatey);
		} else if (!strcmp(*argv, "-rz")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			rotatez = atof(*argv);
			if (rotatez == 0.0) Usage();
			rotatez = Angle2Radians(rotatez);
		} else if (!strcmp(*argv, "+x")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			offsetx = atof(*argv);
		} else if (!strcmp(*argv, "+y")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			offsety = atof(*argv);
		} else if (!strcmp(*argv, "+z")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			offsetz = atof(*argv);
		} else if (!strcmp(*argv, "-scale")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			scale = atof(*argv);
			if (scale <= 0.0) Usage();
		} else if (!strcmp(*argv, "-tscale")) {
			argv++; --argc;
			if (argc <= 0) Usage();
			texscale = atof(*argv);
			if (texscale <= 0.0) Usage();
		} else
			Usage();
		argv++; argc--;
	}

	if (argc != 2)
		Usage();

	scale = GLOBAL_SCALE * scale;
	offsetx *= scale;
	offsety *= scale;
	offsetz *= scale;

	minu = minv = 32768.0;
	maxu = maxv = -32768.0;

// calculate texture rotation matrix
	double ca,cb,cg,sa,sb,sg;

	sa = sin(rotatex); ca = cos(rotatex);
	sb = sin(rotatey); cb = cos(rotatey);
	sg = sin(rotatez); cg = cos(rotatez);

	texrot[0][0] = texscale*(cb*cg);
	texrot[0][1] = texscale*(sa*sb*cg - ca*sg);
	texrot[0][2] = texscale*(ca*sb*cg + sa*sg);

	texrot[1][0] = texscale*(cb*sg);
	texrot[1][1] = texscale*(sa*sb*sg + ca*cg);
	texrot[1][2] = texscale*(ca*sb*sg - sa*cg);

	texrot[2][0] = texscale*(-sb);
	texrot[2][1] = texscale*(sa*cb);
	texrot[2][2] = texscale*(ca*cb);

	numtris = ReadWtkNffFile(argv[0]);
	if (!numtris) {
		fprintf(stderr, "Unable to read .RAW file %s\n", argv[0]);
		exit(1);
	}
	WriteIFile(argv[1], numtris);
	return 0;
}
