/'* 
 @file  time.h
 @brief ENet time constants and macros
'/
#ifndef __ENET_TIME_H__
#define __ENET_TIME_H__

#define ENET_TIME_OVERFLOW 86400000

#define ENET_TIME_LESS(a, b) ((a) - (b) >= ENET_TIME_OVERFLOW)
#define ENET_TIME_GREATER(a, b) ((b) - (a) >= ENET_TIME_OVERFLOW)
#define ENET_TIME_LESS_EQUAL(a, b) ( /' TODO: add parentheses around NOT (different precedence) '/ not ENET_TIME_GREATER (a, b))
#define ENET_TIME_GREATER_EQUAL(a, b) ( /' TODO: add parentheses around NOT (different precedence) '/ not ENET_TIME_LESS (a, b))

''#define ENET_TIME_DIFFERENCE(a, b) ((a) - (b) >= ENET_TIME_OVERFLOW /' TODO: turn a?b:c into iif(a,b,c) '/ ? (b) - (a) : (a) - (b))
#define ENET_TIME_DIFFERENCE(a, b) (iif((a) - (b) >= ENET_TIME_OVERFLOW /' TODO: turn a?b:c into iif(a,b,c) '/, (b) - (a), (a) - (b)))

#endif /' __ENET_TIME_H__ '/

