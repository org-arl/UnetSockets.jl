"""
Julia-Unet API.
"""
module Unet

using Reexport
@reexport using Fjage

export UnetSocket, Protocol, Services, Address, Topics, ReservationStatus
export AddressResolutionReq, ParameterReq

export isclosed, gateway, host, unbind, isbound, connect, disconnect, isconnected, getlocaladdress
export getlocalprotocol, getremoteaddress, getremoteprotocol, settimeout, gettimeout, cancel

export ParameterReq, ParameterRsp, TestReportNtf, AbnormalTerminationNtf, CapabilityListRsp
export CapabilityReq, ClearReq, DatagramCancelReq, DatagramDeliveryNtf, DatagramFailureNtf
export DatagramNtf, DatagramProgressNtf, DatagramReq, ParamChangeNtf, DatagramTraceReq, RouteDiscoveryReq
export RouteTraceReq, RouteDiscoveryNtf, RouteTraceNtf, FecDecodeReq, RxJanusFrameNtf, TxJanusFrameReq
export BadFrameNtf, BadRangeNtf, BeaconReq, ClearSyncReq, CollisionNtf, RangeNtf, RangeReq, RxFrameNtf
export RxFrameStartNtf, SyncInfoReq, SyncInfoRsp, TxFrameNtf, TxFrameReq, TxFrameStartNtf, TxRawFrameReq
export AddressAllocReq, AddressAllocRsp, AddressResolutionReq, AddressResolutionRsp, BasebandSignal
export RecordBasebandSignalReq, RxBasebandSignalNtf, TxBasebandSignalReq, ReservationAcceptReq
export ReservationCancelReq, ReservationReq, ReservationRsp, ReservationStatusNtf, RxAckNtf, TxAckReq
export RemoteExecReq, RemoteFailureNtf, RemoteFileGetReq, RemoteFileNtf, RemoteFilePutReq, RemoteSuccessNtf
export RemoteTextNtf, RemoteTextReq, AddScheduledSleepReq, GetSleepScheduleReq, RemoveScheduledSleepReq
export SleepScheduleRsp, WakeFromSleepNtf, ClearStateReq, SaveStateReq

