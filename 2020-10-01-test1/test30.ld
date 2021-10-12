SECTIONS {
.data0 0x00001000 : { *(data0) }
.data 0x00100000 : { *(data) }
.text0 0x00400000 : { *(text0) }
.text  0x10300000 : { *(.text) }
}
ENTRY(preamble)
trickbox = 0x13000000;
