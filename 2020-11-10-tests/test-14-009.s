.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2896
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0xff, 0xff, 0x7f
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
	.zero 960
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x81, 0xff, 0xff, 0x7f
.data
check_data3:
	.byte 0x80
.data
check_data4:
	.byte 0x02, 0xe4, 0xd2, 0x38, 0xdd, 0x03, 0x0f, 0xfa, 0x0d, 0x7e, 0xfd, 0xa2, 0x0c, 0x7c, 0x5f, 0x42
	.byte 0x1b, 0x70, 0xe2, 0xb8, 0x90, 0x08, 0xc0, 0xda, 0x29, 0x50, 0x3f, 0x78, 0x22, 0x28, 0x48, 0x78
	.byte 0xe6, 0x87, 0x1f, 0xa2, 0xc2, 0x33, 0xc7, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001c3e
	/* C1 */
	.octa 0xc0000000000100050000000000001002
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0xd0000000400000010000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001b6c
	/* C1 */
	.octa 0xc0000000000100050000000000001002
	/* C2 */
	.octa 0xffffffffffffffff
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x100
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C27 */
	.octa 0x7fffff81
	/* C29 */
	.octa 0x1000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4c000000000300050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000400124040000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38d2e402 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:100101110 0:0 opc:11 111000:111000 size:00
	.inst 0xfa0f03dd // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:30 000000:000000 Rm:15 11010000:11010000 S:1 op:1 sf:1
	.inst 0xa2fd7e0d // CASA-C.R-C Ct:13 Rn:16 11111:11111 R:0 Cs:29 1:1 L:1 1:1 10100010:10100010
	.inst 0x425f7c0c // ALDAR-C.R-C Ct:12 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xb8e2701b // ldumin:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:0 00:00 opc:111 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xdac00890 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:16 Rn:4 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x783f5029 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:1 00:00 opc:101 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x78482822 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:1 10:10 imm9:010000010 0:0 opc:01 111000:111000 size:01
	.inst 0xa21f87e6 // STR-C.RIAW-C Ct:6 Rn:31 01:01 imm9:111111000 0:0 opc:00 10100010:10100010
	.inst 0xc2c733c2 // RRMASK-R.R-C Rd:2 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c210a0
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
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2400ead // ldr c13, [x21, #3]
	.inst 0xc24012b0 // ldr c16, [x21, #4]
	.inst 0xc24016be // ldr c30, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103f
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b5 // ldr c21, [c5, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010b5 // ldr c21, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc24002a5 // ldr c5, [x21, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006a5 // ldr c5, [x21, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400ea5 // ldr c5, [x21, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc24012a5 // ldr c5, [x21, #4]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc24016a5 // ldr c5, [x21, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401aa5 // ldr c5, [x21, #6]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401ea5 // ldr c5, [x21, #7]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc24022a5 // ldr c5, [x21, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24026a5 // ldr c5, [x21, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001084
	ldr x1, =check_data1
	ldr x2, =0x00001086
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b6c
	ldr x1, =check_data2
	ldr x2, =0x00001b70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c3e
	ldr x1, =check_data3
	ldr x2, =0x00001c3f
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
	ldr x0, =0x00403f70
	ldr x1, =check_data5
	ldr x2, =0x00403f80
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
