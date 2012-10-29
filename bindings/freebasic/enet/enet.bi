/'* 
 @file  enet.h
 @brief ENet public header file
'/
#ifndef __ENET_ENET_H__
#define __ENET_ENET_H__

#ifdef __cplusplus
extern "C"
#endif

#include "crt/stdlib.bi"

#ifdef __FB_WIN32__
#include "enet/win32.bi"
#else
#include "enet/unix.bi"
#endif

#include "enet/types.bi"
#include "enet/protocol.bi"
#include "enet/list.bi"
#include "enet/callbacks.bi"

#define ENET_VERSION_MAJOR 1
#define ENET_VERSION_MINOR 3
#define ENET_VERSION_PATCH 5
#define ENET_VERSION_CREATE(major, minor, patch) (((major) shl 16) or ((minor) shl 8) or (patch))
#define ENET_VERSION ENET_VERSION_CREATE(ENET_VERSION_MAJOR, ENET_VERSION_MINOR, ENET_VERSION_PATCH)

type as enet_uint32 ENetVersion

enum _ENetSocketType
   ENET_SOCKET_TYPE_STREAM   = 1
   ENET_SOCKET_TYPE_DATAGRAM = 2
end enum : type as _ENetSocketType ENetSocketType

enum _ENetSocketWait
   ENET_SOCKET_WAIT_NONE    = 0
   ENET_SOCKET_WAIT_SEND    = (1 shl 0)
   ENET_SOCKET_WAIT_RECEIVE = (1 shl 1)
end enum : type as _ENetSocketWait ENetSocketWait

enum _ENetSocketOption
   ENET_SOCKOPT_NONBLOCK  = 1
   ENET_SOCKOPT_BROADCAST = 2
   ENET_SOCKOPT_RCVBUF    = 3
   ENET_SOCKOPT_SNDBUF    = 4
   ENET_SOCKOPT_REUSEADDR = 5
   ENET_SOCKOPT_RCVTIMEO  = 6
   ENET_SOCKOPT_SNDTIMEO  = 7
end enum : type as _ENetSocketOption ENetSocketOption

enum
   ENET_HOST_ANY       = 0            /'*< specifies the default server host '/
   ENET_HOST_BROADCAST = &hFFFFFFFF   /'*< specifies a subnet-wide broadcast '/

   ENET_PORT_ANY       = 0             /'*< specifies that a port should be automatically chosen '/
end enum

/'*
 * Portable internet address structure. 
 *
 * The host must be specified in network byte-order, and the port must be in host 
 * byte-order. The constant ENET_HOST_ANY may be used to specify the default 
 * server host. The constant ENET_HOST_BROADCAST may be used to specify the
 * broadcast address (255.255.255.255).  This makes sense for enet_host_connect,
 * but not for enet_host_create.  Once a server responds to a broadcast, the
 * address is updated from ENET_HOST_BROADCAST to the server's actual IP address.
 '/
type _ENetAddress
   as enet_uint32 host
   as enet_uint16 port
end type : type as _ENetAddress ENetAddress

/'*
 * Packet flag bit constants.
 *
 * The host must be specified in network byte-order, and the port must be in
 * host byte-order. The constant ENET_HOST_ANY may be used to specify the
 * default server host.
 
   @sa ENetPacket
'/
enum _ENetPacketFlag
   /'* packet must be received by the target peer and resend attempts should be
     * made until the packet is delivered '/
   ENET_PACKET_FLAG_RELIABLE    = (1 shl 0)
   /'* packet will not be sequenced with other packets
     * not supported for reliable packets
     '/
   ENET_PACKET_FLAG_UNSEQUENCED = (1 shl 1)
   /'* packet will not allocate data, and user must supply it instead '/
   ENET_PACKET_FLAG_NO_ALLOCATE = (1 shl 2)
   /'* packet will be fragmented using unreliable (instead of reliable) sends
     * if it exceeds the MTU '/
   ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT = (1 shl 3)
end enum : type as _ENetPacketFlag ENetPacketFlag

'' TODO: translate (sorry)
''struct _ENetPacket;
type _ENetPacket as ENetPacket
'' TODO: translate (sorry)
type EnetPacketFreeCallback as sub( byval p as _EnetPacket ptr )
''typedef void (ENET_CALLBACK * ENetPacketFreeCallback) (struct _ENetPacket *);

