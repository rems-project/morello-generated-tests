.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc2, 0x67, 0x37, 0xe2, 0x04, 0x48, 0xcf, 0xc2, 0x80, 0x20, 0xcd, 0x1a, 0xd5, 0x03, 0x21, 0xe2
	.byte 0xc2, 0x0b, 0xc0, 0xda, 0xe1, 0xe9, 0xc2, 0xc2, 0xe0, 0x1f, 0x64, 0x2c, 0x88, 0xf1, 0xc0, 0xc2
	.byte 0x0d, 0xb5, 0x7f, 0x82, 0xcd, 0x53, 0x2a, 0xb1, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C12 */
	.octa 0x800800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x1800
final_cap_values:
	/* C1 */
	.octa 0x1800000000000000000000
	/* C2 */
	.octa 0x180000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x1001
	/* C12 */
	.octa 0x800800000000000000000000000
	/* C13 */
	.octa 0x2294
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x1800
initial_SP_EL3_value:
	.octa 0x80000000000100070000000000001214
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000058c0100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000064ec00000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe23767c2 // ALDUR-V.RI-B Rt:2 Rn:30 op2:01 imm9:101110110 V:1 op1:00 11100010:11100010
	.inst 0xc2cf4804 // UNSEAL-C.CC-C Cd:4 Cn:0 0010:0010 opc:01 Cm:15 11000010110:11000010110
	.inst 0x1acd2080 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:4 op2:00 0010:0010 Rm:13 0011010110:0011010110 sf:0
	.inst 0xe22103d5 // ASTUR-V.RI-B Rt:21 Rn:30 op2:00 imm9:000010000 V:1 op1:00 11100010:11100010
	.inst 0xdac00bc2 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c2e9e1 // CTHI-C.CR-C Cd:1 Cn:15 1010:1010 opc:11 Rm:2 11000010110:11000010110
	.inst 0x2c641fe0 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:31 Rt2:00111 imm7:1001000 L:1 1011000:1011000 opc:00
	.inst 0xc2c0f188 // GCTYPE-R.C-C Rd:8 Cn:12 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x827fb50d // ALDRB-R.RI-B Rt:13 Rn:8 op:01 imm9:111111011 L:1 1000001001:1000001001
	.inst 0xb12a53cd // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:30 imm12:101010010100 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006ac // ldr c12, [x21, #1]
	.inst 0xc2400aaf // ldr c15, [x21, #2]
	.inst 0xc2400ebe // ldr c30, [x21, #3]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d5 // ldr c21, [c22, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012d5 // ldr c21, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x22, #0xf
	and x21, x21, x22
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b6 // ldr c22, [x21, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24006b6 // ldr c22, [x21, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401eb6 // ldr c22, [x21, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x22, v0.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v0.d[1]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v2.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v2.d[1]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v7.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v7.d[1]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v21.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v21.d[1]
	cmp x21, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001134
	ldr x1, =check_data0
	ldr x2, =0x0000113c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011fc
	ldr x1, =check_data1
	ldr x2, =0x000011fd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001776
	ldr x1, =check_data2
	ldr x2, =0x00001777
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001811
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
