.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x1f, 0xb4, 0x5f, 0xb8, 0x2d, 0xac, 0xcb, 0x78, 0xee, 0xcb, 0x0a, 0xe2, 0x1e, 0xd0, 0xc5, 0xc2
	.byte 0xfe, 0x75, 0x62, 0x82, 0x9f, 0xd1, 0xc1, 0xc2, 0x5e, 0xb1, 0x00, 0xa2, 0xd3, 0x31, 0xc7, 0xc2
	.byte 0x00, 0xb2, 0xc5, 0xc2, 0x0a, 0x0a, 0x20, 0x4b, 0x20, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004dd6f8
	/* C1 */
	.octa 0x80000000000100070000000000402ffe
	/* C10 */
	.octa 0x40000000000100050000000000001fd5
	/* C15 */
	.octa 0x1fd7
	/* C16 */
	.octa 0x10400000
final_cap_values:
	/* C0 */
	.octa 0x20008000000100070000000010400000
	/* C1 */
	.octa 0x800000000001000700000000004030b8
	/* C10 */
	.octa 0x10400000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1fd7
	/* C16 */
	.octa 0x10400000
	/* C19 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4ffa52
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000180050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb85fb41f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:111111011 0:0 opc:01 111000:111000 size:10
	.inst 0x78cbac2d // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:1 11:11 imm9:010111010 0:0 opc:11 111000:111000 size:01
	.inst 0xe20acbee // ALDURSB-R.RI-64 Rt:14 Rn:31 op2:10 imm9:010101100 V:0 op1:00 11100010:11100010
	.inst 0xc2c5d01e // CVTDZ-C.R-C Cd:30 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x826275fe // ALDRB-R.RI-B Rt:30 Rn:15 op:01 imm9:000100111 L:1 1000001001:1000001001
	.inst 0xc2c1d19f // CPY-C.C-C Cd:31 Cn:12 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa200b15e // STUR-C.RI-C Ct:30 Rn:10 00:00 imm9:000001011 0:0 opc:00 10100010:10100010
	.inst 0xc2c731d3 // RRMASK-R.R-C Rd:19 Rn:14 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c5b200 // CVTP-C.R-C Cd:0 Rn:16 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x4b200a0a // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:10 Rn:16 imm3:010 option:000 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc2401310 // ldr c16, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x8
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603338 // ldr c24, [c25, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601338 // ldr c24, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400319 // ldr c25, [x24, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b19 // ldr c25, [x24, #2]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401f19 // ldr c25, [x24, #7]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2402319 // ldr c25, [x24, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x0, =0x004030b8
	ldr x1, =check_data3
	ldr x2, =0x004030ba
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004dd6f8
	ldr x1, =check_data4
	ldr x2, =0x004dd6fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffafe
	ldr x1, =check_data5
	ldr x2, =0x004ffaff
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
