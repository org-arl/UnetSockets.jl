"""
Julia UnetSocket API for UnetStack 7.
"""
module UnetSockets

using Reexport
@reexport using Fjage
using Dates

export UnetSocket, Protocol, Services, Address, Topics, ReservationStatus, Priority, Robustness
export NON_BLOCKING, SEMI_BLOCKING
export isclosed, getgateway, host, unbind, isbound, connect, disconnect, isconnected, getlocaladdress
export getlocalprotocol, getremoteaddress, getremoteprotocol, settimeout, gettimeout, cancel
export getserviceprovider, setserviceprovider

include("Messages.jl")
include("Properties.jl")

function __init__()
  Fjage.registermessages()
end

# timeout for request-response interactions with the stack
const REQUEST_TIMEOUT = 5000

"""
When used as a timeout value, indicates a non-blocking receive(). When used as
a send mode, indicates non-blocking send(): a request is made to send data, but
the call does not wait for acceptance or transmission.
"""
const NON_BLOCKING = 0

"""
When used as a send mode, indicates semi-blocking send(): the call waits until
the data is accepted for transmission, but does not wait for the actual
transmission of unreliable datagrams. If reliability is enabled, the call waits
until delivery is acknowledged or fails. This is the default send mode.

Not a valid timeout value for receive(). A blocking receive()/send() uses
`BLOCKING` (-1), and a non-blocking one uses `NON_BLOCKING` (0).
"""
const SEMI_BLOCKING = -2

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
  const WORMHOLE = 8
  const LINK2 = 9
  const ENCRYPTED_LINK = 10
  const USER = 32
  const MAX = 63
  const TEST = -1
end

"Well-known topics."
module Topics
  const PARAMCHANGE = "org.arl.unet.Topics.PARAMCHANGE"
  const LIFECYCLE = "org.arl.unet.Topics.LIFECYCLE"
  const DATAGRAM = "org.arl.unet.Topics.DATAGRAM"
  const SYSTEM = "org.arl.unet.Topics.SYSTEM"
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
  const LINK_TUNING = "org.arl.unet.Services.LINK_TUNING"
  const MAC = "org.arl.unet.Services.MAC"
  const ROUTING = "org.arl.unet.Services.ROUTING"
  const ROUTE_MAINTENANCE = "org.arl.unet.Services.ROUTE_MAINTENANCE"
  const TRANSPORT = "org.arl.unet.Services.TRANSPORT"
  const REMOTE = "org.arl.unet.Services.REMOTE"
  const SCHEDULER = "org.arl.unet.Services.SCHEDULER"
  const DEVICE_INFO = "org.arl.unet.Services.DEVICE_INFO"
  const DOA = "org.arl.unet.Services.DOA"
  const SHELL = "org.arl.fjage.shell.Services.SHELL"
end

"Priority of transmitted datagrams."
module Priority
  const URGENT = :URGENT
  const HIGH = :HIGH
  const NORMAL = :NORMAL
  const LOW = :LOW
  const IDLE = :IDLE
end

"Robustness of transmitted datagrams."
module Robustness
  const ROBUST = :ROBUST
  const NORMAL = :NORMAL
end

"Status indicator for a particular request during the reservation process."
module ReservationStatus
  const START = :START        # start of channel reservation for a reservation request
  const END = :END            # end of channel reservation for a reservation request
  const FAILURE = :FAILURE    # failure to reserve channel for a reservation request
  const CANCEL = :CANCEL      # cancel channel reservation for a reservation request
  const REQUEST = :REQUEST    # request information from a client agent for a reservation request
end

