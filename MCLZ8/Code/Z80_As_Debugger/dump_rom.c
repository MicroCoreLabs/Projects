#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define BYTES_PER_LINE 32

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <romfile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        perror("fopen");
        return 1;
    }

    uint8_t buf[BYTES_PER_LINE];
    size_t n;

    while ((n = fread(buf, 1, sizeof(buf), fp)) > 0) {
        for (size_t i = 0; i < n; i++) {
            printf("%02X ", buf[i]);
        }
        printf("\n");
    }

    fclose(fp);
    return 0;
}