.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xe1, 0xb3, 0xc5, 0xc2, 0x9e, 0x10, 0xc0, 0xc2, 0x42, 0x40, 0x14, 0x6b, 0x3f, 0xf0, 0x40, 0xaa
	.byte 0x00, 0xc4, 0xb6, 0xac, 0x5f, 0x00, 0x17, 0x5a, 0xde, 0xfd, 0xdf, 0x08, 0x3c, 0x7c, 0xdf, 0x9b
	.byte 0xbf, 0x65, 0xff, 0xc2, 0xe1, 0x7e, 0x7f, 0x42, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C4 */
	.octa 0x400000000000000000000000
	/* C13 */
	.octa 0x400000004002008a0000000000001080
	/* C14 */
	.octa 0x1000
	/* C23 */
	.octa 0x800000004004c0210000000000400000
final_cap_values:
	/* C0 */
	.octa 0xed0
	/* C1 */
	.octa 0xe1
	/* C4 */
	.octa 0x400000000000000000000000
	/* C13 */
	.octa 0x400000004002008a0000000000001080
	/* C14 */
	.octa 0x1000
	/* C23 */
	.octa 0x800000004004c0210000000000400000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000104b00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006000000100ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b3e1 // CVTP-C.R-C Cd:1 Rn:31 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c0109e // GCBASE-R.C-C Rd:30 Cn:4 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x6b144042 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:2 imm6:010000 Rm:20 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.inst 0xaa40f03f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:111100 Rm:0 N:0 shift:01 01010:01010 opc:01 sf:1
	.inst 0xacb6c400 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:0 Rt2:10001 imm7:1101101 L:0 1011001:1011001 opc:10
	.inst 0x5a17005f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:2 000000:000000 Rm:23 11010000:11010000 S:0 op:1 sf:0
	.inst 0x08dffdde // ldarb:aarch64/instrs/memory/ordered Rt:30 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9bdf7c3c // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:28 Rn:1 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc2ff65bf // ASTR-C.RRB-C Ct:31 Rn:13 1:1 L:0 S:0 option:011 Rm:31 11000010111:11000010111
	.inst 0x427f7ee1 // ALDARB-R.R-B Rt:1 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2400a4d // ldr c13, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc2401257 // ldr c23, [x18, #4]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q0, =0x0
	ldr q17, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603172 // ldr c18, [c11, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601172 // ldr c18, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024b // ldr c11, [x18, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401a4b // ldr c11, [x18, #6]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2401e4b // ldr c11, [x18, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x11, v0.d[0]
	cmp x18, x11
	b.ne comparison_fail
	ldr x18, =0x0
	mov x11, v0.d[1]
	cmp x18, x11
	b.ne comparison_fail
	ldr x18, =0x0
	mov x11, v17.d[0]
	cmp x18, x11
	b.ne comparison_fail
	ldr x18, =0x0
	mov x11, v17.d[1]
	cmp x18, x11
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