/'*
 * ENet packet structure.
 *
 * An ENet data packet that may be sent to or received from a peer. The shown 
 * fields should only be read and never modified. The data field contains the 
 * allocated data for the packet. The dataLength fields specifies the length 
 * of the allocated data.  The flags field is either 0 (specifying no flags), 
 * or a bitwise-or of any combination of the following flags:
 *
 *    ENET_PACKET_FLAG_RELIABLE - packet must be received by the target peer
 *    and resend attempts should be made until the packet is delivered
 *
 *    ENET_PACKET_FLAG_UNSEQUENCED - packet will not be sequenced with other packets 
 *    (not supported for reliable packets)
 *
 *    ENET_PACKET_FLAG_NO_ALLOCATE - packet will not allocate data, and user must supply it instead
 
   @sa ENetPacketFlag
 '/
type _ENetPacket
   as size_t                   referenceCount  /'*< internal use only '/
   as enet_uint32              flags           /'*< bitwise-or of ENetPacketFlag constants '/
   as enet_uint8 ptr data            /'*< allocated data for packet '/
   as size_t                   dataLength      /'*< length of data '/
   as ENetPacketFreeCallback   freeCallback    /'*< function to be called when the packet is no longer in use '/
end type : type as _ENetPacket ENetPacket

type _ENetAcknowledgement
   as ENetListNode acknowledgementList
   as enet_uint32  sentTime
   as ENetProtocol command
end type : type as _ENetAcknowledgement ENetAcknowledgement

type _ENetOutgoingCommand
   as ENetListNode outgoingCommandList
   as enet_uint16  reliableSequenceNumber
   as enet_uint16  unreliableSequenceNumber
   as enet_uint32  sentTime
   as enet_uint32  roundTripTimeout
   as enet_uint32  roundTripTimeoutLimit
   as enet_uint32  fragmentOffset
   as enet_uint16  fragmentLength
   as enet_uint16  sendAttempts
   as ENetProtocol command
   as ENetPacket ptr packet
end type : type as _ENetOutgoingCommand ENetOutgoingCommand

type _ENetIncomingCommand  
   as ENetListNode     incomingCommandList
   as enet_uint16      reliableSequenceNumber
   as enet_uint16      unreliableSequenceNumber
   as ENetProtocol     command
   as enet_uint32      fragmentCount
   as enet_uint32      fragmentsRemaining
   as enet_uint32 ptr fragments
   as ENetPacket ptr packet
end type : type as _ENetIncomingCommand ENetIncomingCommand

enum _ENetPeerState
   ENET_PEER_STATE_DISCONNECTED                = 0
   ENET_PEER_STATE_CONNECTING                  = 1
   ENET_PEER_STATE_ACKNOWLEDGING_CONNECT       = 2
   ENET_PEER_STATE_CONNECTION_PENDING          = 3
   ENET_PEER_STATE_CONNECTION_SUCCEEDED        = 4
   ENET_PEER_STATE_CONNECTED                   = 5
   ENET_PEER_STATE_DISCONNECT_LATER            = 6
   ENET_PEER_STATE_DISCONNECTING               = 7
   ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT    = 8
   ENET_PEER_STATE_ZOMBIE                      = 9 
end enum : type as _ENetPeerState ENetPeerState

#ifndef ENET_BUFFER_MAXIMUM
#define ENET_BUFFER_MAXIMUM (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
#endif

