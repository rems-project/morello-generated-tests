.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xf6, 0x51, 0xc0, 0xc2, 0xad, 0xfe, 0xe4, 0xd2, 0x3f, 0x30, 0xc5, 0xc2, 0xd6, 0x11, 0xc7, 0xc2
	.byte 0xff, 0x43, 0xc2, 0xc2, 0x1d, 0x48, 0xc1, 0xc2, 0xc5, 0x0b, 0xc0, 0xda, 0x20, 0x20, 0x86, 0xe2
	.byte 0x4c, 0xc8, 0x7a, 0x82, 0x16, 0x32, 0xc0, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x1000000000000040000000000001e06
	/* C2 */
	.octa 0x1148
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000000000ffffffffffe001
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x1000000000000040000000000001e06
	/* C2 */
	.octa 0x1148
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x27f5000000000000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000000000ffffffffffe001
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1005c00c0000000050000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c051f6 // GCVALUE-R.C-C Rd:22 Cn:15 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xd2e4fead // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:13 imm16:0010011111110101 hw:11 100101:100101 opc:10 sf:1
	.inst 0xc2c5303f // CVTP-R.C-C Rd:31 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c711d6 // RRLEN-R.R-C Rd:22 Rn:14 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2c243ff // SCVALUE-C.CR-C Cd:31 Cn:31 000:000 opc:10 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c1481d // UNSEAL-C.CC-C Cd:29 Cn:0 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0xdac00bc5 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:5 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe2862020 // ASTUR-R.RI-32 Rt:0 Rn:1 op2:00 imm9:001100010 V:0 op1:10 11100010:11100010
	.inst 0x827ac84c // ALDR-R.RI-32 Rt:12 Rn:2 op:10 imm9:110101100 L:1 1000001001:1000001001
	.inst 0xc2c03216 // GCLEN-R.C-C Rd:22 Cn:16 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2401150 // ldr c16, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030ca // ldr c10, [c6, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010ca // ldr c10, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x6, #0xf
	and x10, x10, x6
	cmp x10, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400146 // ldr c6, [x10, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401146 // ldr c6, [x10, #4]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401546 // ldr c6, [x10, #5]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401946 // ldr c6, [x10, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401d46 // ldr c6, [x10, #7]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2402146 // ldr c6, [x10, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017f8
	ldr x1, =check_data0
	ldr x2, =0x000017fc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e68
	ldr x1, =check_data1
	ldr x2, =0x00001e6c
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
