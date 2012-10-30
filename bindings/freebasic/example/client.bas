#include once "enet/enet.bi"
#inclib "enet"

#include "fbgfx.bi"

#include once "common.bi"

using FB

public sub StartEnet() constructor
	if enet_initialize() <> 0 then
		print "Couldn't initialize enet"
		end -1
	end if
	print "Init enet"
end sub

public sub ShutdownEnet() destructor
	enet_deinitialize()
	print "Deinit enet"
end sub

type Client
public:
	declare constructor()
	declare destructor()
	
	declare function connect(byval host as string, byval port as enet_uint32) as ubyte
	declare sub disconnect()
	
	declare function send(byval information as any ptr, byval size as uint, byval channel as enet_uint32) as ubyte
	
	declare function process() as ubyte
	
private:
	as ENetHost ptr		m_host
	as ENetPeer ptr		m_peer
end type

'' ==========================
'' Entry Point
'' ==========================

dim as Client connection = type<Client>()

ScreenRes 400, 500, 16

if connection.connect("localhost", 12345) then

	print "Connected to localhost:12345"

	dim as KeyboardInfo state = type<KeyboardInfo>(0,0,0,0,0)
	
	while connection.process() And Not multikey(&h01)
		dim as KeyboardInfo k
		
		k.key_w = iif( multikey( SC_W ), 1, 0 )
		k.key_a = iif( multikey( SC_A ), 1, 0 )
		k.key_s = iif( multikey( SC_S ), 1, 0 )
		k.key_d = iif( multikey( SC_D ), 1, 0 )
		
		if compareKeyboard( k, state ) <> 0 then
			print "Sending key data: ";
			print using "w=& a=& s=& d=&"; _
					k.key_w; _
					k.key_a; _
					k.key_s; _
					k.key_d;
			print k.serialized
			connection.send( @k.serialized, sizeof(integer), 0 )
		end if
		state = k
		
		sleep 1, 1
	wend

end if

connection.disconnect()

end 0

constructor Client()
	m_host = enet_host_create( NULL, 1, 2, 57600 / 8, 14400 / 8 )
    if (m_host = NULL) then
		print "An error occurred while trying to create an ENet client host."
        end -1
    end if
end constructor

destructor Client()
	if m_peer <> NULL then enet_peer_reset( m_peer )
	if m_host <> NULL then enet_host_destroy(m_host)
end destructor

function Client.connect(byval host as string, byval port as enet_uint32) as ubyte
	dim as ENetEvent event
	dim as ENetAddress address
	enet_address_set_host( @address, strptr(host) )
	address.port = port
	
	m_peer = enet_host_connect( m_host, @address, 2, 0 )
	if (m_peer = NULL) then return 0
	
	if ( enet_host_service( m_host, @event, 5000) > 0 And event.type = ENET_EVENT_TYPE_CONNECT ) then
		print "Connection successful"
		return 1
	end if
	
	return 0
end function

sub Client.disconnect()
	dim as ENetEvent event
	enet_peer_disconnect( m_peer, 0 )
	while enet_host_service( m_host, @event, 3000 ) > 0
		select case event.type
		case ENET_EVENT_TYPE_RECEIVE
			enet_packet_destroy( event.packet )
		case ENET_EVENT_TYPE_DISCONNECT
			print "Graceful disconnect"
			m_peer = NULL
			return
		end select
	wend
	enet_peer_reset( m_peer )
end sub

function Client.send(byval information as any ptr, byval size as size_t, byval channel as enet_uint32) as ubyte
	dim as ENetPacket ptr packet = enet_packet_create( information, size, ENET_PACKET_FLAG_RELIABLE )
	return (enet_peer_send( m_peer, channel, packet) = 0)
end function

function Client.process() as ubyte
	dim as ENetEvent event
	while enet_host_service( m_host, @event, 0 ) > 0
		select case event.type
        case ENET_EVENT_TYPE_RECEIVE
            enet_packet_destroy( event.packet )
        case ENET_EVENT_TYPE_DISCONNECT
            return 0
		end select
	wend
	return 1
end function
