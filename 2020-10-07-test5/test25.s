.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x40, 0x00, 0x3f, 0xd6, 0x60, 0x65, 0x00, 0xe2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x17, 0xc1, 0x13, 0xb9, 0xe1, 0x0b, 0xda, 0x9a, 0xdf, 0x5b, 0xd9, 0xc2, 0x34, 0xc8, 0xeb, 0xc2
	.byte 0x90, 0x3f, 0x4b, 0xfc, 0x02, 0x2c, 0x32, 0xe2, 0xfc, 0x25, 0x4f, 0xa2, 0xe0, 0x30, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20be
	/* C2 */
	.octa 0x400020
	/* C7 */
	.octa 0x200080008000c8200000000000400005
	/* C8 */
	.octa 0x40000000000100050000000000000800
	/* C11 */
	.octa 0x1000
	/* C15 */
	.octa 0x900000000001800600000000004fffe0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x800000000001000700000000004c100d
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400020
	/* C7 */
	.octa 0x200080008000c8200000000000400005
	/* C8 */
	.octa 0x40000000000100050000000000000800
	/* C11 */
	.octa 0x1000
	/* C15 */
	.octa 0x90000000000180060000000000500f00
	/* C20 */
	.octa 0x5e00000000000000
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000500100000000000000400041
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600100000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xe2006560 // ALDURB-R.RI-32 Rt:0 Rn:11 op2:01 imm9:000000110 V:0 op1:00 11100010:11100010
	.inst 0xc2c21260
	.zero 20
	.inst 0xb913c117 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:8 imm12:010011110000 opc:00 111001:111001 size:10
	.inst 0x9ada0be1 // udiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:31 o1:0 00001:00001 Rm:26 0011010110:0011010110 sf:1
	.inst 0xc2d95bdf // ALIGNU-C.CI-C Cd:31 Cn:30 0110:0110 U:1 imm6:110010 11000010110:11000010110
	.inst 0xc2ebc834 // ORRFLGS-C.CI-C Cd:20 Cn:1 0:0 01:01 imm8:01011110 11000010111:11000010111
	.inst 0xfc4b3f90 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:16 Rn:28 11:11 imm9:010110011 0:0 opc:01 111100:111100 size:11
	.inst 0xe2322c02 // ALDUR-V.RI-Q Rt:2 Rn:0 op2:11 imm9:100100010 V:1 op1:00 11100010:11100010
	.inst 0xa24f25fc // LDR-C.RIAW-C Ct:28 Rn:15 01:01 imm9:011110010 0:0 opc:01 10100010:10100010
	.inst 0xc2c230e0 // BLR-C-C 00000:00000 Cn:7 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1048512
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2400da8 // ldr c8, [x13, #3]
	.inst 0xc24011ab // ldr c11, [x13, #4]
	.inst 0xc24015af // ldr c15, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dba // ldr c26, [x13, #7]
	.inst 0xc24021bc // ldr c28, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326d // ldr c13, [c19, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260126d // ldr c13, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b3 // ldr c19, [x13, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005b3 // ldr c19, [x13, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24009b3 // ldr c19, [x13, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400db3 // ldr c19, [x13, #3]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc24019b3 // ldr c19, [x13, #6]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401db3 // ldr c19, [x13, #7]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc24021b3 // ldr c19, [x13, #8]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24025b3 // ldr c19, [x13, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc24029b3 // ldr c19, [x13, #10]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402db3 // ldr c19, [x13, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x19, v2.d[0]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v2.d[1]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v16.d[0]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v16.d[1]
	cmp x13, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001006
	ldr x1, =check_data0
	ldr x2, =0x00001007
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bc0
	ldr x1, =check_data1
	ldr x2, =0x00001bc4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400020
	ldr x1, =check_data4
	ldr x2, =0x00400040
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004c10c0
	ldr x1, =check_data5
	ldr x2, =0x004c10c8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