"""
    sock = UnetSocket(host, port)

Open a new UnetSocket via TCP/IP to communicate with UnetStack.

In addition to the socket API functions, a socket carries a set of attributes,
read and set as properties. `timeout` controls datagram reception; the others
are applied to all datagrams sent using the socket:

| Property           | Type                  | Default         | Description                                        |
|:-------------------|:----------------------|:----------------|:---------------------------------------------------|
| `timeout`          | `Int`                 | `BLOCKING`      | receive timeout in milliseconds                    |
| `sendmode`         | `Int`                 | `SEMI_BLOCKING` | `NON_BLOCKING`, `SEMI_BLOCKING` or `BLOCKING`      |
| `ttl`              | `Float32`             | `NaN32` (unset) | time-to-live in seconds                            |
| `priority`         | `Symbol`              | `:NORMAL`       | one of the `Priority.*` constants                  |
| `robustness`       | `Symbol`              | `:NORMAL`       | one of the `Robustness.*` constants                |
| `reliability`      | `Bool` or `nothing`   | `nothing`       | request acknowledged delivery                      |
| `route`            | `String` or `nothing` | `nothing`       | route ID                                           |
| `mimetype`         | `String` or `nothing` | `nothing`       | MIME type (sends a `RemoteMessageReq`)             |
| `messageclass`     | `String` or `nothing` | `nothing`       | message class (sends a `RemoteMessageReq`)         |
| `remoterecipient`  | `String` or `nothing` | `nothing`       | remote recipient (sends a `RemoteMessageReq`)      |
| `mailbox`          | `String` or `nothing` | `nothing`       | mailbox (sends a `RemoteMessageReq`)               |

Example:
```julia
sock = UnetSocket("localhost", 1100)
sock.ttl = 60.0
sock.priority = Priority.HIGH
sock.reliability = true
send(sock, "hello!", 31, Protocol.USER)
```
"""
mutable struct UnetSocket
  gw::Union{Gateway, Nothing}
  localprotocol::Int
  remoteaddress::Int
  remoteprotocol::Int
  timeout::Int
  provider::Union{AgentID, Nothing}
  waiting::Bool
  sendmode::Int
  ttl::Float32
  priority::Symbol
  robustness::Symbol
  reliability::Union{Bool, Nothing}
  route::Union{String, Nothing}
  mimetype::Union{String, Nothing}
  messageclass::Union{String, Nothing}
  remoterecipient::Union{String, Nothing}
  mailbox::Union{String, Nothing}
  function UnetSocket(host::String, port::Integer)
    sock = new(Gateway(host, port), -1, -1, 0, -1, nothing, false,
               SEMI_BLOCKING, NaN32, Priority.NORMAL, Robustness.NORMAL,
               nothing, nothing, nothing, nothing, nothing, nothing)
    subscribe(getfield(sock, :gw), topic(Topics.DATAGRAM))
    return sock
  end
end

Base.show(io::IO, sock::UnetSocket) = Base.show(io, sock.gw)

# aliases allow the camelCase attribute names used in other language bindings
const _aliases = Dict{Symbol,Symbol}(
  :sendMode => :sendmode,
  :mimeType => :mimetype,
  :messageClass => :messageclass,
  :remoteRecipient => :remoterecipient
)

const _priorities = (Priority.URGENT, Priority.HIGH, Priority.NORMAL, Priority.LOW, Priority.IDLE)
const _robustnesses = (Robustness.ROBUST, Robustness.NORMAL)
const _sendmodes = (NON_BLOCKING, BLOCKING, SEMI_BLOCKING)

function Base.setproperty!(sock::UnetSocket, p::Symbol, v)
  p = get(_aliases, p, p)
  if p === :priority
    v ∈ _priorities || throw(ArgumentError("priority must be one of the Priority.* constants"))
  elseif p === :robustness
    v ∈ _robustnesses || throw(ArgumentError("robustness must be one of the Robustness.* constants"))
  elseif p === :sendmode
    v ∈ _sendmodes || throw(ArgumentError("sendmode must be NON_BLOCKING, SEMI_BLOCKING or BLOCKING"))
  elseif p === :timeout
    v isa Real && v < 0 && (v = -1)
  end
  setfield!(sock, p, convert(fieldtype(UnetSocket, p), v))
end

Base.getproperty(sock::UnetSocket, p::Symbol) = getfield(sock, get(_aliases, p, p))
Base.propertynames(::UnetSocket) = fieldnames(UnetSocket)

