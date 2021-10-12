.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x3f, 0x73, 0x2d, 0x38, 0xfb, 0x83, 0xc2, 0xc2, 0x00, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xf4, 0x57, 0x8b, 0x1a, 0x01, 0x1c, 0x8f, 0x38, 0x0d, 0xc8, 0xe5, 0xc2, 0xe7, 0x1b, 0x89, 0xcb
	.byte 0xdf, 0x83, 0x61, 0xa2, 0x42, 0xcb, 0xb0, 0xf8, 0x9f, 0xfd, 0x98, 0xb8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000d000d9fd000000000040fff0
	/* C2 */
	.octa 0x1
	/* C12 */
	.octa 0x400089
	/* C13 */
	.octa 0x0
	/* C25 */
	.octa 0x1012
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x4100e1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C12 */
	.octa 0x400018
	/* C13 */
	.octa 0x2e000000004100e1
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x1012
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x382d733f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:111 o3:0 Rs:13 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c283fb // SCTAG-C.CR-C Cd:27 Cn:31 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 65508
	.inst 0x1a8b57f4 // csinc:aarch64/instrs/integer/conditional/select Rd:20 Rn:31 o2:1 0:0 cond:0101 Rm:11 011010100:011010100 op:0 sf:0
	.inst 0x388f1c01 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:011110001 0:0 opc:10 111000:111000 size:00
	.inst 0xc2e5c80d // ORRFLGS-C.CI-C Cd:13 Cn:0 0:0 01:01 imm8:00101110 11000010111:11000010111
	.inst 0xcb891be7 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:7 Rn:31 imm6:000110 Rm:9 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0xa26183df // SWPL-CC.R-C Ct:31 Rn:30 100000:100000 Cs:1 1:1 R:1 A:0 10100010:10100010
	.inst 0xf8b0cb42 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:26 10:10 S:0 option:110 Rm:16 1:1 opc:10 111000:111000 size:11
	.inst 0xb898fd9f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:12 11:11 imm9:110001111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21220
	.zero 983024
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322f // ldr c15, [c17, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260122f // ldr c15, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x17, #0x8
	and x15, x15, x17
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f1 // ldr c17, [x15, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005f1 // ldr c17, [x15, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401df1 // ldr c17, [x15, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001012
	ldr x1, =check_data1
	ldr x2, =0x00001013
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400018
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040fff0
	ldr x1, =check_data4
	ldr x2, =0x00410010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004100e1
	ldr x1, =check_data5
	ldr x2, =0x004100e2
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
