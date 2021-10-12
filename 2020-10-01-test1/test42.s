.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x03, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1f, 0x58, 0x56, 0xb8, 0x20, 0x5d, 0xdb, 0xac, 0x5b, 0x54, 0xdf, 0x82, 0x82, 0x72, 0xc0, 0xc2
	.byte 0x1a, 0x24, 0xda, 0x9a, 0xe0, 0xdf, 0x06, 0xa2, 0x3d, 0x70, 0xc6, 0xc2, 0x01, 0xcc, 0x8d, 0x38
	.byte 0x24, 0xf2, 0xc0, 0xc2, 0x04, 0xc8, 0x3e, 0x38, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000001803
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8000000040008002000000000040bfff
	/* C9 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x700060000000000000000
	/* C30 */
	.octa 0xfffff81d
final_cap_values:
	/* C0 */
	.octa 0x18df
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x1360
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x700060000000000000000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xfffff81d
initial_csp_value:
	.octa 0x930
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000459000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000003d0f001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb856581f // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:101100101 0:0 opc:01 111000:111000 size:10
	.inst 0xacdb5d20 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:9 Rt2:10111 imm7:0110110 L:1 1011001:1011001 opc:10
	.inst 0x82df545b // ALDRSB-R.RRB-32 Rt:27 Rn:2 opc:01 S:1 option:010 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xc2c07282 // GCOFF-R.C-C Rd:2 Cn:20 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9ada241a // lsrv:aarch64/instrs/integer/shift/variable Rd:26 Rn:0 op2:01 0010:0010 Rm:26 0011010110:0011010110 sf:1
	.inst 0xa206dfe0 // STR-C.RIBW-C Ct:0 Rn:31 11:11 imm9:001101101 0:0 opc:00 10100010:10100010
	.inst 0xc2c6703d // CLRPERM-C.CI-C Cd:29 Cn:1 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x388dcc01 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:011011100 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c0f224 // GCTYPE-R.C-C Rd:4 Cn:17 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x383ec804 // strb_reg:aarch64/instrs/memory/single/general/register Rt:4 Rn:0 10:10 S:0 option:110 Rm:30 1:1 opc:00 111000:111000 size:00
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
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
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
	ldr x11, =0x4
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
	/* No processor flags to check */
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
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402570 // ldr c16, [x11, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x16, v0.d[0]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v0.d[1]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v23.d[0]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v23.d[1]
	cmp x11, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x000010fd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001768
	ldr x1, =check_data2
	ldr x2, =0x0000176c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018df
	ldr x1, =check_data3
	ldr x2, =0x000018e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040bfff
	ldr x1, =check_data5
	ldr x2, =0x0040c000
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
