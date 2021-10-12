.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x10, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0xf2, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xaf, 0xd3, 0x5c, 0x82, 0x9e, 0xd3, 0xc1, 0xc2, 0x3f, 0x23, 0x7f, 0x22, 0x41, 0x50, 0xcc, 0xe2
	.byte 0x32, 0x70, 0x57, 0xe2, 0xfe, 0x03, 0xc1, 0xc2, 0x11, 0xd3, 0xc1, 0xc2, 0xe1, 0x7b, 0x20, 0x9b
	.byte 0x5f, 0x30, 0x62, 0x78, 0x3f, 0x82, 0xe3, 0xf2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ff2
	/* C2 */
	.octa 0xc000000040000004000000000000100c
	/* C15 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000540400010000000000001000
	/* C29 */
	.octa 0xfffffffffffffff9
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc000000040000004000000000000100c
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000540400010000000000001000
	/* C29 */
	.octa 0xfffffffffffffff9
	/* C30 */
	.octa 0x5ff200000000000000000000
initial_SP_EL3_value:
	.octa 0x300070000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x480000005f86001700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825cd3af // ASTR-C.RI-C Ct:15 Rn:29 op:00 imm9:111001101 L:0 1000001001:1000001001
	.inst 0xc2c1d39e // CPY-C.C-C Cd:30 Cn:28 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x227f233f // LDXP-C.R-C Ct:31 Rn:25 Ct2:01000 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xe2cc5041 // ASTUR-R.RI-64 Rt:1 Rn:2 op2:00 imm9:011000101 V:0 op1:11 11100010:11100010
	.inst 0xe2577032 // ASTURH-R.RI-32 Rt:18 Rn:1 op2:00 imm9:101110111 V:0 op1:01 11100010:11100010
	.inst 0xc2c103fe // SCBNDS-C.CR-C Cd:30 Cn:31 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2c1d311 // CPY-C.C-C Cd:17 Cn:24 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x9b207be1 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:31 Ra:30 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0x7862305f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:011 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xf2e3823f // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:0001110000010001 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc2c210c0
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a8f // ldr c15, [x20, #2]
	.inst 0xc2400e92 // ldr c18, [x20, #3]
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc240169d // ldr c29, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d4 // ldr c20, [c6, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010d4 // ldr c20, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400286 // ldr c6, [x20, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400686 // ldr c6, [x20, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400a86 // ldr c6, [x20, #2]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2400e86 // ldr c6, [x20, #3]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401286 // ldr c6, [x20, #4]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401686 // ldr c6, [x20, #5]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2401a86 // ldr c6, [x20, #6]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2401e86 // ldr c6, [x20, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x000010e8
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ce0
	ldr x1, =check_data2
	ldr x2, =0x00001cf0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f82
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
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
