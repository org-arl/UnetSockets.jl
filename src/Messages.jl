# This file is largely generated automatically from the Unet message definitions.
# However, there is some customization (see comments marked as "manual editing"),
# and so updating it will involve a careful merge.

abstract type RouteInfo <: Fjage.Message end
abstract type DatagramReq <: Fjage.Message end
abstract type BasebandSignal <: Fjage.Message end
abstract type TxFrameReq <: DatagramReq end
abstract type RemoteMessageReq <: DatagramReq end
abstract type AgentLifecycleNtf <: Fjage.Message end
abstract type DatagramNtf <: Fjage.Message end
abstract type RxFrameNtf <: DatagramNtf end
abstract type DatagramTransmissionNtf <: Fjage.Message end
abstract type DatagramFailureNtf <: Fjage.Message end
abstract type DatagramDeliveryNtf <: Fjage.Message end
abstract type RemoteMessageNtf <: DatagramNtf end

export RouteRsp
Fjage.@message "org.arl.unet.net.RouteRsp" :INFORM struct RouteRsp <: RouteInfo
  op::Union{Symbol,Nothing} = nothing
  uuid::Union{String,Nothing} = nothing
  to::Union{Int32,Nothing} = nothing
  nextHop::Union{Int32,Nothing} = nothing
  link::Union{String,Nothing} = nothing
  reliability::Union{Bool,Nothing} = nothing
  hops::Union{Int32,Nothing} = nothing
  dataRate::Union{Float32,Nothing} = nothing
  MTU::Union{Int32,Nothing} = nothing
  RTU::Union{Int32,Nothing} = nothing
  metric::Union{Float32,Nothing} = nothing
  enabled::Union{Bool,Nothing} = nothing
end

export CapabilityListRsp
Fjage.@message "org.arl.unet.CapabilityListRsp" :INFORM struct CapabilityListRsp
  capSet::Vector{String} = []
end

export ScheduledTaskRsp
Fjage.@message "org.arl.unet.scheduler.ScheduledTaskRsp" :INFORM struct ScheduledTaskRsp
  tasks::Vector{Any} = []
end

export RefuseRsp
Fjage.@message "org.arl.unet.RefuseRsp" :REFUSE struct RefuseRsp
  reason::Union{String,Nothing} = nothing
end

export ReservationRsp
Fjage.@message "org.arl.unet.mac.ReservationRsp" :AGREE struct ReservationRsp
  estimatedStartTime::Union{Int64,Nothing} = nothing
end

export AddressResolutionRsp
Fjage.@message "org.arl.unet.addr.AddressResolutionRsp" :INFORM struct AddressResolutionRsp
  address::Int32 = -1
  name::Union{String,Nothing} = nothing
end

export AddressAllocRsp
Fjage.@message "org.arl.unet.addr.AddressAllocRsp" :INFORM struct AddressAllocRsp
  address::Int32 = -1
end

export GetRouteReq
Fjage.@message "org.arl.unet.net.GetRouteReq" :REQUEST struct GetRouteReq
  to::Int32 = -1
  all::Bool = false
end

export DatagramTraceReq
Fjage.@message "org.arl.unet.net.DatagramTraceReq" :REQUEST struct DatagramTraceReq <: DatagramReq
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export RouteDiscoveryReq
Fjage.@message "org.arl.unet.net.RouteDiscoveryReq" :REQUEST struct RouteDiscoveryReq
  to::Int32 = -1
  maxHops::Int32 = 3
  count::Int32 = 3
  interval::Float32 = 20.0
end

export RouteTraceReq
Fjage.@message "org.arl.unet.net.RouteTraceReq" :REQUEST struct RouteTraceReq
  to::Int32 = -1
end

export EditRouteReq
Fjage.@message "org.arl.unet.net.EditRouteReq" :REQUEST struct EditRouteReq <: RouteInfo
  op::Union{Symbol,Nothing} = nothing
  uuid::Union{String,Nothing} = nothing
  to::Union{Int32,Nothing} = nothing
  nextHop::Union{Int32,Nothing} = nothing
  link::Union{String,Nothing} = nothing
  reliability::Union{Bool,Nothing} = nothing
  hops::Union{Int32,Nothing} = nothing
  dataRate::Union{Float32,Nothing} = nothing
  MTU::Union{Int32,Nothing} = nothing
  RTU::Union{Int32,Nothing} = nothing
  metric::Union{Float32,Nothing} = nothing
  enabled::Union{Bool,Nothing} = nothing
