/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     envoy/config/metrics/v3/stats.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#ifndef ENVOY_CONFIG_METRICS_V3_STATS_PROTO_UPBDEFS_H_
#define ENVOY_CONFIG_METRICS_V3_STATS_PROTO_UPBDEFS_H_

#if COCOAPODS==1
  #include  "third_party/upb/upb/def.h"
#else
  #include  "upb/def.h"
#endif
#if COCOAPODS==1
  #include  "third_party/upb/upb/port_def.inc"
#else
  #include  "upb/port_def.inc"
#endif
#ifdef __cplusplus
extern "C" {
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/def.h"
#else
  #include  "upb/def.h"
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_def.inc"
#else
  #include  "upb/port_def.inc"
#endif

extern upb_def_init envoy_config_metrics_v3_stats_proto_upbdefinit;

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_StatsSink_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.StatsSink");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_StatsConfig_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.StatsConfig");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_StatsMatcher_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.StatsMatcher");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_TagSpecifier_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.TagSpecifier");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_HistogramBucketSettings_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.HistogramBucketSettings");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_StatsdSink_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.StatsdSink");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_DogStatsdSink_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.DogStatsdSink");
}

UPB_INLINE const upb_msgdef *envoy_config_metrics_v3_HystrixSink_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_config_metrics_v3_stats_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.config.metrics.v3.HystrixSink");
}

#ifdef __cplusplus
}  /* extern "C" */
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_undef.inc"
#else
  #include  "upb/port_undef.inc"
#endif

#endif  /* ENVOY_CONFIG_METRICS_V3_STATS_PROTO_UPBDEFS_H_ */
