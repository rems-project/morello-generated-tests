.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x11, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x33, 0x54, 0x3b, 0x22, 0xc1, 0x2f, 0xab, 0xc2, 0xf3, 0xd3, 0x62, 0x82, 0xc4, 0xff, 0x0c, 0x48
	.byte 0x80, 0x3c, 0x4b, 0xb8, 0x18, 0xf8, 0x3f, 0x78, 0xef, 0x63, 0xb9, 0xac, 0xdf, 0x53, 0xa1, 0xb8
	.byte 0x1c, 0x37, 0xfd, 0x37, 0x00, 0x88, 0xd3, 0x38, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0xf81
	/* C11 */
	.octa 0xfe00
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20000180070000000000001004
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20000180070000000000080004
	/* C4 */
	.octa 0x1034
	/* C11 */
	.octa 0xfe00
	/* C12 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20000180070000000000001004
initial_SP_EL3_value:
	.octa 0x80000000400101140000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000aa300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000007000000fffffffff00000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012d0
	.dword initial_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x223b5433 // STXP-R.CR-C Ct:19 Rn:1 Ct2:10101 0:0 Rs:27 1:1 L:0 001000100:001000100
	.inst 0xc2ab2fc1 // ADD-C.CRI-C Cd:1 Cn:30 imm3:011 option:001 Rm:11 11000010101:11000010101
	.inst 0x8262d3f3 // ALDR-C.RI-C Ct:19 Rn:31 op:00 imm9:000101101 L:1 1000001001:1000001001
	.inst 0x480cffc4 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:4 Rn:30 Rt2:11111 o0:1 Rs:12 0:0 L:0 0010000:0010000 size:01
	.inst 0xb84b3c80 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:4 11:11 imm9:010110011 0:0 opc:01 111000:111000 size:10
	.inst 0x783ff818 // strh_reg:aarch64/instrs/memory/single/general/register Rt:24 Rn:0 10:10 S:1 option:111 Rm:31 1:1 opc:00 111000:111000 size:01
	.inst 0xacb963ef // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:15 Rn:31 Rt2:11000 imm7:1110010 L:0 1011001:1011001 opc:10
	.inst 0xb8a153df // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:101 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x37fd371c // tbnz:aarch64/instrs/branch/conditional/test Rt:28 imm14:10100110111000 b40:11111 op:1 011011:011011 b5:0
	.inst 0x38d38800 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:0 10:10 imm9:100111000 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c21240
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2400c73 // ldr c19, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc240187c // ldr c28, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q15, =0x20100000000000000
	ldr q24, =0x80008080000080000000000000
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603243 // ldr c3, [c18, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402472 // ldr c18, [x3, #9]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2402872 // ldr c18, [x3, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x100000000000000
	mov x18, v15.d[0]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x2
	mov x18, v15.d[1]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x80000000000000
	mov x18, v24.d[0]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x8000808000
	mov x18, v24.d[1]
	cmp x3, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001034
	ldr x1, =check_data1
	ldr x2, =0x00001039
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012d0
	ldr x1, =check_data3
	ldr x2, =0x000012e0
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
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
