.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1216
	.byte 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x40, 0x00, 0x80, 0x00, 0x20
	.zero 800
.data
check_data0:
	.byte 0x02, 0x10
.data
check_data1:
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
	.byte 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x40, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x01, 0xe0, 0x67, 0x82, 0x3f, 0xdf, 0x4b, 0xa2, 0x40, 0x2c, 0x5a, 0x78, 0xb4, 0x09, 0xde, 0xc2
	.byte 0x9f, 0x2a, 0xc6, 0x9a, 0xbf, 0x11, 0x31, 0x38, 0x59, 0x60, 0x62, 0x78, 0xfb, 0x6d, 0x1c, 0xb8
	.byte 0xc2, 0x07, 0xdf, 0xc2, 0xd1, 0x13, 0xc4, 0xc2
.data
check_data5:
	.byte 0x00, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000780070000000000408000
	/* C2 */
	.octa 0x1060
	/* C13 */
	.octa 0x800000000000000000001802
	/* C15 */
	.octa 0x1d2a
	/* C17 */
	.octa 0x0
	/* C25 */
	.octa 0xc30
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x901000005e0000010000000000001cc0
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x901000005e0000010000000000001cc0
	/* C13 */
	.octa 0x800000000000000000001802
	/* C15 */
	.octa 0x1cf0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0xe60000000000000000000001802
	/* C25 */
	.octa 0x3
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x901000005e0000010000000000001cc0
initial_SP_EL3_value:
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000600200010000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001cd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8267e001 // ALDR-C.RI-C Ct:1 Rn:0 op:00 imm9:001111110 L:1 1000001001:1000001001
	.inst 0xa24bdf3f // LDR-C.RIBW-C Ct:31 Rn:25 11:11 imm9:010111101 0:0 opc:01 10100010:10100010
	.inst 0x785a2c40 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:110100010 0:0 opc:01 111000:111000 size:01
	.inst 0xc2de09b4 // SEAL-C.CC-C Cd:20 Cn:13 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x9ac62a9f // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:20 op2:10 0010:0010 Rm:6 0011010110:0011010110 sf:1
	.inst 0x383111bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x78626059 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:2 00:00 opc:110 0:0 Rs:2 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xb81c6dfb // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:15 11:11 imm9:111000110 0:0 opc:00 111000:111000 size:10
	.inst 0xc2df07c2 // BUILD-C.C-C Cd:2 Cn:30 001:001 opc:00 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2c413d1 // LDPBR-C.C-C Ct:17 Cn:30 100:100 opc:00 11000010110001000:11000010110001000
	.zero 216
	.inst 0xc2c21100
	.zero 1048316
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2401151 // ldr c17, [x10, #4]
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc240195b // ldr c27, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310a // ldr c10, [c8, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260110a // ldr c10, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400148 // ldr c8, [x10, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400548 // ldr c8, [x10, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401148 // ldr c8, [x10, #4]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401548 // ldr c8, [x10, #5]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401948 // ldr c8, [x10, #6]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401d48 // ldr c8, [x10, #7]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402148 // ldr c8, [x10, #8]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402548 // ldr c8, [x10, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001810
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cc0
	ldr x1, =check_data2
	ldr x2, =0x00001ce0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001cf0
	ldr x1, =check_data3
	ldr x2, =0x00001cf4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x00400104
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004087e0
	ldr x1, =check_data6
	ldr x2, =0x004087f0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