# Unet messages
ParameterReq            = @MessageClass("org.arl.unet.ParameterReq")
ParameterRsp            = @MessageClass("org.arl.unet.ParameterRsp")
TestReportNtf           = @MessageClass("org.arl.unet.TestReportNtf")
AbnormalTerminationNtf  = @MessageClass("org.arl.unet.AbnormalTerminationNtf")
CapabilityListRsp       = @MessageClass("org.arl.unet.CapabilityListRsp")
CapabilityReq           = @MessageClass("org.arl.unet.CapabilityReq")
ClearReq                = @MessageClass("org.arl.unet.ClearReq")
DatagramCancelReq       = @MessageClass("org.arl.unet.DatagramCancelReq")
DatagramDeliveryNtf     = @MessageClass("org.arl.unet.DatagramDeliveryNtf")
DatagramFailureNtf      = @MessageClass("org.arl.unet.DatagramFailureNtf")
DatagramNtf             = @MessageClass("org.arl.unet.DatagramNtf")
DatagramProgressNtf     = @MessageClass("org.arl.unet.DatagramProgressNtf")
DatagramReq             = @MessageClass("org.arl.unet.DatagramReq")
ParamChangeNtf          = @MessageClass("org.arl.unet.ParamChangeNtf")
DatagramTraceReq        = @MessageClass("org.arl.unet.net.DatagramTraceReq")
RouteDiscoveryReq       = @MessageClass("org.arl.unet.net.RouteDiscoveryReq")
RouteTraceReq           = @MessageClass("org.arl.unet.net.RouteTraceReq")
RouteDiscoveryNtf       = @MessageClass("org.arl.unet.net.RouteDiscoveryNtf")
RouteTraceNtf           = @MessageClass("org.arl.unet.net.RouteTraceNtf")
FecDecodeReq            = @MessageClass("org.arl.unet.phy.FecDecodeReq")
RxJanusFrameNtf         = @MessageClass("org.arl.unet.phy.RxJanusFrameNtf")
TxJanusFrameReq         = @MessageClass("org.arl.unet.phy.TxJanusFrameReq")
BadFrameNtf             = @MessageClass("org.arl.unet.phy.BadFrameNtf")
BadRangeNtf             = @MessageClass("org.arl.unet.phy.BadRangeNtf")
BeaconReq               = @MessageClass("org.arl.unet.phy.BeaconReq")
ClearSyncReq            = @MessageClass("org.arl.unet.phy.ClearSyncReq")
CollisionNtf            = @MessageClass("org.arl.unet.phy.CollisionNtf")
RangeNtf                = @MessageClass("org.arl.unet.phy.RangeNtf")
RangeReq                = @MessageClass("org.arl.unet.phy.RangeReq")
RxFrameNtf              = @MessageClass("org.arl.unet.phy.RxFrameNtf", DatagramNtf)
RxFrameStartNtf         = @MessageClass("org.arl.unet.phy.RxFrameStartNtf")
SyncInfoReq             = @MessageClass("org.arl.unet.phy.SyncInfoReq")
SyncInfoRsp             = @MessageClass("org.arl.unet.phy.SyncInfoRsp")
TxFrameNtf              = @MessageClass("org.arl.unet.phy.TxFrameNtf")
TxFrameReq              = @MessageClass("org.arl.unet.phy.TxFrameReq") # TODO: subclass of org_arl_unet_DatagramReq
TxFrameStartNtf         = @MessageClass("org.arl.unet.phy.TxFrameStartNtf")
TxRawFrameReq           = @MessageClass("org.arl.unet.phy.TxRawFrameReq")
AddressAllocReq         = @MessageClass("org.arl.unet.addr.AddressAllocReq")
AddressAllocRsp         = @MessageClass("org.arl.unet.addr.AddressAllocRsp")
AddressResolutionReq    = @MessageClass("org.arl.unet.addr.AddressResolutionReq")
AddressResolutionRsp    = @MessageClass("org.arl.unet.addr.AddressResolutionRsp")
BasebandSignal          = @MessageClass("org.arl.unet.bb.BasebandSignal")
RecordBasebandSignalReq = @MessageClass("org.arl.unet.bb.RecordBasebandSignalReq")
RxBasebandSignalNtf     = @MessageClass("org.arl.unet.bb.RxBasebandSignalNtf") # TODO: subclass of org_arl_unet_phy_BasebandSignal
TxBasebandSignalReq     = @MessageClass("org.arl.unet.bb.TxBasebandSignalReq") # TODO: subclass of org_arl_unet_phy_BasebandSignal
ReservationAcceptReq    = @MessageClass("org.arl.unet.mac.ReservationAcceptReq")
ReservationCancelReq    = @MessageClass("org.arl.unet.mac.ReservationCancelReq")
ReservationReq          = @MessageClass("org.arl.unet.mac.ReservationReq")
ReservationRsp          = @MessageClass("org.arl.unet.mac.ReservationRsp")
ReservationStatusNtf    = @MessageClass("org.arl.unet.mac.ReservationStatusNtf")
RxAckNtf                = @MessageClass("org.arl.unet.mac.RxAckNtf")
TxAckReq                = @MessageClass("org.arl.unet.mac.TxAckReq")
RemoteExecReq           = @MessageClass("org.arl.unet.remote.RemoteExecReq")
RemoteFailureNtf        = @MessageClass("org.arl.unet.remote.RemoteFailureNtf")
RemoteFileGetReq        = @MessageClass("org.arl.unet.remote.RemoteFileGetReq")
RemoteFileNtf           = @MessageClass("org.arl.unet.remote.RemoteFileNtf")
RemoteFilePutReq        = @MessageClass("org.arl.unet.remote.RemoteFilePutReq")
RemoteSuccessNtf        = @MessageClass("org.arl.unet.remote.RemoteSuccessNtf")
RemoteTextNtf           = @MessageClass("org.arl.unet.remote.RemoteTextNtf")
RemoteTextReq           = @MessageClass("org.arl.unet.remote.RemoteTextReq")
AddScheduledSleepReq    = @MessageClass("org.arl.unet.scheduler.AddScheduledSleepReq")
GetSleepScheduleReq     = @MessageClass("org.arl.unet.scheduler.GetSleepScheduleReq")
RemoveScheduledSleepReq = @MessageClass("org.arl.unet.scheduler.RemoveScheduledSleepReq")
SleepScheduleRsp        = @MessageClass("org.arl.unet.scheduler.SleepScheduleRsp")
WakeFromSleepNtf        = @MessageClass("org.arl.unet.scheduler.WakeFromSleepNtf")
ClearStateReq           = @MessageClass("org.arl.unet.state.ClearStateReq")
SaveStateReq            = @MessageClass("org.arl.unet.state.SaveStateReq")

