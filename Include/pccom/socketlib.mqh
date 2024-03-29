#property library

#define BYTE uchar
#define WORD ushort
#define DWORD int
#define DWORD_PTR32 uint
#define DWORD_PTR64 ulong
#define SOCKET32 uint
#define SOCKET64 ulong
#define MAKEWORD(a, b) ((WORD)(((BYTE)(((DWORD_PTR64)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR64)(b)) & 0xff))) << 8))
#define WSADESCRIPTION_LEN 256
#define WSASYS_STATUS_LEN 128
#define INVALID_SOCKET64 (SOCKET64)(~0)
#define INVALID_SOCKET32 (SOCKET32)(~0)
#define SOCKET_ERROR (-1)
#define NO_ERROR 0
#define SOMAXCONN 128
#define AF_INET 2
#define SOCK_STREAM 1
#define SOCK_DGRAM 2
#define IPPROTO_TCP 6
#define IPPROTO_UDP 17
#define SD_RECEIVE 0x00
#define SD_SEND 0x01
#define SD_BOTH 0x02
#define IOCPARM_MASK 0x7f
#define IOC_IN 0x80000000
#define _IOW(x,y,t) (IOC_IN|(((int)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#define FIONBIO _IOW('f', 126, int)

struct WSAData
{
   WORD wVersion;
   WORD wHighVersion;
   char szDescription[WSADESCRIPTION_LEN+1];
   char szSystemStatus[WSASYS_STATUS_LEN+1];
   ushort iMaxSockets;
   ushort iMaxUdpDg;
   char lpVendorInfo[];
};

#define LPWSADATA char&

struct S_un_b 
{ 
   uchar s_b1;
   uchar s_b2;
   uchar s_b3;
   uchar s_b4; 
};

struct S_un_w 
{ 
   ushort s_w1;
   uchar s_w2; 
};

union S_un
{
	S_un_b b;
	S_un_w w;
	uint S_addr;
};

struct in_addr 
{ 
   S_un u; 
};

struct sockaddr_in
{
   ushort sin_family;
   ushort sin_port;
   in_addr sin_addr; 
   char sin_zero[8];
};

union ref_sockaddr_in 
{ 
   char ref[2+2+4+1]; 
   sockaddr_in in; 
};
  
struct sockaddr
{
   ushort sa_family;
   char sa_data[14]; 
};

#define LPSOCKADDR char&

union ref_sockaddr 
{ 
   char ref[2+14]; 
   sockaddr_in in; 
};

#import "Ws2_32.dll"

int WSAStartup(WORD wVersionRequested, LPWSADATA lpWSAData[]);
int WSACleanup();
int WSAGetLastError();
ushort htons(ushort hostshort);
uint inet_addr(char &cp[]);
string inet_ntop(int Family, char &pAddr[], char &pStringBuf[], uint StringBufSize);
ushort ntohs(ushort netshort);
SOCKET64 socket(int af, int type, int protocol);
int ioctlsocket(SOCKET64 s, int cmd, int &argp);
int shutdown(SOCKET64 s, int how);
int closesocket(SOCKET64 s);
int bind(SOCKET64 s, LPSOCKADDR name[], int namelen);
int listen(SOCKET64 s, int backlog);
SOCKET64 accept(SOCKET64 s, LPSOCKADDR addr[], int &addrlen);
int connect(SOCKET64 s, LPSOCKADDR name[], int namelen);
int send(SOCKET64 s, char &buf[], int len, int flags);
int recv(SOCKET64 s, char &buf[], int len, int flags);
int recvfrom(SOCKET64 s, char &buf[], int len, int flags, LPSOCKADDR from[], int &fromlen);
int sendto(SOCKET64 s, const char &buf[], int len, int flags, LPSOCKADDR to[], int tolen);

#import

