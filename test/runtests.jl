using Test
using Dates
using UnetSockets
using Sockets: getipaddrs, IPv4

# start fjåge

println("Starting 2-node simulation...")
run(`bash sim.sh start`)
sleep(5)

# tests

println("Starting tests...")
ips = string.(filter(x -> x isa IPv4, getipaddrs()))
println("IPs: $(ips)")
ip = first(ips)
try

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

  @testset "communication" begin
    s1 = UnetSocket(ip, 1101)
    s2 = UnetSocket(ip, 1102)
    @test bind(s2, Protocol.USER)
    settimeout(s2, 1000)
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
    close(s1)
    close(s2)
  end

finally

# stop simulator

  println("Stopping 2-node simulation...")
  p = run(`bash sim.sh stop`; wait=false)
  sleep(1)
  success(p) || println("Could not stop!")

end
