/***********************************************************************/
#ifndef _SOCKETS_H   /* Don't include this file more than once */
#define _SOCKETS_H

/***********************************************************************/
/* TargetTCP Configuration                                             */
/***********************************************************************/
/*
** Socket Control Block Allocation
*/
#define MAX_NUM_SOCKETS   70

/*
** Network Buffer Allocation
*/
#define TCP_SML_BUFS    32
#define TCP_MED_BUFS    24
#define TCP_BIG_BUFS    24

/***********************************************************************/
/* Symbol and Macro Definitions                                        */
/***********************************************************************/
/*
** Host to network byte order macros
*/
#define htonl(l)    (l)
#define htons(s)    (s)
#define ntohl(l)    htonl(l)
#define ntohs(s)    htons(s)

/*
** Common Addresses
*/
//#define INADDR_ANY        0x00000000
#define INADDR_LOOPBACK   0x7F000001
//#define INADDR_BROADCAST  0xFFFFFFFF

/*
** Address Class Macros
*/
#define IP_CLASSA(a)    (((a) & 0x80000000) == 0x00000000)
#define IP_CLASSB(a)    (((a) & 0xC0000000) == 0x80000000)
#define IP_CLASSC(a)    (((a) & 0xE0000000) == 0xC0000000)
#define IP_CLASSD(a)    (((a) & 0xF0000000) == 0xE0000000)
#define IP_CLASSE(a)    (((a) & 0xF8000000) == 0xF0000000)

/*
** Domain and Protocol Family
*/
#define AF_INET         0
#define PF_INET         0

/*
** Socket Types
*/
#define SOCK_STREAM     2
#define SOCK_DGRAM      3

/*
** Protocol Types
*/
#define TCP             11
#define UDP             12


/* ** Socket Option Names */ 
#define SO_BROADCAST    11 
#define SO_DONTROUTE	12   
#define SO_KEEPALIVE    13 
#define SO_LINGER       14 
#define SO_OOBINLINE	15  
#define SO_RCVBUF    	16 
#define SO_RCVTIMEO     17 
#define SO_REUSEADDR 	18  
#define SO_SNDBUF       19 
#define SO_SNDTIMEO     20 
#define SO_TYPE         21 
#define TCP_NODELAY     22 
#define SO_CALLBACK     23

/*
** Socket Option Levels
*/
#define SOL_SOCKET      32
//#define IPPROTO_TCP     33

/*
** send() and recv() flags
*/
#define MSG_OOB         (1 << 0)
#define MSG_PEEK        (1 << 1)
#define MSG_WAITALL     (1 << 2)
#define MSG_DONTWAIT    (1 << 3)
#define MSG_DONTROUTE   (1 << 4)

/*
** Socket Events (Posted to setsockopt() SO_CALLBACK handler)
*/
#define SE_DATA_ACKED   0x0001
#define SE_CLOSED       0x0002
#define SE_OPENED       0x0004
#define SE_DATA_RCVD    0x0008
#define SE_ACCEPTED     0x0010
#define SE_URGENT       0x0020
#define SE_SND_SHUT     0x0040
#define SE_RCV_SHUT     0x0080
#define SE_GOT_FIN      0x0100
#define SE_ERROR        0xFFFF

/*
** select() socket set macros and prototype
*/
#define NET_FD_ISSET(s, fdset)      ((fdset)->id[(s) - 1])
#define NET_FD_CLR(s, fdset)        ((fdset)->id[(s) - 1] = 0)
#define NET_FD_SET(s, fdset)        ((fdset)->id[(s) - 1] = 1)

#define kBUFFER_POOL_SIZE	    0x28c00
/***********************************************************************/
/* Type Definitions                                                    */
/***********************************************************************/

#ifndef _TIMEVAL_
#define _TIMEVAL_ 
struct timeval
{
  long tv_sec;
  long tv_usec;
};
#endif

typedef struct linger
{
  u_short l_onoff;   /* linger option on/off */
  u_short l_linger;  /* linger time */
} linger;

typedef struct fd_set
{
  u_char id[MAX_NUM_SOCKETS];
} fd_set;

/*
 * Structure used by kernel to store most
 * addresses.
 */
struct sockaddr {
        u_char  sa_len;                 /* total length */
        u_char  sa_family;              /* address family */
        char    sa_data[14];            /* actually longer; address value */
};

