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
	.byte 0x61, 0x11, 0xc2, 0xc2, 0x0d, 0x60, 0x36, 0x12, 0x3f, 0x7d, 0x08, 0x1b, 0xe0, 0x05, 0xc0, 0xda
	.byte 0xfc, 0xcb, 0x3e, 0xb8, 0x5f, 0xf7, 0x53, 0xe2, 0x01, 0x48, 0xa7, 0xb8, 0x45, 0x2c, 0xdf, 0x1a
	.byte 0x1f, 0xe4, 0x93, 0x38, 0xc2, 0x37, 0x60, 0x82, 0x00, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x7fffa
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x4700feff
	/* C26 */
	.octa 0x8000000000010007000000000040010d
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000000011f0
final_cap_values:
	/* C0 */
	.octa 0x47ff3c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x7fffa
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x4700feff
	/* C26 */
	.octa 0x8000000000010007000000000040010d
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000000011f0
initial_SP_EL3_value:
	.octa 0x210
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21161 // CHKSLD-C-C 00001:00001 Cn:11 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x1236600d // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:13 Rn:0 imms:011000 immr:110110 N:0 100100:100100 opc:00 sf:0
	.inst 0x1b087d3f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:9 Ra:31 o0:0 Rm:8 0011011000:0011011000 sf:0
	.inst 0xdac005e0 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:15 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb83ecbfc // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:28 Rn:31 10:10 S:0 option:110 Rm:30 1:1 opc:00 111000:111000 size:10
	.inst 0xe253f75f // ALDURH-R.RI-32 Rt:31 Rn:26 op2:01 imm9:100111111 V:0 op1:01 11100010:11100010
	.inst 0xb8a74801 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:0 option:010 Rm:7 1:1 opc:10 111000:111000 size:10
	.inst 0x1adf2c45 // rorv:aarch64/instrs/integer/shift/variable Rd:5 Rn:2 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x3893e41f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:100111110 0:0 opc:10 111000:111000 size:00
	.inst 0x826037c2 // ALDRB-R.RI-B Rt:2 Rn:30 op:01 imm9:000000011 L:1 1000001001:1000001001
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc240058b // ldr c11, [x12, #1]
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2400d9a // ldr c26, [x12, #3]
	.inst 0xc240119c // ldr c28, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850038
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330c // ldr c12, [c24, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260130c // ldr c12, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x24, #0xf
	and x12, x12, x24
	cmp x12, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400198 // ldr c24, [x12, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400598 // ldr c24, [x12, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400998 // ldr c24, [x12, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400d98 // ldr c24, [x12, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401198 // ldr c24, [x12, #4]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401d98 // ldr c24, [x12, #7]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402198 // ldr c24, [x12, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011f3
	ldr x1, =check_data0
	ldr x2, =0x000011f4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001404
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
	ldr x0, =0x0040004c
	ldr x1, =check_data3
	ldr x2, =0x0040004e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047fffe
	ldr x1, =check_data4
	ldr x2, =0x0047ffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
