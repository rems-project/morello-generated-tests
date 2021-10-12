.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x02, 0x0c, 0xec, 0xaa, 0x5f, 0x3c, 0x03, 0xd5, 0x02, 0x7f, 0xdf, 0x48, 0x9e, 0x33, 0xc1, 0xc2
	.byte 0x75, 0x64, 0xc2, 0xc2, 0x32, 0xfc, 0x9f, 0xc8, 0x03, 0x3b, 0x07, 0x92, 0xe1, 0x95, 0x82, 0x5a
	.byte 0x21, 0xe8, 0xc4, 0xc2, 0x00, 0xd4, 0x97, 0xac, 0x00, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01, 0xe0
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x150010002000000000000e000
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x40010a
final_cap_values:
	/* C0 */
	.octa 0x12f0
	/* C2 */
	.octa 0xe001
	/* C3 */
	.octa 0xa
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x150010002000000000000e001
	/* C24 */
	.octa 0x40010a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xaaec0c02 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:0 imm6:000011 Rm:12 N:1 shift:11 01010:01010 opc:01 sf:1
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0x48df7f02 // ldlarh:aarch64/instrs/memory/ordered Rt:2 Rn:24 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c1339e // GCFLGS-R.C-C Rd:30 Cn:28 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c26475 // CPYVALUE-C.C-C Cd:21 Cn:3 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xc89ffc32 // stlr:aarch64/instrs/memory/ordered Rt:18 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x92073b03 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:24 imms:001110 immr:000111 N:0 100100:100100 opc:00 sf:1
	.inst 0x5a8295e1 // csneg:aarch64/instrs/integer/conditional/select Rd:1 Rn:15 o2:1 0:0 cond:1001 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0xc2c4e821 // CTHI-C.CR-C Cd:1 Cn:1 1010:1010 opc:11 Rm:4 11000010110:11000010110
	.inst 0xac97d400 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:0 Rt2:10101 imm7:0101111 L:0 1011001:1011001 opc:10
	.inst 0xc2c21200
	.zero 220
	.inst 0xe0010000
	.zero 1048308
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc24011b8 // ldr c24, [x13, #4]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q0, =0x0
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x13, #0x20000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320d // ldr c13, [c16, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260120d // ldr c13, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x16, #0x6
	and x13, x13, x16
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b0 // ldr c16, [x13, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24015b0 // ldr c16, [x13, #5]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x16, v0.d[0]
	cmp x13, x16
	b.ne comparison_fail
	ldr x13, =0x0
	mov x16, v0.d[1]
	cmp x13, x16
	b.ne comparison_fail
	ldr x13, =0x0
	mov x16, v21.d[0]
	cmp x13, x16
	b.ne comparison_fail
	ldr x13, =0x0
	mov x16, v21.d[1]
	cmp x13, x16
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
	ldr x0, =0x0040010a
	ldr x1, =check_data2
	ldr x2, =0x0040010c
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
