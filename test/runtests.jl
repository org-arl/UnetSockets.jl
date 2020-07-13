using Test
using UnetSockets

# start fjåge

println("Starting 2-node simulation...")
run(`bash sim.sh start`)
sleep(5)

# tests

println("Starting tests...")
try

  @testset "UnetSockets" begin
    s = UnetSocket("localhost", 1101)
    @test host(s, "A") == 232
    @test host(s, "B") == 31
    close(s)
  end

finally

# stop simulator

  println("Stopping 2-node simulation...")
  run(`bash sim.sh stop`)

end
