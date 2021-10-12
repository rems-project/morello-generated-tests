.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2576
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1488
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xef, 0x03, 0x1e, 0x3a, 0xe5, 0xd7, 0x53, 0xb8, 0x1d, 0x0b, 0xdf, 0xc2, 0x21, 0x31, 0xc2, 0xc2
	.byte 0xef, 0xa7, 0xeb, 0x39, 0xe2, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc9, 0xaf, 0xc9, 0x02, 0xbd, 0xff, 0xb5, 0x48, 0xe1, 0x9b, 0xfe, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x23, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000000000000000000000410000
	/* C7 */
	.octa 0x20008000000100050000000000440000
	/* C9 */
	.octa 0x0
	/* C21 */
	.octa 0x3d3d
	/* C24 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x3
	/* C5 */
	.octa 0xc2c2c2c2
	/* C7 */
	.octa 0x20008000000100050000000000440000
	/* C9 */
	.octa 0x20008000000100070000000000195018
	/* C15 */
	.octa 0xffffffc2
	/* C21 */
	.octa 0xc2c2
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x20008000000100070000000000400018
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005b0200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a1e03ef // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:15 Rn:31 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0xb853d7e5 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:31 01:01 imm9:100111101 0:0 opc:01 111000:111000 size:10
	.inst 0xc2df0b1d // SEAL-C.CC-C Cd:29 Cn:24 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0xc2c23121 // CHKTGD-C-C 00001:00001 Cn:9 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x39eba7ef // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:31 imm12:101011101001 opc:11 111001:111001 size:00
	.inst 0xc2c230e2 // BLRS-C-C 00010:00010 Cn:7 100:100 opc:01 11000010110000100:11000010110000100
	.zero 65512
	.inst 0x02c9afc9 // SUB-C.CIS-C Cd:9 Cn:30 imm12:001001101011 sh:1 A:1 00000010:00000010
	.inst 0x48b5ffbd // cash:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:29 11111:11111 o0:1 Rs:21 1:1 L:0 0010001:0010001 size:01
	.inst 0xc2fe9be1 // SUBS-R.CC-C Rd:1 Cn:31 100110:100110 Cm:30 11000010111:11000010111
	.inst 0xc2c212c0
	.zero 196592
	.inst 0xc2c21023 // BRR-C-C 00011:00011 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 786428
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc2401278 // ldr c24, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d3 // ldr c19, [c22, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012d3 // ldr c19, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x22, #0xf
	and x19, x19, x22
	cmp x19, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400276 // ldr c22, [x19, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400676 // ldr c22, [x19, #1]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400a76 // ldr c22, [x19, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401e76 // ldr c22, [x19, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001a26
	ldr x1, =check_data1
	ldr x2, =0x00001a27
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410000
	ldr x1, =check_data3
	ldr x2, =0x00410010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00440000
	ldr x1, =check_data4
	ldr x2, =0x00440004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
