.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x22, 0x40, 0x4d, 0x7c, 0xff, 0x62, 0x7f, 0x78, 0x82, 0x09, 0x13, 0xe2, 0xe1, 0xa7, 0xd0, 0xc2
	.byte 0x72, 0x69, 0xbe, 0x8a, 0xce, 0x07, 0xc0, 0x5a, 0x29, 0x7c, 0x1f, 0x42, 0x74, 0x04, 0xc0, 0x5a
	.byte 0x00, 0x80, 0x81, 0xb8, 0x3a, 0x34, 0x80, 0x5a, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x40000000000100050000000000001020
	/* C9 */
	.octa 0x1000100010101010001010000000000
	/* C12 */
	.octa 0x80000000000640170000000000404003
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x421f7c29
	/* C1 */
	.octa 0x40000000000100050000000000001020
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x1000100010101010001010000000000
	/* C12 */
	.octa 0x80000000000640170000000000404003
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x1000
	/* C26 */
	.octa 0x1020
initial_SP_EL3_value:
	.octa 0xffffffffffffffffffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c4d4022 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:2 Rn:1 00:00 imm9:011010100 0:0 opc:01 111100:111100 size:01
	.inst 0x787f62ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:110 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xe2130982 // ALDURSB-R.RI-64 Rt:2 Rn:12 op2:10 imm9:100110000 V:0 op1:00 11100010:11100010
	.inst 0xc2d0a7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:16 11000010110:11000010110
	.inst 0x8abe6972 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:11 imm6:011010 Rm:30 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0x5ac007ce // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:14 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x421f7c29 // ASTLR-C.R-C Ct:9 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x5ac00474 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:20 Rn:3 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xb8818000 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:0 00:00 imm9:000011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a80343a // csneg:aarch64/instrs/integer/conditional/select Rd:26 Rn:1 o2:1 0:0 cond:0011 Rm:0 011010100:011010100 op:1 sf:0
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba9 // ldr c9, [x29, #2]
	.inst 0xc2400fac // ldr c12, [x29, #3]
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc24017b7 // ldr c23, [x29, #5]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030dd // ldr c29, [c6, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826010dd // ldr c29, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x6, #0xf
	and x29, x29, x6
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a6 // ldr c6, [x29, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24007a6 // ldr c6, [x29, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400fa6 // ldr c6, [x29, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24013a6 // ldr c6, [x29, #4]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc24017a6 // ldr c6, [x29, #5]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401ba6 // ldr c6, [x29, #6]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401fa6 // ldr c6, [x29, #7]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x6, v2.d[0]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v2.d[1]
	cmp x29, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
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
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010f6
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
	ldr x0, =0x00403f33
	ldr x1, =check_data4
	ldr x2, =0x00403f34
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
