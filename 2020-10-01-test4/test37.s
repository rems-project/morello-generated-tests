.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x12, 0x01
.data
check_data1:
	.byte 0x55, 0x06, 0xc0, 0xda, 0xdf, 0x02, 0xa1, 0xea, 0x42, 0xa0, 0xd5, 0xc2, 0x5e, 0xd6, 0x8e, 0x82
	.byte 0x32, 0xe4, 0x9d, 0xe2, 0xe0, 0xf3, 0xc0, 0xc2, 0x4e, 0x0b, 0xc2, 0x1a, 0x21, 0x68, 0x2f, 0x78
	.byte 0x20, 0x50, 0x75, 0x92, 0x5d, 0x7b, 0xd8, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000400112
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x4ffffd
	/* C15 */
	.octa 0xffffffffffc002e2
	/* C18 */
	.octa 0x800000000000c0000000000000000001
	/* C22 */
	.octa 0x112
	/* C26 */
	.octa 0x700060000000000000000
final_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x80000000000100050000000000400112
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0xffffffffffc002e2
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x100
	/* C22 */
	.octa 0x112
	/* C26 */
	.octa 0x700060000000000000000
	/* C29 */
	.octa 0x430000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100600070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000104700490000000000002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00655 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:18 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xeaa102df // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:22 imm6:000000 Rm:1 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xc2d5a042 // CLRPERM-C.CR-C Cd:2 Cn:2 000:000 1:1 10:10 Rm:21 11000010110:11000010110
	.inst 0x828ed65e // ALDRSB-R.RRB-64 Rt:30 Rn:18 opc:01 S:1 option:110 Rm:14 0:0 L:0 100000101:100000101
	.inst 0xe29de432 // ALDUR-R.RI-32 Rt:18 Rn:1 op2:01 imm9:111011110 V:0 op1:10 11100010:11100010
	.inst 0xc2c0f3e0 // GCTYPE-R.C-C Rd:0 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x1ac20b4e // udiv:aarch64/instrs/integer/arithmetic/div Rd:14 Rn:26 o1:0 00001:00001 Rm:2 0011010110:0011010110 sf:0
	.inst 0x782f6821 // strh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:1 10:10 S:0 option:011 Rm:15 1:1 opc:00 111000:111000 size:01
	.inst 0x92755020 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:1 imms:010100 immr:110101 N:1 100100:100100 opc:00 sf:1
	.inst 0xc2d87b5d // SCBNDS-C.CI-S Cd:29 Cn:26 1110:1110 S:1 imm6:110000 11000010110:11000010110
	.inst 0xc2c21320
	.zero 1048532
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc24011b2 // ldr c18, [x13, #4]
	.inst 0xc24015b6 // ldr c22, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332d // ldr c13, [c25, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x25, #0xf
	and x13, x13, x25
	cmp x13, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015f4
	ldr x1, =check_data0
	ldr x2, =0x000015f6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000f0
	ldr x1, =check_data2
	ldr x2, =0x004000f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
