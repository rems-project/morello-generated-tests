.section data0, #alloc, #write
	.zero 368
	.byte 0x81, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3712
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x81, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04
.data
check_data3:
	.byte 0x17, 0x7c, 0x5f, 0x42, 0x49, 0xfc, 0x01, 0x88, 0x4e, 0x2f, 0xc1, 0x92, 0x10, 0x40, 0xd5, 0xc2
	.byte 0x00, 0xf0, 0xd2, 0xc2
.data
check_data4:
	.byte 0x09, 0xdc, 0x8e, 0x02, 0x4f, 0x70, 0xbf, 0xb8, 0x1f, 0x20, 0x74, 0x38, 0x4f, 0xec, 0xbf, 0x62
	.byte 0x01, 0x10, 0xc2, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0100000580000010000000000001000
	/* C2 */
	.octa 0xc0000000600200040000000000001810
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xe000
	/* C27 */
	.octa 0x4000000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0xd0100000580000010000000000001000
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0xc0000000600200040000000000001800
	/* C9 */
	.octa 0xd0100000580000010000000000000c49
	/* C14 */
	.octa 0xfffff685ffffffff
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0xd010000058000001000000000000e000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xe000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000300010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001170
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7c17 // ALDAR-C.R-C Ct:23 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x8801fc49 // stlxr:aarch64/instrs/memory/exclusive/single Rt:9 Rn:2 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:10
	.inst 0x92c12f4e // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:0000100101111010 hw:10 100101:100101 opc:00 sf:1
	.inst 0xc2d54010 // SCVALUE-C.CR-C Cd:16 Cn:0 000:000 opc:10 0:0 Rm:21 11000010110:11000010110
	.inst 0xc2d2f000 // BR-CI-C 0:0 0000:0000 Cn:0 100:100 imm7:0010111 110000101101:110000101101
	.zero 108
	.inst 0x028edc09 // SUB-C.CIS-C Cd:9 Cn:0 imm12:001110110111 sh:0 A:1 00000010:00000010
	.inst 0xb8bf704f // ldumin:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:2 00:00 opc:111 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x3874201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:20 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x62bfec4f // STP-C.RIBW-C Ct:15 Rn:2 Ct2:11011 imm7:1111111 L:0 011000101:011000101
	.inst 0xc2c21001 // CHKSLD-C-C 00001:00001 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c212c0
	.zero 1048424
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a34 // ldr c20, [x17, #2]
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc240123b // ldr c27, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d1 // ldr c17, [c22, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826012d1 // ldr c17, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x22, #0xf
	and x17, x17, x22
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400236 // ldr c22, [x17, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400636 // ldr c22, [x17, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a36 // ldr c22, [x17, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401236 // ldr c22, [x17, #4]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401636 // ldr c22, [x17, #5]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401e36 // ldr c22, [x17, #7]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402236 // ldr c22, [x17, #8]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402636 // ldr c22, [x17, #9]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402a36 // ldr c22, [x17, #10]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001170
	ldr x1, =check_data1
	ldr x2, =0x00001180
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400080
	ldr x1, =check_data4
	ldr x2, =0x00400098
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
