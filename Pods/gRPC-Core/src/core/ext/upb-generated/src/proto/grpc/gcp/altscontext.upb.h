/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     src/proto/grpc/gcp/altscontext.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#ifndef SRC_PROTO_GRPC_GCP_ALTSCONTEXT_PROTO_UPB_H_
#define SRC_PROTO_GRPC_GCP_ALTSCONTEXT_PROTO_UPB_H_

#if COCOAPODS==1
  #include  "third_party/upb/upb/msg.h"
#else
  #include  "upb/msg.h"
#endif
#if COCOAPODS==1
  #include  "third_party/upb/upb/decode.h"
#else
  #include  "upb/decode.h"
#endif
#if COCOAPODS==1
  #include  "third_party/upb/upb/decode_fast.h"
#else
  #include  "upb/decode_fast.h"
#endif
#if COCOAPODS==1
  #include  "third_party/upb/upb/encode.h"
#else
  #include  "upb/encode.h"
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_def.inc"
#else
  #include  "upb/port_def.inc"
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct grpc_gcp_AltsContext;
struct grpc_gcp_AltsContext_PeerAttributesEntry;
typedef struct grpc_gcp_AltsContext grpc_gcp_AltsContext;
typedef struct grpc_gcp_AltsContext_PeerAttributesEntry grpc_gcp_AltsContext_PeerAttributesEntry;
extern const upb_msglayout grpc_gcp_AltsContext_msginit;
extern const upb_msglayout grpc_gcp_AltsContext_PeerAttributesEntry_msginit;
struct grpc_gcp_RpcProtocolVersions;
extern const upb_msglayout grpc_gcp_RpcProtocolVersions_msginit;


/* grpc.gcp.AltsContext */

UPB_INLINE grpc_gcp_AltsContext *grpc_gcp_AltsContext_new(upb_arena *arena) {
  return (grpc_gcp_AltsContext *)_upb_msg_new(&grpc_gcp_AltsContext_msginit, arena);
}
UPB_INLINE grpc_gcp_AltsContext *grpc_gcp_AltsContext_parse(const char *buf, size_t size,
                        upb_arena *arena) {
  grpc_gcp_AltsContext *ret = grpc_gcp_AltsContext_new(arena);
  return (ret && upb_decode(buf, size, ret, &grpc_gcp_AltsContext_msginit, arena)) ? ret : NULL;
}
UPB_INLINE grpc_gcp_AltsContext *grpc_gcp_AltsContext_parse_ex(const char *buf, size_t size,
                           upb_arena *arena, int options) {
  grpc_gcp_AltsContext *ret = grpc_gcp_AltsContext_new(arena);
  return (ret && _upb_decode(buf, size, ret, &grpc_gcp_AltsContext_msginit, arena, options))
      ? ret : NULL;
}
UPB_INLINE char *grpc_gcp_AltsContext_serialize(const grpc_gcp_AltsContext *msg, upb_arena *arena, size_t *len) {
  return upb_encode(msg, &grpc_gcp_AltsContext_msginit, arena, len);
}

UPB_INLINE upb_strview grpc_gcp_AltsContext_application_protocol(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(8, 8), upb_strview); }
UPB_INLINE upb_strview grpc_gcp_AltsContext_record_protocol(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(16, 24), upb_strview); }
UPB_INLINE int32_t grpc_gcp_AltsContext_security_level(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(4, 4), int32_t); }
UPB_INLINE upb_strview grpc_gcp_AltsContext_peer_service_account(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(24, 40), upb_strview); }
UPB_INLINE upb_strview grpc_gcp_AltsContext_local_service_account(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(32, 56), upb_strview); }
UPB_INLINE bool grpc_gcp_AltsContext_has_peer_rpc_versions(const grpc_gcp_AltsContext *msg) { return _upb_hasbit(msg, 1); }
UPB_INLINE const struct grpc_gcp_RpcProtocolVersions* grpc_gcp_AltsContext_peer_rpc_versions(const grpc_gcp_AltsContext *msg) { return *UPB_PTR_AT(msg, UPB_SIZE(40, 72), const struct grpc_gcp_RpcProtocolVersions*); }
UPB_INLINE bool grpc_gcp_AltsContext_has_peer_attributes(const grpc_gcp_AltsContext *msg) { return _upb_has_submsg_nohasbit(msg, UPB_SIZE(44, 80)); }
UPB_INLINE size_t grpc_gcp_AltsContext_peer_attributes_size(const grpc_gcp_AltsContext *msg) {return _upb_msg_map_size(msg, UPB_SIZE(44, 80)); }
UPB_INLINE bool grpc_gcp_AltsContext_peer_attributes_get(const grpc_gcp_AltsContext *msg, upb_strview key, upb_strview *val) { return _upb_msg_map_get(msg, UPB_SIZE(44, 80), &key, 0, val, 0); }
UPB_INLINE const grpc_gcp_AltsContext_PeerAttributesEntry* grpc_gcp_AltsContext_peer_attributes_next(const grpc_gcp_AltsContext *msg, size_t* iter) { return (const grpc_gcp_AltsContext_PeerAttributesEntry*)_upb_msg_map_next(msg, UPB_SIZE(44, 80), iter); }

