/***********************************************************************/
/*                                                                     */
/*   Module:  tcp_ip.h                                                 */
/*   Release: 2000.1                                                   */
/*   Version: 2000.0                                                   */
/*   Purpose: TCP/IP stack prototypes and constants                    */
/*                                                                     */
/*---------------------------------------------------------------------*/
/*                                                                     */
/*               Copyright 1999, Blunk Microsystems                    */
/*                      ALL RIGHTS RESERVED                            */
/*                                                                     */
/*   Licensees have the non-exclusive right to use, modify, or extract */
/*   this computer program for software development at a single site.  */
/*   This program may be resold or disseminated in executable format   */
/*   only. The source code may not be redistributed or resold.         */
/*                                                                     */
/***********************************************************************/
#ifndef _TCP_IP_H /* Don't include this file more than once */
#define _TCP_IP_H
#ifdef __cplusplus
extern "C"
{
#endif
/***********************************************************************/
/* TargetTCP Configuration                                             */
/***********************************************************************/
#define TCP_PROBE       TRUE    /* TRUE enables protocol decoder */
#define PPP_TRACE       TRUE    /* TRUE enables PPP trace output */
#define MAX_PPP_INTF    1       /* maximum number of PPP channels */
/*
** Buffer Size Definitions (multiple of 4)
*/
#define TCP_SML_SIZE    128
#define TCP_MED_SIZE    (16 + 2047)     /* (1520 + 16) */
#define TCP_BIG_SIZE    (3 * 1520)
/***********************************************************************/
/* Symbol Definitions                                                  */
/***********************************************************************/
#define IP_ALEN         4
#define NIMHLEN         16      /* divisible by 4 and > any NI header */
#define ETH_HW_TYPE     1
#define ETH_MTU         1500
#define ETH_HDR_LEN     14
#define ETH_CRC_LEN     4
#define ETH_ALEN        6
/*
** Network Packet Types
*/
#define IP_TYPE         0x0800      /* type: Internet Protocol */
#define ARP_TYPE        0x0806      /* type: ARP */
#define RARP_TYPE       0x8035      /* type: RARP */
/*
** Network Interface Flags
*/
#define NIF_UP          (1 << 0)  /* set by TargetTCP only */
#define NIF_BORROWED    (1 << 1)  /* set by TargetTCP only */
#define NIF_P2P         (1 << 2)
#define NIF_DEF_GW      (1 << 3)
#define NIF_USE_DHCP    (1 << 4)
#define NIF_USE_RARP    (1 << 5)
/*
** Network Interface Events
*/
#define NIE_UP          1
#define NIE_DOWN        2
#define NIE_RESTART     3
/*
** Modem Input Signals
*/
#define kDCD    (1 << 0)
#define kDSR    (1 << 1)
/*
** PPP Option Flags
*/
#define OPT_MRU         (1 << 0)
#define OPT_ACCM        (1 << 1)
#define OPT_MAGIC       (1 << 2)
#define OPT_PFC         (1 << 3)
#define OPT_ACFC        (1 << 4)
#define OPT_PAP         (1 << 5)
#define OPT_ADDR        (1 << 6)
#define OPT_VJCOMP      (1 << 7)
/*
** PPP Interface Flags
*/
#define PPPF_DEF_GW     (1 << 0)
#define PPPF_TRACE      (1 << 1)
#define PPPF_PASSIVE    (1 << 2)
#define PPPF_ON_DEMAND  (1 << 3)
/***********************************************************************/
/* Type Definitions                                                    */
/***********************************************************************/
/*
** Network Buffer Definition
*/
typedef struct nbuf
{
  unsigned int mark;
  unsigned int count;
  unsigned int next_hop;           /* IP address to send packet to */
  struct netif *ni;        /* pointer to associated NI */
  struct nbuf *next;       /* pointer to next linked NetBuf */
  int  length;             /* length of packet data */
  int  rb_off;             /* TCP receive data offset */
  unsigned int type;               /* IP, ARP, or RARP type */
  unsigned char  *ip_pkt;            /* pointer to start of IP packet */
  void *ip_data;           /* pointer to start of IP data */
  unsigned char  *app_data;          /* pointer to start of application data */
  unsigned char  data[1];            /* variable size field */
} NetBuf;
/*
** Network Interface Structure (one instance per interface)
*/
typedef struct netif
{
  struct netif *next;     /* pointer to next linked NI structure */
  struct netif *entry;    /* pointer to next NI, used by tcpPollReq() */
  void (*poll)(void);     /* used by tcpPollReq() */
  void (*transmit)(NetBuf *, void *hwa); /* called to transmit packet */
  void (*broadcast)(NetBuf *); /* called to broadcast packet */
  void (*callback)(struct netif *ni, int event); /* called if not NULL */
  unsigned int ip_addr;           /* IP address for this interface */
  unsigned int ip_mask;           /* IP subnet mask */
  unsigned int remote_addr;       /* used for point-to-point interfaces */
  void *hw_addr;          /* pointer to NI's hw address */
  char *name;             /* name of this interface */
  int  mtu;               /* max transfer unit (bytes) */
  int  flags;             /* option/status flags */
  int  ipkts;             /* number of input packets */
  int  ierrs;             /* number of input packets with errors */
  int  opkts;             /* number of output packets */
  int  oerrs;             /* number of output packets with errors */
  unsigned char  hw_type;           /* ARP HW type: ETH_HW_TYPE or ... */
  unsigned char  ha_len;            /* MAC address length */
} Ni;
/*
** Chat Configuration
*/
typedef struct
{
  char *init;           /* initialization script */
  char *dial;           /* dial script */
  char *login;          /* login script */
  char *hangup;         /* hangup script */
  char *phone_number;   /* phone number */
  char *phone_number2;  /* additional phone number */
  char *username;       /* login user name */
  char *password;       /* login password */
  int   max_trys;       /* number of times to repeat CHAT scripts */
} ChatCfg;
/*
** Serial Interface Configuration
*/
typedef struct ser_id
{
  int  (*connect)(void);
  int  (*disconnect)(void);
  void (*start_tx)(void);   /* tx start callback */
  int  (*sig_check)(void);  /* checks modem control signals */
  unsigned short DCD_timeout;     /* # seconds persistence or 0xFFFF ignore */
  unsigned short DSR_timeout;     /* # seconds persistence or 0xFFFF ignore */
} SerCfg;
/*
** PPP Configuration
*/
typedef struct pppi PPPi;
typedef struct 
{
  void (*callback)(PPPi *pppi, int event);
  unsigned int asyncmap;        /* bit-map indicating tx chars to be escaped */
  unsigned char *addtl_esc;       /* additional chars escaped during tx */
  char *username;       /* PPP authentication user name */
  char *password;       /* PPP authentication password or key */
  unsigned int local_addr;      /* local IP address */
  unsigned int remote_addr;     /* remote IP address */
  unsigned int accept_opts;     /* peer requests that are accepted */
  unsigned int request_opts;    /* options we request */
  unsigned int flags;
  unsigned short mru;             /* requested max size of packets sent to us */
  unsigned short mtu;             /* requested max size of packets sent by us */
}PppCfg;
/*
** PPP Interface Control Block
*/
struct pppi
{
  void (*data_ind)(void *handle, unsigned char *src, int length, int adjust);
  int  (*data_req)(void *handle, unsigned char *dst, int space, int adjust);
  SerCfg ser;
  ChatCfg chat;
  PppCfg cfg;
  char *name;           /* name of this interface */
  Ni ni;                /* network interface control block */
};
/***********************************************************************/
/* Global Variable Declarations                                        */
/***********************************************************************/
extern unsigned int DnsServer;
extern unsigned int DefGateway;
/***********************************************************************/
/* Function Prototypes                                                 */
/***********************************************************************/
void *tcpModule(int req, ...);
void  tcpDataInd(NetBuf *buf);
void *tcpGetBuf(int length);
void  tcpRetBuf(void **buf);
int   tcpAddNi(Ni *ni);
int   tcpDelNi(Ni *ni);
int   tcpStatNi(char *name);
void  tcpPollReq(Ni *ni, void (*poll)(void));
NetBuf *recvbuf(int s, int flags);
NetBuf *recvbuffrom(int s, int flags, void *from, int *fromlen);
void  tcpPerror(int err_code);
PPPi *pppAlloc(void);
int   pppOpen(PPPi *ppp);
int   pppClose(PPPi *ppp);
int   pppFree(PPPi *ppp);



void  pppConnect(void* start_tx);

int   pppDisconnect(PPPi *id);
#ifdef __cplusplus
}
#endif
#endif /* _TCP_IP_H */