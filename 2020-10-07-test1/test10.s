.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x00
.data
check_data5:
	.byte 0x33, 0xd8, 0x31, 0xe2, 0x51, 0x98, 0x56, 0xa2, 0x36, 0xd8, 0x01, 0xca, 0xdc, 0x7c, 0x3f, 0x42
	.byte 0x40, 0x04, 0x08, 0x38, 0x22, 0x13, 0xc7, 0xc2, 0x95, 0x28, 0x2c, 0x98, 0x85, 0xd0, 0xc1, 0xc2
	.byte 0x8c, 0x51, 0x6c, 0x82, 0xc5, 0x52, 0xc6, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2063
	/* C2 */
	.octa 0xc0000000000500070000000000001a00
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x4c0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2063
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x18c0000000002063
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x18c0000000002063
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000003461000500000000a000f001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001110
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe231d833 // ASTUR-V.RI-Q Rt:19 Rn:1 op2:10 imm9:100011101 V:1 op1:00 11100010:11100010
	.inst 0xa2569851 // LDTR-C.RIB-C Ct:17 Rn:2 10:10 imm9:101101001 0:0 opc:01 10100010:10100010
	.inst 0xca01d836 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:1 imm6:110110 Rm:1 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0x423f7cdc // ASTLRB-R.R-B Rt:28 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x38080440 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:2 01:01 imm9:010000000 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c71322 // RRLEN-R.R-C Rd:2 Rn:25 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x982c2895 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:21 imm19:0010110000101000100 011000:011000 opc:10
	.inst 0xc2c1d085 // CPY-C.C-C Cd:5 Cn:4 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x826c518c // ALDR-C.RI-C Ct:12 Rn:12 op:00 imm9:011000101 L:1 1000001001:1000001001
	.inst 0xc2c652c5 // CLRPERM-C.CI-C Cd:5 Cn:22 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f66 // ldr c6, [x27, #3]
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q19, =0x340000000000000000000000000000
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315b // ldr c27, [c10, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260115b // ldr c27, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036a // ldr c10, [x27, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240076a // ldr c10, [x27, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b6a // ldr c10, [x27, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240176a // ldr c10, [x27, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc2401b6a // ldr c10, [x27, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401f6a // ldr c10, [x27, #7]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240236a // ldr c10, [x27, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240276a // ldr c10, [x27, #9]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2402b6a // ldr c10, [x27, #10]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x10, v19.d[0]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x34000000000000
	mov x10, v19.d[1]
	cmp x27, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001110
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a00
	ldr x1, =check_data3
	ldr x2, =0x00001a01
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00458528
	ldr x1, =check_data6
	ldr x2, =0x0045852c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

	.balign 128
vector_table:
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
