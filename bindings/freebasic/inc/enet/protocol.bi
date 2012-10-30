/'* 
 @file  protocol.h
 @brief ENet protocol
'/
#ifndef __ENET_PROTOCOL_H__
#define __ENET_PROTOCOL_H__

#include "enet/types.bi"

enum
   ENET_PROTOCOL_MINIMUM_MTU             = 576
   ENET_PROTOCOL_MAXIMUM_MTU             = 4096
   ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS = 32
   ENET_PROTOCOL_MINIMUM_WINDOW_SIZE     = 4096
   ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE     = 32768
   ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT   = 1
   ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT   = 255
   ENET_PROTOCOL_MAXIMUM_PEER_ID         = &hFFF
   ENET_PROTOCOL_MAXIMUM_PACKET_SIZE     = 1024 * 1024 * 1024
   ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT  = 1024 * 1024
end enum

enum _ENetProtocolCommand
   ENET_PROTOCOL_COMMAND_NONE               = 0
   ENET_PROTOCOL_COMMAND_ACKNOWLEDGE        = 1
   ENET_PROTOCOL_COMMAND_CONNECT            = 2
   ENET_PROTOCOL_COMMAND_VERIFY_CONNECT     = 3
   ENET_PROTOCOL_COMMAND_DISCONNECT         = 4
   ENET_PROTOCOL_COMMAND_PING               = 5
   ENET_PROTOCOL_COMMAND_SEND_RELIABLE      = 6
   ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE    = 7
   ENET_PROTOCOL_COMMAND_SEND_FRAGMENT      = 8
   ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED   = 9
   ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT    = 10
   ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11
   ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12
   ENET_PROTOCOL_COMMAND_COUNT              = 13

   ENET_PROTOCOL_COMMAND_MASK               = &h0F
end enum : type as _ENetProtocolCommand ENetProtocolCommand

enum _ENetProtocolFlag
   ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 shl 7)
   ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 shl 6)

   ENET_PROTOCOL_HEADER_FLAG_COMPRESSED = (1 shl 14)
   ENET_PROTOCOL_HEADER_FLAG_SENT_TIME  = (1 shl 15)
   ENET_PROTOCOL_HEADER_FLAG_MASK       = ENET_PROTOCOL_HEADER_FLAG_COMPRESSED or ENET_PROTOCOL_HEADER_FLAG_SENT_TIME

   ENET_PROTOCOL_HEADER_SESSION_MASK    = (3 shl 12)
   ENET_PROTOCOL_HEADER_SESSION_SHIFT   = 12
end enum : type as _ENetProtocolFlag ENetProtocolFlag

type _ENetProtocolHeader Field=1
   as enet_uint16 peerID
   as enet_uint16 sentTime
end type : type as _ENetProtocolHeader ENetProtocolHeader

type _ENetProtocolCommandHeader Field=1
   as enet_uint8 command
   as enet_uint8 channelID
   as enet_uint16 reliableSequenceNumber
end type : type as _ENetProtocolCommandHeader ENetProtocolCommandHeader

type _ENetProtocolAcknowledge Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 receivedReliableSequenceNumber
   as enet_uint16 receivedSentTime
end type : type as _ENetProtocolAcknowledge ENetProtocolAcknowledge

type _ENetProtocolConnect Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 outgoingPeerID
   as enet_uint8  incomingSessionID
   as enet_uint8  outgoingSessionID
   as enet_uint32 mtu
   as enet_uint32 windowSize
   as enet_uint32 channelCount
   as enet_uint32 incomingBandwidth
   as enet_uint32 outgoingBandwidth
   as enet_uint32 packetThrottleInterval
   as enet_uint32 packetThrottleAcceleration
   as enet_uint32 packetThrottleDeceleration
   as enet_uint32 connectID
   as enet_uint32 data
end type : type as _ENetProtocolConnect ENetProtocolConnect

type _ENetProtocolVerifyConnect Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 outgoingPeerID
   as enet_uint8  incomingSessionID
   as enet_uint8  outgoingSessionID
   as enet_uint32 mtu
   as enet_uint32 windowSize
   as enet_uint32 channelCount
   as enet_uint32 incomingBandwidth
   as enet_uint32 outgoingBandwidth
   as enet_uint32 packetThrottleInterval
   as enet_uint32 packetThrottleAcceleration
   as enet_uint32 packetThrottleDeceleration
   as enet_uint32 connectID
end type : type as _ENetProtocolVerifyConnect ENetProtocolVerifyConnect

type _ENetProtocolBandwidthLimit Field=1
   as ENetProtocolCommandHeader header
   as enet_uint32 incomingBandwidth
   as enet_uint32 outgoingBandwidth
end type : type as _ENetProtocolBandwidthLimit ENetProtocolBandwidthLimit

type _ENetProtocolThrottleConfigure Field=1
   as ENetProtocolCommandHeader header
   as enet_uint32 packetThrottleInterval
   as enet_uint32 packetThrottleAcceleration
   as enet_uint32 packetThrottleDeceleration
end type : type as _ENetProtocolThrottleConfigure ENetProtocolThrottleConfigure

type _ENetProtocolDisconnect Field=1
   as ENetProtocolCommandHeader header
   as enet_uint32 data
end type : type as _ENetProtocolDisconnect ENetProtocolDisconnect

type _ENetProtocolPing Field=1
   as ENetProtocolCommandHeader header
end type : type as _ENetProtocolPing ENetProtocolPing

type _ENetProtocolSendReliable Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 dataLength
end type : type as _ENetProtocolSendReliable ENetProtocolSendReliable

type _ENetProtocolSendUnreliable Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 unreliableSequenceNumber
   as enet_uint16 dataLength
end type : type as _ENetProtocolSendUnreliable ENetProtocolSendUnreliable

type _ENetProtocolSendUnsequenced Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 unsequencedGroup
   as enet_uint16 dataLength
end type : type as _ENetProtocolSendUnsequenced ENetProtocolSendUnsequenced

type _ENetProtocolSendFragment Field=1
   as ENetProtocolCommandHeader header
   as enet_uint16 startSequenceNumber
   as enet_uint16 dataLength
   as enet_uint32 fragmentCount
   as enet_uint32 fragmentNumber
   as enet_uint32 totalLength
   as enet_uint32 fragmentOffset
end type : type as _ENetProtocolSendFragment ENetProtocolSendFragment

union _ENetProtocol
   as ENetProtocolCommandHeader header
   as ENetProtocolAcknowledge acknowledge
   as ENetProtocolConnect connect
   as ENetProtocolVerifyConnect verifyConnect
   as ENetProtocolDisconnect disconnect
   as ENetProtocolPing ping
   as ENetProtocolSendReliable sendReliable
   as ENetProtocolSendUnreliable sendUnreliable
   as ENetProtocolSendUnsequenced sendUnsequenced
   as ENetProtocolSendFragment sendFragment
   as ENetProtocolBandwidthLimit bandwidthLimit
   as ENetProtocolThrottleConfigure throttleConfigure
end union : type as _ENetProtocol ENetProtocol

#endif /' __ENET_PROTOCOL_H__ '/

