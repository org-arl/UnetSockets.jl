import org.arl.fjage.*

platform = RealTimePlatform   // use real-time mode

simulate {
  node 'A', location: [ 0.km, 0.km, -15.m], web: 8081, api: 1101, stack: "$home/etc/setup"
  node 'B', location: [ 1.km, 0.km, -15.m], web: 8082, api: 1102, stack: "$home/etc/setup"
}