enum
   ENET_HOST_RECEIVE_BUFFER_SIZE          = 256 * 1024
   ENET_HOST_SEND_BUFFER_SIZE             = 256 * 1024
   ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL  = 1000
   ENET_HOST_DEFAULT_MTU                  = 1400

   ENET_PEER_DEFAULT_ROUND_TRIP_TIME      = 500
   ENET_PEER_DEFAULT_PACKET_THROTTLE      = 32
   ENET_PEER_PACKET_THROTTLE_SCALE        = 32
   ENET_PEER_PACKET_THROTTLE_COUNTER      = 7 
   ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2
   ENET_PEER_PACKET_THROTTLE_DECELERATION = 2
   ENET_PEER_PACKET_THROTTLE_INTERVAL     = 5000
   ENET_PEER_PACKET_LOSS_SCALE            = (1 shl 16)
   ENET_PEER_PACKET_LOSS_INTERVAL         = 10000
   ENET_PEER_WINDOW_SIZE_SCALE            = 64 * 1024
   ENET_PEER_TIMEOUT_LIMIT                = 32
   ENET_PEER_TIMEOUT_MINIMUM              = 5000
   ENET_PEER_TIMEOUT_MAXIMUM              = 30000
   ENET_PEER_PING_INTERVAL                = 500
   ENET_PEER_UNSEQUENCED_WINDOWS          = 64
   ENET_PEER_UNSEQUENCED_WINDOW_SIZE      = 1024
   ENET_PEER_FREE_UNSEQUENCED_WINDOWS     = 32
   ENET_PEER_RELIABLE_WINDOWS             = 16
   ENET_PEER_RELIABLE_WINDOW_SIZE         = &h1000
   ENET_PEER_FREE_RELIABLE_WINDOWS        = 8
end enum

type _ENetChannel
   as enet_uint16  outgoingReliableSequenceNumber
   as enet_uint16  outgoingUnreliableSequenceNumber
   as enet_uint16  usedReliableWindows
   '' TODO: translate (sorry)
   ''enet_uint16  reliableWindows [ENET_PEER_RELIABLE_WINDOWS];
   as enet_uint16	reliableWindows(0 TO ENET_PEER_RELIABLE_WINDOWS-1)
   as enet_uint16  incomingReliableSequenceNumber
   as enet_uint16  incomingUnreliableSequenceNumber
   as ENetList     incomingReliableCommands
   as ENetList     incomingUnreliableCommands
end type : type as _ENetChannel ENetChannel

/'*
 * An ENet peer which data packets may be sent or received from. 
 *
 * No fields should be modified unless otherwise specified. 
 '/
type _ENetPeer 
   as ENetListNode  dispatchList
   as _ENetHost ptr host
   as enet_uint16   outgoingPeerID
   as enet_uint16   incomingPeerID
   as enet_uint32   connectID
   as enet_uint8    outgoingSessionID
   as enet_uint8    incomingSessionID
   as ENetAddress   address            /'*< Internet address of the peer '/
   as any ptr data               /'*< Application private data, may be freely modified '/
   as ENetPeerState state
   as ENetChannel ptr channels
   as size_t        channelCount       /'*< Number of channels allocated for communication with peer '/
   as enet_uint32   incomingBandwidth  /'*< Downstream bandwidth of the client in bytes/second '/
   as enet_uint32   outgoingBandwidth  /'*< Upstream bandwidth of the client in bytes/second '/
   as enet_uint32   incomingBandwidthThrottleEpoch
   as enet_uint32   outgoingBandwidthThrottleEpoch
   as enet_uint32   incomingDataTotal
   as enet_uint32   outgoingDataTotal
   as enet_uint32   lastSendTime
   as enet_uint32   lastReceiveTime
   as enet_uint32   nextTimeout
   as enet_uint32   earliestTimeout
   as enet_uint32   packetLossEpoch
   as enet_uint32   packetsSent
   as enet_uint32   packetsLost
   as enet_uint32   packetLoss          /'*< mean packet loss of reliable packets as a ratio with respect to the constant ENET_PEER_PACKET_LOSS_SCALE '/
   as enet_uint32   packetLossVariance
   as enet_uint32   packetThrottle
   as enet_uint32   packetThrottleLimit
   as enet_uint32   packetThrottleCounter
   as enet_uint32   packetThrottleEpoch
   as enet_uint32   packetThrottleAcceleration
   as enet_uint32   packetThrottleDeceleration
   as enet_uint32   packetThrottleInterval
   as enet_uint32   pingInterval
   as enet_uint32   timeoutLimit
   as enet_uint32   timeoutMinimum
   as enet_uint32   timeoutMaximum
   as enet_uint32   lastRoundTripTime
   as enet_uint32   lowestRoundTripTime
   as enet_uint32   lastRoundTripTimeVariance
   as enet_uint32   highestRoundTripTimeVariance
   as enet_uint32   roundTripTime            /'*< mean round trip time (RTT), in milliseconds, between sending a reliable packet and receiving its acknowledgement '/
   as enet_uint32   roundTripTimeVariance
   as enet_uint32   mtu
   as enet_uint32   windowSize
   as enet_uint32   reliableDataInTransit
   as enet_uint16   outgoingReliableSequenceNumber
   as ENetList      acknowledgements
   as ENetList      sentReliableCommands
   as ENetList      sentUnreliableCommands
   as ENetList      outgoingReliableCommands
   as ENetList      outgoingUnreliableCommands
   as ENetList      dispatchedCommands
   as integer           needsDispatch
   as enet_uint16   incomingUnsequencedGroup
   as enet_uint16   outgoingUnsequencedGroup
   '' TODO: translate (sorry)
   ''enet_uint32   unsequencedWindow [ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32]; 
   as enet_uint32	unsequencedWindow(0 TO (ENET_PEER_UNSEQUENCED_WINDOW_SIZE/32)-1)
   as enet_uint32   eventData
