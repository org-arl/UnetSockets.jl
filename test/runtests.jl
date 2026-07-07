using Test
using Dates
using UnetSockets
import Sockets

# tests that do not need a simulator

@testset "constants" begin
  @test Protocol.DATA == 0
  @test Protocol.WORMHOLE == 8
  @test Protocol.LINK2 == 9
  @test Protocol.ENCRYPTED_LINK == 10
  @test Protocol.USER == 32
  @test Protocol.MAX == 63
  @test Protocol.TEST == -1
  @test Topics.DATAGRAM == "org.arl.unet.Topics.DATAGRAM"
  @test Topics.SYSTEM == "org.arl.unet.Topics.SYSTEM"
  @test Services.SCHEDULER == "org.arl.unet.Services.SCHEDULER"
  @test Services.DEVICE_INFO == "org.arl.unet.Services.DEVICE_INFO"
  @test Priority.HIGH === :HIGH
  @test Robustness.ROBUST === :ROBUST
  @test ReservationStatus.START === :START
  @test NON_BLOCKING == 0
  @test BLOCKING == -1
  @test SEMI_BLOCKING == -2
end

@testset "messages" begin
  req = DatagramReq(to=31, data=UInt8[1,2,3])
  @test req.to == 31
  @test req.data == [1,2,3]
  @test isnan(req.ttl)
  @test req.priority === :NORMAL
  rmr = RemoteMessageReq()
  @test rmr isa DatagramReq
  @test rmr.mimeType == "application/octet-stream"
  @test RemoteMessageNtf() isa DatagramNtf
end

# tests that need a 2-node simulation, from a built UnetStack distribution
# pointed to by the UNET_HOME environment variable

unethome = get(ENV, "UNET_HOME", "")

if isempty(unethome) || !isfile(joinpath(unethome, "bin", "unet"))
  @warn "UNET_HOME does not point to a UnetStack distribution, skipping simulation-based tests"
  exit(0)
end

println("Starting 2-node simulation from $(unethome)...")
run(`bash sim.sh start $unethome`)

const ip = "127.0.0.1"

function waitforport(port; timeout=30)
  t0 = time()
  while time() - t0 < timeout
    try
      s = Sockets.connect(ip, port)
      Base.close(s)
      return true
    catch
      sleep(1)
    end
  end
  false
end

# wait until the node's agents are up and responding
function waitforstack(port; timeout=60)
  t0 = time()
  while time() - t0 < timeout
    try
      s = UnetSocket(ip, port)
      try
        if getlocaladdress(s) >= 0 && agentforservice(s, Services.PHYSICAL) !== nothing
          return true
        end
      finally
        close(s)
      end
    catch
    end
    sleep(2)
  end
  false
end

