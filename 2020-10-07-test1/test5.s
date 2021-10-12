.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0xde, 0xe3, 0xa1, 0x9b, 0xc2, 0x5b, 0x81, 0x39, 0xe1, 0xff, 0xdf, 0x48, 0x7e, 0x42, 0xc7, 0xc2
	.byte 0xc4, 0xa8, 0x41, 0xba, 0x01, 0x27, 0xc1, 0x9a, 0x4b, 0x5a, 0x7e, 0xf8, 0x26, 0x00, 0x06, 0xda
	.byte 0xe0, 0x9f, 0x52, 0xd2, 0x3d, 0x83, 0xc2, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xfe3443a1
	/* C7 */
	.octa 0x40448000
	/* C18 */
	.octa 0xfffffffdfddc1000
	/* C19 */
	.octa 0x400080120080000010008000
	/* C24 */
	.octa 0x580cc2e3d3effd48
	/* C30 */
	.octa 0x58ac0088
final_cap_values:
	/* C0 */
	.octa 0xffffc000003fffff
	/* C1 */
	.octa 0x160330b8f4fbff52
	/* C2 */
	.octa 0x1
	/* C7 */
	.octa 0x40448000
	/* C11 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C18 */
	.octa 0xfffffffdfddc1000
	/* C19 */
	.octa 0x400080120080000010008000
	/* C24 */
	.octa 0x580cc2e3d3effd48
	/* C30 */
	.octa 0x400080120000000040448000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000400070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005019001a00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ba1e3de // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:30 Ra:24 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x39815bc2 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:30 imm12:000001010110 opc:10 111001:111001 size:00
	.inst 0x48dfffe1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c7427e // SCVALUE-C.CR-C Cd:30 Cn:19 000:000 opc:10 0:0 Rm:7 11000010110:11000010110
	.inst 0xba41a8c4 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:6 10:10 cond:1010 imm5:00001 111010010:111010010 op:0 sf:1
	.inst 0x9ac12701 // lsrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:24 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xf87e5a4b // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:11 Rn:18 10:10 S:1 option:010 Rm:30 1:1 opc:01 111000:111000 size:11
	.inst 0xda060026 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:6 Rn:1 000000:000000 Rm:6 11010000:11010000 S:0 op:1 sf:1
	.inst 0xd2529fe0 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:31 imms:100111 immr:010010 N:1 100100:100100 opc:10 sf:1
	.inst 0xc2c2833d // SCTAG-C.CR-C Cd:29 Cn:25 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c211a0
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
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2400d93 // ldr c19, [x12, #3]
	.inst 0xc2401198 // ldr c24, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x80000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ac // ldr c12, [c13, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	mov x13, #0xf
	and x12, x12, x13
	cmp x12, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001016
	ldr x1, =check_data1
	ldr x2, =0x00001017
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
