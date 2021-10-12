.section data0, #alloc, #write
	.byte 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1104
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 2960
.data
check_data0:
	.byte 0xfe
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x01, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x99, 0xf6, 0x78, 0x82, 0xfd, 0x7b, 0x63, 0x82, 0x3d, 0x4c, 0x1e, 0x79, 0x09, 0xf4, 0x78, 0xe2
	.byte 0x4f, 0x33, 0xe5, 0xc2, 0x01, 0x18, 0xe1, 0xc2, 0x3f, 0x30, 0xc7, 0xc2, 0x1f, 0x11, 0x7d, 0x38
	.byte 0x00, 0xac, 0x1b, 0xd2, 0x7d, 0x58, 0xfd, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x60242009000000000000107d
	/* C1 */
	.octa 0x40000000000100050000000000000882
	/* C3 */
	.octa 0x400100000000000000000001
	/* C8 */
	.octa 0xc0000000400000020000000000001000
	/* C20 */
	.octa 0x1dff
	/* C26 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0xffe1ffe1ffe1ef9c
	/* C1 */
	.octa 0x602420090000000000000882
	/* C3 */
	.octa 0x400100000000000000000001
	/* C8 */
	.octa 0xc0000000400000020000000000001000
	/* C15 */
	.octa 0x3fff800000002900000000000000
	/* C20 */
	.octa 0x1dff
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x400100000000000000000001
initial_SP_EL3_value:
	.octa 0x1390
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8278f699 // ALDRB-R.RI-B Rt:25 Rn:20 op:01 imm9:110001111 L:1 1000001001:1000001001
	.inst 0x82637bfd // ALDR-R.RI-32 Rt:29 Rn:31 op:10 imm9:000110111 L:1 1000001001:1000001001
	.inst 0x791e4c3d // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:1 imm12:011110010011 opc:00 111001:111001 size:01
	.inst 0xe278f409 // ALDUR-V.RI-H Rt:9 Rn:0 op2:01 imm9:110001111 V:1 op1:01 11100010:11100010
	.inst 0xc2e5334f // EORFLGS-C.CI-C Cd:15 Cn:26 0:0 10:10 imm8:00101001 11000010111:11000010111
	.inst 0xc2e11801 // CVT-C.CR-C Cd:1 Cn:0 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c7303f // RRMASK-R.R-C Rd:31 Rn:1 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x387d111f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:001 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xd21bac00 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:0 imms:101011 immr:011011 N:0 100100:100100 opc:10 sf:1
	.inst 0xc2fd587d // CVTZ-C.CR-C Cd:29 Cn:3 0110:0110 1:1 0:0 Rm:29 11000010111:11000010111
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
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
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603250 // ldr c16, [c18, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601250 // ldr c16, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc2400212 // ldr c18, [x16, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400612 // ldr c18, [x16, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a12 // ldr c18, [x16, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2401a12 // ldr c18, [x16, #6]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2401e12 // ldr c18, [x16, #7]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2402212 // ldr c18, [x16, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x18, v9.d[0]
	cmp x16, x18
	b.ne comparison_fail
	ldr x16, =0x0
	mov x18, v9.d[1]
	cmp x16, x18
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
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000146c
	ldr x1, =check_data2
	ldr x2, =0x00001470
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017a8
	ldr x1, =check_data3
	ldr x2, =0x000017aa
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f8e
	ldr x1, =check_data4
	ldr x2, =0x00001f8f
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