#define WSA_INVALID_HANDLE 6
#define WSA_NOT_ENOUGH_MEMORY 8
#define WSA_INVALID_PARAMETER 87
#define WSA_OPERATION_ABORTED 995
#define WSA_IO_INCOMPLETE 996
#define WSA_IO_PENDING 997
#define WSAEINTR 10004
#define WSAEBADF 10009
#define WSAEACCES 10013
#define WSAEFAULT 10014
#define WSAEINVAL 10022
#define WSAEMFILE 10024
#define WSAEWOULDBLOCK 10035
#define WSAEINPROGRESS 10036
#define WSAEALREADY 10037
#define WSAENOTSOCK 10038
#define WSAEDESTADDRREQ 10039
#define WSAEMSGSIZE 10040
#define WSAEPROTOTYPE 10041
#define WSAENOPROTOOPT 10042
#define WSAEPROTONOSUPPORT 10043
#define WSAESOCKTNOSUPPORT 10044
#define WSAEOPNOTSUPP 10045
#define WSAEPFNOSUPPORT 10046
#define WSAEAFNOSUPPORT 10047
#define WSAEADDRINUSE 10048
#define WSAEADDRNOTAVAIL 10049
#define WSAENETDOWN 10050
#define WSAENETUNREACH 10051
#define WSAENETRESET 10052
#define WSAECONNABORTED 10053
#define WSAECONNRESET 10054
#define WSAENOBUFS 10055
#define WSAEISCONN 10056
#define WSAENOTCONN 10057
#define WSAESHUTDOWN 10058
#define WSAETOOMANYREFS 10059
#define WSAETIMEDOUT 10060
#define WSAECONNREFUSED 10061
#define WSAELOOP 10062
#define WSAENAMETOOLONG 10063
#define WSAEHOSTDOWN 10064
#define WSAEHOSTUNREACH 10065
#define WSAENOTEMPTY 10066
#define WSAEPROCLIM 10067
#define WSAEUSERS 10068
#define WSAEDQUOT 10069
#define WSAESTALE 10070
#define WSAEREMOTE 10071
#define WSASYSNOTREADY 10091
#define WSAVERNOTSUPPORTED 10092
#define WSANOTINITIALISED 10093
#define WSAEDISCON 10101
#define WSAENOMORE 10102
#define WSAECANCELLED 10103
#define WSAEINVALIDPROCTABLE 10104
#define WSAEINVALIDPROVIDER 10105
#define WSAEPROVIDERFAILEDINIT 10106
#define WSASYSCALLFAILURE 10107
#define WSASERVICE_NOT_FOUND 10108
#define WSATYPE_NOT_FOUND 10109
#define WSA_E_NO_MORE 10110
#define WSA_E_CANCELLED 10111
#define WSAEREFUSED 10112
#define WSAHOST_NOT_FOUND 11001
#define WSATRY_AGAIN 11002
#define WSANO_RECOVERY 11003
#define WSANO_DATA 11004
#define WSA_QOS_RECEIVERS 11005
#define WSA_QOS_SENDERS 11006
#define WSA_QOS_NO_SENDERS 11007
#define WSA_QOS_NO_RECEIVERS 11008 
#define WSA_QOS_REQUEST_CONFIRMED 11009
#define WSA_QOS_ADMISSION_FAILURE 11010
#define WSA_QOS_POLICY_FAILURE 11011 
#define WSA_QOS_BAD_STYLE 11012 
#define WSA_QOS_BAD_OBJECT 11013 
#define WSA_QOS_TRAFFIC_CTRL_ERROR 11014
#define WSA_QOS_GENERIC_ERROR 1015
#define WSA_QOS_ESERVICETYPE 11016
#define WSA_QOS_EFLOWSPEC 11017
#define WSA_QOS_EPROVSPECBUF 11018
#define WSA_QOS_EFILTERSTYLE 11019
#define WSA_QOS_EFILTERTYPE 11020
#define WSA_QOS_EFILTERCOUNT 11021
#define WSA_QOS_EOBJLENGTH 11022
#define WSA_QOS_EFLOWCOUNT 11023
#define WSA_QOS_EUNKOWNPSOBJ 11024
#define WSA_QOS_EPOLICYOBJ 11025
#define WSA_QOS_EFLOWDESC 11026
#define WSA_QOS_EPSFLOWSPEC 11027
#define WSA_QOS_EPSFILTERSPEC 11028
#define WSA_QOS_ESDMODEOBJ 11029
#define WSA_QOS_ESHAPERATEOBJ 11030
#define WSA_QOS_RESERVED_PETYPE 11031

