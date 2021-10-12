.section data0, #alloc, #write
	.byte 0x49, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00
	.zero 48
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x49, 0xb0, 0xc4, 0xc2, 0x5e, 0xfc, 0xa1, 0xa2, 0x48, 0xb0, 0xc4, 0xc2, 0x41, 0xd8, 0xee, 0x78
	.byte 0x5f, 0x7f, 0x5f, 0x22, 0x5a, 0x16, 0x55, 0xe2, 0x1e, 0x5a, 0xfc, 0xc2, 0x7e, 0x63, 0xa1, 0x4a
	.byte 0x5e, 0x94, 0x2f, 0xe2, 0x1e, 0x7c, 0x3f, 0x42, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000500400010000000000001000
	/* C1 */
	.octa 0xb049
	/* C2 */
	.octa 0x80000000600000010000000000001000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000700070000000000000001
	/* C18 */
	.octa 0x80000000000782070000000000408401
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0xff
	/* C28 */
	.octa 0x3ffe000
	/* C30 */
	.octa 0x4000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x40000000500400010000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000600000010000000000001000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000700070000000000000001
	/* C18 */
	.octa 0x80000000000782070000000000408401
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0xff
	/* C28 */
	.octa 0x3ffe000
	/* C30 */
	.octa 0xffffff00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040785440000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000005044000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c4b049 // LDCT-R.R-_ Rt:9 Rn:2 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xa2a1fc5e // CASL-C.R-C Ct:30 Rn:2 11111:11111 R:1 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c4b048 // LDCT-R.R-_ Rt:8 Rn:2 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0x78eed841 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:2 10:10 S:1 option:110 Rm:14 1:1 opc:11 111000:111000 size:01
	.inst 0x225f7f5f // LDXR-C.R-C Ct:31 Rn:26 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xe255165a // ALDURH-R.RI-32 Rt:26 Rn:18 op2:01 imm9:101010001 V:0 op1:01 11100010:11100010
	.inst 0xc2fc5a1e // CVTZ-C.CR-C Cd:30 Cn:16 0110:0110 1:1 0:0 Rm:28 11000010111:11000010111
	.inst 0x4aa1637e // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:27 imm6:011000 Rm:1 N:1 shift:10 01010:01010 opc:10 sf:0
	.inst 0xe22f945e // ALDUR-V.RI-B Rt:30 Rn:2 op2:01 imm9:011111001 V:1 op1:00 11100010:11100010
	.inst 0x423f7c1e // ASTLRB-R.R-B Rt:30 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c212c0
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400eae // ldr c14, [x21, #3]
	.inst 0xc24012b0 // ldr c16, [x21, #4]
	.inst 0xc24016b2 // ldr c18, [x21, #5]
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc24022bc // ldr c28, [x21, #8]
	.inst 0xc24026be // ldr c30, [x21, #9]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d5 // ldr c21, [c22, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012d5 // ldr c21, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b6 // ldr c22, [x21, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006b6 // ldr c22, [x21, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401eb6 // ldr c22, [x21, #7]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24022b6 // ldr c22, [x21, #8]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc24026b6 // ldr c22, [x21, #9]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402ab6 // ldr c22, [x21, #10]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402eb6 // ldr c22, [x21, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x22, v30.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v30.d[1]
	cmp x21, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f9
	ldr x1, =check_data1
	ldr x2, =0x000010fa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00408352
	ldr x1, =check_data3
	ldr x2, =0x00408354
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
