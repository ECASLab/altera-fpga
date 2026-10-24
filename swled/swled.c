#include <stdio.h>
#include <stdbool.h>
#include <system.h>
#include <altera_avalon_pio_regs.h>
 
int main(void) {
    printf("SW and LEDS\n");

    while (true) {
        int switches = IORD_ALTERA_AVALON_PIO_DATA(SWITCHES_BASE);
        IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, switches);
    }

    return 0;
}