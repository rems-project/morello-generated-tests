.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x08, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x08
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x9f, 0x02, 0x1d, 0xda, 0x39, 0xa4, 0x9f, 0x5a, 0xc1, 0x84, 0x07, 0x9b, 0xb4, 0xc1, 0xbf, 0xb8
	.byte 0xe1, 0x4f, 0x34, 0xeb, 0xbd, 0x51, 0x1a, 0x82, 0x01, 0x4e, 0x15, 0x38, 0xa8, 0x2f, 0x4f, 0xa2
	.byte 0xff, 0xff, 0x80, 0x82, 0xa1, 0x7d, 0xf0, 0x08, 0x80, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf96
	/* C13 */
	.octa 0x1004
	/* C16 */
	.octa 0x11b0
final_cap_values:
	/* C0 */
	.octa 0xf96
	/* C1 */
	.octa 0x8
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1004
	/* C16 */
	.octa 0x4
	/* C20 */
	.octa 0x4
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1fe0
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000000028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000400400050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda1d029f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:20 000000:000000 Rm:29 11010000:11010000 S:0 op:1 sf:1
	.inst 0x5a9fa439 // csneg:aarch64/instrs/integer/conditional/select Rd:25 Rn:1 o2:1 0:0 cond:1010 Rm:31 011010100:011010100 op:1 sf:0
	.inst 0x9b0784c1 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:6 Ra:1 o0:1 Rm:7 0011011000:0011011000 sf:1
	.inst 0xb8bfc1b4 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:20 Rn:13 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0xeb344fe1 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:31 imm3:011 option:010 Rm:20 01011001:01011001 S:1 op:1 sf:1
	.inst 0x821a51bd // LDR-C.I-C Ct:29 imm17:01101001010001101 1000001000:1000001000
	.inst 0x38154e01 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:16 11:11 imm9:101010100 0:0 opc:00 111000:111000 size:00
	.inst 0xa24f2fa8 // LDR-C.RIBW-C Ct:8 Rn:29 11:11 imm9:011110010 0:0 opc:01 10100010:10100010
	.inst 0x8280ffff // ASTRH-R.RRB-32 Rt:31 Rn:31 opc:11 S:1 option:111 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x08f07da1 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:13 11111:11111 o0:0 Rs:16 1:1 L:1 0010001:0010001 size:00
	.inst 0xc2c21080
	.zero 862388
	.inst 0x000010c0
	.zero 186140
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2400870 // ldr c16, [x3, #2]
	/* Set up flags and system registers */
	mov x3, #0x80000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x4, #0xf
	and x3, x3, x4
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401c64 // ldr c4, [x3, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001104
	ldr x1, =check_data1
	ldr x2, =0x00001105
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f54
	ldr x1, =check_data2
	ldr x2, =0x00001f56
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
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
	ldr x0, =0x004d28e0
	ldr x1, =check_data5
	ldr x2, =0x004d28f0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