"Well-known addresses."
module Address
  const BROADCAST = 0
end

"Well-known protocol number assignments."
module Protocol
  const DATA = 0
  const RANGING = 1
  const LINK = 2
  const REMOTE = 3
  const MAC = 4
  const ROUTING = 5
  const TRANSPORT = 6
  const ROUTE_MAINTENANCE = 7
  const LINK2 = 8
  const USER = 32
  const MAX = 63
end

"Well-known topics."
module Topics
  const PARAMCHANGE = "org.arl.unet.Topics.PARAMCHANGE"
  const LIFECYCLE = "org.arl.unet.Topics.LIFECYCLE"
end

"Well-known service names."
module Services
  const NODE_INFO = "org.arl.unet.Services.NODE_INFO"
  const ADDRESS_RESOLUTION = "org.arl.unet.Services.ADDRESS_RESOLUTION"
  const DATAGRAM = "org.arl.unet.Services.DATAGRAM"
  const PHYSICAL = "org.arl.unet.Services.PHYSICAL"
  const RANGING = "org.arl.unet.Services.RANGING"
  const BASEBAND = "org.arl.unet.Services.BASEBAND"
  const LINK = "org.arl.unet.Services.LINK"
  const MAC = "org.arl.unet.Services.MAC"
  const ROUTING = "org.arl.unet.Services.ROUTING"
  const ROUTE_MAINTENANCE = "org.arl.unet.Services.ROUTE_MAINTENANCE"
  const TRANSPORT = "org.arl.unet.Services.TRANSPORT"
  const REMOTE = "org.arl.unet.Services.REMOTE"
  const STATE_MANAGER = "org.arl.unet.Services.STATE_MANAGER"
  const SCHEDULE = "org.arl.unet.Services.SCHEDULE"
  const SHELL = "org.arl.fjage.shell.Services.SHELL"
end

"Status indicator for a particular request during the reservation process."
module ReservationStatus
  const START = 0             # Start of channel reservation for a reservation request
  const END = 1               # End of channel reservation for a reservation request
  const FAILURE = 2           # Failure to reserve channel for a reservation request
  const CANCEL = 3            # Cancel channel reservation for a reservation request
  const REQUEST = 4           # Request information from a client agent for a reservation request
end

"""
    sock = UnetSocket(host, port)

Open a new UnetSocket via TCP/IP to communicate with UnetStack.
"""
mutable struct UnetSocket
  gw::Union{Gateway, Nothing}
  localprotocol::Integer
  remoteaddress::Integer
  remoteprotocol::Integer
  timeout::Integer
  provider::Union{AgentID, Nothing}
  function UnetSocket(host::String, port::Integer)
    return new(Gateway(host, port), -1, -1, 0, -1, nothing)
  end
end

"Close the socket."
function close(sock::UnetSocket)
  Base.close(sock.gw)
  sock.gw = nothing