end type : type as _ENetPeer ENetPeer

/'* An ENet packet compressor for compressing UDP packets before socket sends or receives.
 '/
type _ENetCompressor
   /'* Context data for the compressor. Must be non-NULL. '/
   as any ptr context
   /'* Compresses from inBuffers[0:inBufferCount-1], containing inLimit bytes, to outData, outputting at most outLimit bytes. Should return 0 on failure. '/
   '' TODO: translate (sorry)
   '' size_t (ENET_CALLBACK * compress) (void * context, const ENetBuffer * inBuffers, size_t inBufferCount, size_t inLimit, enet_uint8 * outData, size_t outLimit);
   as function(byval context as any ptr, byval inBuffers as const ENetBuffer ptr, byval inBufferCount as size_t, byval inLimit as size_t, bycal outData as enet_uint8 ptr, byval outLimit as size_t) as size_t	compress
   /'* Decompresses from inData, containing inLimit bytes, to outData, outputting at most outLimit bytes. Should return 0 on failure. '/
   '' TODO: translate (sorry)
   ''size_t (ENET_CALLBACK * decompress) (void * context, const enet_uint8 * inData, size_t inLimit, enet_uint8 * outData, size_t outLimit);
   as function(byval context as any ptr, byval inData as const enet_uint8 ptr, byval inLimit as size_t, byval outData as enet_uint8 ptr, byval outLimit as size_t) as size_t	decompress
   /'* Destroys the context when compression is disabled or the host is destroyed. May be NULL. '/
   '' TODO: translate (sorry)
   ''void (ENET_CALLBACK * destroy) (void * context);
   as sub(byval context as any ptr)	destroy
end type : type as _ENetCompressor ENetCompressor

/'* Callback that computes the checksum of the data held in buffers[0:bufferCount-1] '/
'' TODO: translate (sorry)
''typedef enet_uint32 (ENET_CALLBACK * ENetChecksumCallback) (const ENetBuffer * buffers, size_t bufferCount);
type EnetChecksumCallback as function(byval buffers as const ENetBuffer ptr, byval bufferCount as size_t) as enet_uint32
 
/'* An ENet host for communicating with peers.
  *
  * No fields should be modified unless otherwise stated.

    @sa enet_host_create()
    @sa enet_host_destroy()
    @sa enet_host_connect()
    @sa enet_host_service()
    @sa enet_host_flush()
    @sa enet_host_broadcast()
    @sa enet_host_compress()
    @sa enet_host_compress_with_range_coder()
    @sa enet_host_channel_limit()
    @sa enet_host_bandwidth_limit()
    @sa enet_host_bandwidth_throttle()
  '/
