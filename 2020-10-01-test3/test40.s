.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xb2, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x41, 0xf0, 0xc5, 0xc2, 0x68, 0x68, 0x82, 0xeb, 0x02, 0xb4, 0x5b, 0xa2, 0x41, 0x77, 0x1a, 0x82
	.byte 0x10, 0x24, 0x0b, 0xfc, 0x0e, 0x8f, 0xba, 0x79, 0xc0, 0xef, 0x52, 0x82, 0x6d, 0x02, 0x50, 0xf8
	.byte 0xf7, 0x8f, 0x25, 0x28, 0x2e, 0x53, 0xc1, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0100000004900050000000000001c50
	/* C2 */
	.octa 0x40000003fbf80
	/* C3 */
	.octa 0x0
	/* C19 */
	.octa 0x800000000000000000000000000011d0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x800000007004c002000000000046c500
	/* C30 */
	.octa 0x820
final_cap_values:
	/* C0 */
	.octa 0xd01000000049000500000000000018b2
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0xffffffffff000000
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x800000000000000000000000000011d0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x800000007004c002000000000046c500
	/* C30 */
	.octa 0x820
initial_csp_value:
	.octa 0x400000005804000100000000000014e8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000000180060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000807089700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5f041 // CVTPZ-C.R-C Cd:1 Rn:2 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xeb826868 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:8 Rn:3 imm6:011010 Rm:2 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xa25bb402 // LDR-C.RIAW-C Ct:2 Rn:0 01:01 imm9:110111011 0:0 opc:01 10100010:10100010
	.inst 0x821a7741 // LDR-C.I-C Ct:1 imm17:01101001110111010 1000001000:1000001000
	.inst 0xfc0b2410 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:16 Rn:0 01:01 imm9:010110010 0:0 opc:00 111100:111100 size:11
	.inst 0x79ba8f0e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:24 imm12:111010100011 opc:10 111001:111001 size:01
	.inst 0x8252efc0 // ASTR-R.RI-64 Rt:0 Rn:30 op:11 imm9:100101110 L:0 1000001001:1000001001
	.inst 0xf850026d // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:13 Rn:19 00:00 imm9:100000000 0:0 opc:01 111000:111000 size:11
	.inst 0x28258ff7 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:23 Rn:31 Rt2:00011 imm7:1001011 L:0 1010000:1010000 opc:00
	.inst 0xc2c1532e // CFHI-R.C-C Rd:14 Cn:25 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2401578 // ldr c24, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x8
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320b // ldr c11, [c16, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260120b // ldr c11, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x16, #0xf
	and x11, x11, x16
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400170 // ldr c16, [x11, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402570 // ldr c16, [x11, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x16, v16.d[0]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v16.d[1]
	cmp x11, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010d8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001190
	ldr x1, =check_data1
	ldr x2, =0x00001198
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001414
	ldr x1, =check_data2
	ldr x2, =0x0000141c
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
	ldr x0, =0x00001c50
	ldr x1, =check_data4
	ldr x2, =0x00001c60
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
	ldr x0, =0x0046e246
	ldr x1, =check_data6
	ldr x2, =0x0046e248
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004d3ba0
	ldr x1, =check_data7
	ldr x2, =0x004d3bb0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
