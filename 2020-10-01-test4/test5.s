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
	.byte 0xc0, 0x18, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x1e, 0x7e, 0x4c, 0xa2, 0x41, 0x31, 0xc4, 0x6a, 0x59, 0x03, 0x00, 0x3a, 0x1e, 0xe8, 0xa2, 0x78
	.byte 0x20, 0x02, 0x5f, 0xd6
.data
check_data4:
	.byte 0xe1, 0x8b, 0xbe, 0x9b, 0x02, 0x10, 0xc0, 0x5a, 0x21, 0xe8, 0x5c, 0x82, 0xc3, 0x08, 0xc0, 0xda
	.byte 0xfe, 0x3f, 0x00, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000000073c
	/* C2 */
	.octa 0x18c0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x80000000000100050000000000001070
	/* C17 */
	.octa 0x400018
final_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000000073c
	/* C1 */
	.octa 0x18c0
	/* C2 */
	.octa 0x15
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x80000000000100050000000000001ce0
	/* C17 */
	.octa 0x400018
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1ff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fee1ff00000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa24c7e1e // LDR-C.RIBW-C Ct:30 Rn:16 11:11 imm9:011000111 0:0 opc:01 10100010:10100010
	.inst 0x6ac43141 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:10 imm6:001100 Rm:4 N:0 shift:11 01010:01010 opc:11 sf:0
	.inst 0x3a000359 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:25 Rn:26 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:0
	.inst 0x78a2e81e // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:0 10:10 S:0 option:111 Rm:2 1:1 opc:10 111000:111000 size:01
	.inst 0xd65f0220 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:17 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x9bbe8be1 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:31 Ra:2 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x5ac01002 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:2 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x825ce821 // ASTR-R.RI-32 Rt:1 Rn:1 op:10 imm9:111001110 L:0 1000001001:1000001001
	.inst 0xdac008c3 // rev:aarch64/instrs/integer/arithmetic/rev Rd:3 Rn:6 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe2003ffe // ALDURSB-R.RI-32 Rt:30 Rn:31 op2:11 imm9:000000011 V:0 op1:00 11100010:11100010
	.inst 0xc2c212a0
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_csp_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085003a
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032af // ldr c15, [c21, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x826012af // ldr c15, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f5 // ldr c21, [x15, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005f5 // ldr c21, [x15, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401df5 // ldr c21, [x15, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ce0
	ldr x1, =check_data0
	ldr x2, =0x00001cf0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff3
	ldr x1, =check_data1
	ldr x2, =0x00001ff4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400018
	ldr x1, =check_data4
	ldr x2, =0x00400030
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