string WSAErrorDescript(int code)
{
   string s = string(code);
   switch(code)
   {
      case WSA_INVALID_HANDLE: return("(#"+s+") Specified event object handle is invalid.");
      case WSA_NOT_ENOUGH_MEMORY: return("(#"+s+") Insufficient memory available.");
      case WSA_INVALID_PARAMETER: return("(#"+s+") One or more parameters are invalid.");
      case WSA_OPERATION_ABORTED: return("(#"+s+") Overlapped operation aborted.");
      case WSA_IO_INCOMPLETE: return("(#"+s+") Overlapped I/O event object not in signaled state.");
      case WSA_IO_PENDING: return("(#"+s+") Overlapped operations will complete later.");
      case WSAEINTR: return("(#"+s+") Interrupted function call.");
      case WSAEBADF: return("(#"+s+") File handle is not valid.");
      case WSAEACCES: return("(#"+s+") Permission denied.");
      case WSAEFAULT: return("(#"+s+") Bad address.");
      case WSAEINVAL: return("(#"+s+") Invalid argument.");
      case WSAEMFILE: return("(#"+s+") Too many open files.");
      case WSAEWOULDBLOCK: return("(#"+s+") Resource temporarily unavailable.");
      case WSAEINPROGRESS: return("(#"+s+") Operation now in progress.");
      case WSAEALREADY: return("(#"+s+") Operation already in progress.");
      case WSAENOTSOCK: return("(#"+s+") Socket operation on nonsocket.");
      case WSAEDESTADDRREQ: return("(#"+s+") Destination address required.");
      case WSAEMSGSIZE: return("(#"+s+") Message too long.");
      case WSAEPROTOTYPE: return("(#"+s+") Protocol wrong type for socket.");
      case WSAENOPROTOOPT: return("(#"+s+") Bad protocol option.");
      case WSAEPROTONOSUPPORT: return("(#"+s+") Protocol not supported.");
      case WSAESOCKTNOSUPPORT: return("(#"+s+") Socket type not supported.");
      case WSAEOPNOTSUPP: return("(#"+s+") Operation not supported.");
      case WSAEPFNOSUPPORT: return("(#"+s+") Protocol family not supported.");
      case WSAEAFNOSUPPORT: return("(#"+s+") Address family not supported by protocol family.");
      case WSAEADDRINUSE: return("(#"+s+") Address already in use.");
      case WSAEADDRNOTAVAIL: return("(#"+s+") Cannot assign requested address.");
      case WSAENETDOWN: return("(#"+s+") Network is down.");
      case WSAENETUNREACH: return("(#"+s+") Network is unreachable.");
      case WSAENETRESET: return("(#"+s+") Network dropped connection on reset.");
      case WSAECONNABORTED: return("(#"+s+") Software caused connection abort.");
      case WSAECONNRESET: return("(#"+s+") Connection reset by peer.");
      case WSAENOBUFS: return("(#"+s+") No buffer space available.");
      case WSAEISCONN: return("(#"+s+") Socket is already connected.");
      case WSAENOTCONN: return("(#"+s+") Socket is not connected.");
      case WSAESHUTDOWN: return("(#"+s+") Cannot send after socket shutdown.");
      case WSAETOOMANYREFS: return("(#"+s+") Too many references.");
      case WSAETIMEDOUT: return("(#"+s+") Connection timed out.");
      case WSAECONNREFUSED: return("(#"+s+") Connection refused.");
      case WSAELOOP: return("(#"+s+") Cannot translate name.");
      case WSAENAMETOOLONG: return("(#"+s+") Name too long.");
      case WSAEHOSTDOWN: return("(#"+s+") Host is down.");
      case WSAEHOSTUNREACH: return("(#"+s+") No route to host.");
      case WSAENOTEMPTY: return("(#"+s+") Directory not empty.");
      case WSAEPROCLIM: return("(#"+s+") Too many processes.");
      case WSAEUSERS: return("(#"+s+") User quota exceeded.");
      case WSAEDQUOT: return("(#"+s+") Disk quota exceeded.");
      case WSAESTALE: return("(#"+s+") Stale file handle reference.");
      case WSAEREMOTE: return("(#"+s+") Item is remote.");
      case WSASYSNOTREADY: return("(#"+s+") Network subsystem is unavailable.");
      case WSAVERNOTSUPPORTED: return("(#"+s+") Winsock.dll version out of range.");
      case WSANOTINITIALISED: return("(#"+s+") Successful WSAStartup not yet performed.");
      case WSAEDISCON: return("(#"+s+") Graceful shutdown in progress.");
      case WSAENOMORE: return("(#"+s+") No more results.");
      case WSAECANCELLED: return("(#"+s+") Call has been canceled.");
      case WSAEINVALIDPROCTABLE: return("(#"+s+") Procedure call table is invalid.");
      case WSAEINVALIDPROVIDER: return("(#"+s+") Service provider is invalid.");
      case WSAEPROVIDERFAILEDINIT: return("(#"+s+") Service provider failed to initialize.");
      case WSASYSCALLFAILURE: return("(#"+s+") System call failure.");
      case WSASERVICE_NOT_FOUND: return("(#"+s+") Service not found.");
      case WSATYPE_NOT_FOUND: return("(#"+s+") Class type not found.");
      case WSA_E_NO_MORE: return("(#"+s+") No more results.");
      case WSA_E_CANCELLED: return("(#"+s+") Call was canceled.");
      case WSAEREFUSED: return("(#"+s+") Database query was refused.");
      case WSAHOST_NOT_FOUND: return("(#"+s+") Host not found.");
      case WSATRY_AGAIN: return("(#"+s+") Nonauthoritative host not found.");
      case WSANO_RECOVERY: return("(#"+s+") This is a nonrecoverable error.");
      case WSANO_DATA: return("(#"+s+") Valid name, no data record of requested type.");
      case WSA_QOS_RECEIVERS: return("(#"+s+") QoS receivers.");
      case WSA_QOS_SENDERS: return("(#"+s+") QoS senders.");
      case WSA_QOS_NO_SENDERS: return("(#"+s+") No QoS senders.");
      case WSA_QOS_NO_RECEIVERS: return("(#"+s+") QoS no receivers.");
      case WSA_QOS_REQUEST_CONFIRMED: return("(#"+s+") QoS request confirmed.");
      case WSA_QOS_ADMISSION_FAILURE: return("(#"+s+") QoS admission error.");
      case WSA_QOS_POLICY_FAILURE: return("(#"+s+") QoS policy failure.");
      case WSA_QOS_BAD_STYLE: return("(#"+s+") QoS bad style.");
      case WSA_QOS_BAD_OBJECT: return("(#"+s+") QoS bad object.");
      case WSA_QOS_TRAFFIC_CTRL_ERROR: return("(#"+s+") QoS traffic control error.");
      case WSA_QOS_GENERIC_ERROR: return("(#"+s+") QoS generic error.");
      case WSA_QOS_ESERVICETYPE: return("(#"+s+") QoS service type error.");
      case WSA_QOS_EFLOWSPEC: return("(#"+s+") QoS flowspec error.");
      case WSA_QOS_EPROVSPECBUF: return("(#"+s+") Invalid QoS provider buffer.");
      case WSA_QOS_EFILTERSTYLE: return("(#"+s+") Invalid QoS filter style.");
      case WSA_QOS_EFILTERTYPE: return("(#"+s+") Invalid QoS filter type.");
      case WSA_QOS_EFILTERCOUNT: return("(#"+s+") Incorrect QoS filter count.");
      case WSA_QOS_EOBJLENGTH: return("(#"+s+") Invalid QoS object length.");
      case WSA_QOS_EFLOWCOUNT: return("(#"+s+") Incorrect QoS flow count.");
      case WSA_QOS_EUNKOWNPSOBJ: return("(#"+s+") Unrecognized QoS object.");
      case WSA_QOS_EPOLICYOBJ: return("(#"+s+") Invalid QoS policy object.");
      case WSA_QOS_EFLOWDESC: return("(#"+s+") Invalid QoS flow descriptor.");
      case WSA_QOS_EPSFLOWSPEC: return("(#"+s+") Invalid QoS provider-specific flowspec.");
      case WSA_QOS_EPSFILTERSPEC: return("(#"+s+") Invalid QoS provider-specific filterspec.");
      case WSA_QOS_ESDMODEOBJ: return("(#"+s+") Invalid QoS shape discard mode object.");
      case WSA_QOS_ESHAPERATEOBJ: return("(#"+s+") Invalid QoS shaping rate object.");
      case WSA_QOS_RESERVED_PETYPE: return("(#"+s+") Reserved policy QoS element type.");
   }
   return("(#"+s+") Unknow error");
}

