.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x4e, 0x00
.data
check_data2:
	.byte 0x3f, 0x1e, 0x1f, 0xf2, 0xe0, 0x73, 0xc2, 0xc2, 0xc3, 0xd5, 0x12, 0xc2, 0x4f, 0x7c, 0x5f, 0x9b
	.byte 0xdf, 0x54, 0x05, 0xe2, 0x51, 0x57, 0xb0, 0x39, 0x02, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0x9e, 0x35, 0x8d, 0xda, 0x1f, 0x94, 0x49, 0x38, 0x68, 0x92, 0xc0, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080003ffc00000000000000400020
	/* C3 */
	.octa 0x4e0001800000000000000000000000
	/* C6 */
	.octa 0x8000000001b180060000000000401f24
	/* C14 */
	.octa 0xffffffffffffd050
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0xd03
final_cap_values:
	/* C0 */
	.octa 0x4000b9
	/* C3 */
	.octa 0x4e0001800000000000000000000000
	/* C6 */
	.octa 0x8000000001b180060000000000401f24
	/* C8 */
	.octa 0x1
	/* C14 */
	.octa 0xffffffffffffd050
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0xd03
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000b00070000000000004001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf21f1e3f // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:17 imms:000111 immr:011111 N:0 100100:100100 opc:11 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc212d5c3 // STR-C.RIB-C Ct:3 Rn:14 imm12:010010110101 L:0 110000100:110000100
	.inst 0x9b5f7c4f // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:15 Rn:2 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xe20554df // ALDURB-R.RI-32 Rt:31 Rn:6 op2:01 imm9:001010101 V:0 op1:00 11100010:11100010
	.inst 0x39b05751 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:26 imm12:110000010101 opc:10 111001:111001 size:00
	.inst 0xc2c21002 // BRS-C-C 00010:00010 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 4
	.inst 0xda8d359e // csneg:aarch64/instrs/integer/conditional/select Rd:30 Rn:12 o2:1 0:0 cond:0011 Rm:13 011010100:011010100 op:1 sf:1
	.inst 0x3849941f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:010011001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c09268 // GCTAG-R.C-C Rd:8 Cn:19 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c21140
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2400a86 // ldr c6, [x20, #2]
	.inst 0xc2400e8e // ldr c14, [x20, #3]
	.inst 0xc2401291 // ldr c17, [x20, #4]
	.inst 0xc2401693 // ldr c19, [x20, #5]
	.inst 0xc2401a9a // ldr c26, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850032
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603154 // ldr c20, [c10, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601154 // ldr c20, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x10, #0xf
	and x20, x20, x10
	cmp x20, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028a // ldr c10, [x20, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240168a // ldr c10, [x20, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401a8a // ldr c10, [x20, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401e8a // ldr c10, [x20, #7]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240228a // ldr c10, [x20, #8]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001918
	ldr x1, =check_data0
	ldr x2, =0x00001919
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ba0
	ldr x1, =check_data1
	ldr x2, =0x00001bb0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400020
	ldr x1, =check_data3
	ldr x2, =0x00400030
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401f79
	ldr x1, =check_data4
	ldr x2, =0x00401f7a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
