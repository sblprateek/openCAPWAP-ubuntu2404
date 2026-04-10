/*
 * CWSecurityStubs.c
 * Empty stubs for DTLS/security functions when building with CW_NO_DTLS.
 */

#include "CWCommon.h"
#include "CWAC.h"

void CWSslCleanUp() { return; }

CWBool CWSecurityInitLib() { return CW_TRUE; }

CWBool CWSecurityReceive(CWSecuritySession session, char *buf, int len, int *readBytesPtr) {
    return CW_FALSE;
}

CWBool CWSecuritySend(CWSecuritySession session, const char *buf, int len) {
    return CW_FALSE;
}

void CWSecurityDestroySession(CWSecuritySession s) { return; }

void CWSecurityDestroyContext(CWSecurityContext ctx) { return; }

void CWSecurityCloseSession(CWSecuritySession *sPtr) { return; }

CWBool CWSecurityInitContext(CWSecurityContext *ctxPtr,
                             const char *caList,
                             const char *keyfile,
                             const char *passw,
                             CWBool isClient,
                             int (*hackPtr)(void *)) {
    return CW_TRUE;
}

CWBool CWSecurityInitSessionClient(CWSocket sock,
                                   CWNetworkLev4Address *addrPtr,
                                   CWSafeList packetReceiveListTmp,
                                   CWSecurityContext ctx,
                                   CWSecuritySession *sessionPtr,
                                   int *PMTUPtr) {
    return CW_FALSE;
}

CWBool CWSecurityInitSessionServer(CWWTPManager *pWtp,
                                   CWSocket sock,
                                   CWSecurityContext ctx,
                                   CWSecuritySession *sessionPtr,
                                   int *PMTUPtr) {
    return CW_FALSE;
}

CWBool CWSecurityInitSessionServerDataChannel(CWWTPManager *pWtp,
                                              CWNetworkLev4Address *address,
                                              CWSocket sock,
                                              CWSecurityContext ctx,
                                              CWSecuritySession *sessionPtr,
                                              int *PMTUPtr) {
    return CW_FALSE;
}

CWBool CWSecurityInitGenericSessionServerDataChannel(CWSafeList packetDataList,
                                                     CWNetworkLev4Address *address,
                                                     CWSocket sock,
                                                     CWSecurityContext ctx,
                                                     CWSecuritySession *sessionPtr,
                                                     int *PMTUPtr) {
    return CW_FALSE;
}