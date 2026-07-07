![CI](https://github.com/org-arl/UnetSockets.jl/workflows/CI/badge.svg)<br>
_[ UnetStack 7 ]_

# UnetStack Julia API

Julia UnetSocket API to connect to [UnetStack](https://unetstack.net).

> [!IMPORTANT]
> Version 1.0 of this package requires **UnetStack 7**. It is not compatible with
> UnetStack 3.x: if you need to talk to an older modem or simulator, pin the previous
> release with `pkg> add UnetSockets@0.5`.

The `UnetSocket` API is modeled on the datagram socket APIs available on many platforms,
and is consistent with the UnetSocket APIs in other languages (Java/Groovy, Python,
JavaScript, C). The underlying concepts are described in the
[Unet handbook](https://org-arl.github.io/unet/handbook/206_api.html).

## Installation

In the Julia REPL:
```julia
julia> # press "]" to enter package manager
pkg> add UnetSockets
```

## Quick start

```julia
using UnetSockets

sock = UnetSocket("192.168.1.42", 1100)     # IP address and API port of the node
addr = host(sock, "B")                      # resolve node name "B" to an address
send(sock, "hello world!", addr)            # send a datagram to node B
close(sock)
```

The basic steps to send/receive data with a `UnetSocket` are:

1. Open the socket.
2. Set socket attributes (optional).
3. Send / receive data using the socket.
4. Close the socket.

## Opening and closing a socket

A socket connects to a UnetStack node over TCP/IP, given the node's IP address and API
port number (1100 by default; simulated modems on one machine typically use 1101, 1102,
etc):
```julia
sock = UnetSocket("localhost", 1101)
isclosed(sock)          # false
close(sock)
isclosed(sock)          # true
```
A node accepts only a limited number of simultaneous connections, so always close
sockets when done with them. After `close()`, the socket can no longer be used.

## Protocol numbers, bind and connect

Every datagram carries a *protocol number* that lets applications distinguish their own
traffic from other traffic flowing through the stack. `Protocol.DATA` (0) is the default
for general-purpose data. Protocol numbers 1–31 are reserved for internal use by the
stack. Application protocols use `Protocol.USER` (32) to `Protocol.MAX` (63).

To *receive* only datagrams with a particular protocol number, bind the socket:
```julia
bind(sock, Protocol.USER)   # listen only for protocol 32 datagrams
isbound(sock)               # true
sock.localprotocol          # 32
unbind(sock)                # listen for all unreserved protocols again
```
An unbound socket (the default) receives datagrams of all unreserved protocols, as well
as broadcast datagrams. `bind` returns `false` for reserved protocol numbers.

To set a default destination address and protocol number for *sending*, connect the
socket:
```julia
addr = host(sock, "B")      # resolve node name to address
connect(sock, addr, Protocol.USER)
isconnected(sock)           # true
sock.remoteaddress          # address of node B
sock.remoteprotocol         # 32
disconnect(sock)            # clear the default destination
```
`host(sock, name)` resolves a node name to its address, and `getlocaladdress(sock)`
returns the address of the local node.

## Sending datagrams

The `send` function transmits a datagram, where `data` is a byte vector or string:
```julia
send(sock, data)                 # to the connected default destination/protocol
send(sock, data, to)             # to address `to`, using the default protocol
send(sock, data, to, protocol)   # to address `to`, using the given protocol
```
`send` returns `true` if the datagram was accepted (and, depending on the send mode and
reliability, transmitted or delivered), or `false` on failure. The first form requires
the socket to be connected, and returns `false` otherwise.

The agent that carries the datagram is chosen automatically: the socket picks the
highest-level datagram service provider available (remote, then transport, routing,
link, physical), so an application normally does not need to care whether the data goes
single-hop or multi-hop. To override the choice:
```julia
getserviceprovider(sock)             # AgentID of the automatically chosen provider
setserviceprovider(sock, agent(sock, "phy"))   # force transmission through an agent
setserviceprovider(sock, nothing)    # revert to automatic selection
```

### Send modes

The *send mode* controls how long a `send` call blocks:

| Mode            | Value | Behavior                                                                 |
|:----------------|:-----:|:-------------------------------------------------------------------------|
| `NON_BLOCKING`  |  `0`  | request transmission and return immediately                              |
| `SEMI_BLOCKING` | `-2`  | wait until the datagram is accepted for transmission (default)           |
| `BLOCKING`      | `-1`  | wait until the datagram is transmitted (or delivered, if reliable)       |

```julia
sock.sendmode = BLOCKING
```
When `reliability` is enabled, `SEMI_BLOCKING` and `BLOCKING` sends wait for delivery to
be acknowledged (or to fail) before returning.

### Socket attributes

Socket attributes are read and set as properties. `timeout` controls datagram
reception; the others carry quality-of-service and metadata attributes that mirror
those on a `DatagramReq`, and apply to all subsequent `send` calls:

| Property          | Type                  | Default         | Description                                    |
|:------------------|:----------------------|:----------------|:-----------------------------------------------|
| `timeout`         | `Int`                 | `BLOCKING`      | receive timeout in milliseconds                |
| `sendmode`        | `Int`                 | `SEMI_BLOCKING` | send mode (see above)                          |
| `ttl`             | `Float32`             | `NaN32` (unset) | time-to-live in seconds                        |
| `priority`        | `Symbol`              | `:NORMAL`       | one of the `Priority.*` constants              |
| `robustness`      | `Symbol`              | `:NORMAL`       | one of the `Robustness.*` constants            |
| `reliability`     | `Bool` or `nothing`   | `nothing`       | request acknowledged delivery                  |
| `route`           | `String` or `nothing` | `nothing`       | route ID                                       |
| `mimetype`        | `String` or `nothing` | `nothing`       | MIME type (sends a `RemoteMessageReq`)         |
| `messageclass`    | `String` or `nothing` | `nothing`       | message class (sends a `RemoteMessageReq`)     |
| `remoterecipient` | `String` or `nothing` | `nothing`       | remote recipient (sends a `RemoteMessageReq`)  |
| `mailbox`         | `String` or `nothing` | `nothing`       | mailbox (sends a `RemoteMessageReq`)           |

```julia
sock.reliability = true             # request acknowledged end-to-end delivery
sock.priority = Priority.HIGH       # Priority.URGENT/HIGH/NORMAL/LOW/IDLE
sock.robustness = Robustness.ROBUST # more robust (slower) coding
sock.ttl = 60.0                     # time-to-live in seconds
```
The camelCase spellings used in other language bindings (`sock.sendMode`,
`sock.mimeType`, `sock.messageClass`, `sock.remoteRecipient`) are accepted as aliases.
Socket state can also be read as properties (`sock.localprotocol`,
`sock.remoteaddress`, `sock.remoteprotocol`); the function forms from earlier versions
(`settimeout`, `gettimeout`, `getlocalprotocol`, `getremoteaddress`,
`getremoteprotocol`) remain available.

When any of `mimetype`, `messageclass`, `remoterecipient` or `mailbox` is set, datagrams
are sent as remote messages (`RemoteMessageReq`) through the remote service. Remote
messages travel over a fixed protocol number, so `send` with an explicit non-zero
protocol returns `false` in that case.

## Receiving datagrams

The `receive` function returns the next incoming datagram as a `DatagramNtf` (or a
subtype such as `RxFrameNtf` or `RemoteMessageNtf`), or `nothing` if the socket timeout
is reached (or the call is cancelled) before a datagram arrives:
```julia
bind(sock, Protocol.USER)   # optional: only receive protocol 32 datagrams
sock.timeout = 10000        # wait at most 10 seconds
ntf = receive(sock)
if ntf !== nothing
  ntf.from                  # sender's node address
  ntf.to                    # recipient address (our address, or broadcast)
  ntf.protocol              # protocol number
  String(copy(ntf.data))    # convert the received bytes to a string
end
```
The `timeout` attribute is in milliseconds: `BLOCKING` (-1) blocks forever (the
default), and `NON_BLOCKING` (0) returns immediately if no datagram is available.

A blocking `receive` running in another task can be interrupted:
```julia
cancel(sock)                # causes the pending receive() to return nothing
```

## Gateway and low-level access

The `UnetSocket` API is intended for sending and receiving datagrams. Under the hood, it
is built on a fjåge `Gateway` that connects the application to the agents running on the
Unet node, and gives lower-level access to the stack: exchanging arbitrary messages with
agents, looking up agents by service, and getting/setting agent parameters.

```julia
gw = getgateway(sock)                          # underlying fjåge Gateway
phy = agentforservice(sock, Services.PHYSICAL) # find the physical-layer agent
phy.MTU                                        # read a parameter
phy[2].frameLength = 64                        # set an indexed parameter
subscribe(gw, phy)                             # subscribe to the agent's notifications
ntf = receive(gw, 10000)                       # receive any message, waiting up to 10 s
```
`agent(sock, name)` returns a named agent, and `agentsforservice(sock, svc)` all agents
providing a service. See the [Fjage.jl](https://github.com/org-arl/Fjage.jl)
documentation for the full gateway API.

## Constants

- `Protocol` — well-known protocol numbers (`DATA`, `USER`, `MAX`, ...)
- `Services` — service names for agent lookup (`PHYSICAL`, `LINK`, `ROUTING`, ...)
- `Topics` — topics that can be subscribed to (`DATAGRAM`, `PARAMCHANGE`, ...)
- `Priority` — datagram priorities (`URGENT`, `HIGH`, `NORMAL`, `LOW`, `IDLE`)
- `Robustness` — datagram robustness (`ROBUST`, `NORMAL`)
- `Address` — well-known addresses (`BROADCAST`)
- `ReservationStatus` — channel reservation status indicators

For more details, see help (press "?" in the Julia REPL) for `UnetSockets`.
