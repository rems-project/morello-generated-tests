.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x03, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x18
.data
check_data1:
	.zero 64
.data
check_data2:
	.byte 0x00, 0x28, 0xd2, 0xc2, 0xfb, 0xff, 0x3f, 0x42, 0x5e, 0x40, 0x61, 0x38, 0x46, 0xb0, 0xc4, 0xc2
	.byte 0x20, 0xf7, 0x52, 0xf8, 0x62, 0x53, 0x40, 0xe2, 0x59, 0x74, 0x94, 0x82, 0xc1, 0x07, 0xcf, 0xc2
	.byte 0x97, 0x7e, 0xa0, 0xc8, 0x5f, 0x37, 0x03, 0xd5, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0x01, 0x00, 0x01, 0x00, 0x00, 0x04, 0x20, 0x00
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xd0000000000300070000000000001800
	/* C15 */
	.octa 0x400100010000000000000001
	/* C20 */
	.octa 0xc00000005000d6710000000000400400
	/* C25 */
	.octa 0x80000000000100050000000000001000
	/* C27 */
	.octa 0x1003
final_cap_values:
	/* C0 */
	.octa 0x20040000010001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xd0000000000300070000000000001800
	/* C6 */
	.octa 0x6
	/* C15 */
	.octa 0x400100010000000000000001
	/* C20 */
	.octa 0xc00000005000d6710000000000400400
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x1003
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000407800000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001810
	.dword 0x0000000000001820
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d22800 // BICFLGS-C.CR-C Cd:0 Cn:0 1010:1010 opc:00 Rm:18 11000010110:11000010110
	.inst 0x423ffffb // ASTLR-R.R-32 Rt:27 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x3861405e // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:2 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c4b046 // LDCT-R.R-_ Rt:6 Rn:2 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xf852f720 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:25 01:01 imm9:100101111 0:0 opc:01 111000:111000 size:11
	.inst 0xe2405362 // ASTURH-R.RI-32 Rt:2 Rn:27 op2:00 imm9:000000101 V:0 op1:01 11100010:11100010
	.inst 0x82947459 // ALDRSB-R.RRB-64 Rt:25 Rn:2 opc:01 S:1 option:011 Rm:20 0:0 L:0 100000101:100000101
	.inst 0xc2cf07c1 // BUILD-C.C-C Cd:1 Cn:30 001:001 opc:00 0:0 Cm:15 11000010110:11000010110
	.inst 0xc8a07e97 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:23 Rn:20 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:11
	.inst 0xd503375f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0111 11010101000000110011:11010101000000110011
	.inst 0xc2c210e0
	.zero 980
	.inst 0x00010001
	.inst 0x00200400
	.zero 1047544
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e0f // ldr c15, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085103d
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f0 // ldr c16, [c7, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826010f0 // ldr c16, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400207 // ldr c7, [x16, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401207 // ldr c7, [x16, #4]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401607 // ldr c7, [x16, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401a07 // ldr c7, [x16, #6]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401e07 // ldr c7, [x16, #7]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402207 // ldr c7, [x16, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001840
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
	ldr x0, =0x00400400
	ldr x1, =check_data3
	ldr x2, =0x00400408
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401c00
	ldr x1, =check_data4
	ldr x2, =0x00401c01
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