end

export GetPreambleSignalReq
Fjage.@message "org.arl.unet.bb.GetPreambleSignalReq" :REQUEST struct GetPreambleSignalReq
  preamble::Int32 = -1
end

export TxBasebandSignalReq
Fjage.@message "org.arl.unet.bb.TxBasebandSignalReq" :REQUEST struct TxBasebandSignalReq <: BasebandSignal
  txStartTime::Union{Int64,Nothing} = nothing
  wakeup::Bool = false
  powerLevel::Union{Float32,Nothing} = nothing
  signal::Union{Union{Vector{Complex{Float32}},Vector{Float32}},Nothing} = nothing
  fc::Float32 = -1.0
  fs::Float32 = -1.0
  channels::Int32 = 1
  preamble::Int32 = 0
  ### begin manual editing
  function TxBasebandSignalReq(txStartTime, wakeup, powerLevel, signal::AbstractVecOrMat, fc, fs, channels, preamble, messageID, performative, sender, recipient, inReplyTo, sentAt)
    eltype(signal) <: Complex && fc == 0 && error("fc must be non-zero for complex (baseband) signals")
    if eltype(signal) <: Real
      fc > 0 && error("fc must be zero for real (passband) signals")
      fc = 0f0
    end
    channels = size(signal, 2)
    msg = new(txStartTime, wakeup, powerLevel, nothing, fc, fs, channels, preamble, messageID, performative, sender, recipient, inReplyTo, sentAt)
    msg.signal = signal
    msg
  end
  ### end manual editing
end

export RecordBasebandSignalReq
Fjage.@message "org.arl.unet.bb.RecordBasebandSignalReq" :REQUEST struct RecordBasebandSignalReq
  recStartTime::Union{Int64,Nothing} = nothing
  recLength::Union{Int32,Nothing} = nothing
end

export CapabilityReq
Fjage.@message "org.arl.unet.CapabilityReq" :QUERY_IF struct CapabilityReq
  cap::Union{String,Nothing} = nothing
end

export SleepReq
Fjage.@message "org.arl.unet.scheduler.SleepReq" :REQUEST struct SleepReq
end

export AddScheduledTaskReq
Fjage.@message "org.arl.unet.scheduler.AddScheduledTaskReq" :REQUEST struct AddScheduledTaskReq
  scheduler::Union{String,Nothing} = nothing
  minute::String = "*"
  hour::String = "*"
  date::String = "*"
  month::String = "*"
  year::String = "*"
  day::String = "*"
  cmd::Union{String,Nothing} = nothing
  shell::Union{String,Nothing} = nothing
  persist::Bool = true
  repeat::Bool = true
end

export RemoveScheduledTaskReq
Fjage.@message "org.arl.unet.scheduler.RemoveScheduledTaskReq" :REQUEST struct RemoveScheduledTaskReq
  id::Union{String,Nothing} = nothing
end

export StayAwakeReq
Fjage.@message "org.arl.unet.scheduler.StayAwakeReq" :REQUEST struct StayAwakeReq
  seconds::Int32 = 0
end

export GetScheduleReq
Fjage.@message "org.arl.unet.scheduler.GetScheduleReq" :REQUEST struct GetScheduleReq
end

export FrameToSignalReq
Fjage.@message "org.arl.unet.phy.FrameToSignalReq" :REQUEST struct FrameToSignalReq
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  type::Int32 = 1
end

export SignalToFrameReq
Fjage.@message "org.arl.unet.phy.SignalToFrameReq" :REQUEST struct SignalToFrameReq <: BasebandSignal
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  rssi::Float32 = NaN
  preambleLength::Int32 = 0
  signal::Union{Union{Vector{Complex{Float32}},Vector{Float32}},Nothing} = nothing
  fc::Float32 = -1.0
  fs::Float32 = -1.0
  channels::Int32 = 1
  preamble::Int32 = 0
end

export FecDecodeReq
Fjage.@message "org.arl.unet.phy.FecDecodeReq" :REQUEST struct FecDecodeReq
  type::Int32 = 2
  rxStartTime::Union{Int64,Nothing} = nothing
  metrics::Union{Vector{Float32},Nothing} = nothing
end

