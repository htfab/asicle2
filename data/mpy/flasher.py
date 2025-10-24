# This flasher script assumes that the QSPI Pmod is inserted
# into the "RP PMOD" slot of a Pico-ice board, but it can be
# easily adapted to other RP2040 / RP2350 based boards.

from machine import SPI, Pin
from mpy.winbond import W25QFlash

cs = Pin(17)
spi = SPI(sck=Pin(18), mosi=Pin(19), miso=Pin(16))
flash = W25QFlash(spi=spi, cs=cs, baud=2000000, software_reset=True)

assert flash.manufacturer == 0xef
assert flash.mem_type == 0x70
assert flash.device == 0x7018
assert flash.capacity == 0x1000000

with open("asicle.bin", "rb") as f:
    i = 0
    while True:
        buf = f.read(512)
        if not buf:
            break
        flash.writeblocks(i, buf)
        i += 1
        print(i*512)

