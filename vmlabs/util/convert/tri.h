// tri.h: triangle definitions

struct Point {
    double x,y,z;
    double nx,ny,nz;
    double u,v;
    int numuses;				// number of times this point is used
};

struct Triangle {
    double fx, fy, fz, fd;		// face normal
    Point *pt[3];
    char *material;     // material name
};