UPB_INLINE void grpc_gcp_AltsContext_set_application_protocol(grpc_gcp_AltsContext *msg, upb_strview value) {
  *UPB_PTR_AT(msg, UPB_SIZE(8, 8), upb_strview) = value;
}
UPB_INLINE void grpc_gcp_AltsContext_set_record_protocol(grpc_gcp_AltsContext *msg, upb_strview value) {
  *UPB_PTR_AT(msg, UPB_SIZE(16, 24), upb_strview) = value;
}
UPB_INLINE void grpc_gcp_AltsContext_set_security_level(grpc_gcp_AltsContext *msg, int32_t value) {
  *UPB_PTR_AT(msg, UPB_SIZE(4, 4), int32_t) = value;
}
UPB_INLINE void grpc_gcp_AltsContext_set_peer_service_account(grpc_gcp_AltsContext *msg, upb_strview value) {
  *UPB_PTR_AT(msg, UPB_SIZE(24, 40), upb_strview) = value;
}
UPB_INLINE void grpc_gcp_AltsContext_set_local_service_account(grpc_gcp_AltsContext *msg, upb_strview value) {
  *UPB_PTR_AT(msg, UPB_SIZE(32, 56), upb_strview) = value;
}
UPB_INLINE void grpc_gcp_AltsContext_set_peer_rpc_versions(grpc_gcp_AltsContext *msg, struct grpc_gcp_RpcProtocolVersions* value) {
  _upb_sethas(msg, 1);
  *UPB_PTR_AT(msg, UPB_SIZE(40, 72), struct grpc_gcp_RpcProtocolVersions*) = value;
}
UPB_INLINE struct grpc_gcp_RpcProtocolVersions* grpc_gcp_AltsContext_mutable_peer_rpc_versions(grpc_gcp_AltsContext *msg, upb_arena *arena) {
  struct grpc_gcp_RpcProtocolVersions* sub = (struct grpc_gcp_RpcProtocolVersions*)grpc_gcp_AltsContext_peer_rpc_versions(msg);
  if (sub == NULL) {
    sub = (struct grpc_gcp_RpcProtocolVersions*)_upb_msg_new(&grpc_gcp_RpcProtocolVersions_msginit, arena);
    if (!sub) return NULL;
    grpc_gcp_AltsContext_set_peer_rpc_versions(msg, sub);
  }
  return sub;
}
UPB_INLINE void grpc_gcp_AltsContext_peer_attributes_clear(grpc_gcp_AltsContext *msg) { _upb_msg_map_clear(msg, UPB_SIZE(44, 80)); }
UPB_INLINE bool grpc_gcp_AltsContext_peer_attributes_set(grpc_gcp_AltsContext *msg, upb_strview key, upb_strview val, upb_arena *a) { return _upb_msg_map_set(msg, UPB_SIZE(44, 80), &key, 0, &val, 0, a); }
UPB_INLINE bool grpc_gcp_AltsContext_peer_attributes_delete(grpc_gcp_AltsContext *msg, upb_strview key) { return _upb_msg_map_delete(msg, UPB_SIZE(44, 80), &key, 0); }
UPB_INLINE grpc_gcp_AltsContext_PeerAttributesEntry* grpc_gcp_AltsContext_peer_attributes_nextmutable(grpc_gcp_AltsContext *msg, size_t* iter) { return (grpc_gcp_AltsContext_PeerAttributesEntry*)_upb_msg_map_next(msg, UPB_SIZE(44, 80), iter); }

/* grpc.gcp.AltsContext.PeerAttributesEntry */

UPB_INLINE upb_strview grpc_gcp_AltsContext_PeerAttributesEntry_key(const grpc_gcp_AltsContext_PeerAttributesEntry *msg) {
  upb_strview ret;
  _upb_msg_map_key(msg, &ret, 0);
  return ret;
}
UPB_INLINE upb_strview grpc_gcp_AltsContext_PeerAttributesEntry_value(const grpc_gcp_AltsContext_PeerAttributesEntry *msg) {
  upb_strview ret;
  _upb_msg_map_value(msg, &ret, 0);
  return ret;
}

UPB_INLINE void grpc_gcp_AltsContext_PeerAttributesEntry_set_value(grpc_gcp_AltsContext_PeerAttributesEntry *msg, upb_strview value) {
  _upb_msg_map_set_value(msg, &value, 0);
}

#ifdef __cplusplus
}  /* extern "C" */
#endif

#if COCOAPODS==1
  #include  "third_party/upb/upb/port_undef.inc"
#else
  #include  "upb/port_undef.inc"
#endif

#endif  /* SRC_PROTO_GRPC_GCP_ALTSCONTEXT_PROTO_UPB_H_ */
