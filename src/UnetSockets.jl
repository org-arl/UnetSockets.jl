"""
Julia UnetSocket API.
"""
module UnetSockets

using Reexport
@reexport using Fjage
using Dates, Distributed

export UnetSocket, Protocol, Services, Address, Topics, ReservationStatus

export isclosed, gateway, host, unbind, isbound, connect, disconnect, isconnected, getlocaladdress
export getlocalprotocol, getremoteaddress, getremoteprotocol, settimeout, gettimeout, cancel

export AbnormalTerminationNtf, CapabilityListRsp
export CapabilityReq, ClearReq, DatagramCancelReq, DatagramDeliveryNtf, DatagramFailureNtf
export DatagramNtf, DatagramProgressNtf, DatagramReq, ParamChangeNtf, DatagramTraceReq, RouteDiscoveryReq
export RouteTraceReq, RouteDiscoveryNtf, RouteTraceNtf, FecDecodeReq, RxJanusFrameNtf, TxJanusFrameReq
export BadFrameNtf, BadRangeNtf, BeaconReq, ClearSyncReq, CollisionNtf, RangeNtf, RangeReq, RxFrameNtf
export RxFrameStartNtf, SyncInfoReq, SyncInfoRsp, TxFrameNtf, TxFrameReq, TxFrameStartNtf, TxRawFrameReq
export AddressAllocReq, AddressAllocRsp, AddressResolutionReq, AddressResolutionRsp
export RecordBasebandSignalReq, RxBasebandSignalNtf, TxBasebandSignalReq, ReservationAcceptReq
export ReservationCancelReq, ReservationReq, ReservationRsp, ReservationStatusNtf, RxAckNtf, TxAckReq
export RemoteExecReq, RemoteFailureNtf, RemoteFileGetReq, RemoteFileNtf, RemoteFilePutReq, RemoteSuccessNtf
export RemoteTextNtf, RemoteTextReq, AddScheduledSleepReq, GetSleepScheduleReq, RemoveScheduledSleepReq
export SleepScheduleRsp, WakeFromSleepNtf, ClearStateReq, SaveStateReq

# Unet messages
global AbnormalTerminationNtf, CapabilityListRsp
global CapabilityReq, ClearReq, DatagramCancelReq, DatagramDeliveryNtf, DatagramFailureNtf
global DatagramNtf, DatagramProgressNtf, DatagramReq, ParamChangeNtf, DatagramTraceReq, RouteDiscoveryReq
global RouteTraceReq, RouteDiscoveryNtf, RouteTraceNtf, FecDecodeReq, RxJanusFrameNtf, TxJanusFrameReq
global BadFrameNtf, BadRangeNtf, BeaconReq, ClearSyncReq, CollisionNtf, RangeNtf, RangeReq, RxFrameNtf
global RxFrameStartNtf, SyncInfoReq, SyncInfoRsp, TxFrameNtf, TxFrameReq, TxFrameStartNtf, TxRawFrameReq
global AddressAllocReq, AddressAllocRsp, AddressResolutionReq, AddressResolutionRsp
global RecordBasebandSignalReq, RxBasebandSignalNtf, TxBasebandSignalReq, ReservationAcceptReq
global ReservationCancelReq, ReservationReq, ReservationRsp, ReservationStatusNtf, RxAckNtf, TxAckReq
global RemoteExecReq, RemoteFailureNtf, RemoteFileGetReq, RemoteFileNtf, RemoteFilePutReq, RemoteSuccessNtf
global RemoteTextNtf, RemoteTextReq, AddScheduledSleepReq, GetSleepScheduleReq, RemoveScheduledSleepReq
global SleepScheduleRsp, WakeFromSleepNtf, ClearStateReq, SaveStateReq

