export AbnormalTerminationNtf, AgentLifecycleNtf, AgentStartNtf, AgentTerminationNtf
export FailureNtf, RefuseRsp, CapabilityListRsp, CapabilityReq, ParamChangeNtf
export DatagramReq, DatagramNtf, ClearReq, DatagramCancelReq
export DatagramDeliveryNtf, DatagramFailureNtf, DatagramProgressNtf
export TxFrameReq, TxRawFrameReq, TxFrameStartNtf, TxFrameNtf, RxFrameStartNtf, RxFrameNtf
export BadFrameNtf, CollisionNtf, TxJanusFrameReq, RxJanusFrameNtf, FecDecodeReq
export TxBasebandSignalReq, RxBasebandSignalNtf, RecordBasebandSignalReq, GetPreambleSignalReq
export AddressAllocReq, AddressAllocRsp, AddressResolutionReq, AddressResolutionRsp
export RangeReq, BeaconReq, RangeNtf, InterrogationNtf, RespondReq
export ReservationReq, ReservationCancelReq, ReservationAcceptReq, TxAckReq
export ReservationRsp, ReservationStatusNtf, RxAckNtf, LinkStatusNtf
export EditRouteReq, GetRouteReq, RouteRsp, RouteChangeNtf, RouteTraceReq, RouteTraceNtf
export DatagramTraceReq, RouteDiscoveryReq, RouteDiscoveryNtf
export RemoteTextReq, RemoteFileGetReq, RemoteFilePutReq, RemoteExecReq
export RemoteTextNtf, RemoteFileNtf, RemoteSuccessNtf, RemoteFailureNtf
export AddScheduledSleepReq, RemoveScheduledSleepReq, GetSleepScheduleReq, SleepScheduleRsp, WakeFromSleepNtf
export ClearStateReq, SaveStateReq

global AbnormalTerminationNtf, AgentLifecycleNtf, AgentStartNtf, AgentTerminationNtf
global FailureNtf, RefuseRsp, CapabilityListRsp, CapabilityReq, ParamChangeNtf
global DatagramReq, DatagramNtf, ClearReq, DatagramCancelReq
global DatagramDeliveryNtf, DatagramFailureNtf, DatagramProgressNtf
global TxFrameReq, TxRawFrameReq, TxFrameStartNtf, TxFrameNtf, RxFrameStartNtf, RxFrameNtf
global BadFrameNtf, CollisionNtf, TxJanusFrameReq, RxJanusFrameNtf, FecDecodeReq
global TxBasebandSignalReq, RxBasebandSignalNtf, RecordBasebandSignalReq, GetPreambleSignalReq
global AddressAllocReq, AddressAllocRsp, AddressResolutionReq, AddressResolutionRsp
global RangeReq, BeaconReq, RangeNtf, InterrogationNtf, RespondReq
global ReservationReq, ReservationCancelReq, ReservationAcceptReq, TxAckReq
global ReservationRsp, ReservationStatusNtf, RxAckNtf, LinkStatusNtf
global EditRouteReq, GetRouteReq, RouteRsp, RouteChangeNtf, RouteTraceReq, RouteTraceNtf
global DatagramTraceReq, RouteDiscoveryReq, RouteDiscoveryNtf
global RemoteTextReq, RemoteFileGetReq, RemoteFilePutReq, RemoteExecReq
global RemoteTextNtf, RemoteFileNtf, RemoteSuccessNtf, RemoteFailureNtf
global AddScheduledSleepReq, RemoveScheduledSleepReq, GetSleepScheduleReq, SleepScheduleRsp, WakeFromSleepNtf
global ClearStateReq, SaveStateReq