"Close the socket."
function close(sock::UnetSocket)
  Base.close(sock.gw)
  sock.gw = nothing
end

"Checks if a socket is closed."
function isclosed(sock::UnetSocket)
  return sock.gw === nothing
end

"""
Binds a socket to listen to a specific protocol datagrams.

Protocol numbers between Protocol.DATA+1 and Protocol.USER-1 are reserved
protocols and cannot be bound. Unbound sockets listen to all unreserved
protocols.
"""
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
  if sock.gw === nothing
    return -1
  end
  nodeinfo = agentforservice(sock.gw, Services.NODE_INFO)
  if nodeinfo === nothing
    return -1
  end
  req = ParameterReq(recipient=nodeinfo, param="address")
  rsp = request(sock.gw, req, REQUEST_TIMEOUT)
  if rsp === nothing
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
  sock.timeout = ms
end

"Gets the timeout for datagram reception."
function gettimeout(sock::UnetSocket)
  return sock.timeout
end

"""
Gets the service provider AgentID used for sending datagrams. If a provider
has not been set explicitly, one is chosen automatically: the remote service
is preferred, followed by transport, routing, link and physical, in that
order.
"""
function getserviceprovider(sock::UnetSocket)
  sock.gw === nothing && return nothing
  if sock.provider === nothing
    providers = agentsforservice(sock.gw, Services.DATAGRAM)
    isempty(providers) && return nothing
    p = agentforservice(sock.gw, Services.REMOTE)
    p !== nothing && p ∉ providers && (p = nothing)
    p === nothing && (p = agentforservice(sock.gw, Services.TRANSPORT))
    p === nothing && (p = agentforservice(sock.gw, Services.ROUTING))
    p === nothing && (p = agentforservice(sock.gw, Services.LINK))
    p === nothing && (p = agentforservice(sock.gw, Services.PHYSICAL))
    p === nothing && (p = first(providers))
    sock.provider = p
  end
  return sock.provider
end

"""
Sets the service provider AgentID used for sending datagrams. Set to `nothing`
to revert to automatic selection.
"""
function setserviceprovider(sock::UnetSocket, provider::Union{AgentID, Nothing})
  sock.provider = provider
  nothing
end

# create a DatagramReq (or RemoteMessageReq, if remote message attributes are
# set on the socket) carrying the socket's QoS attributes
function createdatagramreq(sock::UnetSocket)
  local req
  if sock.mimetype === nothing && sock.messageclass === nothing &&
     sock.remoterecipient === nothing && sock.mailbox === nothing
    req = DatagramReq()
  else
    req = RemoteMessageReq()
    sock.mimetype === nothing || (req.mimeType = sock.mimetype)
    req.messageClass = sock.messageclass
    req.remoteRecipient = sock.remoterecipient
    req.mailbox = sock.mailbox
  end
  req.ttl = sock.ttl
  req.priority = sock.priority
  req.robustness = sock.robustness
  req.reliability = sock.reliability
  req.route = sock.route
  return req
end

function _sendto(sock::UnetSocket, data, to::Integer, protocol::Integer)
  req = createdatagramreq(sock)
  req.data = Vector{UInt8}(data)
  req.to = to
  if protocol > 0
    req isa RemoteMessageReq && return false  # remote messages have a fixed protocol
    req.protocol = protocol
  end
  return send(sock, req)
end

"Transmits a datagram to the default node address using the default protocol."
function Fjage.send(sock::UnetSocket, data)
  sock.remoteaddress < 0 && return false
  return _sendto(sock, data, sock.remoteaddress, sock.remoteprotocol)
end

"Transmits a datagram to the specified node address using the default protocol."
function Fjage.send(sock::UnetSocket, data, to::Integer)
  return _sendto(sock, data, to, sock.remoteprotocol)
end

"""
Transmits a datagram to the specified node address using the specified protocol.

Protocol numbers between Protocol.DATA+1 and Protocol.USER-1 are considered
reserved, and cannot be used for sending datagrams using the socket.
"""
function Fjage.send(sock::UnetSocket, data, to::Integer, protocol::Integer)
  return _sendto(sock, data, to, protocol)
