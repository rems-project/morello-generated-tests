.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x80, 0x99, 0xff, 0xc2, 0xe1, 0x53, 0x18, 0x38, 0x44, 0x14, 0x0e, 0xc2, 0x56, 0xd8, 0x6d, 0x78
	.byte 0xf3, 0x03, 0x01, 0x9a, 0x18, 0x78, 0xd6, 0xc2, 0xd0, 0xe3, 0x5b, 0xe2, 0x70, 0x0d, 0xc0, 0xda
	.byte 0xed, 0x53, 0xe0, 0x78, 0x01, 0x30, 0xc2, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffd900
	/* C4 */
	.octa 0x10000000000000000000000000
	/* C12 */
	.octa 0x200
	/* C13 */
	.octa 0x1ba0
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000400000020000000000001044
final_cap_values:
	/* C0 */
	.octa 0x200
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffd900
	/* C4 */
	.octa 0x10000000000000000000000000
	/* C12 */
	.octa 0x200
	/* C13 */
	.octa 0x10
	/* C19 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x44c002000000000000000200
	/* C30 */
	.octa 0x40000000400000020000000000001044
initial_SP_EL3_value:
	.octa 0x115c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400200b10000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ff9980 // SUBS-R.CC-C Rd:0 Cn:12 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x381853e1 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:110000101 0:0 opc:00 111000:111000 size:00
	.inst 0xc20e1444 // STR-C.RIB-C Ct:4 Rn:2 imm12:001110000101 L:0 110000100:110000100
	.inst 0x786dd856 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:22 Rn:2 10:10 S:1 option:110 Rm:13 1:1 opc:01 111000:111000 size:01
	.inst 0x9a0103f3 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:19 Rn:31 000000:000000 Rm:1 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2d67818 // SCBNDS-C.CI-S Cd:24 Cn:0 1110:1110 S:1 imm6:101100 11000010110:11000010110
	.inst 0xe25be3d0 // ASTURH-R.RI-32 Rt:16 Rn:30 op2:00 imm9:110111110 V:0 op1:01 11100010:11100010
	.inst 0xdac00d70 // rev:aarch64/instrs/integer/arithmetic/rev Rd:16 Rn:11 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0x78e053ed // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:31 00:00 opc:101 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c210e0
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc240114d // ldr c13, [x10, #4]
	.inst 0xc2401550 // ldr c16, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ea // ldr c10, [c7, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010ea // ldr c10, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x7, #0xf
	and x10, x10, x7
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400147 // ldr c7, [x10, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401547 // ldr c7, [x10, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401947 // ldr c7, [x10, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401d47 // ldr c7, [x10, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402147 // ldr c7, [x10, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402547 // ldr c7, [x10, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e1
	ldr x1, =check_data2
	ldr x2, =0x000010e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001150
	ldr x1, =check_data3
	ldr x2, =0x00001160
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
