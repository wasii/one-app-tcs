/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     envoy/config/listener/v3/listener.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#include <stddef.h>
#if COCOAPODS==1
  #include  "third_party/upb/upb/msg.h"
#else
  #include  "upb/msg.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/listener/v3/listener.upb.h"
#else
  #include  "envoy/config/listener/v3/listener.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/accesslog/v3/accesslog.upb.h"
#else
  #include  "envoy/config/accesslog/v3/accesslog.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/core/v3/address.upb.h"
#else
  #include  "envoy/config/core/v3/address.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/core/v3/base.upb.h"
#else
  #include  "envoy/config/core/v3/base.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/core/v3/extension.upb.h"
#else
  #include  "envoy/config/core/v3/extension.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/core/v3/socket_option.upb.h"
#else
  #include  "envoy/config/core/v3/socket_option.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/listener/v3/api_listener.upb.h"
#else
  #include  "envoy/config/listener/v3/api_listener.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/listener/v3/listener_components.upb.h"
#else
  #include  "envoy/config/listener/v3/listener_components.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/envoy/config/listener/v3/udp_listener_config.upb.h"
#else
  #include  "envoy/config/listener/v3/udp_listener_config.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/google/protobuf/duration.upb.h"
#else
  #include  "google/protobuf/duration.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/google/protobuf/wrappers.upb.h"
#else
  #include  "google/protobuf/wrappers.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/xds/core/v3/collection_entry.upb.h"
#else
  #include  "xds/core/v3/collection_entry.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/udpa/annotations/security.upb.h"
#else
  #include  "udpa/annotations/security.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/udpa/annotations/status.upb.h"
#else
  #include  "udpa/annotations/status.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/udpa/annotations/versioning.upb.h"
#else
  #include  "udpa/annotations/versioning.upb.h"
#endif
#if COCOAPODS==1
  #include  "src/core/ext/upb-generated/validate/validate.upb.h"
#else
  #include  "validate/validate.upb.h"
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_def.inc"
#else
  #include  "upb/port_def.inc"
#endif

static const upb_msglayout *const envoy_config_listener_v3_ListenerCollection_submsgs[1] = {
  &xds_core_v3_CollectionEntry_msginit,
};

static const upb_msglayout_field envoy_config_listener_v3_ListenerCollection__fields[1] = {
  {1, UPB_SIZE(0, 0), 0, 0, 11, 3},
};

const upb_msglayout envoy_config_listener_v3_ListenerCollection_msginit = {
  &envoy_config_listener_v3_ListenerCollection_submsgs[0],
  &envoy_config_listener_v3_ListenerCollection__fields[0],
  UPB_SIZE(8, 8), 1, false, 255,
};

static const upb_msglayout *const envoy_config_listener_v3_Listener_submsgs[14] = {
  &envoy_config_accesslog_v3_AccessLog_msginit,
  &envoy_config_core_v3_Address_msginit,
  &envoy_config_core_v3_Metadata_msginit,
  &envoy_config_core_v3_SocketOption_msginit,
  &envoy_config_core_v3_TypedExtensionConfig_msginit,
  &envoy_config_listener_v3_ApiListener_msginit,
  &envoy_config_listener_v3_FilterChain_msginit,
  &envoy_config_listener_v3_Listener_ConnectionBalanceConfig_msginit,
  &envoy_config_listener_v3_Listener_DeprecatedV1_msginit,
  &envoy_config_listener_v3_ListenerFilter_msginit,
  &envoy_config_listener_v3_UdpListenerConfig_msginit,
  &google_protobuf_BoolValue_msginit,
  &google_protobuf_Duration_msginit,
  &google_protobuf_UInt32Value_msginit,
};