end

# transmits a datagram request over the socket, honoring the socket's send
# mode; prefer setting socket attributes and using send(sock, data, ...)
function Fjage.send(sock::UnetSocket, req::Message)
  sock.gw === nothing && return false
  req isa DatagramReq || return false
  protocol = req.protocol
  (protocol == Protocol.DATA || (protocol >= Protocol.USER && protocol <= Protocol.MAX)) || return false
  provider = getserviceprovider(sock)
  provider === nothing && return false
  # unlike the Java API, an explicitly set recipient is respected here
  req.recipient === nothing && (req.recipient = provider)
  sock.sendmode == NON_BLOCKING && return send(sock.gw, req)
  waitfortx = req.reliability === true
  rsp = request(sock.gw, req, REQUEST_TIMEOUT)
  rsp === nothing && return false
  rsp.performative == Performative.AGREE || return false
  sock.sendmode == SEMI_BLOCKING && !waitfortx && return true
  ntf = receive(sock.gw, req, BLOCKING)
  return ntf isa DatagramDeliveryNtf || ntf isa DatagramTransmissionNtf
end

"""
Receives a datagram sent to the local node and the bound protocol number. If the
socket is unbound, then datagrams with all unreserved protocols are received. Any
broadcast datagrams are also received.

This call blocks until a datagram is available, the socket timeout is reached,
or until cancel() is called.
"""
function Fjage.receive(sock::UnetSocket)
  sock.gw === nothing && return nothing
  timeout = sock.timeout
  deadline = timeout > 0 ? now() + Millisecond(timeout) : nothing
  sock.waiting = true
  try
    while true
      remaining = timeout
      if deadline !== nothing
        remaining = (deadline - now()).value
        remaining <= 0 && return nothing
      end
      ntf = receive(sock.gw, DatagramNtf, remaining)
      ntf === nothing && return nothing
      p = ntf.protocol
      if p == Protocol.DATA || p >= Protocol.USER
        if sock.localprotocol < 0 || sock.localprotocol == p
          ntf.data === nothing || (ntf.data = reinterpret(UInt8, ntf.data))
          return ntf
        end
      elseif p == -1    # sentinel injected by cancel()
        return nothing
      end
    end
  finally
    sock.waiting = false
  end
end

"Cancels an ongoing blocking receive()."
function cancel(sock::UnetSocket)
  if sock.waiting && sock.gw !== nothing
    send(sock.gw, DatagramNtf(recipient=AgentID(sock.gw), protocol=-1))
  end
  nothing
end

"Gets a Gateway to provide low-level access to UnetStack."
function getgateway(sock::UnetSocket)
  return sock.gw
end

"Gets an AgentID providing a specified service for low-level access to UnetStack."
function Fjage.agentforservice(sock::UnetSocket, svc::String)
  if sock.gw === nothing
    return nothing
  else
    return agentforservice(sock.gw, svc)
  end
end

"Gets a list of AgentIDs providing a specified service for low-level access to UnetStack."
function Fjage.agentsforservice(sock::UnetSocket, svc::String)
  if sock.gw === nothing
    return []
  else
    return agentsforservice(sock.gw, svc)
  end
end

"Gets a named AgentID for low-level access to UnetStack."
function Fjage.agent(sock::UnetSocket, name::String)
  if sock.gw === nothing
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
  if sock.gw === nothing
    return nothing
  end
  arp = agentforservice(sock.gw, Services.ADDRESS_RESOLUTION)
  if arp === nothing
    return nothing
  end
  rsp = request(sock.gw, AddressResolutionReq(recipient=arp, name=name), REQUEST_TIMEOUT)
  if rsp === nothing || !(rsp isa AddressResolutionRsp)
    return nothing
  end
  return rsp.address
end

# Base functions to add local methods
Base.close(sock::UnetSocket) = close(sock)
Base.bind(sock::UnetSocket, protocol::Integer) = bind(sock, protocol)

end
