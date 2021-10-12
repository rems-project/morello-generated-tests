.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x20, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80
.data
check_data3:
	.byte 0x20, 0x57, 0x84, 0xda, 0x9e, 0x73, 0xc3, 0xc2, 0xdf, 0x8a, 0x46, 0x18, 0xfd, 0xd3, 0x29, 0x29
	.byte 0x00, 0xfd, 0xfe, 0xa2, 0x60, 0x23, 0x25, 0xe2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x1f, 0x7c, 0xfe, 0xa2, 0xbf, 0x71, 0x3d, 0x78, 0xb6, 0x67, 0xdd, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C8 */
	.octa 0xc00000000807041e0000000000001000
	/* C13 */
	.octa 0x1000
	/* C17 */
	.octa 0x2000800000010005000000000040003c
	/* C20 */
	.octa 0x80010000
	/* C25 */
	.octa 0x1020
	/* C27 */
	.octa 0xfaf
	/* C28 */
	.octa 0x80000000000000008000000000
	/* C29 */
	.octa 0x800780050000f10800001080
final_cap_values:
	/* C0 */
	.octa 0x1020
	/* C8 */
	.octa 0xc00000000807041e0000000000001000
	/* C13 */
	.octa 0x1000
	/* C17 */
	.octa 0x2000800000010005000000000040003c
	/* C20 */
	.octa 0x80010000
	/* C22 */
	.octa 0x800780050000f10800001080
	/* C25 */
	.octa 0x1020
	/* C27 */
	.octa 0xfaf
	/* C28 */
	.octa 0x80000000000000008000000000
	/* C29 */
	.octa 0x800780050000f10800001080
	/* C30 */
	.octa 0x1800000000000008000000000
initial_SP_EL3_value:
	.octa 0x40000000001500070000000000001240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa000800006c700020000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda845720 // csneg:aarch64/instrs/integer/conditional/select Rd:0 Rn:25 o2:1 0:0 cond:0101 Rm:4 011010100:011010100 op:1 sf:1
	.inst 0xc2c3739e // SEAL-C.CI-C Cd:30 Cn:28 100:100 form:11 11000010110000110:11000010110000110
	.inst 0x18468adf // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:31 imm19:0100011010001010110 011000:011000 opc:00
	.inst 0x2929d3fd // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:29 Rn:31 Rt2:10100 imm7:1010011 L:0 1010010:1010010 opc:00
	.inst 0xa2fefd00 // CASAL-C.R-C Ct:0 Rn:8 11111:11111 R:1 Cs:30 1:1 L:1 1:1 10100010:10100010
	.inst 0xe2252360 // ASTUR-V.RI-B Rt:0 Rn:27 op2:00 imm9:001010010 V:1 op1:00 11100010:11100010
	.inst 0xc2c21220 // BR-C-C 00000:00000 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32
	.inst 0xa2fe7c1f // CASA-C.R-C Ct:31 Rn:0 11111:11111 R:0 Cs:30 1:1 L:1 1:1 10100010:10100010
	.inst 0x783d71bf // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:111 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2dd67b6 // CPYVALUE-C.C-C Cd:22 Cn:29 001:001 opc:11 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c211e0
	.zero 1048500
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
	ldr x19, =initial_cap_values
	.inst 0xc2400268 // ldr c8, [x19, #0]
	.inst 0xc240066d // ldr c13, [x19, #1]
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2401279 // ldr c25, [x19, #4]
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2401a7c // ldr c28, [x19, #6]
	.inst 0xc2401e7d // ldr c29, [x19, #7]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q0, =0x1
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f3 // ldr c19, [c15, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011f3 // ldr c19, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x15, #0x8
	and x19, x19, x15
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026f // ldr c15, [x19, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240066f // ldr c15, [x19, #1]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401a6f // ldr c15, [x19, #6]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2401e6f // ldr c15, [x19, #7]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240226f // ldr c15, [x19, #8]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240266f // ldr c15, [x19, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402a6f // ldr c15, [x19, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x1
	mov x15, v0.d[0]
	cmp x19, x15
	b.ne comparison_fail
	ldr x19, =0x0
	mov x15, v0.d[1]
	cmp x19, x15
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000118c
	ldr x1, =check_data2
	ldr x2, =0x00001194
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040003c
	ldr x1, =check_data4
	ldr x2, =0x0040004c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0048d160
	ldr x1, =check_data5
	ldr x2, =0x0048d164
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
