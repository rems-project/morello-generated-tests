.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0xed, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x68, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x40, 0xed, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x68, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x12, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1e, 0x00, 0xc0, 0x5a, 0xc2, 0xda, 0x41, 0x82, 0x2b, 0x33, 0xc5, 0xc2, 0xde, 0x3b, 0xc3, 0xc2
	.byte 0x22, 0x44, 0x37, 0x7d, 0xc1, 0x91, 0xc5, 0xc2, 0x00, 0x7c, 0x9f, 0x08, 0x5e, 0xf8, 0xcd, 0xc2
	.byte 0x3e, 0x78, 0x00, 0xad, 0xdf, 0x13, 0x7e, 0x78, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001700
	/* C1 */
	.octa 0x4000000000010005fffffffffffff460
	/* C2 */
	.octa 0xc0000000600402090000000000001012
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffffffc0
	/* C25 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001700
	/* C1 */
	.octa 0x40000000101700200000000000001000
	/* C2 */
	.octa 0xc0000000600402090000000000001012
	/* C11 */
	.octa 0x1
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffffffc0
	/* C25 */
	.octa 0x1
	/* C30 */
	.octa 0xc000000051c210120000000000001012
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000101700200000000000200040
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac0001e // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:30 Rn:0 101101011000000000000:101101011000000000000 sf:0
	.inst 0x8241dac2 // ASTR-R.RI-32 Rt:2 Rn:22 op:10 imm9:000011101 L:0 1000001001:1000001001
	.inst 0xc2c5332b // CVTP-R.C-C Rd:11 Cn:25 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c33bde // SCBNDS-C.CI-C Cd:30 Cn:30 1110:1110 S:0 imm6:000110 11000010110:11000010110
	.inst 0x7d374422 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:2 Rn:1 imm12:110111010001 opc:00 111101:111101 size:01
	.inst 0xc2c591c1 // CVTD-C.R-C Cd:1 Rn:14 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x089f7c00 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2cdf85e // SCBNDS-C.CI-S Cd:30 Cn:2 1110:1110 S:1 imm6:011011 11000010110:11000010110
	.inst 0xad00783e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:1 Rt2:11110 imm7:0000000 L:0 1011010:1011010 opc:10
	.inst 0x787e13df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21120
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010f6 // ldr c22, [x7, #4]
	.inst 0xc24014f9 // ldr c25, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q2, =0x0
	ldr q30, =0x6800000000000000ed400000
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603127 // ldr c7, [c9, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601127 // ldr c7, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x9, #0xf
	and x7, x7, x9
	cmp x7, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e9 // ldr c9, [x7, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004e9 // ldr c9, [x7, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24010e9 // ldr c9, [x7, #4]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc24014e9 // ldr c9, [x7, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24018e9 // ldr c9, [x7, #6]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2401ce9 // ldr c9, [x7, #7]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x9, v2.d[0]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x0
	mov x9, v2.d[1]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0xed400000
	mov x9, v30.d[0]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x68000000
	mov x9, v30.d[1]
	cmp x7, x9
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
	ldr x0, =0x00001034
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001700
	ldr x1, =check_data2
	ldr x2, =0x00001701
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
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
