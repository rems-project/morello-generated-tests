.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x19
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x78, 0x19, 0xe2, 0xc1, 0xff, 0x9f, 0xc8, 0x41, 0xb3, 0x40, 0xba, 0x91, 0x06, 0x21, 0x6a
	.byte 0xfe, 0xa3, 0x5a, 0x38, 0xdf, 0xf9, 0x3d, 0x2c, 0x1e, 0x60, 0x81, 0xda, 0xe3, 0x17, 0x81, 0x5a
	.byte 0xe1, 0x39, 0xce, 0x78, 0x02, 0x6c, 0xa1, 0x82, 0x40, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200c
	/* C1 */
	.octa 0x0
	/* C14 */
	.octa 0x40000000000080080000000000001040
	/* C15 */
	.octa 0x800000005042007a0000000000000f4f
	/* C20 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x40000000000000000000000000001400
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1800
	/* C3 */
	.octa 0x0
	/* C14 */
	.octa 0x40000000000080080000000000001040
	/* C15 */
	.octa 0x800000005042007a0000000000000f4f
	/* C17 */
	.octa 0xffffffff
	/* C20 */
	.octa 0xffffffff
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x800000003006220f0000000000400200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000c0f00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000001000500ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2197800 // ALDURSB-R.RI-64 Rt:0 Rn:0 op2:10 imm9:110010111 V:0 op1:00 11100010:11100010
	.inst 0xc89fffc1 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xba40b341 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:26 00:00 cond:1011 Rm:0 111010010:111010010 op:0 sf:1
	.inst 0x6a210691 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:17 Rn:20 imm6:000001 Rm:1 N:1 shift:00 01010:01010 opc:11 sf:0
	.inst 0x385aa3fe // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:110101010 0:0 opc:01 111000:111000 size:00
	.inst 0x2c3df9df // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:14 Rt2:11110 imm7:1111011 L:0 1011000:1011000 opc:00
	.inst 0xda81601e // csinv:aarch64/instrs/integer/conditional/select Rd:30 Rn:0 o2:0 0:0 cond:0110 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0x5a8117e3 // csneg:aarch64/instrs/integer/conditional/select Rd:3 Rn:31 o2:1 0:0 cond:0001 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x78ce39e1 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:15 10:10 imm9:011100011 0:0 opc:11 111000:111000 size:01
	.inst 0x82a16c02 // ASTR-V.RRB-S Rt:2 Rn:0 opc:11 S:0 option:011 Rm:1 1:1 L:0 100000101:100000101
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008ee // ldr c14, [x7, #2]
	.inst 0xc2400cef // ldr c15, [x7, #3]
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q2, =0x19000000
	ldr q30, =0x18000000
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x7, #0x80000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850038
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603147 // ldr c7, [c10, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601147 // ldr c7, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x10, #0xf
	and x7, x7, x10
	cmp x7, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ea // ldr c10, [x7, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004ea // ldr c10, [x7, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24010ea // ldr c10, [x7, #4]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc24014ea // ldr c10, [x7, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24018ea // ldr c10, [x7, #6]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401cea // ldr c10, [x7, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x19000000
	mov x10, v2.d[0]
	cmp x7, x10
	b.ne comparison_fail
	ldr x7, =0x0
	mov x10, v2.d[1]
	cmp x7, x10
	b.ne comparison_fail
	ldr x7, =0x18000000
	mov x10, v30.d[0]
	cmp x7, x10
	b.ne comparison_fail
	ldr x7, =0x0
	mov x10, v30.d[1]
	cmp x7, x10
	b.ne comparison_fail
	ldr x7, =0x0
	mov x10, v31.d[0]
	cmp x7, x10
	b.ne comparison_fail
	ldr x7, =0x0
	mov x10, v31.d[1]
	cmp x7, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000102c
	ldr x1, =check_data0
	ldr x2, =0x00001034
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001804
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa3
	ldr x1, =check_data3
	ldr x2, =0x00001fa4
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
	ldr x0, =0x004001aa
	ldr x1, =check_data5
	ldr x2, =0x004001ab
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