function __init__()
  BasebandSignal = AbstractMessageClass(@__MODULE__, "org.arl.unet.bb.BasebandSignal")
  global DatagramReq = AbstractMessageClass(@__MODULE__, "org.arl.unet.DatagramReq")
  global DatagramNtf = AbstractMessageClass(@__MODULE__, "org.arl.unet.DatagramNtf")
  global AbnormalTerminationNtf = MessageClass(@__MODULE__, "org.arl.unet.AbnormalTerminationNtf")
  global CapabilityListRsp = MessageClass(@__MODULE__, "org.arl.unet.CapabilityListRsp")
  global CapabilityReq = MessageClass(@__MODULE__, "org.arl.unet.CapabilityReq")
  global ClearReq = MessageClass(@__MODULE__, "org.arl.unet.ClearReq")
  global DatagramCancelReq = MessageClass(@__MODULE__, "org.arl.unet.DatagramCancelReq")
  global DatagramDeliveryNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramDeliveryNtf")
  global DatagramFailureNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramFailureNtf")
  global DatagramProgressNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramProgressNtf")
  global ParamChangeNtf = MessageClass(@__MODULE__, "org.arl.unet.ParamChangeNtf")
  global DatagramTraceReq = MessageClass(@__MODULE__, "org.arl.unet.net.DatagramTraceReq")
  global RouteDiscoveryReq = MessageClass(@__MODULE__, "org.arl.unet.net.RouteDiscoveryReq")
  global RouteTraceReq = MessageClass(@__MODULE__, "org.arl.unet.net.RouteTraceReq")
  global RouteDiscoveryNtf = MessageClass(@__MODULE__, "org.arl.unet.net.RouteDiscoveryNtf")
  global RouteTraceNtf = MessageClass(@__MODULE__, "org.arl.unet.net.RouteTraceNtf")
  global FecDecodeReq = MessageClass(@__MODULE__, "org.arl.unet.phy.FecDecodeReq")
  global RxJanusFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxJanusFrameNtf")
  global TxJanusFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxJanusFrameReq")
  global BadFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.BadFrameNtf")
  global BadRangeNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.BadRangeNtf")
  global BeaconReq = MessageClass(@__MODULE__, "org.arl.unet.phy.BeaconReq")
  global ClearSyncReq = MessageClass(@__MODULE__, "org.arl.unet.phy.ClearSyncReq")
  global CollisionNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.CollisionNtf")
  global RangeNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RangeNtf")
  global RangeReq = MessageClass(@__MODULE__, "org.arl.unet.phy.RangeReq")
  global RxFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxFrameNtf", DatagramNtf)
  global RxFrameStartNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxFrameStartNtf")
  global SyncInfoReq = MessageClass(@__MODULE__, "org.arl.unet.phy.SyncInfoReq")
  global SyncInfoRsp = MessageClass(@__MODULE__, "org.arl.unet.phy.SyncInfoRsp")
  global TxFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameNtf")
  global TxFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameReq", DatagramReq)
  global TxFrameStartNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameStartNtf")
  global TxRawFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxRawFrameReq")
  global AddressAllocReq = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressAllocReq")
  global AddressAllocRsp = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressAllocRsp")
  global AddressResolutionReq = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressResolutionReq")
  global AddressResolutionRsp = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressResolutionRsp")
  global RecordBasebandSignalReq = MessageClass(@__MODULE__, "org.arl.unet.bb.RecordBasebandSignalReq")
  global RxBasebandSignalNtf = MessageClass(@__MODULE__, "org.arl.unet.bb.RxBasebandSignalNtf", BasebandSignal)
  global TxBasebandSignalReq = MessageClass(@__MODULE__, "org.arl.unet.bb.TxBasebandSignalReq", BasebandSignal)
  global ReservationAcceptReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationAcceptReq")
  global ReservationCancelReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationCancelReq")
  global ReservationReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationReq")
  global ReservationRsp = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationRsp")
  global ReservationStatusNtf = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationStatusNtf")
  global RxAckNtf = MessageClass(@__MODULE__, "org.arl.unet.mac.RxAckNtf")
  global TxAckReq = MessageClass(@__MODULE__, "org.arl.unet.mac.TxAckReq")
  global RemoteExecReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteExecReq")
  global RemoteFailureNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFailureNtf")
  global RemoteFileGetReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFileGetReq")
  global RemoteFileNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFileNtf")
  global RemoteFilePutReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFilePutReq")
  global RemoteSuccessNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteSuccessNtf")
  global RemoteTextNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteTextNtf")
  global RemoteTextReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteTextReq")
  global AddScheduledSleepReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.AddScheduledSleepReq")
  global GetSleepScheduleReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.GetSleepScheduleReq")
  global RemoveScheduledSleepReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.RemoveScheduledSleepReq")
  global SleepScheduleRsp = MessageClass(@__MODULE__, "org.arl.unet.scheduler.SleepScheduleRsp")
  global WakeFromSleepNtf = MessageClass(@__MODULE__, "org.arl.unet.scheduler.WakeFromSleepNtf")
  global ClearStateReq = MessageClass(@__MODULE__, "org.arl.unet.state.ClearStateReq")
  global SaveStateReq = MessageClass(@__MODULE__, "org.arl.unet.state.SaveStateReq")
end

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
  waiting::Bool
  function UnetSocket(host::String, port::Integer)
    sock = new(Gateway(host, port), -1, -1, 0, -1, nothing, false)
    @async begin
      alist = agentsforservice(sock.gw, Services.DATAGRAM)
      for a in alist
        subscribe(sock.gw, a)
      end
    end
    return sock
  end
end

Base.show(io::IO, sock::UnetSocket) = Base.show(io, sock.gw)

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
receive() call is non-blocking. Negative timeout is considered infinite.
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
function Fjage.send(sock::UnetSocket, req::Message)
  if sock.gw == nothing
    return false
  end
  if !isa(req, DatagramReq)
    return false
  end
  protocol = req.protocol
  protocol == nothing && (protocol = Protocol.USER)
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
  if sock.gw == nothing
    return nothing
  end
  t0 = now()
  while sock.timeout <= 0 || (now()-t0).value < sock.timeout
    sock.waiting = true
    ntf = receive(sock.gw, DatagramNtf, sock.timeout)
    sock.waiting = false
    if ntf == nothing
      return nothing
    end
    if isa(ntf, DatagramNtf)
      p = ntf.protocol
      if p == Protocol.DATA || p >= Protocol.USER
        if sock.localprotocol < 0 || localprotocol == p
          return ntf
        end
      end
    end
  end
  return nothing
end

"Cancels an ongoing blocking receive()."
function cancel(sock::UnetSocket)
  if sock.waiting
    push!(sock.gw.queue, nothing)
  end
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
