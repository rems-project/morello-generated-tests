.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.byte 0x40, 0x54, 0x09, 0xa2, 0x04, 0x80, 0x74, 0xb2, 0x01, 0x34, 0x6d, 0x2d, 0x6c, 0xfd, 0x3f, 0x42
	.byte 0xc2, 0xbf, 0xdb, 0x78, 0x20, 0x00, 0x3f, 0xd6
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xac, 0xce, 0x50, 0x69, 0xd7, 0xe3, 0x92, 0x1a, 0x20, 0x5c, 0x27, 0x82, 0x9f, 0x91, 0xc1, 0xc2
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000001800
	/* C1 */
	.octa 0x4d0000
	/* C2 */
	.octa 0x4c000000000100070000000000001800
	/* C11 */
	.octa 0x20
	/* C12 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000410000220000000000400000
	/* C30 */
	.octa 0x800000000041c00500000000004ad8c1
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4d0000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1ffffffff800
	/* C11 */
	.octa 0x20
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000410000220000000000400000
	/* C23 */
	.octa 0x400019
	/* C30 */
	.octa 0xb0008000800100060000000000400019
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005281100000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2095440 // STR-C.RIAW-C Ct:0 Rn:2 01:01 imm9:010010101 0:0 opc:00 10100010:10100010
	.inst 0xb2748004 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:4 Rn:0 imms:100000 immr:110100 N:1 100100:100100 opc:01 sf:1
	.inst 0x2d6d3401 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:0 Rt2:01101 imm7:1011010 L:1 1011010:1011010 opc:00
	.inst 0x423ffd6c // ASTLR-R.R-32 Rt:12 Rn:11 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x78dbbfc2 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:30 11:11 imm9:110111011 0:0 opc:11 111000:111000 size:01
	.inst 0xd63f0020 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 851944
	.inst 0x6950ceac // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:12 Rn:21 Rt2:10011 imm7:0100001 L:1 1010010:1010010 opc:01
	.inst 0x1a92e3d7 // csel:aarch64/instrs/integer/conditional/select Rd:23 Rn:30 o2:0 0:0 cond:1110 Rm:18 011010100:011010100 op:0 sf:0
	.inst 0x82275c20 // LDR-C.I-C Ct:0 imm17:10011101011100001 1000001000:1000001000
	.inst 0xc2c1919f // CLRTAG-C.C-C Cd:31 Cn:12 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c21360
	.zero 196588
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
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc24011ac // ldr c12, [x13, #4]
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x84
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336d // ldr c13, [c27, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260136d // ldr c13, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bb // ldr c27, [x13, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24005bb // ldr c27, [x13, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24009bb // ldr c27, [x13, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400dbb // ldr c27, [x13, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc24011bb // ldr c27, [x13, #4]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc24019bb // ldr c27, [x13, #6]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2401dbb // ldr c27, [x13, #7]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc24021bb // ldr c27, [x13, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc24025bb // ldr c27, [x13, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x27, v1.d[0]
	cmp x13, x27
	b.ne comparison_fail
	ldr x13, =0x0
	mov x27, v1.d[1]
	cmp x13, x27
	b.ne comparison_fail
	ldr x13, =0x0
	mov x27, v13.d[0]
	cmp x13, x27
	b.ne comparison_fail
	ldr x13, =0x0
	mov x27, v13.d[1]
	cmp x13, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001768
	ldr x1, =check_data1
	ldr x2, =0x00001770
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400084
	ldr x1, =check_data4
	ldr x2, =0x0040008c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040ae10
	ldr x1, =check_data5
	ldr x2, =0x0040ae20
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ad87c
	ldr x1, =check_data6
	ldr x2, =0x004ad87e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004d0000
	ldr x1, =check_data7
	ldr x2, =0x004d0014
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
