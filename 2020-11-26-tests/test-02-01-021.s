.section data0, #alloc, #write
	.zero 2048
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x40, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xa6, 0x1c, 0x97, 0xe2, 0x34, 0xfc, 0xdf, 0x48, 0xaf, 0x8f, 0x64, 0xb9, 0x1e, 0x7d, 0x1d, 0x48
	.byte 0x00, 0x31, 0xc7, 0xc2, 0x3f, 0xf0, 0xc1, 0x82, 0xe7, 0x7f, 0x14, 0x48, 0x3f, 0x60, 0x23, 0x78
	.byte 0xde, 0x1b, 0xfe, 0xc2, 0xd2, 0xf3, 0x7c, 0x6d, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000600200020000000000000800
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000030003000000000000200f
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x3ff000
	/* C29 */
	.octa 0x3fcb78
	/* C30 */
	.octa 0x800100070000000000001008
final_cap_values:
	/* C0 */
	.octa 0xfffffffffffffc00
	/* C1 */
	.octa 0x80000000600200020000000000000800
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000030003000000000000200f
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x3ff000
	/* C15 */
	.octa 0x48dffc34
	/* C20 */
	.octa 0x1
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x800100070000000000001008
initial_SP_EL3_value:
	.octa 0x1f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000f002000fffffffff00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2971ca6 // ASTUR-C.RI-C Ct:6 Rn:5 op2:11 imm9:101110001 V:0 op1:10 11100010:11100010
	.inst 0x48dffc34 // ldarh:aarch64/instrs/memory/ordered Rt:20 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xb9648faf // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:29 imm12:100100100011 opc:01 111001:111001 size:10
	.inst 0x481d7d1e // stxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:8 Rt2:11111 o0:0 Rs:29 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c73100 // RRMASK-R.R-C Rd:0 Rn:8 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x82c1f03f // ALDRB-R.RRB-B Rt:31 Rn:1 opc:00 S:1 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x48147fe7 // stxrh:aarch64/instrs/memory/exclusive/single Rt:7 Rn:31 Rt2:11111 o0:0 Rs:20 0:0 L:0 0010000:0010000 size:01
	.inst 0x7823603f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:3 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2fe1bde // CVT-C.CR-C Cd:30 Cn:30 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0x6d7cf3d2 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:18 Rn:30 Rt2:11100 imm7:1111001 L:1 1011010:1011010 opc:01
	.inst 0xc2c211a0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc240149d // ldr c29, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085103d
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a4 // ldr c4, [c13, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011a4 // ldr c4, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008d // ldr c13, [x4, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240048d // ldr c13, [x4, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240088d // ldr c13, [x4, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240108d // ldr c13, [x4, #4]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240148d // ldr c13, [x4, #5]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240188d // ldr c13, [x4, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401c8d // ldr c13, [x4, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240208d // ldr c13, [x4, #8]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240248d // ldr c13, [x4, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x13, v18.d[0]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v18.d[1]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v28.d[0]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v28.d[1]
	cmp x4, x13
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
	ldr x0, =0x000011f0
	ldr x1, =check_data1
	ldr x2, =0x000011f2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd0
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
