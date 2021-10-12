.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 12
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x35, 0x7c, 0xf3, 0xa2, 0x04, 0x08, 0x0a, 0x2c, 0xea, 0x83, 0x41, 0x3a, 0x20, 0x08, 0xc0, 0xda
	.byte 0x5f, 0x70, 0x3f, 0xf8, 0xfc, 0xfe, 0xdf, 0x48, 0x68, 0x2d, 0x94, 0x3c, 0xe2, 0xe7, 0x4e, 0xa2
	.byte 0xff, 0x27, 0xde, 0xca, 0x22, 0xe4, 0x76, 0x8a, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1034
	/* C1 */
	.octa 0x1010
	/* C2 */
	.octa 0x1088
	/* C11 */
	.octa 0x142e
	/* C19 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x12fe
final_cap_values:
	/* C0 */
	.octa 0x10100000
	/* C1 */
	.octa 0x1010
	/* C11 */
	.octa 0x1370
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x12fe
	/* C28 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000007100700ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2f37c35 // CASA-C.R-C Ct:21 Rn:1 11111:11111 R:0 Cs:19 1:1 L:1 1:1 10100010:10100010
	.inst 0x2c0a0804 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:4 Rn:0 Rt2:00010 imm7:0010100 L:0 1011000:1011000 opc:00
	.inst 0x3a4183ea // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1010 0:0 Rn:31 00:00 cond:1000 Rm:1 111010010:111010010 op:0 sf:0
	.inst 0xdac00820 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf83f705f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:111 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x48dffefc // ldarh:aarch64/instrs/memory/ordered Rt:28 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x3c942d68 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:8 Rn:11 11:11 imm9:101000010 0:0 opc:10 111100:111100 size:00
	.inst 0xa24ee7e2 // LDR-C.RIAW-C Ct:2 Rn:31 01:01 imm9:011101110 0:0 opc:01 10100010:10100010
	.inst 0xcade27ff // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:31 imm6:001001 Rm:30 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x8a76e422 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:1 imm6:111001 Rm:22 N:1 shift:01 01010:01010 opc:00 sf:1
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q2, =0x0
	ldr q4, =0x0
	ldr q8, =0x0
	/* Set up flags and system registers */
	mov x14, #0x60000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
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
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x10, #0xf
	and x14, x14, x10
	cmp x14, #0xa
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
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc24011ca // ldr c10, [x14, #4]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc24015ca // ldr c10, [x14, #5]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc24019ca // ldr c10, [x14, #6]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x10, v2.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v2.d[1]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v4.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v4.d[1]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v8.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v8.d[1]
	cmp x14, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001084
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012fe
	ldr x1, =check_data2
	ldr x2, =0x00001300
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001370
	ldr x1, =check_data3
	ldr x2, =0x00001380
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
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
