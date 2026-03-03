#ifndef CRYPTO_LAYER2_H
#define CRYPTO_LAYER2_H

#include "packet_crypto.h"

/* EtherType for L2-encrypted payload: keeps Ethernet header valid on wire (no "IP invalid") */
#define ETHERTYPE_L2_ENCRYPTED  0x88b5

int crypto_layer2_encrypt(struct packet_crypto_ctx *ctx, uint8_t *packet, size_t pkt_len);
int crypto_layer2_decrypt(struct packet_crypto_ctx *ctx, uint8_t *packet, size_t pkt_len);

#endif