end

"Checks if a socket is closed."
function isclosed(sock::UnetSocket)
  return sock.gw == nothing
end

"Binds a socket to listen to a specific protocol datagrams."
function bind(sock::UnetSocket, protocol::Integer)
  if protocol == Protocol.DATA || (protocol >= Protocol.USER && protocol <= Protocol.MAX)
    sock.localprotocol = protocol
    return true
  end
  return false
end

"Unbinds a socket so that it listens to all unreserved protocols."
function unbind(sock::UnetSocket)
  sock.localprotocol = -1
end

"Checks if a socket is bound."
function isbound(sock::UnetSocket)
  return sock.localprotocol >= 0
end

"""
Sets the default destination address and destination protocol number for
datagrams sent using this socket. The defaults can be overridden for specific
send() calls.
"""
function connect(sock::UnetSocket, to::Integer, protocol::Integer)
  if to >= 0 && (protocol == Protocol.DATA || (protocol >= Protocol.USER && protocol <= Protocol.MAX))
    sock.remoteaddress = to
    sock.remoteprotocol = protocol
    return true
  end
  return false
end

"Resets the default destination address to undefined, and the default protocol number to Protocol.DATA."
function disconnect(sock::UnetSocket)
  sock.remoteaddress = -1
  sock.remoteprotocol = 0
end

"Checks if a socket is connected, i.e., has a default destination address and protocol number."
function isconnected(sock::UnetSocket)
  return sock.remoteaddress >= 0
end

"Gets the local node address."
function getlocaladdress(sock::UnetSocket)
  if sock.gw == nothing
    return -1
  end
  nodeinfo = agentforservice(sock.gw, Services.NODE_INFO)
  if nodeinfo == nothing
    return -1
  end
  req = ParameterReq(recipient=nodeinfo, param="address")
  rsp = request(sock.gw, req)
  if rsp == nothing
    return -1
  end
  return rsp.value
end

"Gets the protocol number that the socket is bound to."
function getlocalprotocol(sock::UnetSocket)
  return sock.localprotocol
end

"Gets the default destination node address for a connected socket."
function getremoteaddress(sock::UnetSocket)
  return sock.remoteaddress
end

"Gets the default transmission protocol number."
function getremoteprotocol(sock::UnetSocket)
  return sock.remoteprotocol
end

"""
Sets the timeout for datagram reception. The default timeout is infinite.
i.e., the receive() call blocks forever. A timeout of 0 means the
receive() call is non-blocking.
"""
function settimeout(sock::UnetSocket, ms::Integer)
  if ms < 0
    ms = -1
  end
  sock.timeout = ms
end

"Gets the timeout for datagram reception."
function gettimeout(sock::UnetSocket)
  return sock.timeout
end

"Transmits a datagram to the default node address using the default protocol."
function Fjage.send(sock::UnetSocket, data)
  if sock.remoteaddress < 0
    return false
  end
  return send(sock, DatagramReq(to=sock.remoteaddress, protocol=sock.remoteprotocol, data=Vector{UInt8}(data)))
end

"Transmits a datagram to the specified node address using the default protocol."
function Fjage.send(sock::UnetSocket, data, to::Integer)
  return send(sock, DatagramReq(to=to, protocol=sock.remoteprotocol, data=Vector{UInt8}(data)))
end

"Transmits a datagram to the specified node address using the specified protocol."
function Fjage.send(sock::UnetSocket, data, to::Integer, protocol::Integer)
  return send(sock, DatagramReq(to=to, protocol=protocol, data=Vector{UInt8}(data)))
end

