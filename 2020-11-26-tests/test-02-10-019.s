.section data0, #alloc, #write
	.zero 704
	.byte 0xd6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3376
.data
check_data0:
	.byte 0x01, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0xd5, 0x1e, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xb7, 0x5c, 0x45, 0x38, 0x21, 0x30, 0xc2, 0xc2, 0xbf, 0xc3, 0x3f, 0xa2, 0xc1, 0x23, 0xe6, 0xb8
	.byte 0x21, 0x28, 0x9d, 0xca, 0xbd, 0x02, 0x1f, 0xfa, 0xf2, 0x63, 0x24, 0xb8, 0x19, 0x2c, 0xde, 0x1a
	.byte 0x81, 0x60, 0x25, 0xb8, 0x20, 0x03, 0x3f, 0xd6
.data
check_data5:
	.byte 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2040040
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x12c0
	/* C5 */
	.octa 0x1e80
	/* C6 */
	.octa 0x4001
	/* C29 */
	.octa 0x19e0
	/* C30 */
	.octa 0x1010
final_cap_values:
	/* C0 */
	.octa 0x2040040
	/* C1 */
	.octa 0xd6
	/* C4 */
	.octa 0x12c0
	/* C5 */
	.octa 0x1ed5
	/* C6 */
	.octa 0x4001
	/* C18 */
	.octa 0x4001
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x400204
	/* C30 */
	.octa 0x400028
initial_SP_EL3_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38455cb7 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:23 Rn:5 11:11 imm9:001010101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c23021 // CHKTGD-C-C 00001:00001 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xa23fc3bf // LDAPR-C.R-C Ct:31 Rn:29 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xb8e623c1 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:010 0:0 Rs:6 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xca9d2821 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:001010 Rm:29 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0xfa1f02bd // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:21 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0xb82463f2 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:31 00:00 opc:110 0:0 Rs:4 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x1ade2c19 // rorv:aarch64/instrs/integer/shift/variable Rd:25 Rn:0 op2:11 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xb8256081 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:4 00:00 opc:110 0:0 Rs:5 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xd63f0320 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:25 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 476
	.inst 0xc2c21100
	.zero 1048056
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc24011a6 // ldr c6, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103f
	msr SCTLR_EL3, x13
	ldr x13, =0x8
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310d // ldr c13, [c8, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260110d // ldr c13, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x8, #0x3
	and x13, x13, x8
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a8 // ldr c8, [x13, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005a8 // ldr c8, [x13, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009a8 // ldr c8, [x13, #2]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400da8 // ldr c8, [x13, #3]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc24011a8 // ldr c8, [x13, #4]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc24015a8 // ldr c8, [x13, #5]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc24019a8 // ldr c8, [x13, #6]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401da8 // ldr c8, [x13, #7]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc24021a8 // ldr c8, [x13, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012c0
	ldr x1, =check_data1
	ldr x2, =0x000012c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019e0
	ldr x1, =check_data2
	ldr x2, =0x000019f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ed5
	ldr x1, =check_data3
	ldr x2, =0x00001ed6
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
	ldr x0, =0x00400204
	ldr x1, =check_data5
	ldr x2, =0x00400208
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
