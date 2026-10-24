#include <stdio.h>
#include <stdbool.h>
#include <system.h>
#include <altera_avalon_pio_regs.h>

#define SEVENSEG_DIGITS     4
#define SEVENSEG_DIGIT_BITS 7
#define SEVENSEG_DIGIT_MASK 0x7F

/* Shadow copy so updating one digit preserves the others. */
static unsigned int sevenseg_shadow = 0;

/*
 * Write a raw 7-bit segment pattern to one digit (0..3).
 * Digit n occupies bits [7n .. 7n+6] of SEVENSEG_BASE.
 * Returns 0 on success, -1 if the digit index is invalid.
 */
int sevenseg_write(unsigned int digit, unsigned int segments) {
    if (digit >= SEVENSEG_DIGITS) {
        return -1;
    }
    unsigned int shift = digit * SEVENSEG_DIGIT_BITS;
    sevenseg_shadow &= ~((unsigned int)SEVENSEG_DIGIT_MASK << shift);
    sevenseg_shadow |= (segments & SEVENSEG_DIGIT_MASK) << shift;
    IOWR_ALTERA_AVALON_PIO_DATA(SEVENSEG_BASE, sevenseg_shadow);
    return 0;
}

/*
 * Convert a digit 0..9 to a 7-bit pattern. Bit 0 = segment a ... bit 6 = g.
 * Active-low: a 0 bit turns the segment on. Invalid input blanks the digit.
 */
unsigned int sevenseg_encode(unsigned int number) {
    switch (number) {
        case 0: return 0x40; /* a b c d e f   */
        case 1: return 0x79; /*   b c         */
        case 2: return 0x24; /* a b   d e   g */
        case 3: return 0x30; /* a b c d     g */
        case 4: return 0x19; /*   b c     f g */
        case 5: return 0x12; /* a   c d   f g */
        case 6: return 0x02; /* a   c d e f g */
        case 7: return 0x78; /* a b c         */
        case 8: return 0x00; /* all on        */
        case 9: return 0x10; /* a b c d   f g */
        default: return 0x7F; /* all off      */
    }
}

/* Show a number 0..9 on one digit (0..3). */
int sevenseg_show(unsigned int digit, unsigned int number) {
    return sevenseg_write(digit, sevenseg_encode(number));
}

/*
 * 10-bit binary (0..1023) to packed BCD (double dabble). The lowest nibble
 * is the units digit, the highest the thousands digit.
 */
unsigned int bin_to_bcd(unsigned int bin) {
    unsigned int bcd = 0;
    bin &= 0x3FF;
    for (int i = 9; i >= 0; i--) {
        for (int n = 0; n < 4; n++) {
            if (((bcd >> (4 * n)) & 0xF) >= 5) {
                bcd += 3u << (4 * n);
            }
        }
        bcd = (bcd << 1) | ((bin >> i) & 1);
    }
    return bcd;
}

/* Display a binary number (0..1023) in decimal on the four digits (digit 0 = units). */
void sevenseg_show_number(unsigned int bin) {
    unsigned int bcd = bin_to_bcd(bin);
    for (unsigned int d = 0; d < SEVENSEG_DIGITS; d++) {
        sevenseg_show(d, (bcd >> (4 * d)) & 0xF);
    }
}

/* Read the 10 switches and show their value in decimal */
void switch_show_decimal(void) {
    sevenseg_show_number(IORD_ALTERA_AVALON_PIO_DATA(SWITCH_BASE) & 0x3FF);
}

int main(void) {
    printf("Switch to decimal in seven segments\n");
    while (1) {
        switch_show_decimal();
    }
    return 0;
}