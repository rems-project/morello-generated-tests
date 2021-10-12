.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x07, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x01, 0x82
.data
check_data3:
	.byte 0xd4, 0x9e, 0x67, 0x37, 0x52, 0x84, 0x99, 0xb8, 0xe1, 0xfe, 0xdf, 0xc8, 0x22, 0x25, 0xdf, 0x1a
	.byte 0x61, 0x85, 0xc3, 0xc2, 0xe1, 0x8f, 0xaf, 0xc2, 0x17, 0xcc, 0xdf, 0xc2, 0xfe, 0x03, 0xc0, 0xda
	.byte 0x00, 0x90, 0x16, 0xa2, 0xc2, 0xb0, 0xc5, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x820100c2000000000000000000002007
	/* C2 */
	.octa 0x181c
	/* C3 */
	.octa 0x3000700ffe00000000001
	/* C6 */
	.octa 0xffe08000400000
	/* C11 */
	.octa 0x400100000000000000004000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x1400
final_cap_values:
	/* C0 */
	.octa 0x820100c2000000000000000000002007
	/* C1 */
	.octa 0xc000a0000000000000000800
	/* C2 */
	.octa 0x200080000003000700ffe08000400000
	/* C3 */
	.octa 0x3000700ffe00000000001
	/* C6 */
	.octa 0xffe08000400000
	/* C11 */
	.octa 0x400100000000000000004000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0xc000a0000000000000000800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe0000003e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x37679ed4 // tbnz:aarch64/instrs/branch/conditional/test Rt:20 imm14:11110011110110 b40:01100 op:1 011011:011011 b5:0
	.inst 0xb8998452 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:18 Rn:2 01:01 imm9:110011000 0:0 opc:10 111000:111000 size:10
	.inst 0xc8dffee1 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x1adf2522 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:9 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2c38561 // CHKSS-_.CC-C 00001:00001 Cn:11 001:001 opc:00 1:1 Cm:3 11000010110:11000010110
	.inst 0xc2af8fe1 // ADD-C.CRI-C Cd:1 Cn:31 imm3:011 option:100 Rm:15 11000010101:11000010101
	.inst 0xc2dfcc17 // CSEL-C.CI-C Cd:23 Cn:0 11:11 cond:1100 Cm:31 11000010110:11000010110
	.inst 0xdac003fe // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:30 Rn:31 101101011000000000000:101101011000000000000 sf:1
	.inst 0xa2169000 // STUR-C.RI-C Ct:0 Rn:0 00:00 imm9:101101001 0:0 opc:00 10100010:10100010
	.inst 0xc2c5b0c2 // CVTP-C.R-C Cd:2 Rn:6 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c21360
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2401b54 // ldr c20, [x26, #6]
	.inst 0xc2401f57 // ldr c23, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0xc
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337a // ldr c26, [c27, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260137a // ldr c26, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x27, #0xf
	and x26, x26, x27
	cmp x26, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035b // ldr c27, [x26, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240075b // ldr c27, [x26, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b5b // ldr c27, [x26, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240235b // ldr c27, [x26, #8]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc240275b // ldr c27, [x26, #9]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2402b5b // ldr c27, [x26, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001408
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000181c
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f70
	ldr x1, =check_data2
	ldr x2, =0x00001f80
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
	.inst 0xc28b413a // msr ddc_el3, c26
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