export TxFrameReq
Fjage.@message "org.arl.unet.phy.TxFrameReq" :REQUEST struct TxFrameReq <: TxFrameReq
  type::Int32 = 1
  timestamped::Bool = false
  txStartTime::Union{Int64,Nothing} = nothing
  wakeup::Bool = false
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export TxSWiG1FrameReq
Fjage.@message "org.arl.unet.phy.TxSWiG1FrameReq" :REQUEST struct TxSWiG1FrameReq <: TxFrameReq
  appData::Int64 = 0
  type::Int32 = 3
  timestamped::Bool = false
  txStartTime::Union{Int64,Nothing} = nothing
  wakeup::Bool = false
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export TxJanusFrameReq
Fjage.@message "org.arl.unet.phy.TxJanusFrameReq" :REQUEST struct TxJanusFrameReq <: TxFrameReq
  classUserID::Int32 = 42
  appType::Int32 = 0
  appData::Int64 = 0
  mobility::Union{Bool,Nothing} = nothing
  canForward::Union{Bool,Nothing} = nothing
  txRxFlag::Bool = true
  reservationDuration::Float32 = 0.0
  repeatInterval::Float32 = 0.0
  type::Int32 = 3
  timestamped::Bool = false
  txStartTime::Union{Int64,Nothing} = nothing
  wakeup::Bool = false
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export DatagramReq
Fjage.@message "org.arl.unet.DatagramReq" :REQUEST struct DatagramReq <: DatagramReq
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export ReservationAcceptReq
Fjage.@message "org.arl.unet.mac.ReservationAcceptReq" :REQUEST struct ReservationAcceptReq
  id::Union{String,Nothing} = nothing
  payload::Union{Vector{UInt8},Nothing} = nothing
end

export ReservationReq
Fjage.@message "org.arl.unet.mac.ReservationReq" :REQUEST struct ReservationReq
  to::Int32 = 0
  duration::Float32 = 0.0
  payload::Union{Vector{UInt8},Nothing} = nothing
  reliable::Bool = false
  ttl::Union{Float32,Nothing} = nothing
  priority::Symbol = :NORMAL
  startTime::Union{Int64,Nothing} = nothing
end

export TxAckReq
Fjage.@message "org.arl.unet.mac.TxAckReq" :REQUEST struct TxAckReq
  requestID::Union{String,Nothing} = nothing
  payload::Union{Vector{UInt8},Nothing} = nothing
end

export ReservationCancelReq
Fjage.@message "org.arl.unet.mac.ReservationCancelReq" :REQUEST struct ReservationCancelReq
  id::Union{String,Nothing} = nothing
end

export LinkTuneReq
Fjage.@message "org.arl.unet.link.LinkTuneReq" :REQUEST struct LinkTuneReq
  to::Int32 = -1
end

export LinkSchemeReq
Fjage.@message "org.arl.unet.link.LinkSchemeReq" :REQUEST struct LinkSchemeReq
  to::Int32 = -1
  schemeCode::Union{String,Nothing} = nothing
  powerLevel::Union{Int32,Nothing} = nothing
  test::Int32 = 0
end

export CancelReq
Fjage.@message "org.arl.unet.CancelReq" :REQUEST struct CancelReq
  id::Union{String,Nothing} = nothing
end

export ClearReq
Fjage.@message "org.arl.unet.ClearReq" :REQUEST struct ClearReq
end

export AddressAllocReq
Fjage.@message "org.arl.unet.addr.AddressAllocReq" :REQUEST struct AddressAllocReq
  name::Union{String,Nothing} = nothing
  addressSize::Union{Int32,Nothing} = nothing
end

export AddressResolutionReq
Fjage.@message "org.arl.unet.addr.AddressResolutionReq" :REQUEST struct AddressResolutionReq
  name::Union{String,Nothing} = nothing
end

export RangeReq
Fjage.@message "org.arl.unet.localization.RangeReq" :REQUEST struct RangeReq
  to::Int32 = -1
  requestLocation::Bool = false
  data::Union{Vector{UInt8},Nothing} = nothing
end

export RespondReq
Fjage.@message "org.arl.unet.localization.RespondReq" :REQUEST struct RespondReq
  to::Int32 = 0
  type::Int32 = 0
  rxStartTime::Int64 = 0
  data::Union{Vector{UInt8},Nothing} = nothing
end

