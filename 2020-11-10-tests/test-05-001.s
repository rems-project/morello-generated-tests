.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x20
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x04, 0xc6, 0x30, 0x9b, 0x59, 0x61, 0x3f, 0xb8, 0xe2, 0xb3, 0xef, 0xc2, 0xd7, 0x19, 0x5d, 0x82
	.byte 0x27, 0x5c, 0xa2, 0xea, 0x22, 0x7c, 0x7f, 0x42, 0x3f, 0x40, 0x8e, 0x38, 0xc1, 0x23, 0xd1, 0xc2
	.byte 0x02, 0x65, 0xc1, 0x82, 0xe2, 0x8a, 0xb9, 0xd8, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000100740270000000000404002
	/* C8 */
	.octa 0x1000
	/* C10 */
	.octa 0xc0000000000700060000000000001010
	/* C14 */
	.octa 0x1040
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x10400600060000000000000000
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x404002
	/* C8 */
	.octa 0x1000
	/* C10 */
	.octa 0xc0000000000700060000000000001010
	/* C14 */
	.octa 0x1040
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000
	/* C30 */
	.octa 0x10400600060000000000000000
initial_SP_EL3_value:
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000e0005000000000000d401
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b30c604 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:4 Rn:16 Ra:17 o0:1 Rm:16 01:01 U:0 10011011:10011011
	.inst 0xb83f6159 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:10 00:00 opc:110 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2efb3e2 // EORFLGS-C.CI-C Cd:2 Cn:31 0:0 10:10 imm8:01111101 11000010111:11000010111
	.inst 0x825d19d7 // ASTR-R.RI-32 Rt:23 Rn:14 op:10 imm9:111010001 L:0 1000001001:1000001001
	.inst 0xeaa25c27 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:1 imm6:010111 Rm:2 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0x427f7c22 // ALDARB-R.R-B Rt:2 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x388e403f // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:011100100 0:0 opc:10 111000:111000 size:00
	.inst 0xc2d123c1 // SCBNDSE-C.CR-C Cd:1 Cn:30 000:000 opc:01 0:0 Rm:17 11000010110:11000010110
	.inst 0x82c16502 // ALDRSB-R.RRB-32 Rt:2 Rn:8 opc:01 S:0 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xd8b98ae2 // prfm_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:1011100110001010111 011000:011000 opc:11
	.inst 0xc2c210a0
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400668 // ldr c8, [x19, #1]
	.inst 0xc2400a6a // ldr c10, [x19, #2]
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc240167e // ldr c30, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b3 // ldr c19, [c5, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826010b3 // ldr c19, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x5, #0xf
	and x19, x19, x5
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400265 // ldr c5, [x19, #0]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401665 // ldr c5, [x19, #5]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401a65 // ldr c5, [x19, #6]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2401e65 // ldr c5, [x19, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001784
	ldr x1, =check_data2
	ldr x2, =0x00001788
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
	ldr x0, =0x00404002
	ldr x1, =check_data4
	ldr x2, =0x00404003
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004040e6
	ldr x1, =check_data5
	ldr x2, =0x004040e7
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
