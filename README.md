# clz80

## Software for the SGS Ates Nanocomputer

Version 0.1  Pe-release  
13 Feb 2023

### Related Pages

-   [CLZ80 Microcomputer System - Introduction](https://drive.google.com/file/d/1IllsLbFTDK88EcuQzJ1aRzmlek3LI8XC/view)
-   [CLZ80 Microcomputer users's manual](https://archive.org/details/clz80)
-   [Nanocomputer NBZ80 Archive](https://forum.vcfed.org/index.php?threads/free-archive-for-all-the-single-board-computers-i-have-worked-on-over-the-years.1209293/)

# Overview

This repository contains ports for the CLZ80 Nanocomputer Z80 trainer board commerialized in 1978 by SGS ATES.

The base configuration (the NBZ80), contained a Z80 running at 2.4756 Mhz, 4K DRAM, 2K ROM, 2 Z80-PIOs and a "Miniterminal" to control the Monitor program. The system was also sold in a "Super" configuration, NBZ80-S with an additonal experiment board, a power supply and a metal case. 

SGS also commercialized many expansions to the base system:

- The mainboard called CLZ80 could be expanded to 16K Dram and configured for 2K EPROMS, for a total of 8Kb in the 4 sockets.
The base system could also save and load programs on a cassette recorder or a TTY terminal. On the base system the RS232 interface was implemented by bitbanging on the PIO for speeds of up to 600 baud.

- The NBZ80HL was a 16K Ram NBZ80S with an external serial terminal with video output and included a BASIC 8K interpreter mounted on a small daughterboard connected to the experiment board.

- Finally, the "microcomputer" version was sold packaged in a 8 or 4 slot card cage. The mainboard included an 8251 UART and a DC-DC converter to use a single 5V supply. The expanded main board was called "CLZ80-4" and is the main focus of this repository. In addition, RAM, ROM, Video and Floppy cards could be installed in the card cage. 

The CLZ80 board contains a small prom which makes a jump to a routine in ROM from location 0 at reset. It's in socket Q48. While the NBZ80 prom jumps to $FC02, the CLZ80-4 board has a different prom which jumps to $FC00.

## SGS Software

The standard software was contained in the NC-Z and NE-Z eproms (2K in 1 or 2 chips). The first one included the monitor program and the routines to control the miniterminal keyboard. The NE eprom was used together with the experiment board of the NBZ80S.

In addition SGS commercialized

- NC/Z1 Monitor to use the miniterminal on a CLZ80-4 (which included the UART).
- BAS-Z Basic 8K
- SEX 2K Real time operating system
- FP-Z 2K Floating point routines
- MF-Z 6K Assembler/Editor
- MO-Z Monitor.

While the NC and NE eproms are quite common, no copies of the other eproms have surfaced yet. 

# Hardware notes

## Serial interface issues

The basic serial interface implemented by bitbanging was quite slow and inefficient. For this reason an UART can be added to the system. Unfortunately, as one of the documents linked above shows, the 8251 TX pin is connected (through the miniterminal) to the PIO PA4 line. Since the regular NC-Z monitor configures this pin as output as well, it will conflict with the UART when both are active. For this reason SGS Ates distributed (probably with the keyboard or with the NBZ80HL version) a special version of the monitor NC/Z1 which used the UART for the serial interface and configures PA4 as input or at leasts never keeps boot PIO and UART active at the same time. 

While most of the software appears to be written for the "microcomputer" version (with the UART), it's possible that the BAS-Z was compatible with both serial configurations since it was distributed with the NBZ80HL version which didn't include the UART.

## Expanding the NBZ80.

It's quite easy to expand the NBZ80 since the board contains quite a lot of configurable "links". The expansion to 16Kb can be easily done with 4116 chips as described in the technical manual (or with MK4516N if one wants to use a single +5V supply for the ram).

It's recommended to configure the board to use more modern 2K EEprom chips (AT28C16 or equivalents). While the manual doesn't explicity describe it, the configuration is identical to the 2716 (Links 1-5-8).

The 8251 UART can be easily added (it's recommended to add a socket) to the empty Q1 space. The links can be configured for TTY (current loop), RS232 or TTL modes. The configuration is described on page 27 of the CLZ80 manual, altough there are a few typos. For example, the TTL mode must also include link 58. In addition, while the manual in table 1.7.III talks about the UART interrupts, it doesn't say where they are routed. The 8251 activates the B port strobe signal on PIO 1 (~BSTB Pin 17).

IMPORTANT!!!! Once you fit the 8251 don't enable it's transmission together with the unmodified NC-Z monitor, in particular the serial I/O routines which set PA4 to output mode.

## J5 PINOUT

The manual describes the J5 serial connector, but the UART signals are missing.

CTS is at PIN 17. It has to be connected to ground for the UART to transmit (connect it to pin 10).
DTR - PIN 6.
RTS - PIN 8.
DSR - PIN 7.

# Software

The software here assumes a CLZ80-4 board (with UART), 16K ram and 8K eprom. The interrupt links (63-64-67) are all set. Ram starts at $0000. The 8K rom space is mapped from $E000 to $FFFF. Note that when configured for 2K eproms the rom sockets must be used in this order: Q49-Q51-Q50-Q52 (i.e. Q50 starts at $F000 and Q51 at $E800). Both Q48 Proms are supported, so the Basic can start from both $FC00 and $FC02.

The code is derived from Nascom 8K Basic 4.7 (included in ROMWBW) with a modified memory map and serial I/O on the 8251.

The executable is at $E000. The first page ($00-$FF) has the interrupt jump tables. $100-$145 is reserved for the variables and buffers for the serial I/O. The Basic workspace starts at $145. Finally the Basic program is stored starting from $23E.







