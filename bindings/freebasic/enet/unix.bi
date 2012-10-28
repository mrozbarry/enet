/'* 
 @file  unix.h
 @brief ENet Unix header
'/
#ifndef __ENET_UNIX_H__
#define __ENET_UNIX_H__

#include "stdlib.h"
#include "sys/time.h"
#include "sys/types.h"
#include "netinet/in.h"
#include "unistd.h"

type as integer ENetSocket

enum
    ENET_SOCKET_NULL = -1
end enum

#define ENET_HOST_TO_NET_16(value) (htons (value)) /'*< macro that converts host to net byte-order of a 16-bit value '/
#define ENET_HOST_TO_NET_32(value) (htonl (value)) /'*< macro that converts host to net byte-order of a 32-bit value '/

#define ENET_NET_TO_HOST_16(value) (ntohs (value)) /'*< macro that converts net to host byte-order of a 16-bit value '/
#define ENET_NET_TO_HOST_32(value) (ntohl (value)) /'*< macro that converts net to host byte-order of a 32-bit value '/

type _
 ENetBuffer
    as any ptr data
    as size_t dataLength
end type

#define ENET_CALLBACK

#define ENET_API extern

type as fd_set ENetSocketSet

#define ENET_SOCKETSET_EMPTY(sockset)          FD_ZERO ( /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_ADD(sockset, socket)    FD_SET (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_REMOVE(sockset, socket) FD_CLEAR (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_CHECK(sockset, socket)  FD_ISSET (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))
    
#endif /' __ENET_UNIX_H__ '/

