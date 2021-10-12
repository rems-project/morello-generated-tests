.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xbe, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf4, 0xff, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x22, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x5f, 0xfd, 0x9f, 0x88, 0xa0, 0xa7, 0x14, 0xa2, 0x13, 0x20, 0x84, 0xb8, 0x21, 0xf7, 0xe8, 0xe2
	.byte 0xbd, 0x00, 0x01, 0x1a, 0x12, 0x7f, 0x5e, 0x9b, 0x75, 0x65, 0xc0, 0xc2, 0x5f, 0x63, 0x21, 0x78
	.byte 0xbf, 0x53, 0xc1, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfff40000000000000000000019be
	/* C1 */
	.octa 0x200080000006000f000000000041fff0
	/* C10 */
	.octa 0x1110
	/* C11 */
	.octa 0x800380070000800000000001
	/* C25 */
	.octa 0x80000000600000000000000000001769
	/* C26 */
	.octa 0x100c
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xfff40000000000000000000019be
	/* C1 */
	.octa 0x200080000006000f000000000041fff0
	/* C10 */
	.octa 0x1110
	/* C11 */
	.octa 0x800380070000800000000001
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x8003800700000000000019be
	/* C25 */
	.octa 0x80000000600000000000000000001769
	/* C26 */
	.octa 0x100c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000007020700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21022 // BRS-C-C 00010:00010 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 131052
	.inst 0x889ffd5f // stlr:aarch64/instrs/memory/ordered Rt:31 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xa214a7a0 // STR-C.RIAW-C Ct:0 Rn:29 01:01 imm9:101001010 0:0 opc:00 10100010:10100010
	.inst 0xb8842013 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:0 00:00 imm9:001000010 0:0 opc:10 111000:111000 size:10
	.inst 0xe2e8f721 // ALDUR-V.RI-D Rt:1 Rn:25 op2:01 imm9:010001111 V:1 op1:11 11100010:11100010
	.inst 0x1a0100bd // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:5 000000:000000 Rm:1 11010000:11010000 S:0 op:0 sf:0
	.inst 0x9b5e7f12 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:18 Rn:24 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xc2c06575 // CPYVALUE-C.C-C Cd:21 Cn:11 001:001 opc:11 0:0 Cm:0 11000010110:11000010110
	.inst 0x7821635f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c153bf // CFHI-R.C-C Rd:31 Cn:29 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c211c0
	.zero 917480
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
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc24019fd // ldr c29, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cf // ldr c15, [c14, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x14, v1.d[0]
	cmp x15, x14
	b.ne comparison_fail
	ldr x15, =0x0
	mov x14, v1.d[1]
	cmp x15, x14
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
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001114
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x00001800
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a00
	ldr x1, =check_data3
	ldr x2, =0x00001a04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0041fff0
	ldr x1, =check_data5
	ldr x2, =0x00420018
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
