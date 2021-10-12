.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x7e, 0x00, 0x00, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x10, 0x00, 0x00
	.byte 0x40, 0x00, 0x00, 0x00, 0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x00
.data
check_data1:
	.byte 0x01, 0xd0, 0xc1, 0xc2, 0xc1, 0x2e, 0x85, 0x13, 0xc0, 0x17, 0xd2, 0x78, 0x1a, 0x7c, 0xdf, 0xc8
	.byte 0x40, 0xb0, 0x87, 0xac, 0x3e, 0xd0, 0xc1, 0xc2, 0x69, 0xd1, 0x42, 0x71, 0xfe, 0xca, 0x77, 0x78
	.byte 0x21, 0xfc, 0x9f, 0x08, 0x21, 0x84, 0xc2, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0x804000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x800
	/* C30 */
	.octa 0x100c
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1008
	/* C2 */
	.octa 0x10f0
	/* C5 */
	.octa 0x804000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x800
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000081100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000003fc3000300ff000000009191
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1d001 // CPY-C.C-C Cd:1 Cn:0 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x13852ec1 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:1 Rn:22 imms:001011 Rm:5 0:0 N:0 00100111:00100111 sf:0
	.inst 0x78d217c0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:100100001 0:0 opc:11 111000:111000 size:01
	.inst 0xc8df7c1a // ldlar:aarch64/instrs/memory/ordered Rt:26 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xac87b040 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:2 Rt2:01100 imm7:0001111 L:0 1011001:1011001 opc:10
	.inst 0xc2c1d03e // CPY-C.C-C Cd:30 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x7142d169 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:9 Rn:11 imm12:000010110100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x7877cafe // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:23 10:10 S:0 option:110 Rm:23 1:1 opc:01 111000:111000 size:01
	.inst 0x089ffc21 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c28421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400202 // ldr c2, [x16, #0]
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2400a16 // ldr c22, [x16, #2]
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q0, =0x1000000200000000007e00000000
	ldr q12, =0xd20000000000000000007e00000040
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603150 // ldr c16, [c10, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601150 // ldr c16, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x10, #0xf
	and x16, x16, x10
	cmp x16, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020a // ldr c10, [x16, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240060a // ldr c10, [x16, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240160a // ldr c10, [x16, #5]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401e0a // ldr c10, [x16, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x7e00000000
	mov x10, v0.d[0]
	cmp x16, x10
	b.ne comparison_fail
	ldr x16, =0x100000020000
	mov x10, v0.d[1]
	cmp x16, x10
	b.ne comparison_fail
	ldr x16, =0x7e00000040
	mov x10, v12.d[0]
	cmp x16, x10
	b.ne comparison_fail
	ldr x16, =0xd2000000000000
	mov x10, v12.d[1]
	cmp x16, x10
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
