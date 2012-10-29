/'* 
 @file  win32.h
 @brief ENet Win32 header
'/
#ifndef __ENET_WIN32_H__
#define __ENET_WIN32_H__

#include "crt/stdlib.bi"
#include "win/winsock2.bi"

type as SOCKET ENetSocket

enum
    ENET_SOCKET_NULL = INVALID_SOCKET
end enum

#define ENET_HOST_TO_NET_16(value) (htons (value))
#define ENET_HOST_TO_NET_32(value) (htonl (value))

#define ENET_NET_TO_HOST_16(value) (ntohs (value))
#define ENET_NET_TO_HOST_32(value) (ntohl (value))

type _
 ENetBuffer
    as size_t dataLength
    as any ptr data
end type

#define ENET_CALLBACK __cdecl

#if defined ENET_DLL
#if defined ENET_BUILDING_LIB
#define ENET_API __declspec( dllexport )
#else
#define ENET_API __declspec( dllimport )
#endif /' ENET_BUILDING_LIB '/
#else /' !ENET_DLL '/
#define ENET_API extern
#endif /' ENET_DLL '/

type as fd_set ENetSocketSet

#define ENET_SOCKETSET_EMPTY(sockset)          FD_ZERO ( /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_ADD(sockset, socket)    FD_SET (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_REMOVE(sockset, socket) FD_CLEAR (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))
#define ENET_SOCKETSET_CHECK(sockset, socket)  FD_ISSET (socket, /' TODO: check whether & meant @ or AND '/ @ (sockset))

#endif /' __ENET_WIN32_H__ '/


