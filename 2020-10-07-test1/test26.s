.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x03, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xe3, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0x02, 0x9a, 0xf2, 0xc2, 0xa1, 0xe6, 0xb3, 0x98, 0xe1, 0x08, 0xc0, 0xda, 0x2b, 0x64, 0xdf, 0xc2
	.byte 0xe2, 0x63, 0xb5, 0x82, 0x52, 0xe9, 0x68, 0x38, 0x3f, 0x2a, 0xc0, 0x9a, 0xe1, 0x4b, 0xd0, 0xc2
	.byte 0x01, 0xd0, 0xc5, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C7 */
	.octa 0xa0008000800100050000000000498329
	/* C8 */
	.octa 0x4ffffd
	/* C10 */
	.octa 0x80000000000100050000000000000001
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x40000000000100050000000000000001
	/* C2 */
	.octa 0x3
	/* C7 */
	.octa 0xa0008000800100050000000000498329
	/* C8 */
	.octa 0x4ffffd
	/* C10 */
	.octa 0x80000000000100050000000000000001
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002006000d0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c210e3 // BRR-C-C 00011:00011 Cn:7 100:100 opc:00 11000010110000100:11000010110000100
	.zero 623396
	.inst 0xc2f29a02 // SUBS-R.CC-C Rd:2 Cn:16 100110:100110 Cm:18 11000010111:11000010111
	.inst 0x98b3e6a1 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:1011001111100110101 011000:011000 opc:10
	.inst 0xdac008e1 // rev:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:7 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2df642b // CPYVALUE-C.C-C Cd:11 Cn:1 001:001 opc:11 0:0 Cm:31 11000010110:11000010110
	.inst 0x82b563e2 // ASTR-R.RRB-32 Rt:2 Rn:31 opc:00 S:0 option:011 Rm:21 1:1 L:0 100000101:100000101
	.inst 0x3868e952 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:18 Rn:10 10:10 S:0 option:111 Rm:8 1:1 opc:01 111000:111000 size:00
	.inst 0x9ac02a3f // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:17 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2d04be1 // UNSEAL-C.CC-C Cd:1 Cn:31 0010:0010 opc:01 Cm:16 11000010110:11000010110
	.inst 0xc2c5d001 // CVTDZ-C.R-C Cd:1 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c21340
	.zero 425136
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011d0 // ldr c16, [x14, #4]
	.inst 0xc24015d2 // ldr c18, [x14, #5]
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334e // ldr c14, [c26, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260134e // ldr c14, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x26, #0xf
	and x14, x14, x26
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001da // ldr c26, [x14, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005da // ldr c26, [x14, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009da // ldr c26, [x14, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dda // ldr c26, [x14, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc2401dda // ldr c26, [x14, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc24021da // ldr c26, [x14, #8]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc24025da // ldr c26, [x14, #9]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00498328
	ldr x1, =check_data2
	ldr x2, =0x00498350
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