type _ENetHost
   as ENetSocket           socket
   as ENetAddress          address                     /'*< Internet address of the host '/
   as enet_uint32          incomingBandwidth           /'*< downstream bandwidth of the host '/
   as enet_uint32          outgoingBandwidth           /'*< upstream bandwidth of the host '/
   as enet_uint32          bandwidthThrottleEpoch
   as enet_uint32          mtu
   as enet_uint32          randomSeed
   as integer                  recalculateBandwidthLimits
   as ENetPeer ptr peers                       /'*< array of peers allocated for this host '/
   as size_t               peerCount                   /'*< number of peers allocated for this host '/
   as size_t               channelLimit                /'*< maximum number of channels allowed for connected peers '/
   as enet_uint32          serviceTime
   as ENetList             dispatchQueue
   as integer                  continueSending
   as size_t               packetSize
   as enet_uint16          headerFlags
   '' TODO: translate (sorry)
   ''ENetProtocol         commands [ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS];
   as EnetProtocol			commands(0 TO ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS-1)
   as size_t               commandCount
   '' TODO: translate (sorry)
   ''ENetBuffer           buffers [ENET_BUFFER_MAXIMUM];
   as ENetBuffer			buffers(0 TO ENET_BUFFER_MAXIMUM-1)
   as size_t               bufferCount
   as ENetChecksumCallback checksum                    /'*< callback the user can set to enable packet checksums for this host '/
   as ENetCompressor       compressor
   '' TODO: translate (sorry)
   ''enet_uint8           packetData [2][ENET_PROTOCOL_MAXIMUM_MTU];
   as enet_uint8			packetData(0 TO 1, 0 TO ENET_PROTOCOL_MAXIMUM_MTU-1)
   as ENetAddress          receivedAddress
   as enet_uint8 ptr receivedData
   as size_t               receivedDataLength
   as enet_uint32          totalSentData               /'*< total data sent, user should reset to 0 as needed to prevent overflow '/
   as enet_uint32          totalSentPackets            /'*< total UDP packets sent, user should reset to 0 as needed to prevent overflow '/
   as enet_uint32          totalReceivedData           /'*< total data received, user should reset to 0 as needed to prevent overflow '/
   as enet_uint32          totalReceivedPackets        /'*< total UDP packets received, user should reset to 0 as needed to prevent overflow '/
end type : type as _ENetHost ENetHost

/'*
 * An ENet event type, as specified in @ref ENetEvent.
 '/
enum _ENetEventType
   /'* no event occurred within the specified time limit '/
   ENET_EVENT_TYPE_NONE       = 0  

   /'* a connection request initiated by enet_host_connect has completed.  
     * The peer field contains the peer which successfully connected. 
     '/
   ENET_EVENT_TYPE_CONNECT    = 1  

   /'* a peer has disconnected.  This event is generated on a successful 
     * completion of a disconnect initiated by enet_pper_disconnect, if 
     * a peer has timed out, or if a connection request intialized by 
     * enet_host_connect has timed out.  The peer field contains the peer 
     * which disconnected. The data field contains user supplied data 
     * describing the disconnection, or 0, if none is available.
     '/
   ENET_EVENT_TYPE_DISCONNECT = 2  

   /'* a packet has been received from a peer.  The peer field specifies the
     * peer which sent the packet.  The channelID field specifies the channel
     * number upon which the packet was received.  The packet field contains
     * the packet that was received; this packet must be destroyed with
     * enet_packet_destroy after use.
     '/
   ENET_EVENT_TYPE_RECEIVE    = 3
end enum : type as _ENetEventType ENetEventType

/'*
 * An ENet event as returned by enet_host_service().
   
   @sa enet_host_service
 '/
type _ENetEvent
   as ENetEventType        type      /'*< type of the event '/
   as ENetPeer ptr peer      /'*< peer that generated a connect, disconnect or receive event '/
   as enet_uint8           channelID /'*< channel on the peer that generated the event, if appropriate '/
   as enet_uint32          data      /'*< data associated with the event, if appropriate '/
   as ENetPacket ptr packet    /'*< packet associated with the event, if appropriate '/
end type : type as _ENetEvent ENetEvent

