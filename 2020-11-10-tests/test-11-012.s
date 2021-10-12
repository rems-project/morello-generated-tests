.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xe5, 0x10
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0xbd, 0x34, 0x12, 0x78, 0x24, 0x38, 0x5e, 0x38, 0xbf, 0x7c, 0xc0, 0x9b, 0x3f, 0xe4, 0x9a, 0x1a
	.byte 0x16, 0x79, 0x89, 0x52, 0xd1, 0x1a, 0xd4, 0xc2, 0x00, 0x30, 0x52, 0xe2, 0xf9, 0xc0, 0x55, 0x78
	.byte 0x3c, 0xc0, 0xbf, 0xf8, 0x72, 0x81, 0x55, 0x82, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010e5
	/* C1 */
	.octa 0x4ffff0
	/* C5 */
	.octa 0x1004
	/* C7 */
	.octa 0x18a0
	/* C11 */
	.octa 0x48000000000100050000000000000a60
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010e5
	/* C1 */
	.octa 0x4ffff0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xf27
	/* C7 */
	.octa 0x18a0
	/* C11 */
	.octa 0x48000000000100050000000000000a60
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0x4bc8
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x781234bd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:5 01:01 imm9:100100011 0:0 opc:00 111000:111000 size:01
	.inst 0x385e3824 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:111100011 0:0 opc:01 111000:111000 size:00
	.inst 0x9bc07cbf // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:5 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0x1a9ae43f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:1 o2:1 0:0 cond:1110 Rm:26 011010100:011010100 op:0 sf:0
	.inst 0x52897916 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:22 imm16:0100101111001000 hw:00 100101:100101 opc:10 sf:0
	.inst 0xc2d41ad1 // ALIGND-C.CI-C Cd:17 Cn:22 0110:0110 U:0 imm6:101000 11000010110:11000010110
	.inst 0xe2523000 // ASTURH-R.RI-32 Rt:0 Rn:0 op2:00 imm9:100100011 V:0 op1:01 11100010:11100010
	.inst 0x7855c0f9 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:7 00:00 imm9:101011100 0:0 opc:01 111000:111000 size:01
	.inst 0xf8bfc03c // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:28 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0x82558172 // ASTR-C.RI-C Ct:18 Rn:11 op:00 imm9:101011000 L:0 1000001001:1000001001
	.inst 0xc2c210c0
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2400c47 // ldr c7, [x2, #3]
	.inst 0xc240104b // ldr c11, [x2, #4]
	.inst 0xc2401452 // ldr c18, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c2 // ldr c2, [c6, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x826010c2 // ldr c2, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400046 // ldr c6, [x2, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400446 // ldr c6, [x2, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400846 // ldr c6, [x2, #2]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400c46 // ldr c6, [x2, #3]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2401046 // ldr c6, [x2, #4]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2401446 // ldr c6, [x2, #5]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401846 // ldr c6, [x2, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401c46 // ldr c6, [x2, #7]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2402046 // ldr c6, [x2, #8]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2402446 // ldr c6, [x2, #9]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402846 // ldr c6, [x2, #10]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402c46 // ldr c6, [x2, #11]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
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
	ldr x0, =0x004fffd3
	ldr x1, =check_data5
	ldr x2, =0x004fffd4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
