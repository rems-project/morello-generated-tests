.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0xc4, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2928
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 880
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc4, 0x02, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x3f, 0x50, 0x21, 0xb8, 0xdf, 0x23, 0x64, 0xf8, 0xe2, 0xff, 0xbc, 0x08, 0x40, 0x7c, 0x1a, 0x48
	.byte 0x2a, 0x18, 0x55, 0x7a, 0x88, 0x4c, 0xaa, 0xf2, 0x4c, 0x7c, 0xdf, 0xc8, 0x9f, 0x40, 0x60, 0x38
	.byte 0x81, 0x02, 0x1e, 0x1a, 0xe3, 0x19, 0xd1, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1084
	/* C2 */
	.octa 0x1100
	/* C4 */
	.octa 0x1000
	/* C15 */
	.octa 0x400101040000000000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1c08
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1100
	/* C3 */
	.octa 0x400101040000000000000000
	/* C4 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x400101040000000000000000
	/* C26 */
	.octa 0x1
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1c08
initial_SP_EL3_value:
	.octa 0xf80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005d81008000ffffffffffffc0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb821503f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:101 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xf86423df // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:010 o3:0 Rs:4 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x08bcffe2 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:2 Rn:31 11111:11111 o0:1 Rs:28 1:1 L:0 0010001:0010001 size:00
	.inst 0x481a7c40 // stxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:2 Rt2:11111 o0:0 Rs:26 0:0 L:0 0010000:0010000 size:01
	.inst 0x7a55182a // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:1 10:10 cond:0001 imm5:10101 111010010:111010010 op:1 sf:0
	.inst 0xf2aa4c88 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:0101001001100100 hw:01 100101:100101 opc:11 sf:1
	.inst 0xc8df7c4c // ldlar:aarch64/instrs/memory/ordered Rt:12 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x3860409f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:100 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x1a1e0281 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:20 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2d119e3 // ALIGND-C.CI-C Cd:3 Cn:15 0110:0110 U:0 imm6:100010 11000010110:11000010110
	.inst 0xc2c213a0
	.zero 1048532
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae2 // ldr c2, [x23, #2]
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc24016fc // ldr c28, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x3085103d
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b7 // ldr c23, [c29, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826013b7 // ldr c23, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x29, #0xf
	and x23, x23, x29
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fd // ldr c29, [x23, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24006fd // ldr c29, [x23, #1]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400afd // ldr c29, [x23, #2]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc2400efd // ldr c29, [x23, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24012fd // ldr c29, [x23, #4]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc2401afd // ldr c29, [x23, #6]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc2401efd // ldr c29, [x23, #7]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc24022fd // ldr c29, [x23, #8]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001104
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001180
	ldr x1, =check_data3
	ldr x2, =0x00001188
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c88
	ldr x1, =check_data4
	ldr x2, =0x00001c90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
