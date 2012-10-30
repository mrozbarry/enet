
#include once "enet/enet.bi"

#ifndef __common_bi__
#define __common_bi__	1

type KeyboardInfo field=1
	union
		type
			as enet_uint8	key_w : 1, key_a : 1, key_s : 1, key_d : 1, key_space : 1
		end type
		as integer serialized
	end union
end type

function compareKeyboard( byval a as KeyboardInfo, byval b as KeyboardInfo ) as ubyte
	return (a.key_w <> b.key_w) or _
			(a.key_a <> b.key_a) or _
			(a.key_s <> b.key_s) or _
			(a.key_d <> b.key_d)
end function

#endif /' __common_bi__ '/
