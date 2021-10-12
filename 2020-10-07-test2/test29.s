.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x59
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x22, 0x12, 0xc7, 0xc2, 0x4b, 0xfc, 0x9f, 0x08, 0x57, 0x44, 0xc7, 0xc2, 0x1e, 0x11, 0x10, 0x78
	.byte 0xe9, 0x11, 0x4b, 0xba, 0x64, 0x71, 0x16, 0xa2, 0xba, 0x44, 0x08, 0x98, 0x40, 0xd0, 0x11, 0x7c
	.byte 0xe4, 0xff, 0x7f, 0x42, 0x1e, 0x2b, 0x00, 0x6a, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fffff
	/* C4 */
	.octa 0x4100000000000000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x2001
	/* C11 */
	.octa 0x1459
	/* C17 */
	.octa 0x10e3
	/* C24 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x3fffff
	/* C2 */
	.octa 0x10e3
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x2001
	/* C11 */
	.octa 0x1459
	/* C17 */
	.octa 0x10e3
	/* C23 */
	.octa 0x10e3
	/* C24 */
	.octa 0xffffffff
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xfffffc00
initial_SP_EL3_value:
	.octa 0x800000000087008c0000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000010b00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4800000060040f040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71222 // RRLEN-R.R-C Rd:2 Rn:17 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x089ffc4b // stlrb:aarch64/instrs/memory/ordered Rt:11 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c74457 // CSEAL-C.C-C Cd:23 Cn:2 001:001 opc:10 0:0 Cm:7 11000010110:11000010110
	.inst 0x7810111e // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:8 00:00 imm9:100000001 0:0 opc:00 111000:111000 size:01
	.inst 0xba4b11e9 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1001 0:0 Rn:15 00:00 cond:0001 Rm:11 111010010:111010010 op:0 sf:1
	.inst 0xa2167164 // STUR-C.RI-C Ct:4 Rn:11 00:00 imm9:101100111 0:0 opc:00 10100010:10100010
	.inst 0x980844ba // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:26 imm19:0000100001000100101 011000:011000 opc:10
	.inst 0x7c11d040 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:0 Rn:2 00:00 imm9:100011101 0:0 opc:00 111100:111100 size:01
	.inst 0x427fffe4 // ALDAR-R.R-32 Rt:4 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x6a002b1e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:24 imm6:001010 Rm:0 N:0 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2c212a0
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
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc240118b // ldr c11, [x12, #4]
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ac // ldr c12, [c21, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826012ac // ldr c12, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	mov x21, #0xf
	and x12, x12, x21
	cmp x12, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400195 // ldr c21, [x12, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400595 // ldr c21, [x12, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400995 // ldr c21, [x12, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400d95 // ldr c21, [x12, #3]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401195 // ldr c21, [x12, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401595 // ldr c21, [x12, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401d95 // ldr c21, [x12, #7]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402195 // ldr c21, [x12, #8]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2402595 // ldr c21, [x12, #9]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402995 // ldr c21, [x12, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x21, v0.d[0]
	cmp x12, x21
	b.ne comparison_fail
	ldr x12, =0x0
	mov x21, v0.d[1]
	cmp x12, x21
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
	ldr x0, =0x000010e3
	ldr x1, =check_data1
	ldr x2, =0x000010e4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013c0
	ldr x1, =check_data2
	ldr x2, =0x000013d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f02
	ldr x1, =check_data3
	ldr x2, =0x00001f04
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
	ldr x0, =0x004108ac
	ldr x1, =check_data5
	ldr x2, =0x004108b0
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
