.section data0, #alloc, #write
	.byte 0xfe, 0xfd, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0xfd, 0x55, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x74, 0x2f, 0x36, 0xe2, 0xa0, 0x90, 0xc0, 0xc2, 0x1e, 0xfc, 0xa1, 0x9b, 0xe5, 0x67, 0x91, 0x82
	.byte 0xcc, 0x53, 0xc1, 0xc2, 0xdf, 0x60, 0x22, 0xb8, 0x5f, 0xfc, 0x0b, 0x48, 0xbe, 0xe5, 0xab, 0x82
	.byte 0x41, 0x84, 0xc2, 0xc2, 0x35, 0xc0, 0xbf, 0x38, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000007800f0000000000408420
	/* C2 */
	.octa 0x400000000003000300000000004ffd08
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0xc0000000000300070000000000001000
	/* C13 */
	.octa 0x1007
	/* C17 */
	.octa 0x3ff7180000000001
	/* C27 */
	.octa 0x40040e
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000000007800f0000000000408420
	/* C2 */
	.octa 0x400000000003000300000000004ffd08
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0xc0000000000300070000000000001000
	/* C11 */
	.octa 0x1
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1007
	/* C17 */
	.octa 0x3ff7180000000001
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x40040e
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc008e80000001040
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000010010005000000000000a001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2362f74 // ALDUR-V.RI-Q Rt:20 Rn:27 op2:11 imm9:101100010 V:1 op1:00 11100010:11100010
	.inst 0xc2c090a0 // GCTAG-R.C-C Rd:0 Cn:5 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x9ba1fc1e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:31 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x829167e5 // ALDRSB-R.RRB-64 Rt:5 Rn:31 opc:01 S:0 option:011 Rm:17 0:0 L:0 100000101:100000101
	.inst 0xc2c153cc // CFHI-R.C-C Rd:12 Cn:30 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xb82260df // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:110 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x480bfc5f // stlxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:2 Rt2:11111 o0:1 Rs:11 0:0 L:0 0010000:0010000 size:01
	.inst 0x82abe5be // ASTR-R.RRB-64 Rt:30 Rn:13 opc:01 S:0 option:111 Rm:11 1:1 L:0 100000101:100000101
	.inst 0xc2c28441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0x38bfc035 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xc2c212c0
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
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2401651 // ldr c17, [x18, #5]
	.inst 0xc2401a5b // ldr c27, [x18, #6]
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d2 // ldr c18, [c22, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826012d2 // ldr c18, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x22, #0xf
	and x18, x18, x22
	cmp x18, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400256 // ldr c22, [x18, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400656 // ldr c22, [x18, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a56 // ldr c22, [x18, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400e56 // ldr c22, [x18, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401256 // ldr c22, [x18, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401a56 // ldr c22, [x18, #6]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401e56 // ldr c22, [x18, #7]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2402256 // ldr c22, [x18, #8]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2402656 // ldr c22, [x18, #9]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402a56 // ldr c22, [x18, #10]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402e56 // ldr c22, [x18, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x22, v20.d[0]
	cmp x18, x22
	b.ne comparison_fail
	ldr x18, =0x0
	mov x22, v20.d[1]
	cmp x18, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001041
	ldr x1, =check_data2
	ldr x2, =0x00001042
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400370
	ldr x1, =check_data4
	ldr x2, =0x00400380
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408420
	ldr x1, =check_data5
	ldr x2, =0x00408421
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffd08
	ldr x1, =check_data6
	ldr x2, =0x004ffd0a
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
