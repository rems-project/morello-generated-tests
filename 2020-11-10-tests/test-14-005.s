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
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x3f, 0x7c, 0x5f, 0x48, 0xbf, 0x67, 0x96, 0x82, 0xe8, 0x83, 0x7e, 0x38, 0x50, 0x7c, 0x7f, 0x42
	.byte 0xbf, 0xdf, 0xc4, 0x2c, 0xad, 0x73, 0x61, 0xe2, 0x8b, 0x6e, 0xb9, 0x02, 0xed, 0xc3, 0xbf, 0x38
	.byte 0xa4, 0x24, 0xc6, 0xe2, 0xdf, 0x90, 0x5a, 0x38, 0x20, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000400000000000000001018
	/* C2 */
	.octa 0xfff
	/* C5 */
	.octa 0x1005
	/* C6 */
	.octa 0x80000000000100050000000000500055
	/* C20 */
	.octa 0x8001a0040000000000000000
	/* C22 */
	.octa 0x215
	/* C29 */
	.octa 0x800000004006000b0000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x80000000000400000000000000001018
	/* C2 */
	.octa 0xfff
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1005
	/* C6 */
	.octa 0x80000000000100050000000000500055
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x8001a004fffffffffffff1a5
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x8001a0040000000000000000
	/* C22 */
	.octa 0x215
	/* C29 */
	.octa 0x800000004006000b0000000000001024
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000090100070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005408000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x485f7c3f // ldxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x829667bf // ALDRSB-R.RRB-64 Rt:31 Rn:29 opc:01 S:0 option:011 Rm:22 0:0 L:0 100000101:100000101
	.inst 0x387e83e8 // swpb:aarch64/instrs/memory/atomicops/swp Rt:8 Rn:31 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x427f7c50 // ALDARB-R.R-B Rt:16 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x2cc4dfbf // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:29 Rt2:10111 imm7:0001001 L:1 1011001:1011001 opc:00
	.inst 0xe26173ad // ASTUR-V.RI-H Rt:13 Rn:29 op2:00 imm9:000010111 V:1 op1:01 11100010:11100010
	.inst 0x02b96e8b // SUB-C.CIS-C Cd:11 Cn:20 imm12:111001011011 sh:0 A:1 00000010:00000010
	.inst 0x38bfc3ed // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:13 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xe2c624a4 // ALDUR-R.RI-64 Rt:4 Rn:5 op2:01 imm9:001100010 V:0 op1:11 11100010:11100010
	.inst 0x385a90df // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:6 00:00 imm9:110101001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21320
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2401254 // ldr c20, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603332 // ldr c18, [c25, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601332 // ldr c18, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400259 // ldr c25, [x18, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400659 // ldr c25, [x18, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400a59 // ldr c25, [x18, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400e59 // ldr c25, [x18, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401259 // ldr c25, [x18, #4]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2401659 // ldr c25, [x18, #5]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401a59 // ldr c25, [x18, #6]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401e59 // ldr c25, [x18, #7]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2402259 // ldr c25, [x18, #8]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2402659 // ldr c25, [x18, #9]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402a59 // ldr c25, [x18, #10]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2402e59 // ldr c25, [x18, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2403259 // ldr c25, [x18, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x25, v13.d[0]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v13.d[1]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v23.d[0]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v23.d[1]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v31.d[0]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v31.d[1]
	cmp x18, x25
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000103c
	ldr x1, =check_data2
	ldr x2, =0x0000103e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001068
	ldr x1, =check_data3
	ldr x2, =0x00001070
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001216
	ldr x1, =check_data4
	ldr x2, =0x00001217
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
