.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x3d, 0x6c, 0xdd, 0xc2, 0xe0, 0x63, 0x50, 0x78, 0xe0, 0x77, 0x9f, 0x5a, 0x1e, 0x20, 0xfe, 0xf8
	.byte 0x54, 0x85, 0x83, 0x02, 0xf0, 0x53, 0xc1, 0xc2, 0x9d, 0x64, 0x1a, 0x6d, 0xfb, 0x4b, 0x45, 0xb8
	.byte 0x1f, 0x27, 0xdd, 0xc2, 0xea, 0x11, 0x83, 0x39, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x40004000000000000000a002
	/* C15 */
	.octa 0x82
	/* C24 */
	.octa 0x800000740070000100000018000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x82
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x400040000000000000009f21
	/* C24 */
	.octa 0x800000740070000100000018000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x20c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000008710070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd6c3d // CSEL-C.CI-C Cd:29 Cn:1 11:11 cond:0110 Cm:29 11000010110:11000010110
	.inst 0x785063e0 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:100000110 0:0 opc:01 111000:111000 size:01
	.inst 0x5a9f77e0 // csneg:aarch64/instrs/integer/conditional/select Rd:0 Rn:31 o2:1 0:0 cond:0111 Rm:31 011010100:011010100 op:1 sf:0
	.inst 0xf8fe201e // ldeor:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:010 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x02838554 // SUB-C.CIS-C Cd:20 Cn:10 imm12:000011100001 sh:0 A:1 00000010:00000010
	.inst 0xc2c153f0 // 0xc2c153f0
	.inst 0x6d1a649d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:29 Rn:4 Rt2:11001 imm7:0110100 L:0 1011010:1011010 opc:01
	.inst 0xb8454bfb // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:31 10:10 imm9:001010100 0:0 opc:01 111000:111000 size:10
	.inst 0xc2dd271f // CPYTYPE-C.C-C Cd:31 Cn:24 001:001 opc:01 0:0 Cm:29 11000010110:11000010110
	.inst 0x398311ea // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:15 imm12:000011000100 opc:10 111001:111001 size:00
	.inst 0xc2c21180
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2400a2a // ldr c10, [x17, #2]
	.inst 0xc2400e2f // ldr c15, [x17, #3]
	.inst 0xc2401238 // ldr c24, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q25, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x17, #0x10000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851037
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603191 // ldr c17, [c12, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601191 // ldr c17, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x12, #0x1
	and x17, x17, x12
	cmp x17, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022c // ldr c12, [x17, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240062c // ldr c12, [x17, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a2c // ldr c12, [x17, #2]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc2400e2c // ldr c12, [x17, #3]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc240122c // ldr c12, [x17, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc240162c // ldr c12, [x17, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401a2c // ldr c12, [x17, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401e2c // ldr c12, [x17, #7]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc240222c // ldr c12, [x17, #8]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc240262c // ldr c12, [x17, #9]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402a2c // ldr c12, [x17, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x12, v25.d[0]
	cmp x17, x12
	b.ne comparison_fail
	ldr x17, =0x0
	mov x12, v25.d[1]
	cmp x17, x12
	b.ne comparison_fail
	ldr x17, =0x0
	mov x12, v29.d[0]
	cmp x17, x12
	b.ne comparison_fail
	ldr x17, =0x0
	mov x12, v29.d[1]
	cmp x17, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001112
	ldr x1, =check_data1
	ldr x2, =0x00001114
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001146
	ldr x1, =check_data2
	ldr x2, =0x00001147
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011a0
	ldr x1, =check_data3
	ldr x2, =0x000011b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001260
	ldr x1, =check_data4
	ldr x2, =0x00001264
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
