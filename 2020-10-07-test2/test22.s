.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 304
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 3696
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xe1, 0xa7, 0xdf, 0xc2, 0x04, 0xb0, 0xc0, 0xc2, 0x40, 0x7d, 0xdf, 0x48, 0x67, 0xb3, 0x4c, 0x3a
	.byte 0x00, 0x9a, 0xeb, 0xa9, 0x4e, 0x28, 0xde, 0x1a, 0x21, 0x00, 0xaa, 0x9b, 0x40, 0x80, 0x91, 0xda
	.byte 0x22, 0x3f, 0x86, 0x38, 0xe1, 0xdf, 0x9f, 0xf9, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000010005000000000000117c
	/* C16 */
	.octa 0x80000000400100020000000000001170
	/* C25 */
	.octa 0x80000000000100050000000000001f9b
final_cap_values:
	/* C2 */
	.octa 0xffffffffffffffc2
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C10 */
	.octa 0x8000000000010005000000000000117c
	/* C16 */
	.octa 0x80000000400100020000000000001028
	/* C25 */
	.octa 0x80000000000100050000000000001ffe
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dfa7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c0b004 // GCSEAL-R.C-C Rd:4 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x48df7d40 // ldlarh:aarch64/instrs/memory/ordered Rt:0 Rn:10 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x3a4cb367 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:27 00:00 cond:1011 Rm:12 111010010:111010010 op:0 sf:0
	.inst 0xa9eb9a00 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:16 Rt2:00110 imm7:1010111 L:1 1010011:1010011 opc:10
	.inst 0x1ade284e // asrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:2 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0x9baa0021 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:1 Ra:0 o0:0 Rm:10 01:01 U:1 10011011:10011011
	.inst 0xda918040 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:2 o2:0 0:0 cond:1000 Rm:17 011010100:011010100 op:1 sf:1
	.inst 0x38863f22 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:25 11:11 imm9:001100011 0:0 opc:10 111000:111000 size:00
	.inst 0xf99fdfe1 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:011111110111 opc:10 111001:111001 size:11
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc240074a // ldr c10, [x26, #1]
	.inst 0xc2400b50 // ldr c16, [x26, #2]
	.inst 0xc2400f59 // ldr c25, [x26, #3]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011fa // ldr c26, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x15, #0xf
	and x26, x26, x15
	cmp x26, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034f // ldr c15, [x26, #0]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc240074f // ldr c15, [x26, #1]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400b4f // ldr c15, [x26, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240134f // ldr c15, [x26, #4]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x00001038
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000117c
	ldr x1, =check_data1
	ldr x2, =0x0000117e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
