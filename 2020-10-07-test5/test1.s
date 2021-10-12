.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0xc0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x5f, 0xd3, 0x6a, 0x31, 0x1e, 0x0c, 0x95, 0xe2, 0x3a, 0x6a, 0x08, 0xb4
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x5f, 0x7d, 0x5f, 0x42, 0x5e, 0x7c, 0x9f, 0x08, 0xc5, 0x53, 0x15, 0xc2, 0xd9, 0x7a, 0x5d, 0xb6
	.byte 0xf2, 0xb2, 0xc0, 0xc2, 0x84, 0x51, 0xc0, 0xc2, 0x1e, 0x7c, 0x7f, 0x42, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000538406920000000000001330
	/* C2 */
	.octa 0x1a10
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x90100000000000000000000000402000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x10000000ffffffffffffc000
final_cap_values:
	/* C0 */
	.octa 0xc0000000538406920000000000001330
	/* C2 */
	.octa 0x1a10
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x90100000000000000000000000402000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x480000004004000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x316ad35f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:26 imm12:101010110100 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xe2950c1e // ASTUR-C.RI-C Ct:30 Rn:0 op2:11 imm9:101010000 V:0 op1:10 11100010:11100010
	.inst 0xb4086a3a // cbz:aarch64/instrs/branch/conditional/compare Rt:26 imm19:0000100001101010001 op:0 011010:011010 sf:1
	.zero 68928
	.inst 0x425f7d5f // ALDAR-C.R-C Ct:31 Rn:10 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x089f7c5e // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc21553c5 // STR-C.RIB-C Ct:5 Rn:30 imm12:010101010100 L:0 110000100:110000100
	.inst 0xb65d7ad9 // tbz:aarch64/instrs/branch/conditional/test Rt:25 imm14:10101111010110 b40:01011 op:0 011011:011011 b5:1
	.inst 0xc2c0b2f2 // GCSEAL-R.C-C Rd:18 Cn:23 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c05184 // GCVALUE-R.C-C Rd:4 Cn:12 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x427f7c1e // ALDARB-R.R-B Rt:30 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c212c0
	.zero 979604
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
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cd // ldr c13, [c22, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012cd // ldr c13, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0xf
	and x13, x13, x22
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b6 // ldr c22, [x13, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005b6 // ldr c22, [x13, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc24009b6 // ldr c22, [x13, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400db6 // ldr c22, [x13, #3]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24015b6 // ldr c22, [x13, #5]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc24019b6 // ldr c22, [x13, #6]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401db6 // ldr c22, [x13, #7]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc24021b6 // ldr c22, [x13, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001280
	ldr x1, =check_data0
	ldr x2, =0x00001290
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001330
	ldr x1, =check_data1
	ldr x2, =0x00001331
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001540
	ldr x1, =check_data2
	ldr x2, =0x00001550
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a10
	ldr x1, =check_data3
	ldr x2, =0x00001a11
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x00402010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00410d4c
	ldr x1, =check_data6
	ldr x2, =0x00410d6c
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
