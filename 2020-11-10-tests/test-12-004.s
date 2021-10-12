.section data0, #alloc, #write
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x01, 0x00, 0x00
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x00
	.zero 560
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3376
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xfe, 0x23, 0xbe, 0x38, 0xdf, 0x1f, 0x4d, 0x38, 0x81, 0x30, 0xc2, 0xc2, 0xfe, 0x23, 0x5b, 0xa2
	.byte 0x9c, 0x3c, 0xd9, 0xe2, 0x1f, 0x2c, 0x22, 0xe2, 0xc0, 0x47, 0xda, 0xc2, 0x5f, 0x20, 0x7f, 0x78
	.byte 0x41, 0x20, 0xd5, 0x42, 0xe1, 0x03, 0x7e, 0x78, 0x40, 0x11, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001fbe
	/* C2 */
	.octa 0x2
	/* C4 */
	.octa 0x8000000000010005000000000040008d
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1f
final_cap_values:
	/* C0 */
	.octa 0x104800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2
	/* C4 */
	.octa 0x8000000000010005000000000040008d
	/* C8 */
	.octa 0x101800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xc2c21140787e03e142d52041
	/* C30 */
	.octa 0x104800000000000000000000000
initial_SP_EL3_value:
	.octa 0x80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000005810100e00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x00000000000012c0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38be23fe // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:31 00:00 opc:010 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x384d1fdf // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:011010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c23081 // CHKTGD-C-C 00001:00001 Cn:4 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xa25b23fe // LDUR-C.RI-C Ct:30 Rn:31 00:00 imm9:110110010 0:0 opc:01 10100010:10100010
	.inst 0xe2d93c9c // ALDUR-C.RI-C Ct:28 Rn:4 op2:11 imm9:110010011 V:0 op1:11 11100010:11100010
	.inst 0xe2222c1f // ALDUR-V.RI-Q Rt:31 Rn:0 op2:11 imm9:000100010 V:1 op1:00 11100010:11100010
	.inst 0xc2da47c0 // CSEAL-C.C-C Cd:0 Cn:30 001:001 opc:10 0:0 Cm:26 11000010110:11000010110
	.inst 0x787f205f // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:010 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x42d52041 // LDP-C.RIB-C Ct:1 Rn:2 Ct2:01000 imm7:0101010 L:1 010000101:010000101
	.inst 0x787e03e1 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:000 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c21140
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc240131e // ldr c30, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603158 // ldr c24, [c10, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x10, #0xf
	and x24, x24, x10
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x10, v31.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v31.d[1]
	cmp x24, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000108e
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010fe
	ldr x1, =check_data3
	ldr x2, =0x000010ff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000012b0
	ldr x1, =check_data4
	ldr x2, =0x000012d0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe0
	ldr x1, =check_data5
	ldr x2, =0x00001ff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
