.section data0, #alloc, #write
	.zero 4064
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xdc, 0x59, 0x31, 0x36
.data
check_data3:
	.byte 0x8d, 0x21, 0x5e, 0x7a, 0xe2, 0xf0, 0xc0, 0xc2, 0x40, 0x84, 0xa0, 0x9b, 0xde, 0x93, 0xc1, 0xc2
	.byte 0x09, 0x04, 0x6b, 0xb1, 0xc1, 0xbe, 0x4a, 0xa2, 0x62, 0xb4, 0x76, 0x82, 0x24, 0x78, 0x4a, 0x3a
	.byte 0x3e, 0x68, 0xa2, 0xf8, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x7fffffffff800000
	/* C3 */
	.octa 0x80000000000100050000000000001e93
	/* C7 */
	.octa 0x0
	/* C22 */
	.octa 0x1530
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x7fffffffff800000
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C2 */
	.octa 0xc2
	/* C3 */
	.octa 0x80000000000100050000000000001e93
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000002c1000
	/* C22 */
	.octa 0x1fe0
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006003f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000000007040500ffffffffff8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x363159dc // tbz:aarch64/instrs/branch/conditional/test Rt:28 imm14:00101011001110 b40:00110 op:0 011011:011011 b5:0
	.zero 11060
	.inst 0x7a5e218d // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1101 0:0 Rn:12 00:00 cond:0010 Rm:30 111010010:111010010 op:1 sf:0
	.inst 0xc2c0f0e2 // GCTYPE-R.C-C Rd:2 Cn:7 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x9ba08440 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:2 Ra:1 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xc2c193de // CLRTAG-C.C-C Cd:30 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xb16b0409 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:9 Rn:0 imm12:101011000001 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xa24abec1 // LDR-C.RIBW-C Ct:1 Rn:22 11:11 imm9:010101011 0:0 opc:01 10100010:10100010
	.inst 0x8276b462 // ALDRB-R.RI-B Rt:2 Rn:3 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x3a4a7824 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:1 10:10 cond:0111 imm5:01010 111010010:111010010 op:0 sf:0
	.inst 0xf8a2683e // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:1 10:10 S:0 option:011 Rm:2 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c21160
	.zero 1037472
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
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	/* Set up flags and system registers */
	mov x6, #0x20000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603166 // ldr c6, [c11, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601166 // ldr c6, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x6, x6, x11
	cmp x6, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cb // ldr c11, [x6, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004cb // ldr c11, [x6, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc24018cb // ldr c11, [x6, #6]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc2401ccb // ldr c11, [x6, #7]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402b38
	ldr x1, =check_data3
	ldr x2, =0x00402b60
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
