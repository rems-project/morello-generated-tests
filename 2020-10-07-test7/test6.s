.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xdf, 0xfb, 0x22, 0x7c, 0xfa, 0xc3, 0xee, 0x62, 0x04, 0xd0, 0xc5, 0xc2, 0xe1, 0x2b, 0x0c, 0x79
	.byte 0xa0, 0xd0, 0xc1, 0xc2, 0x40, 0x6c, 0x0f, 0x38, 0x07, 0x18, 0x49, 0x7a, 0x82, 0x7d, 0xdf, 0x08
	.byte 0xe5, 0x79, 0x14, 0x38, 0xc1, 0xa7, 0xc1, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000002001c0050000000000000f0c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x800000000000800800000000004ffffe
	/* C15 */
	.octa 0x400000000001000500000000000020b7
	/* C30 */
	.octa 0x4000000000030007fffffffffffff6f0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x800000000000800800000000004ffffe
	/* C15 */
	.octa 0x400000000001000500000000000020b7
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000030007fffffffffffff6f0
initial_SP_EL3_value:
	.octa 0xd0100000000100070000000000001c00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x3fff800000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c22fbdf // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:31 Rn:30 10:10 S:1 option:111 Rm:2 1:1 opc:00 111100:111100 size:01
	.inst 0x62eec3fa // LDP-C.RIBW-C Ct:26 Rn:31 Ct2:10000 imm7:1011101 L:1 011000101:011000101
	.inst 0xc2c5d004 // CVTDZ-C.R-C Cd:4 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x790c2be1 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:001100001010 opc:00 111001:111001 size:01
	.inst 0xc2c1d0a0 // CPY-C.C-C Cd:0 Cn:5 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x380f6c40 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:011110110 0:0 opc:00 111000:111000 size:00
	.inst 0x7a491807 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0111 0:0 Rn:0 10:10 cond:0001 imm5:01001 111010010:111010010 op:1 sf:0
	.inst 0x08df7d82 // ldlarb:aarch64/instrs/memory/ordered Rt:2 Rn:12 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x381479e5 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:5 Rn:15 10:10 imm9:101000111 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c1a7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314e // ldr c14, [c10, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260114e // ldr c14, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x10, #0xf
	and x14, x14, x10
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001ca // ldr c10, [x14, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ca // ldr c10, [x14, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24011ca // ldr c10, [x14, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24015ca // ldr c10, [x14, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24019ca // ldr c10, [x14, #6]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401dca // ldr c10, [x14, #7]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc24021ca // ldr c10, [x14, #8]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc24025ca // ldr c10, [x14, #9]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x10, v31.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v31.d[1]
	cmp x14, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001508
	ldr x1, =check_data1
	ldr x2, =0x0000150a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019d0
	ldr x1, =check_data2
	ldr x2, =0x000019f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe4
	ldr x1, =check_data3
	ldr x2, =0x00001fe6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
