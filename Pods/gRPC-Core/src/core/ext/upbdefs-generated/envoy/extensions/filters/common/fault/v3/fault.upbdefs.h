/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     envoy/extensions/filters/common/fault/v3/fault.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#ifndef ENVOY_EXTENSIONS_FILTERS_COMMON_FAULT_V3_FAULT_PROTO_UPBDEFS_H_
#define ENVOY_EXTENSIONS_FILTERS_COMMON_FAULT_V3_FAULT_PROTO_UPBDEFS_H_

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

extern upb_def_init envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit;

UPB_INLINE const upb_msgdef *envoy_extensions_filters_common_fault_v3_FaultDelay_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.extensions.filters.common.fault.v3.FaultDelay");
}

UPB_INLINE const upb_msgdef *envoy_extensions_filters_common_fault_v3_FaultDelay_HeaderDelay_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.extensions.filters.common.fault.v3.FaultDelay.HeaderDelay");
}

UPB_INLINE const upb_msgdef *envoy_extensions_filters_common_fault_v3_FaultRateLimit_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.extensions.filters.common.fault.v3.FaultRateLimit");
}

UPB_INLINE const upb_msgdef *envoy_extensions_filters_common_fault_v3_FaultRateLimit_FixedLimit_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.extensions.filters.common.fault.v3.FaultRateLimit.FixedLimit");
}

UPB_INLINE const upb_msgdef *envoy_extensions_filters_common_fault_v3_FaultRateLimit_HeaderLimit_getmsgdef(upb_symtab *s) {
  _upb_symtab_loaddefinit(s, &envoy_extensions_filters_common_fault_v3_fault_proto_upbdefinit);
  return upb_symtab_lookupmsg(s, "envoy.extensions.filters.common.fault.v3.FaultRateLimit.HeaderLimit");
}

#ifdef __cplusplus
}  /* extern "C" */
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_undef.inc"
#else
  #include  "upb/port_undef.inc"
#endif

#endif  /* ENVOY_EXTENSIONS_FILTERS_COMMON_FAULT_V3_FAULT_PROTO_UPBDEFS_H_ */
