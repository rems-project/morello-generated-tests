.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x0f, 0x00, 0x00
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc0, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x2a, 0xdf, 0x48, 0x82, 0xf2, 0x73, 0xc0, 0xc2, 0x01, 0x8c, 0x49, 0x78, 0x1b, 0x7c, 0x5e, 0x9b
	.byte 0xf2, 0xf3, 0x19, 0x28, 0xc7, 0x7f, 0xdf, 0x08, 0xfe, 0x0f, 0xc3, 0x9a, 0x40, 0x59, 0x44, 0xa2
	.byte 0x5f, 0x38, 0x03, 0xd5, 0xcd, 0xfe, 0x3d, 0x9b, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000400000
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x80100000400000010000000000000bc0
	/* C25 */
	.octa 0x1078
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000400100040000000000001034
final_cap_values:
	/* C0 */
	.octa 0xf42000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x80100000400000010000000000000bc0
	/* C18 */
	.octa 0xf42
	/* C25 */
	.octa 0x1078
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000004001000e0000000000000f50
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000000c0000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8248df2a // ASTR-R.RI-64 Rt:10 Rn:25 op:11 imm9:010001101 L:0 1000001001:1000001001
	.inst 0xc2c073f2 // GCOFF-R.C-C Rd:18 Cn:31 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x78498c01 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:010011000 0:0 opc:01 111000:111000 size:01
	.inst 0x9b5e7c1b // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:27 Rn:0 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0x2819f3f2 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:18 Rn:31 Rt2:11100 imm7:0110011 L:0 1010000:1010000 opc:00
	.inst 0x08df7fc7 // ldlarb:aarch64/instrs/memory/ordered Rt:7 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9ac30ffe // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:31 o1:1 00001:00001 Rm:3 0011010110:0011010110 sf:1
	.inst 0xa2445940 // LDTR-C.RIB-C Ct:0 Rn:10 10:10 imm9:001000101 0:0 opc:01 10100010:10100010
	.inst 0xd503385f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1000 11010101000000110011:11010101000000110011
	.inst 0x9b3dfecd // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:13 Rn:22 Ra:31 o0:1 Rm:29 01:01 U:0 10011011:10011011
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2400dd9 // ldr c25, [x14, #3]
	.inst 0xc24011dc // ldr c28, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085003a
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330e // ldr c14, [c24, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260130e // ldr c14, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d8 // ldr c24, [x14, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005d8 // ldr c24, [x14, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24009d8 // ldr c24, [x14, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc24015d8 // ldr c24, [x14, #5]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc24021d8 // ldr c24, [x14, #8]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc24025d8 // ldr c24, [x14, #9]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001034
	ldr x1, =check_data1
	ldr x2, =0x00001035
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014e0
	ldr x1, =check_data2
	ldr x2, =0x000014e8
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
	ldr x0, =0x00400098
	ldr x1, =check_data4
	ldr x2, =0x0040009a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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

	.balign 128
vector_table:
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
