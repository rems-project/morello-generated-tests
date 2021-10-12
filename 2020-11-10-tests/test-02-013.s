.section data0, #alloc, #write
	.zero 2560
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xd2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xfe, 0x73, 0x17, 0x38, 0x52, 0x30, 0xc5, 0xc2, 0x6b, 0x00, 0x1e, 0xba, 0x42, 0x58, 0xc5, 0xc2
	.byte 0x26, 0x30, 0xa1, 0x38, 0x62, 0x91, 0x4c, 0x51, 0xd4, 0x16, 0xc0, 0x5a, 0x16, 0x21, 0x61, 0xb8
	.byte 0xde, 0xcb, 0x02, 0xe2, 0x29, 0xb3, 0xc5, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1200
	/* C2 */
	.octa 0x1000480a3000025fffffffd00
	/* C8 */
	.octa 0x1a00
	/* C25 */
	.octa 0x3fc000
	/* C30 */
	.octa 0x80000000000100050000000000001fd2
final_cap_values:
	/* C1 */
	.octa 0x1200
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x1a00
	/* C9 */
	.octa 0x200080006066e08400000000003fc000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1200
	/* C25 */
	.octa 0x3fc000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1fc1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080006066e0840000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000620000010000000000000000
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
	.inst 0x381773fe // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:101110111 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c53052 // CVTP-R.C-C Rd:18 Cn:2 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xba1e006b // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:11 Rn:3 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c55842 // ALIGNU-C.CI-C Cd:2 Cn:2 0110:0110 U:1 imm6:001010 11000010110:11000010110
	.inst 0x38a13026 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:1 00:00 opc:011 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x514c9162 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:11 imm12:001100100100 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x5ac016d4 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:20 Rn:22 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xb8612116 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:8 00:00 opc:010 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xe202cbde // ALDURSB-R.RI-64 Rt:30 Rn:30 op2:10 imm9:000101100 V:0 op1:00 11100010:11100010
	.inst 0xc2c5b329 // CVTP-C.R-C Cd:9 Rn:25 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c21180
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
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba8 // ldr c8, [x29, #2]
	.inst 0xc2400fb9 // ldr c25, [x29, #3]
	.inst 0xc24013be // ldr c30, [x29, #4]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851037
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319d // ldr c29, [c12, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260119d // ldr c29, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ac // ldr c12, [x29, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24007ac // ldr c12, [x29, #1]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400bac // ldr c12, [x29, #2]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2400fac // ldr c12, [x29, #3]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24017ac // ldr c12, [x29, #5]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2401bac // ldr c12, [x29, #6]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2401fac // ldr c12, [x29, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001201
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a00
	ldr x1, =check_data1
	ldr x2, =0x00001a04
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f38
	ldr x1, =check_data2
	ldr x2, =0x00001f39
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
