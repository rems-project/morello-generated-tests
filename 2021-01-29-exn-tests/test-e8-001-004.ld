SECTIONS {
.text0 0x40400000 : AT(0x00400000) { *(text0) }
.text  0x10300000 : { *(.text) }
.data0 0x00001000 : { *(data0) }
.data 0x00100000 : { *(data) }
.vector_table 0x0000000010310000 : { *(vector_table) }
.vector_table_el1 0x0000000050320000 : AT(0x0000000010320000) { *(vector_table_el1) }
.text_tt 0x0000000010400000 : { *(text_tt) }
}
ENTRY(preamble)
trickbox = 0x13000000;