function __init__()
  global AbnormalTerminationNtf = MessageClass(@__MODULE__, "org.arl.unet.AbnormalTerminationNtf")
  global AgentLifecycleNtf = MessageClass(@__MODULE__, "org.arl.unet.AgentLifecycleNtf")
  global AgentStartNtf = MessageClass(@__MODULE__, "org.arl.unet.AgentStartNtf")
  global AgentTerminationNtf = MessageClass(@__MODULE__, "org.arl.unet.AgentTerminationNtf")
  global FailureNtf = MessageClass(@__MODULE__, "org.arl.unet.FailureNtf")
  global RefuseRsp = MessageClass(@__MODULE__, "org.arl.unet.RefuseRsp")
  global CapabilityListRsp = MessageClass(@__MODULE__, "org.arl.unet.CapabilityListRsp")
  global CapabilityReq = MessageClass(@__MODULE__, "org.arl.unet.CapabilityReq")
  global ParamChangeNtf = MessageClass(@__MODULE__, "org.arl.unet.ParamChangeNtf")
  global DatagramReq = AbstractMessageClass(@__MODULE__, "org.arl.unet.DatagramReq")
  global DatagramNtf = AbstractMessageClass(@__MODULE__, "org.arl.unet.DatagramNtf")
  global ClearReq = MessageClass(@__MODULE__, "org.arl.unet.ClearReq")
  global DatagramCancelReq = MessageClass(@__MODULE__, "org.arl.unet.DatagramCancelReq")
  global DatagramDeliveryNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramDeliveryNtf")
  global DatagramFailureNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramFailureNtf")
  global DatagramProgressNtf = MessageClass(@__MODULE__, "org.arl.unet.DatagramProgressNtf")
  global TxFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameReq", DatagramReq)
  global TxRawFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxRawFrameReq")
  global TxFrameStartNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameStartNtf")
  global TxFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.TxFrameNtf")
  global RxFrameStartNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxFrameStartNtf")
  global RxFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxFrameNtf", DatagramNtf)
  global BadFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.BadFrameNtf")
  global CollisionNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.CollisionNtf")
  global TxJanusFrameReq = MessageClass(@__MODULE__, "org.arl.unet.phy.TxJanusFrameReq")
  global RxJanusFrameNtf = MessageClass(@__MODULE__, "org.arl.unet.phy.RxJanusFrameNtf")
  global FecDecodeReq = MessageClass(@__MODULE__, "org.arl.unet.phy.FecDecodeReq")
  BasebandSignal = AbstractMessageClass(@__MODULE__, "org.arl.unet.bb.BasebandSignal")
  global TxBasebandSignalReq = MessageClass(@__MODULE__, "org.arl.unet.bb.TxBasebandSignalReq", BasebandSignal)
  global RxBasebandSignalNtf = MessageClass(@__MODULE__, "org.arl.unet.bb.RxBasebandSignalNtf", BasebandSignal)
  global RecordBasebandSignalReq = MessageClass(@__MODULE__, "org.arl.unet.bb.RecordBasebandSignalReq")
  global GetPreambleSignalReq = MessageClass(@__MODULE__, "org.arl.unet.bb.GetPreambleSignalReq")
  global RangeReq = MessageClass(@__MODULE__, "org.arl.unet.localization.RangeReq")
  global BeaconReq = MessageClass(@__MODULE__, "org.arl.unet.localization.BeaconReq")
  global RangeNtf = MessageClass(@__MODULE__, "org.arl.unet.localization.RangeNtf")
  global InterrogationNtf = MessageClass(@__MODULE__, "org.arl.unet.localization.InterrogationNtf")
  global RespondReq = MessageClass(@__MODULE__, "org.arl.unet.localization.RespondReq")
  global AddressAllocReq = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressAllocReq")
  global AddressAllocRsp = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressAllocRsp")
  global AddressResolutionReq = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressResolutionReq")
  global AddressResolutionRsp = MessageClass(@__MODULE__, "org.arl.unet.addr.AddressResolutionRsp")
  global ReservationReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationReq")
  global ReservationAcceptReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationAcceptReq")
  global ReservationCancelReq = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationCancelReq")
  global TxAckReq = MessageClass(@__MODULE__, "org.arl.unet.mac.TxAckReq")
  global ReservationRsp = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationRsp")
  global ReservationStatusNtf = MessageClass(@__MODULE__, "org.arl.unet.mac.ReservationStatusNtf")
  global RxAckNtf = MessageClass(@__MODULE__, "org.arl.unet.mac.RxAckNtf")
  global LinkStatusNtf = MessageClass(@__MODULE__, "org.arl.unet.link.LinkStatusNtf")
  global EditRouteReq = MessageClass(@__MODULE__, "org.arl.unet.net.EditRouteReq")
  global GetRouteReq = MessageClass(@__MODULE__, "org.arl.unet.net.GetRouteReq")
  global RouteRsp = MessageClass(@__MODULE__, "org.arl.unet.net.RouteRsp")
  global RouteChangeNtf = MessageClass(@__MODULE__, "org.arl.unet.net.RouteChangeNtf")
  global RouteTraceReq = MessageClass(@__MODULE__, "org.arl.unet.net.RouteTraceReq")
  global RouteTraceNtf = MessageClass(@__MODULE__, "org.arl.unet.net.RouteTraceNtf")
  global DatagramTraceReq = MessageClass(@__MODULE__, "org.arl.unet.net.DatagramTraceReq")
  global RouteDiscoveryReq = MessageClass(@__MODULE__, "org.arl.unet.net.RouteDiscoveryReq")
  global RouteDiscoveryNtf = MessageClass(@__MODULE__, "org.arl.unet.net.RouteDiscoveryNtf")
  global RemoteTextReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteTextReq")
  global RemoteFileGetReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFileGetReq")
  global RemoteFilePutReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFilePutReq")
  global RemoteExecReq = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteExecReq")
  global RemoteTextNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteTextNtf")
  global RemoteFileNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFileNtf")
  global RemoteSuccessNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteSuccessNtf")
  global RemoteFailureNtf = MessageClass(@__MODULE__, "org.arl.unet.remote.RemoteFailureNtf")
  global AddScheduledSleepReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.AddScheduledSleepReq")
  global RemoveScheduledSleepReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.RemoveScheduledSleepReq")
  global GetSleepScheduleReq = MessageClass(@__MODULE__, "org.arl.unet.scheduler.GetSleepScheduleReq")
  global SleepScheduleRsp = MessageClass(@__MODULE__, "org.arl.unet.scheduler.SleepScheduleRsp")
  global WakeFromSleepNtf = MessageClass(@__MODULE__, "org.arl.unet.scheduler.WakeFromSleepNtf")
  global SaveStateReq = MessageClass(@__MODULE__, "org.arl.unet.state.SaveStateReq")
  global ClearStateReq = MessageClass(@__MODULE__, "org.arl.unet.state.ClearStateReq")
end
