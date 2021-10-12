.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe2, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x0c, 0xfc, 0x9f, 0x08, 0x80, 0x00, 0x5f, 0xd6
.data
check_data5:
	.byte 0x61, 0x00, 0x04, 0x12, 0x09, 0x30, 0x4f, 0x7a, 0x00, 0x20, 0x25, 0x29, 0x57, 0x24, 0xac, 0xe2
	.byte 0x71, 0xd1, 0xc1, 0xc2, 0x1c, 0x10, 0xc1, 0xc2, 0x71, 0xcf, 0x71, 0x29, 0x96, 0xea, 0x50, 0x7d
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x6002200100000000000010e2
	/* C2 */
	.octa 0x80000000000100050000000000407f36
	/* C4 */
	.octa 0x40000c
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x1786
	/* C27 */
	.octa 0x1ffa
final_cap_values:
	/* C0 */
	.octa 0x6002200100000000000010e2
	/* C2 */
	.octa 0x80000000000100050000000000407f36
	/* C4 */
	.octa 0x40000c
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1786
	/* C27 */
	.octa 0x1ffa
	/* C28 */
	.octa 0x2002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020140050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc0c // stlrb:aarch64/instrs/memory/ordered Rt:12 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xd65f0080 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:4 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x12040061 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:3 imms:000000 immr:000100 N:0 100100:100100 opc:00 sf:0
	.inst 0x7a4f3009 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1001 0:0 Rn:0 00:00 cond:0011 Rm:15 111010010:111010010 op:1 sf:0
	.inst 0x29252000 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:0 Rt2:01000 imm7:1001010 L:0 1010010:1010010 opc:00
	.inst 0xe2ac2457 // ALDUR-V.RI-S Rt:23 Rn:2 op2:01 imm9:011000010 V:1 op1:10 11100010:11100010
	.inst 0xc2c1d171 // CPY-C.C-C Cd:17 Cn:11 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c1101c // GCLIM-R.C-C Rd:28 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x2971cf71 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:27 Rt2:10011 imm7:1100011 L:1 1010010:1010010 opc:00
	.inst 0x7d50ea96 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:22 Rn:20 imm12:010000111010 opc:01 111101:111101 size:01
	.inst 0xc2c212c0
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba4 // ldr c4, [x29, #2]
	.inst 0xc2400fa8 // ldr c8, [x29, #3]
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc24017b4 // ldr c20, [x29, #5]
	.inst 0xc2401bbb // ldr c27, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0xc
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032dd // ldr c29, [c22, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826012dd // ldr c29, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b6 // ldr c22, [x29, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24007b6 // ldr c22, [x29, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400bb6 // ldr c22, [x29, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400fb6 // ldr c22, [x29, #3]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24013b6 // ldr c22, [x29, #4]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc24017b6 // ldr c22, [x29, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401bb6 // ldr c22, [x29, #6]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401fb6 // ldr c22, [x29, #7]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc24023b6 // ldr c22, [x29, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24027b6 // ldr c22, [x29, #9]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x22, v22.d[0]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v22.d[1]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v23.d[0]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v23.d[1]
	cmp x29, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e4
	ldr x1, =check_data1
	ldr x2, =0x000010e5
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f88
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040000c
	ldr x1, =check_data5
	ldr x2, =0x00400030
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407ff8
	ldr x1, =check_data6
	ldr x2, =0x00407ffc
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
