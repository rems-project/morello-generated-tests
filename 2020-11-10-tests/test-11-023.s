.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xd8, 0x2f, 0xc2, 0x1a, 0x1e, 0xa6, 0xc9, 0x38, 0x1f, 0xe9, 0xde, 0xc2, 0x1e, 0x62, 0xc0, 0xc2
	.byte 0xe1, 0xa3, 0x45, 0xe2, 0x02, 0x00, 0x1d, 0x3a, 0xe5, 0x07, 0xc0, 0x5a, 0x21, 0xe0, 0xc7, 0xc2
	.byte 0xdf, 0x02, 0xe5, 0xc2, 0xff, 0xf6, 0x1a, 0x82, 0x80, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x210000200000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C8 */
	.octa 0x1fa0
	/* C16 */
	.octa 0x800000000007400e0000000000413ff0
	/* C22 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x210000200000
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x1fa0
	/* C16 */
	.octa 0x800000000007400e000000000041408a
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x800000000007400e0000210000608010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac22fd8 // rorv:aarch64/instrs/integer/shift/variable Rd:24 Rn:30 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0x38c9a61e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:16 01:01 imm9:010011010 0:0 opc:11 111000:111000 size:00
	.inst 0xc2dee91f // CTHI-C.CR-C Cd:31 Cn:8 1010:1010 opc:11 Rm:30 11000010110:11000010110
	.inst 0xc2c0621e // SCOFF-C.CR-C Cd:30 Cn:16 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0xe245a3e1 // ASTURH-R.RI-32 Rt:1 Rn:31 op2:00 imm9:001011010 V:0 op1:01 11100010:11100010
	.inst 0x3a1d0002 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:0 000000:000000 Rm:29 11010000:11010000 S:1 op:0 sf:0
	.inst 0x5ac007e5 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:5 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c7e021 // SCFLGS-C.CR-C Cd:1 Cn:1 111000:111000 Rm:7 11000010110:11000010110
	.inst 0xc2e502df // BICFLGS-C.CI-C Cd:31 Cn:22 0:0 00:00 imm8:00101000 11000010111:11000010111
	.inst 0x821af6ff // LDR-C.I-C Ct:31 imm17:01101011110110111 1000001000:1000001000
	.inst 0xc2c21380
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc8 // ldr c8, [x6, #3]
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085103f
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603386 // ldr c6, [c28, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601386 // ldr c6, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000dc // ldr c28, [x6, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24004dc // ldr c28, [x6, #1]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc24008dc // ldr c28, [x6, #2]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2400cdc // ldr c28, [x6, #3]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc24010dc // ldr c28, [x6, #4]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffa
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00413ff0
	ldr x1, =check_data2
	ldr x2, =0x00413ff1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004d7b90
	ldr x1, =check_data3
	ldr x2, =0x004d7ba0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
