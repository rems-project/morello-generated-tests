.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x08, 0x00
.data
check_data2:
	.byte 0xf6, 0x03, 0xc0, 0x5a, 0xc2, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x48, 0x77, 0xc6, 0xca, 0x17, 0x84, 0xa0, 0x9b, 0x5e, 0x0b, 0x03, 0x78, 0x00, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x58, 0x48, 0x61, 0x38, 0xe2, 0xaf, 0x80, 0xb8, 0x17, 0x14, 0x58, 0xa2, 0x57, 0x52, 0xf7, 0xc2
	.byte 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800080080000000000402000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x200080005000001a0000000000400100
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x401810
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x200080005000001a0000000000400100
	/* C8 */
	.octa 0x200080000001000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xba00000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C30 */
	.octa 0x20008000000080080000000000400008
initial_SP_EL3_value:
	.octa 0x40d9f6
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000200140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac003f6 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:22 Rn:31 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c230c2 // BLRS-C-C 00010:00010 Cn:6 100:100 opc:01 11000010110000100:11000010110000100
	.zero 248
	.inst 0xcac67748 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:8 Rn:26 imm6:011101 Rm:6 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x9ba08417 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:23 Rn:0 Ra:1 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x78030b5e // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:26 10:10 imm9:000110000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 7920
	.inst 0x38614858 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:24 Rn:2 10:10 S:0 option:010 Rm:1 1:1 opc:01 111000:111000 size:00
	.inst 0xb880afe2 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:31 11:11 imm9:000001010 0:0 opc:10 111000:111000 size:10
	.inst 0xa2581417 // LDR-C.RIAW-C Ct:23 Rn:0 01:01 imm9:110000001 0:0 opc:01 10100010:10100010
	.inst 0xc2f75257 // EORFLGS-C.CI-C Cd:23 Cn:18 0:0 10:10 imm8:10111010 11000010111:11000010111
	.inst 0xc2c21380
	.zero 1040364
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603383 // ldr c3, [c28, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601383 // ldr c3, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007c // ldr c28, [x3, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240047c // ldr c28, [x3, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240087c // ldr c28, [x3, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400c7c // ldr c28, [x3, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240107c // ldr c28, [x3, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240187c // ldr c28, [x3, #6]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc240207c // ldr c28, [x3, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc240247c // ldr c28, [x3, #9]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240287c // ldr c28, [x3, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400100
	ldr x1, =check_data3
	ldr x2, =0x00400110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040da00
	ldr x1, =check_data5
	ldr x2, =0x0040da04
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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

	.balign 128
vector_table:
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