export BeaconReq
Fjage.@message "org.arl.unet.localization.BeaconReq" :REQUEST struct BeaconReq
  type::Int32 = 0
  to::Int32 = 0
  txLocation::Bool = false
  data::Union{Vector{UInt8},Nothing} = nothing
end

export RemoteFilePutReq
Fjage.@message "org.arl.unet.remote.RemoteFilePutReq" :REQUEST struct RemoteFilePutReq
  to::Int32 = -1
  data::Union{Vector{UInt8},Nothing} = nothing
  filename::Union{String,Nothing} = nothing
  localFilename::Union{String,Nothing} = nothing
  resume::Bool = true
  progress::Bool = false
  credentials::Union{String,Nothing} = nothing
  priority::Symbol = :NORMAL
end

export RemoteFileGetReq
Fjage.@message "org.arl.unet.remote.RemoteFileGetReq" :REQUEST struct RemoteFileGetReq
  to::Int32 = -1
  filename::Union{String,Nothing} = nothing
  localFilename::Union{String,Nothing} = nothing
  credentials::Union{String,Nothing} = nothing
  progress::Bool = false
  resume::Bool = true
  priority::Symbol = :NORMAL
end

export RemoteTextReq
Fjage.@message "org.arl.unet.remote.RemoteTextReq" :REQUEST struct RemoteTextReq <: RemoteMessageReq
  text::Union{String,Nothing} = nothing
  mimeType::String = "application/x-chat"
  remoteRecipient::Union{String,Nothing} = nothing
  mailbox::Union{String,Nothing} = nothing
  messageClass::Union{String,Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export RemoteMessageReq
Fjage.@message "org.arl.unet.remote.RemoteMessageReq" :REQUEST struct RemoteMessageReq <: RemoteMessageReq
  mimeType::String = "application/octet-stream"
  remoteRecipient::Union{String,Nothing} = nothing
  mailbox::Union{String,Nothing} = nothing
  messageClass::Union{String,Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export RemoteExecReq
Fjage.@message "org.arl.unet.remote.RemoteExecReq" :REQUEST struct RemoteExecReq <: RemoteMessageReq
  command::Union{String,Nothing} = nothing
  credentials::Union{String,Nothing} = nothing
  mimeType::String = "application/x-command"
  remoteRecipient::Union{String,Nothing} = nothing
  mailbox::Union{String,Nothing} = nothing
  messageClass::Union{String,Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  to::Int32 = 0
  from::Int32 = 0
  protocol::Int32 = 0
  reliability::Union{Bool,Nothing} = nothing
  robustness::Symbol = :NORMAL
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
  shortcircuit::Bool = true
  route::Union{String,Nothing} = nothing
  progress::Bool = false
end

export DatagramDeliveryNtf
Fjage.@message "org.arl.unet.DatagramDeliveryNtf" :INFORM struct DatagramDeliveryNtf <: DatagramDeliveryNtf
end

export ParamChangeNtf
Fjage.@message "org.arl.unet.ParamChangeNtf" :INFORM struct ParamChangeNtf
  paramValues::Dict{String,Any} = Dict{String,Any}()
  readonly::Vector{String} = []
  index::Int32 = -1
end

export RouteDiscoveryNtf
Fjage.@message "org.arl.unet.net.RouteDiscoveryNtf" :INFORM struct RouteDiscoveryNtf
  to::Int32 = 0
  nextHop::Int32 = -1
  link::Union{String,Nothing} = nothing
  reliability::Bool = true
  hops::Int32 = 0
  route::Union{Vector{Int32},Nothing} = nothing
end

export RouteChangeNtf
Fjage.@message "org.arl.unet.net.RouteChangeNtf" :INFORM struct RouteChangeNtf <: RouteInfo
  op::Union{Symbol,Nothing} = nothing
  uuid::Union{String,Nothing} = nothing
  to::Union{Int32,Nothing} = nothing
  nextHop::Union{Int32,Nothing} = nothing
  link::Union{String,Nothing} = nothing
  reliability::Union{Bool,Nothing} = nothing
  hops::Union{Int32,Nothing} = nothing
  dataRate::Union{Float32,Nothing} = nothing
  MTU::Union{Int32,Nothing} = nothing
  RTU::Union{Int32,Nothing} = nothing
  metric::Union{Float32,Nothing} = nothing
  enabled::Union{Bool,Nothing} = nothing
end

export RouteTraceNtf
Fjage.@message "org.arl.unet.net.RouteTraceNtf" :INFORM struct RouteTraceNtf
  to::Int32 = -1
  trace::Union{Vector{Int32},Nothing} = nothing
end

export DetectionNtf
Fjage.@message "org.arl.unet.bb.DetectionNtf" :INFORM struct DetectionNtf
  rxStartTime::Union{Int64,Nothing} = nothing
  rxDuration::Union{Int32,Nothing} = nothing
  preamble::Int32 = -1
  detector::Float32 = 0.0
end

export RxBasebandSignalNtf
Fjage.@message "org.arl.unet.bb.RxBasebandSignalNtf" :INFORM struct RxBasebandSignalNtf <: BasebandSignal
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  rssi::Union{Float32,Nothing} = nothing
  preambleLength::Int32 = 0
  signal::Union{Union{Vector{Complex{Float32}},Vector{Float32}},Nothing} = nothing
  fc::Float32 = -1.0
  fs::Float32 = -1.0
  channels::Int32 = 1
  preamble::Int32 = 0
end

export TxEndNtf
Fjage.@message "org.arl.unet.bb.TxEndNtf" :INFORM struct TxEndNtf
  txStartTime::Union{Int64,Nothing} = nothing
  preamble::Int32 = -1
  location::Union{Vector{Float64},Nothing} = nothing
end

export TxStartNtf
Fjage.@message "org.arl.unet.bb.TxStartNtf" :INFORM struct TxStartNtf
  txStartTime::Union{Int64,Nothing} = nothing
  txDuration::Union{Int32,Nothing} = nothing
  preamble::Int32 = -1
end

export ProgressNtf
Fjage.@message "org.arl.unet.ProgressNtf" :INFORM struct ProgressNtf
  peer::Int32 = 0
  transferred::Int64 = 0
  total::Int64 = 0
  incoming::Bool = false
  filename::Union{String,Nothing} = nothing
end

export AgentTerminationNtf
Fjage.@message "org.arl.unet.AgentTerminationNtf" :INFORM struct AgentTerminationNtf <: AgentLifecycleNtf
  agentClassName::Union{String,Nothing} = nothing
  containerName::Union{String,Nothing} = nothing
end

export AbnormalTerminationNtf
Fjage.@message "org.arl.unet.AbnormalTerminationNtf" :INFORM struct AbnormalTerminationNtf <: AgentLifecycleNtf
  exception::Union{Any,Nothing} = nothing
  agentClassName::Union{String,Nothing} = nothing
  containerName::Union{String,Nothing} = nothing
end

export AgentLifecycleNtf
Fjage.@message "org.arl.unet.AgentLifecycleNtf" :INFORM struct AgentLifecycleNtf <: AgentLifecycleNtf
  agentClassName::Union{String,Nothing} = nothing
  containerName::Union{String,Nothing} = nothing
end

export WakeFromSleepNtf
Fjage.@message "org.arl.unet.scheduler.WakeFromSleepNtf" :INFORM struct WakeFromSleepNtf
end

export AboutToSleepNtf
Fjage.@message "org.arl.unet.scheduler.AboutToSleepNtf" :INFORM struct AboutToSleepNtf
  scheduledNextWakeupTime::Int64 = 0
end

export BadFrameNtf
Fjage.@message "org.arl.unet.phy.BadFrameNtf" :INFORM struct BadFrameNtf
  rxStartTime::Int64 = 0
  location::Union{Vector{Float64},Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  metrics::Union{Vector{Float32},Nothing} = nothing
  type::Int32 = -1
  rssi::Float32 = NaN
end

export RxFrameNtf
Fjage.@message "org.arl.unet.phy.RxFrameNtf" :INFORM struct RxFrameNtf <: RxFrameNtf
  type::Int32 = 1
  txStartTime::Union{Int64,Nothing} = nothing
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  bits::Int32 = 0
  errors::Union{Int32,Nothing} = nothing
  rssi::Float32 = NaN
  cfo::Float32 = NaN
  metrics::Union{Vector{Float32},Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export TxFrameStartNtf
Fjage.@message "org.arl.unet.phy.TxFrameStartNtf" :INFORM struct TxFrameStartNtf
  txStartTime::Union{Int64,Nothing} = nothing
  txDuration::Union{Int32,Nothing} = nothing
  type::Int32 = -1
end

export RxSWiG1FrameNtf
Fjage.@message "org.arl.unet.phy.RxSWiG1FrameNtf" :INFORM struct RxSWiG1FrameNtf <: RxFrameNtf
  appData::Int64 = 0
  type::Int32 = 3
  txStartTime::Union{Int64,Nothing} = nothing
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  bits::Int32 = 0
  errors::Union{Int32,Nothing} = nothing
  rssi::Float32 = NaN
  cfo::Float32 = NaN
  metrics::Union{Vector{Float32},Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export CollisionNtf
Fjage.@message "org.arl.unet.phy.CollisionNtf" :INFORM struct CollisionNtf
  type::Int32 = -1
  rxStartTime::Union{Int64,Nothing} = nothing
  detector::Float32 = 0.0
end

export RxJanusFrameNtf
Fjage.@message "org.arl.unet.phy.RxJanusFrameNtf" :INFORM struct RxJanusFrameNtf <: RxFrameNtf
  classUserID::Int32 = 0
  appType::Int32 = 0
  appData::Int64 = 0
  mobility::Bool = false
  canForward::Bool = false
  txRxFlag::Bool = false
  reservationDuration::Float32 = 0.0
  repeatInterval::Float32 = 0.0
  type::Int32 = 3
  txStartTime::Union{Int64,Nothing} = nothing
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  bits::Int32 = 0
  errors::Union{Int32,Nothing} = nothing
  rssi::Float32 = NaN
  cfo::Float32 = NaN
  metrics::Union{Vector{Float32},Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export TxFrameNtf
Fjage.@message "org.arl.unet.phy.TxFrameNtf" :INFORM struct TxFrameNtf <: DatagramTransmissionNtf
  txStartTime::Union{Int64,Nothing} = nothing
  type::Int32 = -1
  location::Union{Vector{Float64},Nothing} = nothing
end

export RxFrameStartNtf
Fjage.@message "org.arl.unet.phy.RxFrameStartNtf" :INFORM struct RxFrameStartNtf
  rxStartTime::Union{Int64,Nothing} = nothing
  rxDuration::Union{Int32,Nothing} = nothing
  type::Int32 = -1
  detector::Float32 = 0.0
end

export ReservationStatusNtf
Fjage.@message "org.arl.unet.mac.ReservationStatusNtf" :INFORM struct ReservationStatusNtf
  to::Int32 = 0
  from::Int32 = -1
  status::Union{Symbol,Nothing} = nothing
  payload::Union{Vector{UInt8},Nothing} = nothing
end

export ReservationNtf
Fjage.@message "org.arl.unet.mac.ReservationNtf" :INFORM struct ReservationNtf
  id::Union{String,Nothing} = nothing
  duration::Float32 = 0.0
  startTime::Union{Int64,Nothing} = nothing
end

export LinkSchemeNtf
Fjage.@message "org.arl.unet.link.LinkSchemeNtf" :INFORM struct LinkSchemeNtf
  to::Int32 = 0
  schemeCode::Union{String,Nothing} = nothing
  powerLevel::Union{Int32,Nothing} = nothing
end

export LinkPerformanceNtf
Fjage.@message "org.arl.unet.link.LinkPerformanceNtf" :INFORM struct LinkPerformanceNtf
  to::Int32 = 0
  schemeCode::Union{String,Nothing} = nothing
  powerLevel::Union{Int32,Nothing} = nothing
  bits::Int32 = 0
  errors::Vector{Int32} = []
  rssi::Vector{Float32} = []
end

export LinkStatusNtf
Fjage.@message "org.arl.unet.link.LinkStatusNtf" :INFORM struct LinkStatusNtf
  to::Int32 = 0
  up::Union{Bool,Nothing} = nothing
  quality::Union{Float32,Nothing} = nothing
end

export TestReportNtf
Fjage.@message "org.arl.unet.TestReportNtf" :INFORM struct TestReportNtf
  report::Union{Vector{String},Nothing} = nothing
  pass::Bool = true
end

export AgentStartNtf
Fjage.@message "org.arl.unet.AgentStartNtf" :INFORM struct AgentStartNtf <: AgentLifecycleNtf
  services::Union{Vector{String},Nothing} = nothing
  agentClassName::Union{String,Nothing} = nothing
  containerName::Union{String,Nothing} = nothing
end

export DatagramFailureNtf
Fjage.@message "org.arl.unet.DatagramFailureNtf" :INFORM struct DatagramFailureNtf <: DatagramFailureNtf
end

export DatagramTransmissionNtf
Fjage.@message "org.arl.unet.DatagramTransmissionNtf" :INFORM struct DatagramTransmissionNtf <: DatagramTransmissionNtf
end

export FailureNtf
Fjage.@message "org.arl.unet.FailureNtf" :FAILURE struct FailureNtf
  reason::Union{String,Nothing} = nothing
end

export InterrogationNtf
Fjage.@message "org.arl.unet.localization.InterrogationNtf" :INFORM struct InterrogationNtf
  from::Int32 = 0
  to::Int32 = 0
  type::Int32 = 0
  rxStartTime::Int64 = 0
  data::Union{Vector{UInt8},Nothing} = nothing
  responded::Bool = false
end

export BearingNtf
Fjage.@message "org.arl.unet.localization.BearingNtf" :INFORM struct BearingNtf
  azimuth::Union{Float64,Nothing} = nothing
  elevation::Union{Float64,Nothing} = nothing
  worldAzimuth::Union{Float64,Nothing} = nothing
  worldElevation::Union{Float64,Nothing} = nothing
  rxStartTime::Union{Int64,Nothing} = nothing
  pitch::Union{Float64,Nothing} = nothing
  roll::Union{Float64,Nothing} = nothing
  yaw::Union{Float64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
end

export PeerLocationNtf
Fjage.@message "org.arl.unet.localization.PeerLocationNtf" :INFORM struct PeerLocationNtf
  peer::Int32 = -1
  peerLocation::Union{Vector{Float64},Nothing} = nothing
  rxStartTime::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
end

export RangeNtf
Fjage.@message "org.arl.unet.localization.RangeNtf" :INFORM struct RangeNtf
  from::Int32 = 0
  to::Int32 = 0
  rxStartTime::Union{Int64,Nothing} = nothing
  range::Union{Float32,Nothing} = nothing
  offset::Union{Int64,Nothing} = nothing
  location::Union{Vector{Float64},Nothing} = nothing
  peerLocation::Union{Vector{Float64},Nothing} = nothing
  data::Union{Vector{UInt8},Nothing} = nothing
end

export DatagramNtf
Fjage.@message "org.arl.unet.DatagramNtf" :INFORM struct DatagramNtf <: DatagramNtf
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export SystemNtf
Fjage.@message "org.arl.unet.SystemNtf" :INFORM struct SystemNtf
  level::Symbol = :WARNING
  description::Union{String,Nothing} = nothing
  details::Union{Any,Nothing} = nothing
end

export RemoteFailureNtf
Fjage.@message "org.arl.unet.remote.RemoteFailureNtf" :INFORM struct RemoteFailureNtf <: DatagramFailureNtf
  reason::Union{String,Nothing} = nothing
end

export RemoteMessageNtf
Fjage.@message "org.arl.unet.remote.RemoteMessageNtf" :INFORM struct RemoteMessageNtf <: RemoteMessageNtf
  mimeType::String = "application/octet-stream"
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export RemoteSuccessNtf
Fjage.@message "org.arl.unet.remote.RemoteSuccessNtf" :INFORM struct RemoteSuccessNtf <: DatagramDeliveryNtf
end

export RemoteTextNtf
Fjage.@message "org.arl.unet.remote.RemoteTextNtf" :INFORM struct RemoteTextNtf <: RemoteMessageNtf
  text::Union{String,Nothing} = nothing
  mimeType::String = "application/x-chat"
  data::Union{Vector{UInt8},Nothing} = nothing
  from::Int32 = 0
  to::Int32 = 0
  protocol::Int32 = 0
  ttl::Float32 = NaN
  priority::Symbol = :NORMAL
end

export RemoteFileNtf
Fjage.@message "org.arl.unet.remote.RemoteFileNtf" :INFORM struct RemoteFileNtf
  from::Int32 = -1
  data::Union{Vector{UInt8},Nothing} = nothing
  filename::Union{String,Nothing} = nothing
  transferDuration::Float32 = NaN
end

export BasebandSignal
Fjage.@message "org.arl.unet.bb.BasebandSignal" :INFORM struct BasebandSignal <: BasebandSignal
  signal::Union{Union{Vector{Complex{Float32}},Vector{Float32}},Nothing} = nothing
  fc::Float32 = -1.0
  fs::Float32 = -1.0
  channels::Int32 = 1
  preamble::Int32 = 0
end