/*
 * Structure used by kernel to pass protocol
 * information in raw sockets.
 */
struct sockproto {
        u_short sp_family;              /* address family */
        u_short sp_protocol;            /* protocol */
};

/*
 * Message header for recvmsg and sendmsg calls.
 * Used value-result for recvmsg, value only for sendmsg.
 */
struct msghdr {
        caddr_t msg_name;               /* optional address */
        u_int   msg_namelen;            /* size of address */
        struct  iovec *msg_iov;         /* scatter/gather array */
        u_int   msg_iovlen;             /* # elements in msg_iov */
        caddr_t msg_control;            /* ancillary data, see below */
        u_int   msg_controllen;         /* ancillary data buffer len */
        int     msg_flags;              /* flags on received message */
};

typedef struct SocketBufferDesc
{
         void*  address;		/* address of pool  */
	 u_int  size; 			/* size of pool     */
	 				/* the following fields are optional 
					/* leave 0 if default - size must be kBUFFER_POOL_SIZE */					
	 u_int  smallbufs;		/* number of small bufs (size = ) */
	 u_int  medbufs;		/* number of med bufs (size = ) */
	 u_int  bigbufs;		/* number of large bufs (size = ) */
} SocketBufferDesc;
	 		 
/***********************************************************************/
/* Function Prototypes                                                 */
/***********************************************************************/
/*
** Sockets API
*/
int accept(int socket, void *addr, int *addrlen);
int bind(int socket, const void *addr, int addrlen);
int closesocket(int socket);
int connect(int socket, const void *addr, int addrlen);
int getpeername(int socket, void *addr, int *addrlen);
int getsockname(int socket, void *addr, int *addrlen);
int getsockopt(int socket, int level, int opt, void *oval, int *olen);
void NET_FD_ZERO(fd_set *fdset);
int ioctlsocket(int socket, int request, void *argp);
int listen(int socket, int backlog);
int recv(int socket, void *buffer, int buflen, int flags);
int recvfrom(int socket, void *buffer, int buflen, int flags,
             void *from, int *fromlen);
int select(int fd, fd_set *fread, fd_set *fwrite, fd_set *fexcept,
           struct timeval *timeout);
int send(int socket, const void *buffer, int buflen, int flags);
int sendto(int socket, const void *buffer, int buflen, int flags,
const void *to, int tolen);
int setsockopt(int socket, int level, int opt_name, const void *opt_value,
               int opt_length);
int shutdown(int socket, int how);
int socket(int family, int type, int protocol);

/*
** Additional Functions
*/
u_int getHostByName(char *name);
int  tcpPing(u_int addr, uint length, int verbose);
int  tcpAddRoute(u_int gw, u_int mask, u_int addr);
int  tcpDelRoute(u_int mask, u_int addr);
void tcpDiag(int type);
void tcpPoll(u_int msg);
int tcpInit(SocketBufferDesc *bufferDesc);

#define TCP_DIAG_SOCK   (1 << 0)
#define TCP_DIAG_BUFS   (1 << 1)
#define TCP_DIAG_ROUTE  (1 << 2)

/***********************************************************************/
/* Error Codes (written to errno)                                      */
/***********************************************************************/
enum sock_errs
{
  EADDRINUSE = 300,
  EADDRNOTAVAIL,
  EAFNOSUPPORT,
  ECOLL,
  ECONNABORTED,
  ECONNREFUSED,
  ECONNRESET,
  EDESTADDRREQ,
  EDNS_FAILED,
  EDNS_SERVER,
  EHOSTUNREACH,
  EISCONN,
  ENETDOWN,
  ENETUNREACH,
  ENOBUFS,
  ENOPROTOOPT,
  ENOTCONN,
  EOPNOTSUPP,
  EPFNOSUPPORT,
  EPROTOTYPE,
  ESHUTDOWN,
  ESOCKTNOSUPPORT,
  ETIMEDOUT
#ifndef _SYS_ERRNO_H_
  ,
  EWOULDBLOCK = 11,
  EACCES = 13,
  EFAULT = 14,
  EINPROGRESS = 114,
  EINVAL = 22,
  EMFILE = 24,
  EMSGSIZE = 190,
  ENOTSOCK = 92
#endif  
}SocketErrors;

#endif /* _SOCKETS_H */