/'* @defgroup global ENet global functions
    @{ 
'/

/'* 
  Initializes ENet globally.  Must be called prior to using any functions in
  ENet.
  @returns 0 on success, < 0 on failure
'/
declare function enet_initialize () as integer

/'* 
  Initializes ENet globally and supplies user-overridden callbacks. Must be called prior to using any functions in ENet. Do not use enet_initialize() if you use this variant. Make sure the ENetCallbacks structure is zeroed out so that any additional callbacks added in future versions will be properly ignored.

  @param version the constant ENET_VERSION should be supplied so ENet knows which version of ENetCallbacks struct to use
  @param inits user-overriden callbacks where any NULL callbacks will use ENet's defaults
  @returns 0 on success, < 0 on failure
'/
declare function enet_initialize_with_callbacks (byval version as ENetVersion, byval inits as const ENetCallbacks ptr) as integer

/'* 
  Shuts down ENet globally.  Should be called when a program that has
  initialized ENet exits.
'/
declare sub enet_deinitialize ()

/'* @} '/

/'* @defgroup private ENet private implementation functions '/

/'*
  Returns the wall-time in milliseconds.  Its initial value is unspecified
  unless otherwise set.
  '/
declare function enet_time_get () as enet_uint32
/'*
  Sets the current wall-time in milliseconds.
  '/
declare sub enet_time_set (byval as enet_uint32)

/'* @defgroup socket ENet socket functions
    @{
'/
declare function enet_socket_create (byval as ENetSocketType) as ENetSocket
declare function        enet_socket_bind (byval as ENetSocket, byval as const ENetAddress ptr ) as integer
declare function        enet_socket_listen (byval as ENetSocket, byval as integer) as integer
declare function enet_socket_accept (byval as ENetSocket, byval as ENetAddress ptr ) as ENetSocket
declare function        enet_socket_connect (byval as ENetSocket, byval as const ENetAddress ptr ) as integer
declare function        enet_socket_send (byval as ENetSocket, byval as const ENetAddress ptr , byval as const ENetBuffer ptr , byval as size_t) as integer
declare function        enet_socket_receive (byval as ENetSocket, byval as ENetAddress ptr , byval as ENetBuffer ptr , byval as size_t) as integer
declare function        enet_socket_wait (byval as ENetSocket, byval as enet_uint32 ptr , byval as enet_uint32) as integer
declare function        enet_socket_set_option (byval as ENetSocket, byval as ENetSocketOption, byval as integer) as integer
declare sub       enet_socket_destroy (byval as ENetSocket)
declare function        enet_socketset_select (byval as ENetSocket, byval as ENetSocketSet ptr , byval as ENetSocketSet ptr , byval as enet_uint32) as integer

/'* @} '/

/'* @defgroup Address ENet address functions
    @{
'/
/'* Attempts to resolve the host named by the parameter hostName and sets
    the host field in the address parameter if successful.
    @param address destination to store resolved address
    @param hostName host name to lookup
    @retval 0 on success
    @retval < 0 on failure
    @returns the address of the given hostName in address on success
'/
declare function enet_address_set_host (byval address as ENetAddress ptr, byval hostName as const byte ptr) as integer

/'* Gives the printable form of the ip address specified in the address parameter.
    @param address    address printed
    @param hostName   destination for name, must not be NULL
    @param nameLength maximum length of hostName.
    @returns the null-terminated name of the host in hostName on success
    @retval 0 on success
    @retval < 0 on failure
'/
declare function enet_address_get_host_ip (byval address as const ENetAddress ptr, byval hostName as byte ptr, byval nameLength as size_t) as integer

/'* Attempts to do a reverse lookup of the host field in the address parameter.
    @param address    address used for reverse lookup
    @param hostName   destination for name, must not be NULL
    @param nameLength maximum length of hostName.
    @returns the null-terminated name of the host in hostName on success
    @retval 0 on success
    @retval < 0 on failure
'/
declare function enet_address_get_host (byval address as const ENetAddress ptr, byval hostName as byte ptr, byval nameLength as size_t) as integer

/'* @} '/

declare function enet_packet_create (byval as const any ptr , byval as size_t, byval as enet_uint32) as ENetPacket ptr
declare sub         enet_packet_destroy (byval as ENetPacket ptr )
declare function          enet_packet_resize  (byval as ENetPacket ptr , byval as size_t) as integer
declare function  enet_crc32 (byval as const ENetBuffer ptr , byval as size_t) as enet_uint32
                
declare function enet_host_create (byval as const ENetAddress ptr , byval as size_t, byval as size_t, byval as enet_uint32, byval as enet_uint32) as ENetHost ptr
declare sub       enet_host_destroy (byval as ENetHost ptr )
declare function enet_host_connect (byval as ENetHost ptr , byval as const ENetAddress ptr , byval as size_t, byval as enet_uint32) as ENetPeer ptr
declare function        enet_host_check_events (byval as ENetHost ptr , byval as ENetEvent ptr ) as integer
declare function        enet_host_service (byval as ENetHost ptr , byval as ENetEvent ptr , byval as enet_uint32) as integer
declare sub       enet_host_flush (byval as ENetHost ptr )
declare sub       enet_host_broadcast (byval as ENetHost ptr , byval as enet_uint8, byval as ENetPacket ptr )
declare sub       enet_host_compress (byval as ENetHost ptr , byval as const ENetCompressor ptr )
declare function        enet_host_compress_with_range_coder (byval host as ENetHost ptr) as integer
declare sub       enet_host_channel_limit (byval as ENetHost ptr , byval as size_t)
declare sub       enet_host_bandwidth_limit (byval as ENetHost ptr , byval as enet_uint32, byval as enet_uint32)
declare sub       enet_host_bandwidth_throttle (byval as ENetHost ptr )

declare function                 enet_peer_send (byval as ENetPeer ptr , byval as enet_uint8, byval as ENetPacket ptr ) as integer
declare function enet_peer_receive (byval as ENetPeer ptr , byval channelID as enet_uint8 ptr) as ENetPacket ptr
declare sub                enet_peer_ping (byval as ENetPeer ptr )
declare sub                enet_peer_ping_interval (byval as ENetPeer ptr , byval as enet_uint32)
declare sub                enet_peer_timeout (byval as ENetPeer ptr , byval as enet_uint32, byval as enet_uint32, byval as enet_uint32)
declare sub                enet_peer_reset (byval as ENetPeer ptr )
declare sub                enet_peer_disconnect (byval as ENetPeer ptr , byval as enet_uint32)
declare sub                enet_peer_disconnect_now (byval as ENetPeer ptr , byval as enet_uint32)
declare sub                enet_peer_disconnect_later (byval as ENetPeer ptr , byval as enet_uint32)
declare sub                enet_peer_throttle_configure (byval as ENetPeer ptr , byval as enet_uint32, byval as enet_uint32, byval as enet_uint32)
declare function                   enet_peer_throttle (byval as ENetPeer ptr , byval as enet_uint32) as integer
declare sub                  enet_peer_reset_queues (byval as ENetPeer ptr )
declare sub                  enet_peer_setup_outgoing_command (byval as ENetPeer ptr , byval as ENetOutgoingCommand ptr )
declare function enet_peer_queue_outgoing_command (byval as ENetPeer ptr , byval as const ENetProtocol ptr , byval as ENetPacket ptr , byval as enet_uint32, byval as enet_uint16) as ENetOutgoingCommand ptr
declare function enet_peer_queue_incoming_command (byval as ENetPeer ptr , byval as const ENetProtocol ptr , byval as ENetPacket ptr , byval as enet_uint32) as ENetIncomingCommand ptr
declare function enet_peer_queue_acknowledgement (byval as ENetPeer ptr , byval as const ENetProtocol ptr , byval as enet_uint16) as ENetAcknowledgement ptr
declare sub                  enet_peer_dispatch_incoming_unreliable_commands (byval as ENetPeer ptr , byval as ENetChannel ptr )
declare sub                  enet_peer_dispatch_incoming_reliable_commands (byval as ENetPeer ptr , byval as ENetChannel ptr )

declare function enet_range_coder_create () as any ptr
declare sub   enet_range_coder_destroy (byval as any ptr )
declare function enet_range_coder_compress (byval as any ptr , byval as const ENetBuffer ptr , byval as size_t, byval as size_t, byval as enet_uint8 ptr , byval as size_t) as size_t
declare function enet_range_coder_decompress (byval as any ptr , byval as const enet_uint8 ptr , byval as size_t, byval as enet_uint8 ptr , byval as size_t) as size_t
   
declare function enet_protocol_command_size (byval as enet_uint8) as size_t

#ifdef __cplusplus
end extern
#endif

#endif /' __ENET_ENET_H__ '/

