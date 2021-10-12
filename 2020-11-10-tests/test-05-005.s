.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xba, 0x83, 0x79, 0xb6
.data
check_data4:
	.byte 0x2d, 0x7e, 0xa0, 0xa2, 0xe0, 0xe0, 0xcc, 0x22, 0x21, 0xfc, 0x57, 0x3c, 0x20, 0x00, 0xcc, 0xc2
	.byte 0x2c, 0x7f, 0x41, 0x9b, 0x05, 0xd8, 0x9d, 0xa8, 0xde, 0x93, 0xc1, 0xc2, 0x21, 0x12, 0xc2, 0xc2
	.byte 0x42, 0x94, 0x4d, 0x82, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C1 */
	.octa 0x1879
	/* C2 */
	.octa 0x40000000580600040000000000001000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x1010
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x1010
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x19d0
	/* C1 */
	.octa 0x17f8
	/* C2 */
	.octa 0x40000000580600040000000000001000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x11a0
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x1010
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8100000600407fc00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb67983ba // tbz:aarch64/instrs/branch/conditional/test Rt:26 imm14:00110000011101 b40:01111 op:0 011011:011011 b5:1
	.zero 12400
	.inst 0xa2a07e2d // CAS-C.R-C Ct:13 Rn:17 11111:11111 R:0 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0x22cce0e0 // LDP-CC.RIAW-C Ct:0 Rn:7 Ct2:11000 imm7:0011001 L:1 001000101:001000101
	.inst 0x3c57fc21 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:1 11:11 imm9:101111111 0:0 opc:01 111100:111100 size:00
	.inst 0xc2cc0020 // SCBNDS-C.CR-C Cd:0 Cn:1 000:000 opc:00 0:0 Rm:12 11000010110:11000010110
	.inst 0x9b417f2c // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:12 Rn:25 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0xa89dd805 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:5 Rn:0 Rt2:10110 imm7:0111011 L:0 1010001:1010001 opc:10
	.inst 0xc2c193de // CLRTAG-C.C-C Cd:30 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c21221 // CHKSLD-C-C 00001:00001 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x824d9442 // ASTRB-R.RI-B Rt:2 Rn:2 op:01 imm9:011011001 L:0 1000001001:1000001001
	.inst 0xc2c21060
	.zero 1036132
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
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc24011e7 // ldr c7, [x15, #4]
	.inst 0xc24015ed // ldr c13, [x15, #5]
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc24021fa // ldr c26, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306f // ldr c15, [c3, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260106f // ldr c15, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x15, x15, x3
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e3 // ldr c3, [x15, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005e3 // ldr c3, [x15, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400de3 // ldr c3, [x15, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24011e3 // ldr c3, [x15, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24015e3 // ldr c3, [x15, #5]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc24019e3 // ldr c3, [x15, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401de3 // ldr c3, [x15, #7]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc24021e3 // ldr c3, [x15, #8]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24025e3 // ldr c3, [x15, #9]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x3, v1.d[0]
	cmp x15, x3
	b.ne comparison_fail
	ldr x15, =0x0
	mov x3, v1.d[1]
	cmp x15, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d9
	ldr x1, =check_data1
	ldr x2, =0x000010da
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x00001808
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403074
	ldr x1, =check_data4
	ldr x2, =0x0040309c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
