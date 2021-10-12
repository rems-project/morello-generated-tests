.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2a
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0xc6, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x60, 0x0d, 0xfe, 0xf2, 0x00, 0x70, 0xc6, 0xc2, 0xe0, 0xaf, 0xc1, 0xc2, 0xfe, 0xb7, 0xc0, 0x38
	.byte 0x8e, 0x27, 0xce, 0x9a, 0x40, 0x48, 0x96, 0xb8, 0xc2, 0x0e, 0x8d, 0x4a, 0x04, 0x3d, 0x16, 0x62
	.byte 0x23, 0x2c, 0x1c, 0x38, 0x74, 0xea, 0x3f, 0xfc, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1800
	/* C2 */
	.octa 0x8a0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x380000000000000000000000
	/* C8 */
	.octa 0x700
	/* C15 */
	.octa 0x2a000000000000000000000010000000
	/* C19 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x17c2
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x380000000000000000000000
	/* C8 */
	.octa 0x700
	/* C15 */
	.octa 0x2a000000000000000000000010000000
	/* C19 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xe00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807040600ffffffffffc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf2fe0d60 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1111000001101011 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc2c67000 // CLRPERM-C.CI-C Cd:0 Cn:0 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0xc2c1afe0 // CSEL-C.CI-C Cd:0 Cn:31 11:11 cond:1010 Cm:1 11000010110:11000010110
	.inst 0x38c0b7fe // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:000001011 0:0 opc:11 111000:111000 size:00
	.inst 0x9ace278e // lsrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:28 op2:01 0010:0010 Rm:14 0011010110:0011010110 sf:1
	.inst 0xb8964840 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:2 10:10 imm9:101100100 0:0 opc:10 111000:111000 size:10
	.inst 0x4a8d0ec2 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:22 imm6:000011 Rm:13 N:0 shift:10 01010:01010 opc:10 sf:0
	.inst 0x62163d04 // STNP-C.RIB-C Ct:4 Rn:8 Ct2:01111 imm7:0101100 L:0 011000100:011000100
	.inst 0x381c2c23 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:1 11:11 imm9:111000010 0:0 opc:00 111000:111000 size:00
	.inst 0xfc3fea74 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:20 Rn:19 10:10 S:0 option:111 Rm:31 1:1 opc:00 111100:111100 size:11
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e04 // ldr c4, [x16, #3]
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q20, =0xc6000000
	/* Set up flags and system registers */
	mov x16, #0x80000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085003a
	msr SCTLR_EL3, x16
	ldr x16, =0x4
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
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x18, #0x9
	and x16, x16, x18
	cmp x16, #0x8
	b.ne comparison_fail
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
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401a12 // ldr c18, [x16, #6]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401e12 // ldr c18, [x16, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0xc6000000
	mov x18, v20.d[0]
	cmp x16, x18
	b.ne comparison_fail
	ldr x16, =0x0
	mov x18, v20.d[1]
	cmp x16, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011c0
	ldr x1, =check_data1
	ldr x2, =0x000011e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001600
	ldr x1, =check_data2
	ldr x2, =0x00001601
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc2
	ldr x1, =check_data4
	ldr x2, =0x00001fc3
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
