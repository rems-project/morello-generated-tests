.section data0, #alloc, #write
	.zero 2032
	.byte 0xe2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x00
.data
check_data0:
	.byte 0xe2
.data
check_data1:
	.byte 0xe2
.data
check_data2:
	.byte 0x20, 0xdc, 0x21, 0x02, 0x71, 0x62, 0x96, 0xf9, 0xc1, 0x57, 0x58, 0xe2, 0x41, 0xd4, 0x20, 0xe2
	.byte 0xe2, 0x7f, 0x7f, 0x42, 0x3f, 0x90, 0x2b, 0x02, 0xee, 0x2b, 0xca, 0x1a, 0x5f, 0x34, 0x03, 0xd5
	.byte 0x7a, 0xbb, 0x82, 0x8b, 0xfe, 0x69, 0xe6, 0x38, 0x40, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xe2, 0xe2
.data
check_data4:
	.byte 0xe2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc000200000fffffffffff801
	/* C2 */
	.octa 0x1ff1
	/* C6 */
	.octa 0x4ffffd
	/* C15 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0x43bc61
final_cap_values:
	/* C0 */
	.octa 0xc00020000100000000000078
	/* C1 */
	.octa 0xe2e2
	/* C2 */
	.octa 0xe2
	/* C6 */
	.octa 0x4ffffd
	/* C15 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0xffffffe2
initial_SP_EL3_value:
	.octa 0x17f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000604070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0221dc20 // ADD-C.CIS-C Cd:0 Cn:1 imm12:100001110111 sh:0 A:0 00000010:00000010
	.inst 0xf9966271 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:19 imm12:010110011000 opc:10 111001:111001 size:11
	.inst 0xe25857c1 // ALDURH-R.RI-32 Rt:1 Rn:30 op2:01 imm9:110000101 V:0 op1:01 11100010:11100010
	.inst 0xe220d441 // ALDUR-V.RI-B Rt:1 Rn:2 op2:01 imm9:000001101 V:1 op1:00 11100010:11100010
	.inst 0x427f7fe2 // ALDARB-R.R-B Rt:2 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x022b903f // ADD-C.CIS-C Cd:31 Cn:1 imm12:101011100100 sh:0 A:0 00000010:00000010
	.inst 0x1aca2bee // asrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:31 op2:10 0010:0010 Rm:10 0011010110:0011010110 sf:0
	.inst 0xd503345f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0100 11010101000000110011:11010101000000110011
	.inst 0x8b82bb7a // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:26 Rn:27 imm6:101110 Rm:2 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0x38e669fe // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:15 10:10 S:0 option:011 Rm:6 1:1 opc:11 111000:111000 size:00
	.inst 0xc2c21240
	.zero 244664
	.inst 0xe2e20000
	.zero 803860
	.inst 0x00e20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010be // ldr c30, [x5, #4]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x3085003a
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603245 // ldr c5, [c18, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601245 // ldr c5, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b2 // ldr c18, [x5, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004b2 // ldr c18, [x5, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400cb2 // ldr c18, [x5, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0xe2
	mov x18, v1.d[0]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v1.d[1]
	cmp x5, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017f0
	ldr x1, =check_data0
	ldr x2, =0x000017f1
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x0043bbe6
	ldr x1, =check_data3
	ldr x2, =0x0043bbe8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
