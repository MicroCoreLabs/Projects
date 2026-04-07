#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define BLOCK_SIZE 64

typedef struct {
    uint32_t h[5];
    uint64_t total_len;
    uint8_t block[64];
    size_t block_len;
} Sha1Context;

static uint32_t rol32(uint32_t v, uint8_t n) {
    return (v << n) | (v >> (32 - n));
}

static void sha1_init(Sha1Context *ctx) {
    ctx->h[0] = 0x67452301UL;
    ctx->h[1] = 0xEFCDAB89UL;
    ctx->h[2] = 0x98BADCFEUL;
    ctx->h[3] = 0x10325476UL;
    ctx->h[4] = 0xC3D2E1F0UL;
    ctx->total_len = 0;
    ctx->block_len = 0;
}

static void sha1_process_block(Sha1Context *ctx, const uint8_t block[64]) {
    uint32_t w[80];

    for (int i = 0; i < 16; i++) {
        w[i] =
            ((uint32_t)block[i * 4 + 0] << 24) |
            ((uint32_t)block[i * 4 + 1] << 16) |
            ((uint32_t)block[i * 4 + 2] <<  8) |
            ((uint32_t)block[i * 4 + 3] <<  0);
    }

    for (int i = 16; i < 80; i++) {
        w[i] = rol32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
    }

    uint32_t a = ctx->h[0];
    uint32_t b = ctx->h[1];
    uint32_t c = ctx->h[2];
    uint32_t d = ctx->h[3];
    uint32_t e = ctx->h[4];

    for (int i = 0; i < 80; i++) {
        uint32_t f, k;

        if (i < 20) {
            f = (b & c) | ((~b) & d);
            k = 0x5A827999UL;
        } else if (i < 40) {
            f = b ^ c ^ d;
            k = 0x6ED9EBA1UL;
        } else if (i < 60) {
            f = (b & c) | (b & d) | (c & d);
            k = 0x8F1BBCDCUL;
        } else {
            f = b ^ c ^ d;
            k = 0xCA62C1D6UL;
        }

        uint32_t temp = rol32(a, 5) + f + e + k + w[i];
        e = d;
        d = c;
        c = rol32(b, 30);
        b = a;
        a = temp;
    }

    ctx->h[0] += a;
    ctx->h[1] += b;
    ctx->h[2] += c;
    ctx->h[3] += d;
    ctx->h[4] += e;
}

static void sha1_update(Sha1Context *ctx, const uint8_t *data, size_t len) {
    ctx->total_len += len;

    while (len > 0) {
        size_t take = 64 - ctx->block_len;
        if (take > len) take = len;

        memcpy(&ctx->block[ctx->block_len], data, take);
        ctx->block_len += take;
        data += take;
        len -= take;

        if (ctx->block_len == 64) {
            sha1_process_block(ctx, ctx->block);
            ctx->block_len = 0;
        }
    }
}

static void sha1_final(Sha1Context *ctx, uint8_t out[20]) {
    uint64_t total_bits = ctx->total_len * 8ULL;

    ctx->block[ctx->block_len++] = 0x80;

    if (ctx->block_len > 56) {
        while (ctx->block_len < 64) ctx->block[ctx->block_len++] = 0x00;
        sha1_process_block(ctx, ctx->block);
        ctx->block_len = 0;
    }

    while (ctx->block_len < 56) ctx->block[ctx->block_len++] = 0x00;

    for (int i = 7; i >= 0; i--) {
        ctx->block[ctx->block_len++] = (uint8_t)((total_bits >> (i * 8)) & 0xFF);
    }

    sha1_process_block(ctx, ctx->block);
    ctx->block_len = 0;

    for (int i = 0; i < 5; i++) {
        out[i * 4 + 0] = (uint8_t)((ctx->h[i] >> 24) & 0xFF);
        out[i * 4 + 1] = (uint8_t)((ctx->h[i] >> 16) & 0xFF);
        out[i * 4 + 2] = (uint8_t)((ctx->h[i] >>  8) & 0xFF);
        out[i * 4 + 3] = (uint8_t)((ctx->h[i] >>  0) & 0xFF);
    }
}

static uint32_t crc32_update_byte(uint32_t crc, uint8_t data) {
    crc ^= data;
    for (int i = 0; i < 8; i++) {
        if (crc & 1U) crc = (crc >> 1) ^ 0xEDB88320UL;
        else          crc = (crc >> 1);
    }
    return crc;
}

static void print_sha1_hex(const uint8_t sha1[20]) {
    for (int i = 0; i < 20; i++) {
        printf("%02x", sha1[i]);
    }
}

static void hash_block(const uint8_t *data, size_t len, uint32_t *out_crc, uint8_t out_sha1[20]) {
    uint32_t crc = 0xFFFFFFFFUL;
    Sha1Context sha1;
    sha1_init(&sha1);

    for (size_t i = 0; i < len; i++) {
        crc = crc32_update_byte(crc, data[i]);
        sha1_update(&sha1, &data[i], 1);
    }

    crc ^= 0xFFFFFFFFUL;
    sha1_final(&sha1, out_sha1);
    *out_crc = crc;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <romfile>\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        perror("fopen");
        return 1;
    }

    uint8_t block[BLOCK_SIZE];
    size_t offset = 0;

    while (1) {
        size_t n = fread(block, 1, BLOCK_SIZE, fp);
        if (n == 0) break;

        uint32_t crc;
        uint8_t sha1[20];
        hash_block(block, n, &crc, sha1);

        printf("%04zx-%04zx  LEN=%3zu  CRC(%08x) SHA1(",
               offset,
               offset + n - 1,
               n,
               crc);
        print_sha1_hex(sha1);
        printf(")\n");

        offset += n;

        if (n < BLOCK_SIZE) break;
    }

    fclose(fp);
    return 0;
}