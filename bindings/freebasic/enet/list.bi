/'* 
 @file  list.h
 @brief ENet list management 
'/
#ifndef __ENET_LIST_H__
#define __ENET_LIST_H__

#include "stdlib.h"

type _ENetListNode
   as _ENetListNode ptr next
   as _ENetListNode ptr previous
end type : type as _ENetListNode ENetListNode

type as ENetListNode ptr ENetListIterator

type _ENetList
   as ENetListNode sentinel
end type : type as _ENetList ENetList

declare sub enet_list_clear (byval as ENetList ptr )

declare function enet_list_insert (byval as ENetListIterator, byval as any ptr ) as ENetListIterator
declare function enet_list_remove (byval as ENetListIterator) as any ptr
declare function enet_list_move (byval as ENetListIterator, byval as any ptr , byval as any ptr ) as ENetListIterator

declare function enet_list_size (byval as ENetList ptr ) as size_t

#define enet_list_begin(list) ((list) -> sentinel.next)
#define enet_list_end(list) ( /' TODO: check whether & meant @ or AND '/ @ (list) -> sentinel)

#define enet_list_empty(list) (enet_list_begin (list) = enet_list_end (list))

#define enet_list_next(iterator) ((iterator) -> next)
#define enet_list_previous(iterator) ((iterator) -> previous)

#define enet_list_front(list) ((void *) (list) -> sentinel.next)
#define enet_list_back(list) ((void *) (list) -> sentinel.previous)

#endif /' __ENET_LIST_H__ '/

