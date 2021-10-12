.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc6
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x1e, 0x80, 0x99, 0xb8, 0x9e, 0x46, 0x82, 0x5a, 0x9e, 0x30, 0xc7, 0xc2, 0xf2, 0x0b, 0x52, 0x78
	.byte 0x1e, 0x5d, 0x68, 0xb2, 0x51, 0xe0, 0xda, 0xc2, 0x5d, 0x40, 0x03, 0xfc, 0x0b, 0xf0, 0xc0, 0xc2
	.byte 0x62, 0xe0, 0xfb, 0x62, 0x34, 0x70, 0xc0, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2010
	/* C1 */
	.octa 0x400000000000000000000000
	/* C2 */
	.octa 0x800000000000000000000fe4
	/* C3 */
	.octa 0x2020
	/* C4 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2010
	/* C1 */
	.octa 0x400000000000000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1f90
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x801e
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4000e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000106000000ffffffff0e8100
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fa0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb899801e // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:110011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a82469e // csneg:aarch64/instrs/integer/conditional/select Rd:30 Rn:20 o2:1 0:0 cond:0100 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0xc2c7309e // RRMASK-R.R-C Rd:30 Rn:4 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x78520bf2 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:18 Rn:31 10:10 imm9:100100000 0:0 opc:01 111000:111000 size:01
	.inst 0xb2685d1e // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:8 imms:010111 immr:101000 N:1 100100:100100 opc:01 sf:1
	.inst 0xc2dae051 // SCFLGS-C.CR-C Cd:17 Cn:2 111000:111000 Rm:26 11000010110:11000010110
	.inst 0xfc03405d // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:2 00:00 imm9:000110100 0:0 opc:00 111100:111100 size:11
	.inst 0xc2c0f00b // GCTYPE-R.C-C Rd:11 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x62fbe062 // LDP-C.RIBW-C Ct:2 Rn:3 Ct2:11000 imm7:1110111 L:1 011000101:011000101
	.inst 0xc2c07034 // GCOFF-R.C-C Rd:20 Cn:1 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc24010c4 // ldr c4, [x6, #4]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q29, =0xc600000000000000
	/* Set up flags and system registers */
	mov x6, #0x80000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a6 // ldr c6, [c13, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011a6 // ldr c6, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x13, #0x8
	and x6, x6, x13
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cd // ldr c13, [x6, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24004cd // ldr c13, [x6, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24008cd // ldr c13, [x6, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400ccd // ldr c13, [x6, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc24010cd // ldr c13, [x6, #4]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc24014cd // ldr c13, [x6, #5]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc24018cd // ldr c13, [x6, #6]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc2401ccd // ldr c13, [x6, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc24020cd // ldr c13, [x6, #8]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xc600000000000000
	mov x13, v29.d[0]
	cmp x6, x13
	b.ne comparison_fail
	ldr x6, =0x0
	mov x13, v29.d[1]
	cmp x6, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f90
	ldr x1, =check_data1
	ldr x2, =0x00001fb0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
