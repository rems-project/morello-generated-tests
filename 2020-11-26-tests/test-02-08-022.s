.section data0, #alloc, #write
	.zero 384
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xff, 0xff, 0x05, 0x08, 0xbf, 0x87, 0x25, 0xe2, 0x93, 0x12, 0xc0, 0x5a, 0xc1, 0x23, 0x3e, 0x38
	.byte 0x9d, 0xb1, 0xc0, 0xc2, 0xc1, 0xaf, 0x09, 0x39, 0x3e, 0x52, 0xad, 0xf9, 0x8c, 0xa7, 0xcf, 0xb0
	.byte 0xc0, 0x33, 0xc7, 0xc2, 0xc9, 0xea, 0x5c, 0xf8, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C12 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x2012
	/* C29 */
	.octa 0x800000006004c005000000000040c006
	/* C30 */
	.octa 0x1180
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x80
	/* C5 */
	.octa 0x1
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffff9f8f1000
	/* C22 */
	.octa 0x2012
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1180
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000204900070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fe8000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0805ffff // stlxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:31 Rt2:11111 o0:1 Rs:5 0:0 L:0 0010000:0010000 size:00
	.inst 0xe22587bf // ALDUR-V.RI-B Rt:31 Rn:29 op2:01 imm9:001011000 V:1 op1:00 11100010:11100010
	.inst 0x5ac01293 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:19 Rn:20 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x383e23c1 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:010 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c0b19d // GCSEAL-R.C-C Rd:29 Cn:12 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x3909afc1 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:001001101011 opc:00 111001:111001 size:00
	.inst 0xf9ad523e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:17 imm12:101101010100 opc:10 111001:111001 size:11
	.inst 0xb0cfa78c // ADRP-C.I-C Rd:12 immhi:100111110100111100 P:1 10000:10000 immlo:01 op:1
	.inst 0xc2c733c0 // RRMASK-R.R-C Rd:0 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xf85ceac9 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:22 10:10 imm9:111001110 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c210c0
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
	.inst 0xc240024c // ldr c12, [x18, #0]
	.inst 0xc2400656 // ldr c22, [x18, #1]
	.inst 0xc2400a5d // ldr c29, [x18, #2]
	.inst 0xc2400e5e // ldr c30, [x18, #3]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x3085103f
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d2 // ldr c18, [c6, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010d2 // ldr c18, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	.inst 0xc2400246 // ldr c6, [x18, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400646 // ldr c6, [x18, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401246 // ldr c6, [x18, #4]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401646 // ldr c6, [x18, #5]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401a46 // ldr c6, [x18, #6]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2401e46 // ldr c6, [x18, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x6, v31.d[0]
	cmp x18, x6
	b.ne comparison_fail
	ldr x18, =0x0
	mov x6, v31.d[1]
	cmp x18, x6
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
	ldr x0, =0x00001180
	ldr x1, =check_data1
	ldr x2, =0x00001181
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013eb
	ldr x1, =check_data2
	ldr x2, =0x000013ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001fe8
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
	ldr x0, =0x0040c05e
	ldr x1, =check_data5
	ldr x2, =0x0040c05f
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
