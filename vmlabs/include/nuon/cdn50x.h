typedef struct
{
	long foo[16];
} iso_dir;

int CDInit(void);
int CDExit(void);
int CDReadSectors(int lsn,int count,char *addr, int isXA);

void  *iso_init(long para, int * err);
void *iso_open(void *context, const char * path, int flags, int mode, int * err);
int iso_close(void *context, void * fp, int * err);
int iso_read(void *context, void * fp, void * ptr, int len, int * err);
int iso_lseek(void *context, void * fp, int offt, int whence, int * err);
int iso_lstat(void *context, const char * path, struct stat * st, int * err);
int iso_fstat(void *context, void * fp, struct stat * st, int * err);

int iso_opendir(void *context, const char *path, iso_dir *dir, int *err);
int iso_rewinddir(void *context, iso_dir *dir, int *err);
int iso_readdir(void *context, iso_dir *dir, char *name, struct stat * st, int *err);
