.section data0, #alloc, #write
	.zero 3488
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x50, 0x00, 0x00
	.zero 592
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x50, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x20, 0xf8, 0xcc, 0x38, 0xbf, 0x3f, 0x9c, 0xb8, 0xe2, 0x87, 0x08, 0x6c, 0x00, 0x50, 0x82, 0x1a
	.byte 0x20, 0x50, 0xe0, 0xe2, 0x41, 0x32, 0xc2, 0xc2, 0xc0, 0xa2, 0x65, 0x82, 0xa1, 0x0d, 0xc2, 0x9a
	.byte 0xc3, 0x93, 0xc0, 0xc2, 0xa0, 0x00, 0x1f, 0xd6
.data
check_data6:
	.byte 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000600000010000000000001db3
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x401000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1800
	/* C29 */
	.octa 0x8000000000070007000000000000103d
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x5001000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1
	/* C5 */
	.octa 0x401000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1800
	/* C29 */
	.octa 0x80000000000700070000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000711900100000000000000f80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000504400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd000000060070da700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001da0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38ccf820 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:011001111 0:0 opc:11 111000:111000 size:00
	.inst 0xb89c3fbf // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:29 11:11 imm9:111000011 0:0 opc:10 111000:111000 size:10
	.inst 0x6c0887e2 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:2 Rn:31 Rt2:00001 imm7:0010001 L:0 1011000:1011000 opc:01
	.inst 0x1a825000 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:0 o2:0 0:0 cond:0101 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0xe2e05020 // ASTUR-V.RI-D Rt:0 Rn:1 op2:00 imm9:000000101 V:1 op1:11 11100010:11100010
	.inst 0xc2c23241 // CHKTGD-C-C 00001:00001 Cn:18 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x8265a2c0 // ALDR-C.RI-C Ct:0 Rn:22 op:00 imm9:001011010 L:1 1000001001:1000001001
	.inst 0x9ac20da1 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:13 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c093c3 // GCTAG-R.C-C Rd:3 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xd61f00a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 4056
	.inst 0xc2c21180
	.zero 1044476
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
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc24011d6 // ldr c22, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q0, =0x90000000000
	ldr q1, =0x200000000000000
	ldr q2, =0x1000000000000
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
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318e // ldr c14, [c12, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260118e // ldr c14, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x12, #0xf
	and x14, x14, x12
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cc // ldr c12, [x14, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24005cc // ldr c12, [x14, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24009cc // ldr c12, [x14, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400dcc // ldr c12, [x14, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc24015cc // ldr c12, [x14, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24019cc // ldr c12, [x14, #6]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2401dcc // ldr c12, [x14, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24021cc // ldr c12, [x14, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x90000000000
	mov x12, v0.d[0]
	cmp x14, x12
	b.ne comparison_fail
	ldr x14, =0x0
	mov x12, v0.d[1]
	cmp x14, x12
	b.ne comparison_fail
	ldr x14, =0x200000000000000
	mov x12, v1.d[0]
	cmp x14, x12
	b.ne comparison_fail
	ldr x14, =0x0
	mov x12, v1.d[1]
	cmp x14, x12
	b.ne comparison_fail
	ldr x14, =0x1000000000000
	mov x12, v2.d[0]
	cmp x14, x12
	b.ne comparison_fail
	ldr x14, =0x0
	mov x12, v2.d[1]
	cmp x14, x12
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
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001da0
	ldr x1, =check_data2
	ldr x2, =0x00001db0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001db8
	ldr x1, =check_data3
	ldr x2, =0x00001dc0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e82
	ldr x1, =check_data4
	ldr x2, =0x00001e83
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
