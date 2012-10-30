
'' build with -l winmm

#include once "enet/enet.bi"
#inclib "enet"

#include once "common.bi"

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

type ClientConnection
	as ubyte		id
	as KeyboardInfo	state
end type

type KeyServer
public:
	declare constructor(byval port as enet_uint32, byval max_connections as enet_uint32 = 16)
	declare destructor()
	
	declare sub process()
	
private:
	as ENetHost ptr		m_host
	as integer			m_clientid
end type

'' ==========================
'' Entry Point
'' ==========================

ScreenRes 400, 500, 16
cls

dim as KeyServer server = type<KeyServer>(12345, 8)

do
	dim k as string * 1 = inkey()
	if k = chr(27) then exit do
	server.process()
loop

end 0

constructor KeyServer(byval port as enet_uint32, byval max_connections as enet_uint32)
	dim as ENetAddress address
	address.host = ENET_HOST_ANY
	address.port = port
	
	m_host = NULL
	
	m_host = enet_host_create( @address, max_connections, 2, 0, 0 )
	if m_host = NULL then
		print "Can't create server,"
		end -2
	end if
	
	m_clientid = 0
end constructor

destructor KeyServer()
	if m_host <> NULL then enet_host_destroy(m_host)
end destructor

sub KeyServer.process()

	dim as ENetEvent event
	
	while enet_host_service( m_host, @event, 1000) > 0
		select case event.type
		case ENET_EVENT_TYPE_CONNECT
			var client = new ClientConnection
			client->id = m_clientid
			client->state = type<KeyboardInfo>(0,0,0,0,0)
			event.peer->data = client
			
			dim as string  * 19 ipaddy
			enet_address_get_host_ip( @event.peer->address, strptr(ipaddy), 18 )
			
			print "New client connection (" & ipaddy & ") ID "; client->id
			m_clientid += 1
		
		case ENET_EVENT_TYPE_RECEIVE
			print "Received client data"
			
			if event.channelID = 0 then
				dim state as KeyboardInfo
				state.serialized = *cptr( integer ptr, event.packet->data )
				dim client as ClientConnection ptr
				client = cptr( ClientConnection ptr, event.peer->data )
				client->state = state
				print using "Player ID & (serialized=&) w=& a=& s=& d=&"; _
					client->id; _
					state.serialized; _
					state.key_w; _
					state.key_a; _
					state.key_s; _
					state.key_d
			end if
			
			enet_packet_destroy( event.packet )
		case ENET_EVENT_TYPE_DISCONNECT
			dim client as ClientConnection ptr
			client = cptr( ClientConnection ptr, event.peer->data )
			print "Disconnecting ID "; client->id
			delete client
			event.peer->data = NULL
		end select
	wend

end sub

