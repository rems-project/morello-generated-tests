.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x02, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 1936
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 2096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x02, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xe0, 0x7f, 0xdf, 0x48, 0xd4, 0x03, 0xc0, 0x5a, 0x46, 0x72, 0xa2, 0x78, 0xe2, 0xff, 0xa2, 0xa2
	.byte 0x42, 0x68, 0xd8, 0xc2, 0x9e, 0xc4, 0x66, 0x10, 0x40, 0x98, 0x3f, 0x9b, 0x30, 0x51, 0xe1, 0x78
	.byte 0x02, 0x33, 0xc2, 0xc2
.data
check_data5:
	.byte 0xbe, 0xab, 0x7f, 0x22, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x17cc
	/* C18 */
	.octa 0x102c
	/* C24 */
	.octa 0x20008000cc04cc050000000000400801
	/* C29 */
	.octa 0x90000000000708270000000000001800
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x4000
	/* C2 */
	.octa 0x210000000000000000000000000
	/* C6 */
	.octa 0x1
	/* C9 */
	.octa 0x17cc
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C18 */
	.octa 0x102c
	/* C24 */
	.octa 0x20008000cc04cc050000000000400801
	/* C29 */
	.octa 0x90000000000708270000000000001800
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc1000003ffb0007000002180020e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001800
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48df7fe0 // ldlarh:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x5ac003d4 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:20 Rn:30 101101011000000000000:101101011000000000000 sf:0
	.inst 0x78a27246 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:18 00:00 opc:111 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xa2a2ffe2 // CASL-C.R-C Ct:2 Rn:31 11111:11111 R:1 Cs:2 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2d86842 // ORRFLGS-C.CR-C Cd:2 Cn:2 1010:1010 opc:01 Rm:24 11000010110:11000010110
	.inst 0x1066c49e // ADR-C.I-C Rd:30 immhi:110011011000100100 P:0 10000:10000 immlo:00 op:0
	.inst 0x9b3f9840 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:2 Ra:6 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0x78e15130 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:9 00:00 opc:101 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c23302 // BLRS-C-C 00010:00010 Cn:24 100:100 opc:01 11000010110000100:11000010110000100
	.zero 2012
	.inst 0x227fabbe // LDAXP-C.R-C Ct:30 Rn:29 Ct2:01010 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c211a0
	.zero 1046520
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
	ldr x0, =initial_tag_locations
	mov x1, #1
tag_init_loop:
	ldr x2, [x0], #8
	cbz x2, tag_init_end
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c18063 // sctag c3, c3, c1
	.inst 0xc2000043 // str c3, [x2, #0]
	b tag_init_loop
tag_init_end:
	/* Write general purpose registers */
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103d
	msr SCTLR_EL3, x8
	ldr x8, =0x8c
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a8 // ldr c8, [c13, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826011a8 // ldr c8, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010d // ldr c13, [x8, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240050d // ldr c13, [x8, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc240150d // ldr c13, [x8, #5]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240190d // ldr c13, [x8, #6]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc2401d0d // ldr c13, [x8, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240210d // ldr c13, [x8, #8]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240250d // ldr c13, [x8, #9]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240290d // ldr c13, [x8, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000102c
	ldr x1, =check_data1
	ldr x2, =0x0000102e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017cc
	ldr x1, =check_data2
	ldr x2, =0x000017ce
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400800
	ldr x1, =check_data5
	ldr x2, =0x00400808
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =fail_message
write_tube:
	ldr x1, =trickbox
write_tube_loop:
	ldrb w2, [x0], #1
	strb w2, [x1]
	b write_tube_loop
ok_message:
	.ascii "OK\n\004"
fail_message:
	.ascii "FAILED\n\004"

.section vector_table, #alloc, #execinstr
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