try

  waitforport(1101) || error("Simulator did not start")
  waitforport(1102) || error("Simulator did not start")
  waitforstack(1101) || error("Node A stack did not start")
  waitforstack(1102) || error("Node B stack did not start")

  println("Starting tests...")

  @testset "socket" begin
    s = UnetSocket(ip, 1101)
    @test getlocaladdress(s) == 232
    @test host(s, "A") == 232
    @test host(s, "B") == 31
    @test !isclosed(s)
    close(s)
    @test isclosed(s)
  end

  @testset "gateway" begin
    s = UnetSocket(ip, 1101)
    gw = getgateway(s)
    @test gw isa Fjage.Gateway
    shell = agentforservice(gw, Services.SHELL)
    @test shell isa AgentID
    @test shell.language == "Groovy"
    close(s)
  end

  @testset "agents" begin
    s = UnetSocket(ip, 1101)
    node = agent(s, "node")
    @test node isa AgentID
    @test node.address == 232
    @test node.nodeName == "A"
    phy = agentforservice(s, Services.PHYSICAL)
    @test phy isa AgentID
    @test phy.name == "phy"
    @test phy.MTU > 0
    close(s)
  end

  @testset "attributes" begin
    s = UnetSocket(ip, 1101)
    @test s.sendmode == SEMI_BLOCKING
    @test isnan(s.ttl)
    @test s.priority === Priority.NORMAL
    @test s.robustness === Robustness.NORMAL
    @test s.reliability === nothing
    @test s.route === nothing
    @test s.mimetype === nothing
    @test s.messageclass === nothing
    @test s.remoterecipient === nothing
    @test s.mailbox === nothing
    s.ttl = 60
    @test s.ttl == 60f0
    s.ttl = NaN
    @test isnan(s.ttl)
    s.priority = Priority.HIGH
    @test s.priority === :HIGH
    s.robustness = Robustness.ROBUST
    @test s.robustness === :ROBUST
    s.reliability = true
    @test s.reliability === true
    s.reliability = nothing
    @test s.reliability === nothing
    s.route = "abc"
    @test s.route == "abc"
    s.route = nothing
    s.sendmode = BLOCKING
    @test s.sendmode == BLOCKING
    s.sendMode = NON_BLOCKING              # camelCase alias
    @test s.sendmode == NON_BLOCKING
    s.mimeType = "application/json"        # camelCase alias
    @test s.mimetype == "application/json"
    s.mimetype = nothing
    s.messageClass = "org.example.Foo"     # camelCase alias
    @test s.messageclass == "org.example.Foo"
    s.messageclass = nothing
    s.remoteRecipient = "websh"            # camelCase alias
    @test s.remoterecipient == "websh"
    s.remoterecipient = nothing
    s.mailbox = "STATUS"
    @test s.mailbox == "STATUS"
    s.mailbox = nothing
    @test_throws ArgumentError s.priority = :BOGUS
    @test_throws ArgumentError s.robustness = :BOGUS
    @test_throws ArgumentError s.sendmode = 42
    s.timeout = -5
    @test s.timeout == -1
    settimeout(s, 1000)
    @test gettimeout(s) == 1000
    settimeout(s, -5)
    @test gettimeout(s) == -1
    close(s)
  end

  @testset "bind/connect" begin
    s = UnetSocket(ip, 1101)
    @test getlocalprotocol(s) == -1
    @test !isbound(s)
    @test bind(s, 42)
    @test isbound(s)
    @test getlocalprotocol(s) == 42
    unbind(s)
    @test !isbound(s)
    @test getlocalprotocol(s) == -1
    @test getremoteaddress(s) == -1
    @test getremoteprotocol(s) == 0
    @test !isconnected(s)
    @test connect(s, 31, 0)
    @test getremoteaddress(s) == 31
    @test getremoteprotocol(s) == 0
    @test isconnected(s)
    disconnect(s)
    @test !isconnected(s)
    @test getremoteaddress(s) == -1
    @test getremoteprotocol(s) == 0
    close(s)
  end

  @testset "timeouts" begin
    s = UnetSocket(ip, 1101)
    @test bind(s, 0)
    @test gettimeout(s) == -1
    settimeout(s, 1000)
    @test gettimeout(s) == 1000
    t1 = now().instant
    @test receive(s) == nothing
    dt = now().instant - t1
    @test dt.value > 1000
    settimeout(s, 0)
    @test gettimeout(s) == 0
    t1 = now().instant
    @test receive(s) == nothing
    dt = now().instant - t1
    @test dt.value < 500
    close(s)
  end

  @testset "cancel" begin
    s = UnetSocket(ip, 1101)
    settimeout(s, 7000)
    @test bind(s, 0)
    t1 = now().instant
    @async begin
      sleep(2)
      cancel(s)
    end
    @test receive(s) == nothing
    dt = now().instant - t1
    @test dt.value > 1500
    @test dt.value < 5000
    close(s)
  end

  @testset "provider" begin
    s = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    @test bind(s2, Protocol.USER)
    settimeout(s2, 10000)
    p = getserviceprovider(s)
    @test p isa AgentID
    phy = agent(s, "phy")
    setserviceprovider(s, phy)
    @test getserviceprovider(s) == phy
    @test send(s, [1,2,3], 31, Protocol.USER)
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    setserviceprovider(s, nothing)
    @test getserviceprovider(s) isa AgentID
    close(s)
    close(s2)
  end

  @testset "communication" begin
    s1 = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    @test bind(s2, Protocol.USER)
    settimeout(s2, 5000)
    @test !send(s1, [1,2,3])
    @test send(s1, [1,2,3], 31)
    @test receive(s2) == nothing
    @test send(s1, [1,2,3], 31, Protocol.USER)
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    @test connect(s1, 31, Protocol.USER)
    @test send(s1, [1,2,3])
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    @test send(s1, [1,2,3], 31, 0)
    @test receive(s2) == nothing
    @test send(s1, [1,2,3], 27, Protocol.USER)
    @test receive(s2) == nothing
    @test send(s1, [1,2,3])
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    disconnect(s1)
    @test !send(s1, [1,2,3])
    @test send(s1, [1,2,3], 31, Protocol.USER)
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    @test send(s1, [71,129,253], 31, Protocol.USER)
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [71,129,253]
    close(s1)
    close(s2)
  end

  @testset "send modes" begin
    s1 = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    @test bind(s2, Protocol.USER)
    settimeout(s2, 10000)
    s1.sendmode = NON_BLOCKING
    @test send(s1, [1,2,3], 31, Protocol.USER)
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [1,2,3]
    s1.sendmode = BLOCKING
    done = Channel{Bool}(1)
    @async put!(done, send(s1, [4,5,6], 31, Protocol.USER))
    ok = false
    t0 = time()
    while time() - t0 < 30           # watchdog: a hung BLOCKING send fails the test
      isready(done) && (ok = take!(done); break)
      sleep(0.5)
    end
    @test ok
    ntf = receive(s2)
    @test ntf isa DatagramNtf
    @test ntf.data == [4,5,6]
    close(s1)
    close(s2)
  end

  @testset "remote message" begin
    s1 = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    settimeout(s2, 10000)
    s1.mimetype = "text/plain"
    @test !send(s1, Vector{UInt8}("hello"), 31, Protocol.USER)  # remote messages have a fixed protocol
    @test send(s1, Vector{UInt8}("hello"), 31)
    ntf = receive(s2)
    @test ntf isa RemoteMessageNtf
    @test String(copy(ntf.data)) == "hello"
    @test ntf.mimeType == "text/plain"
    close(s1)
    close(s2)
  end

  @testset "receive deadline" begin
    s1 = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    @test bind(s2, Protocol.USER + 1)
    settimeout(s2, 3000)
    @async begin                     # datagrams that are filtered out by the bound protocol
      sleep(1)
      send(s1, [1], 31, Protocol.USER)
      sleep(1)
      send(s1, [2], 31, Protocol.USER)
    end
    t1 = now().instant
    @test receive(s2) === nothing
    dt = (now().instant - t1).value
    @test dt >= 3000                 # timeout must be honored...
    @test dt < 4500                  # ...and not restarted by filtered-out datagrams
    close(s1)
    close(s2)
  end

finally

  println("Stopping 2-node simulation...")
  run(`bash sim.sh stop`)

end
