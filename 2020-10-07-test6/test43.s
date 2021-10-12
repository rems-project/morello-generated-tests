.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xc0, 0x03, 0x1f, 0xd6, 0x9a, 0x93, 0xc0, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x8a, 0x4a, 0x57, 0xba, 0x2a, 0x70, 0xc3, 0xc2, 0x75, 0x8f, 0xc7, 0xa9, 0x9e, 0xb8, 0xbe, 0x2d
	.byte 0xdf, 0x4c, 0xa1, 0x82, 0xc4, 0x93, 0xc1, 0xc2, 0x81, 0x91, 0xc0, 0xc2, 0x90, 0x72, 0x25, 0x37
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000
	/* C4 */
	.octa 0x40000000080100070000000000001618
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x10
	/* C27 */
	.octa 0x80000000580408060000000000000fa0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x5198
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x5198
	/* C6 */
	.octa 0x1000
	/* C10 */
	.octa 0x1800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x10
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C27 */
	.octa 0x80000000580408060000000000001018
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x5198
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800011bf00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000000c0000000000002000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd61f03c0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xc2c0939a // GCTAG-R.C-C Rd:26 Cn:28 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c21320
	.zero 20876
	.inst 0xba574a8a // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:20 10:10 cond:0100 imm5:10111 111010010:111010010 op:0 sf:1
	.inst 0xc2c3702a // SEAL-C.CI-C Cd:10 Cn:1 100:100 form:11 11000010110000110:11000010110000110
	.inst 0xa9c78f75 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:21 Rn:27 Rt2:00011 imm7:0001111 L:1 1010011:1010011 opc:10
	.inst 0x2dbeb89e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:4 Rt2:01110 imm7:1111101 L:0 1011011:1011011 opc:00
	.inst 0x82a14cdf // ASTR-V.RRB-S Rt:31 Rn:6 opc:11 S:0 option:010 Rm:1 1:1 L:0 100000101:100000101
	.inst 0xc2c193c4 // CLRTAG-C.C-C Cd:4 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c09181 // GCTAG-R.C-C Rd:1 Cn:12 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x37257290 // tbnz:aarch64/instrs/branch/conditional/test Rt:16 imm14:10101110010100 b40:00100 op:1 011011:011011 b5:0
	.zero 1027656
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
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400dac // ldr c12, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q14, =0x0
	ldr q30, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0xc
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332d // ldr c13, [c25, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x25, #0xf
	and x13, x13, x25
	cmp x13, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402db9 // ldr c25, [x13, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x25, v14.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v14.d[1]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v30.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v30.d[1]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v31.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v31.d[1]
	cmp x13, x25
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000160c
	ldr x1, =check_data2
	ldr x2, =0x00001614
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
	ldr x0, =0x00405198
	ldr x1, =check_data4
	ldr x2, =0x004051b8
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
