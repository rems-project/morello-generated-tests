.section data0, #alloc, #write
	.byte 0x60, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 48
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xa9, 0x20, 0x7f, 0xf8, 0x61, 0x52, 0x34, 0xe2, 0x40, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x31, 0xad, 0x04, 0xa2, 0xc6, 0x33, 0xc1, 0xc2, 0xa0, 0x7c, 0xc2, 0x9b, 0x11, 0x48, 0xab, 0x78
	.byte 0x7e, 0x7f, 0xbe, 0xa2, 0x60, 0xb1, 0xc4, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x20008000580202f500000000004012a0
	/* C5 */
	.octa 0xc0000000400000010000000000001000
	/* C11 */
	.octa 0x1000
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C19 */
	.octa 0x201c
	/* C27 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x20008000580202f500000000004012a0
	/* C5 */
	.octa 0xc0000000400000010000000000001000
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C11 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x201c
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0x4000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d0040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000600001640000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xf87f20a9 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:5 00:00 opc:010 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xe2345261 // ASTUR-V.RI-B Rt:1 Rn:19 op2:00 imm9:101000101 V:1 op1:00 11100010:11100010
	.inst 0xc2c23040 // BLR-C-C 00000:00000 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4752
	.inst 0xa204ad31 // STR-C.RIBW-C Ct:17 Rn:9 11:11 imm9:001001010 0:0 opc:00 10100010:10100010
	.inst 0xc2c133c6 // GCFLGS-R.C-C Rd:6 Cn:30 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9bc27ca0 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:5 Ra:11111 0:0 Rm:2 10:10 U:1 10011011:10011011
	.inst 0x78ab4811 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:17 Rn:0 10:10 S:0 option:010 Rm:11 1:1 opc:10 111000:111000 size:01
	.inst 0xa2be7f7e // CAS-C.R-C Ct:30 Rn:27 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c4b160 // LDCT-R.R-_ Rt:0 Rn:11 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xc2c211e0
	.zero 1043780
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400585 // ldr c5, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x80
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ec // ldr c12, [c15, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ec // ldr c12, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018f // ldr c15, [x12, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240058f // ldr c15, [x12, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240198f // ldr c15, [x12, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401d8f // ldr c15, [x12, #7]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240218f // ldr c15, [x12, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240258f // ldr c15, [x12, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x15, v1.d[0]
	cmp x12, x15
	b.ne comparison_fail
	ldr x12, =0x0
	mov x15, v1.d[1]
	cmp x12, x15
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
	ldr x0, =0x00001f61
	ldr x1, =check_data1
	ldr x2, =0x00001f62
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004012a0
	ldr x1, =check_data3
	ldr x2, =0x004012bc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
