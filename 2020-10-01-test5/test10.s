.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x40, 0x00
.data
check_data4:
	.byte 0x3e, 0x84, 0x04, 0xe2, 0xc2, 0x51, 0xc2, 0xc2, 0x4d, 0xb0, 0x54, 0xd8, 0xbe, 0x10, 0x4e, 0x82
	.byte 0xde, 0xb3, 0xc0, 0xc2, 0x5f, 0xb0, 0xe0, 0xc2, 0x9f, 0x02, 0xe7, 0xe2, 0xc0, 0x2b, 0xc0, 0xc2
	.byte 0xfe, 0xef, 0x28, 0xfd, 0xa4, 0x03, 0xbc, 0xe2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000001007000f0000000000001000
	/* C2 */
	.octa 0x40000000000faffffffffffc008
	/* C5 */
	.octa 0x40000000000f000f0000000000000230
	/* C14 */
	.octa 0x200080000007c0e30000000000400008
	/* C20 */
	.octa 0x40000000600100720000000000001000
	/* C29 */
	.octa 0x40000000200000800000000000002000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000001007000f0000000000001000
	/* C2 */
	.octa 0x40000000000faffffffffffc008
	/* C5 */
	.octa 0x40000000000f000f0000000000000230
	/* C14 */
	.octa 0x200080000007c0e30000000000400008
	/* C20 */
	.octa 0x40000000600100720000000000001000
	/* C29 */
	.octa 0x40000000200000800000000000002000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000001007001700ffffffffffe021
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe204843e // ALDURB-R.RI-32 Rt:30 Rn:1 op2:01 imm9:001001000 V:0 op1:00 11100010:11100010
	.inst 0xc2c251c2 // RETS-C-C 00010:00010 Cn:14 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xd854b04d // prfm_lit:aarch64/instrs/memory/literal/general Rt:13 imm19:0101010010110000010 011000:011000 opc:11
	.inst 0x824e10be // ASTR-C.RI-C Ct:30 Rn:5 op:00 imm9:011100001 L:0 1000001001:1000001001
	.inst 0xc2c0b3de // GCSEAL-R.C-C Rd:30 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2e0b05f // EORFLGS-C.CI-C Cd:31 Cn:2 0:0 10:10 imm8:00000101 11000010111:11000010111
	.inst 0xe2e7029f // ASTUR-V.RI-D Rt:31 Rn:20 op2:00 imm9:001110000 V:1 op1:11 11100010:11100010
	.inst 0xc2c02bc0 // BICFLGS-C.CR-C Cd:0 Cn:30 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xfd28effe // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:31 imm12:101000111011 opc:00 111101:111101 size:11
	.inst 0xe2bc03a4 // ASTUR-V.RI-S Rt:4 Rn:29 op2:00 imm9:111000000 V:1 op1:10 11100010:11100010
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q4, =0x400000
	ldr q30, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e3 // ldr c3, [c7, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826010e3 // ldr c3, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401467 // ldr c7, [x3, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401867 // ldr c7, [x3, #6]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401c67 // ldr c7, [x3, #7]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x400000
	mov x7, v4.d[0]
	cmp x3, x7
	b.ne comparison_fail
	ldr x3, =0x0
	mov x7, v4.d[1]
	cmp x3, x7
	b.ne comparison_fail
	ldr x3, =0x0
	mov x7, v30.d[0]
	cmp x3, x7
	b.ne comparison_fail
	ldr x3, =0x0
	mov x7, v30.d[1]
	cmp x3, x7
	b.ne comparison_fail
	ldr x3, =0x0
	mov x7, v31.d[0]
	cmp x3, x7
	b.ne comparison_fail
	ldr x3, =0x0
	mov x7, v31.d[1]
	cmp x3, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x000011f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fc4
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