"Transmits a datagram to the specified node address using the specified protocol."
function Fjage.send(sock::UnetSocket, req::DatagramReq)
  if sock.gw == nothing
    return false
  end
  protocol = req.protocol
  if protocol != Protocol.DATA && (protocol < Protocol.USER || protocol > Protocol.MAX)
    return false
  end
  if req.recipient == nothing
    (sock.provider == nothing) && (sock.provider = agentforservice(sock.gw, Services.TRANSPORT))
    (sock.provider == nothing) && (sock.provider = agentforservice(sock.gw, Services.ROUTING))
    (sock.provider == nothing) && (sock.provider = agentforservice(sock.gw, Services.LINK))
    (sock.provider == nothing) && (sock.provider = agentforservice(sock.gw, Services.PHYSICAL))
    (sock.provider == nothing) && (sock.provider = agentforservice(sock.gw, Services.DATAGRAM))
    (sock.provider == nothing) && (return false)
    req.recipient = sock.provider
  end
  rsp = request(sock.gw, req)
  return rsp != nothing && rsp.performative == Performative.AGREE
end

"""
Receives a datagram sent to the local node and the bound protocol number. If the
socket is unbound, then datagrams with all unreserved protocols are received. Any
broadcast datagrams are also received.

This call blocks until a datagram is availbale, the socket timeout is reached,
or until cancel() is called.
"""
function Fjage.receive(sock::UnetSocket)
# TODO
#  try {
#    if (gw == null) return null;
#    waiting = Thread.currentThread();
#    long deadline = -1;
#    Platform platform = null;
#    if (timeout == 0) deadline = 0;
#    else if (timeout > 0) {
#      platform = gw.getPlatform();
#      deadline = platform.currentTimeMillis() + timeout;
#    }
#    Message ntf = null;
#    while (!Thread.interrupted()) {
#      long timeRemaining = -1;
#      if (timeout == 0) timeRemaining = 0;
#      else if (timeout > 0) {
#        timeRemaining = deadline - platform.currentTimeMillis();
#        if (timeRemaining <= 0) return null;
#      }
#      ntf = gw.receive(DatagramNtf.class, timeRemaining);
#      if (ntf == null) return null;
#      if (ntf instanceof DatagramNtf) {
#        DatagramNtf dg = (DatagramNtf)ntf;
#        int p = dg.getProtocol();
#        if (p == Protocol.DATA || p >= Protocol.USER) {
#          if (localprotocol < 0) return dg;
#          if (localprotocol == p) return dg;
#        }
#      }
#    }
#  } finally {
#    waiting = null;
#  }
#  return null;
end

"Cancels an ongoing blocking receive()."
function cancel(sock::UnetSocket)
# TODO
#  if (waiting == null) return;
#  waiting.interrupt();
end

"Gets a Gateway to provide low-level access to UnetStack."
function gateway(sock::UnetSocket)
  return sock.gw
end

"Gets an AgentID providing a specified service for low-level access to UnetStack."
function Fjage.agentforservice(sock::UnetSocket, svc::String)
  if sock.gw == nothing
    return nothing
  else
    return agentforservice(sock.gw, svc)
  end
end

"Gets a list of AgentIDs providing a specified service for low-level access to UnetStack."
function Fjage.agentsforservice(sock::UnetSocket, svc::String)
  if sock.gw == nothing
    return []
  else
    return agentsforservice(sock.gw, svc)
  end
end

"Gets a named AgentID for low-level access to UnetStack."
function Fjage.agent(sock::UnetSocket, name::String)
  if sock.gw == nothing
    return nothing
  else
    return agent(sock.gw, name)
  end
end

"""
    address = host(sock, name)

Resolve node name to node address.
"""
function host(sock::UnetSocket, name::String)
  if sock.gw == nothing
    return nothing
  end
  arp = agentforservice(sock.gw, Services.ADDRESS_RESOLUTION)
  if arp == nothing
    return nothing
  end
  rsp = arp << AddressResolutionReq(name=name)
  if rsp == nothing
    return nothing
  end
  return rsp.address
end

# Base functions to add local methods
Base.close(sock::UnetSocket) = close(sock)
Base.bind(sock::UnetSocket, protocol::Integer) = bind(sock, protocol)

end
