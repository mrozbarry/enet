/'* 
 @file  callbacks.h
 @brief ENet callbacks
'/
#ifndef __ENET_CALLBACKS_H__
#define __ENET_CALLBACKS_H__

#include "stdlib.h"

type _ENetCallbacks
    '' TODO: translate (sorry)
    ''void * (ENET_CALLBACK * malloc) (size_t size);
	as function( byval size as size_t ) as any ptr	malloc
    '' TODO: translate (sorry)
    ''void (ENET_CALLBACK * free) (void * memory);
	as sub(byval memory as any ptr)	free
    '' TODO: translate (sorry)
    ''void (ENET_CALLBACK * no_memory) (void);
	as sub()	no_memory
end type : type as _ENetCallbacks ENetCallbacks

/'* @defgroup callbacks ENet internal callbacks
    @{
    @ingroup private
'/
declare function enet_malloc (byval as size_t) as any ptr
declare sub   enet_free (byval as any ptr )

/'* @} '/

#endif /' __ENET_CALLBACKS_H__ '/

