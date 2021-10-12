.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x54, 0x74, 0x82, 0x82, 0x9e, 0xb0, 0x81, 0x1a, 0x9f, 0xd9, 0x3e, 0x78, 0xf5, 0x07, 0xc0, 0x5a
	.byte 0xd9, 0xfa, 0x95, 0xb5, 0x1e, 0x60, 0xc2, 0xc2, 0xc2, 0xcd, 0x3f, 0xe2, 0x8d, 0x52, 0xb5, 0xd8
	.byte 0xe8, 0xff, 0x3f, 0x42, 0xfa, 0x67, 0x26, 0xe2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000001007ffffffffff800
	/* C2 */
	.octa 0x200000
	/* C4 */
	.octa 0x800
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000500110020000000000000002
	/* C14 */
	.octa 0x4fffe4
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000001007ffffffffff800
	/* C2 */
	.octa 0x200000
	/* C4 */
	.octa 0x800
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000500110020000000000000002
	/* C14 */
	.octa 0x4fffe4
	/* C20 */
	.octa 0x54
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x400000010080000000200001
initial_csp_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000ffd00030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000600ffffffffc10001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82827454 // ALDRSB-R.RRB-64 Rt:20 Rn:2 opc:01 S:1 option:011 Rm:2 0:0 L:0 100000101:100000101
	.inst 0x1a81b09e // csel:aarch64/instrs/integer/conditional/select Rd:30 Rn:4 o2:0 0:0 cond:1011 Rm:1 011010100:011010100 op:0 sf:0
	.inst 0x783ed99f // strh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:12 10:10 S:1 option:110 Rm:30 1:1 opc:00 111000:111000 size:01
	.inst 0x5ac007f5 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xb595fad9 // cbnz:aarch64/instrs/branch/conditional/compare Rt:25 imm19:1001010111111010110 op:1 011010:011010 sf:1
	.inst 0xc2c2601e // SCOFF-C.CR-C Cd:30 Cn:0 000:000 opc:11 0:0 Rm:2 11000010110:11000010110
	.inst 0xe23fcdc2 // ALDUR-V.RI-Q Rt:2 Rn:14 op2:11 imm9:111111100 V:1 op1:00 11100010:11100010
	.inst 0xd8b5528d // prfm_lit:aarch64/instrs/memory/literal/general Rt:13 imm19:1011010101010010100 011000:011000 opc:11
	.inst 0x423fffe8 // ASTLR-R.R-32 Rt:8 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xe22667fa // ALDUR-V.RI-B Rt:26 Rn:31 op2:01 imm9:001100110 V:1 op1:00 11100010:11100010
	.inst 0xc2c21200
	.zero 1048532
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba4 // ldr c4, [x29, #2]
	.inst 0xc2400fa8 // ldr c8, [x29, #3]
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc24017ae // ldr c14, [x29, #5]
	.inst 0xc2401bb9 // ldr c25, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x80000000
	msr nzcv, x29
	ldr x29, =initial_csp_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321d // ldr c29, [c16, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x8260121d // ldr c29, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x16, #0x9
	and x29, x29, x16
	cmp x29, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b0 // ldr c16, [x29, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24007b0 // ldr c16, [x29, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400bb0 // ldr c16, [x29, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400fb0 // ldr c16, [x29, #3]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24017b0 // ldr c16, [x29, #5]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401bb0 // ldr c16, [x29, #6]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401fb0 // ldr c16, [x29, #7]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24023b0 // ldr c16, [x29, #8]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24027b0 // ldr c16, [x29, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x16, v2.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v2.d[1]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v26.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v26.d[1]
	cmp x29, x16
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
	ldr x0, =0x00001066
	ldr x1, =check_data1
	ldr x2, =0x00001067
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data3
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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
