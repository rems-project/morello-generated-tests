.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x09, 0x33, 0xbf, 0x38, 0x90, 0xff, 0x1d, 0xc8, 0x2d, 0x58, 0xe0, 0xc2, 0xbe, 0xe2, 0xe7, 0xad
	.byte 0x7c, 0x20, 0xdd, 0xc2, 0x24, 0x7c, 0xe1, 0xc8, 0x58, 0xfc, 0x14, 0x08, 0x21, 0xfc, 0xbd, 0xa2
	.byte 0x8e, 0x7c, 0xc0, 0x9b, 0x3d, 0xd3, 0x9f, 0x1a, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x700070000000000000000
	/* C4 */
	.octa 0x1
	/* C21 */
	.octa 0x1410
	/* C24 */
	.octa 0x1004
	/* C28 */
	.octa 0x1008
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x700070000000000000000
	/* C4 */
	.octa 0x1
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x1
	/* C21 */
	.octa 0x1100
	/* C24 */
	.octa 0x1004
	/* C28 */
	.octa 0x400100000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005400000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bf3309 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:24 00:00 opc:011 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc81dff90 // stlxr:aarch64/instrs/memory/exclusive/single Rt:16 Rn:28 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2e0582d // CVTZ-C.CR-C Cd:13 Cn:1 0110:0110 1:1 0:0 Rm:0 11000010111:11000010111
	.inst 0xade7e2be // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:21 Rt2:11000 imm7:1001111 L:1 1011011:1011011 opc:10
	.inst 0xc2dd207c // SCBNDSE-C.CR-C Cd:28 Cn:3 000:000 opc:01 0:0 Rm:29 11000010110:11000010110
	.inst 0xc8e17c24 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:4 Rn:1 11111:11111 o0:0 Rs:1 1:1 L:1 0010001:0010001 size:11
	.inst 0x0814fc58 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:2 Rt2:11111 o0:1 Rs:20 0:0 L:0 0010000:0010000 size:00
	.inst 0xa2bdfc21 // CASL-C.R-C Ct:1 Rn:1 11111:11111 R:1 Cs:29 1:1 L:0 1:1 10100010:10100010
	.inst 0x9bc07c8e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:14 Rn:4 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0x1a9fd33d // csel:aarch64/instrs/integer/conditional/select Rd:29 Rn:25 o2:0 0:0 cond:1101 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xc2c210a0
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
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2401244 // ldr c4, [x18, #4]
	.inst 0xc2401655 // ldr c21, [x18, #5]
	.inst 0xc2401a58 // ldr c24, [x18, #6]
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x80000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b2 // ldr c18, [c5, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010b2 // ldr c18, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	mov x5, #0x9
	and x18, x18, x5
	cmp x18, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400245 // ldr c5, [x18, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400645 // ldr c5, [x18, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e45 // ldr c5, [x18, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401245 // ldr c5, [x18, #4]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401645 // ldr c5, [x18, #5]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401a45 // ldr c5, [x18, #6]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401e45 // ldr c5, [x18, #7]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2402245 // ldr c5, [x18, #8]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402645 // ldr c5, [x18, #9]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402a45 // ldr c5, [x18, #10]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402e45 // ldr c5, [x18, #11]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x5, v24.d[0]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v24.d[1]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v30.d[0]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v30.d[1]
	cmp x18, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001120
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
