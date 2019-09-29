"""
Julia-Unet API.
"""
module Unet

using Fjage

# Unet exports
export UnetSocket, Protocol, Services
export AddressResolutionReq, ParameterReq
export isclosed, gateway, host, bind, unbind, isbound, connect, disconnect, isconnected, getlocaladdress, getlocalprotocol, getremoteaddress, getremoteprotocol, settimeout, gettimeout, cancel

# messages
AddressResolutionReq = MessageClass("org.arl.unet.addr.AddressResolutionReq")
ParameterReq = MessageClass("org.arl.unet.ParameterReq")
DatagramReq = MessageClass("org.arl.unet.DatagramReq")

"Well-known protocol number assignments."
module Protocol
  const DATA = 0
  const USER = 32
  const MAX = 63
end

"Unet service names."
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

end