static const upb_msglayout_field envoy_config_listener_v3_Listener__fields[25] = {
  {1, UPB_SIZE(16, 16), 0, 0, 9, 1},
  {2, UPB_SIZE(24, 32), 1, 1, 11, 1},
  {3, UPB_SIZE(88, 160), 0, 6, 11, 3},
  {4, UPB_SIZE(28, 40), 2, 11, 11, 1},
  {5, UPB_SIZE(32, 48), 3, 13, 11, 1},
  {6, UPB_SIZE(36, 56), 4, 2, 11, 1},
  {7, UPB_SIZE(40, 64), 5, 8, 11, 1},
  {8, UPB_SIZE(4, 4), 0, 0, 14, 1},
  {9, UPB_SIZE(92, 168), 0, 9, 11, 3},
  {10, UPB_SIZE(44, 72), 6, 11, 11, 1},
  {11, UPB_SIZE(48, 80), 7, 11, 11, 1},
  {12, UPB_SIZE(52, 88), 8, 13, 11, 1},
  {13, UPB_SIZE(96, 176), 0, 3, 11, 3},
  {15, UPB_SIZE(56, 96), 9, 12, 11, 1},
  {16, UPB_SIZE(8, 8), 0, 0, 14, 1},
  {17, UPB_SIZE(12, 12), 0, 0, 8, 1},
  {18, UPB_SIZE(60, 104), 10, 10, 11, 1},
  {19, UPB_SIZE(64, 112), 11, 5, 11, 1},
  {20, UPB_SIZE(68, 120), 12, 7, 11, 1},
  {21, UPB_SIZE(13, 13), 0, 0, 8, 1},
  {22, UPB_SIZE(100, 184), 0, 0, 11, 3},
  {23, UPB_SIZE(72, 128), 13, 4, 11, 1},
  {24, UPB_SIZE(76, 136), 14, 13, 11, 1},
  {25, UPB_SIZE(80, 144), 15, 6, 11, 1},
  {26, UPB_SIZE(84, 152), 16, 11, 11, 1},
};

const upb_msglayout envoy_config_listener_v3_Listener_msginit = {
  &envoy_config_listener_v3_Listener_submsgs[0],
  &envoy_config_listener_v3_Listener__fields[0],
  UPB_SIZE(104, 192), 25, false, 255,
};

static const upb_msglayout *const envoy_config_listener_v3_Listener_DeprecatedV1_submsgs[1] = {
  &google_protobuf_BoolValue_msginit,
};

static const upb_msglayout_field envoy_config_listener_v3_Listener_DeprecatedV1__fields[1] = {
  {1, UPB_SIZE(4, 8), 1, 0, 11, 1},
};

const upb_msglayout envoy_config_listener_v3_Listener_DeprecatedV1_msginit = {
  &envoy_config_listener_v3_Listener_DeprecatedV1_submsgs[0],
  &envoy_config_listener_v3_Listener_DeprecatedV1__fields[0],
  UPB_SIZE(8, 16), 1, false, 255,
};

static const upb_msglayout *const envoy_config_listener_v3_Listener_ConnectionBalanceConfig_submsgs[1] = {
  &envoy_config_listener_v3_Listener_ConnectionBalanceConfig_ExactBalance_msginit,
};

static const upb_msglayout_field envoy_config_listener_v3_Listener_ConnectionBalanceConfig__fields[1] = {
  {1, UPB_SIZE(0, 0), UPB_SIZE(-5, -9), 0, 11, 1},
};

const upb_msglayout envoy_config_listener_v3_Listener_ConnectionBalanceConfig_msginit = {
  &envoy_config_listener_v3_Listener_ConnectionBalanceConfig_submsgs[0],
  &envoy_config_listener_v3_Listener_ConnectionBalanceConfig__fields[0],
  UPB_SIZE(8, 16), 1, false, 255,
};

const upb_msglayout envoy_config_listener_v3_Listener_ConnectionBalanceConfig_ExactBalance_msginit = {
  NULL,
  NULL,
  UPB_SIZE(0, 0), 0, false, 255,
};

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_undef.inc"
#else
  #include  "upb/port_undef.inc"
#endif

