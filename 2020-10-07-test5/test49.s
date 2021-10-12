.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xa0, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0xa0, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0xdd, 0xdb, 0xbf, 0xea, 0x00, 0x80, 0x9b, 0x42, 0xdb, 0x51, 0x88, 0xb8, 0x41, 0x00, 0xc0, 0xda
	.byte 0x92, 0x59, 0xd0, 0xc2, 0xe2, 0xf3, 0xc5, 0xc2, 0x81, 0xfb, 0x58, 0xa2, 0x58, 0xaa, 0xdd, 0xc2
	.byte 0xe2, 0x53, 0x0a, 0x78, 0x40, 0x07, 0xc0, 0x5a, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000000000000000014a0
	/* C12 */
	.octa 0x104002400200ffffffffff8000
	/* C14 */
	.octa 0x106b
	/* C28 */
	.octa 0x17e0
	/* C30 */
	.octa 0xffffffffffffffff
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x104002400200ffffffffff8000
	/* C14 */
	.octa 0x106b
	/* C18 */
	.octa 0x10400240020100000000000000
	/* C24 */
	.octa 0x1040024002fe00000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x17e0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x1003
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010d0
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeabfdbdd // bics:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:30 imm6:110110 Rm:31 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0x429b8000 // STP-C.RIB-C Ct:0 Rn:0 Ct2:00000 imm7:0110111 L:0 010000101:010000101
	.inst 0xb88851db // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:14 00:00 imm9:010000101 0:0 opc:10 111000:111000 size:10
	.inst 0xdac00041 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:1 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2d05992 // ALIGNU-C.CI-C Cd:18 Cn:12 0110:0110 U:1 imm6:100000 11000010110:11000010110
	.inst 0xc2c5f3e2 // CVTPZ-C.R-C Cd:2 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xa258fb81 // LDTR-C.RIB-C Ct:1 Rn:28 10:10 imm9:110001111 0:0 opc:01 10100010:10100010
	.inst 0xc2ddaa58 // EORFLGS-C.CR-C Cd:24 Cn:18 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0x780a53e2 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:010100101 0:0 opc:00 111000:111000 size:01
	.inst 0x5ac00740 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:26 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006ec // ldr c12, [x23, #1]
	.inst 0xc2400aee // ldr c14, [x23, #2]
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603297 // ldr c23, [c20, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601297 // ldr c23, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x20, #0xf
	and x23, x23, x20
	cmp x23, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f4 // ldr c20, [x23, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24006f4 // ldr c20, [x23, #1]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400af4 // ldr c20, [x23, #2]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2400ef4 // ldr c20, [x23, #3]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2401af4 // ldr c20, [x23, #6]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2401ef4 // ldr c20, [x23, #7]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc24022f4 // ldr c20, [x23, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24026f4 // ldr c20, [x23, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a8
	ldr x1, =check_data0
	ldr x2, =0x000010aa
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x000010f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001830
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
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
