.section data0, #alloc, #write
	.zero 80
	.byte 0x21, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfb, 0x3f, 0x00, 0x80, 0x00, 0x20
	.zero 4000
.data
check_data0:
	.byte 0x40, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x21, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfb, 0x3f, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x41, 0x7f, 0xeb, 0xc8, 0xfe, 0xff, 0x10, 0x48, 0x1e, 0x30, 0xc5, 0xc2, 0x3f, 0x30, 0xc4, 0xc2
.data
check_data5:
	.byte 0xbf, 0x03, 0x65, 0x38, 0x3e, 0xc6, 0x9e, 0x82, 0x60, 0x51, 0xc3, 0xc2, 0x7d, 0x47, 0x22, 0xc8
	.byte 0x3e, 0x48, 0x20, 0xa2, 0x62, 0x88, 0x02, 0x8b, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd01000005eb00fd30000000000001040
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0xffffffffffc00810
	/* C26 */
	.octa 0x800
	/* C27 */
	.octa 0x40000000000780170000000000408010
	/* C29 */
	.octa 0xc0000000000100050000000000001ed0
final_cap_values:
	/* C0 */
	.octa 0x1000000000000000000000000
	/* C1 */
	.octa 0xd01000005eb00fd30000000000001040
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C17 */
	.octa 0xffffffffffc00810
	/* C26 */
	.octa 0x800
	/* C27 */
	.octa 0x40000000000780170000000000408010
	/* C29 */
	.octa 0xc0000000000100050000000000001ed0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x804
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005204080000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8eb7f41 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:26 11111:11111 o0:0 Rs:11 1:1 L:1 0010001:0010001 size:11
	.inst 0x4810fffe // stlxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:31 Rt2:11111 o0:1 Rs:16 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c5301e // CVTP-R.C-C Rd:30 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c4303f // LDPBLR-C.C-C Ct:31 Cn:1 100:100 opc:01 11000010110001000:11000010110001000
	.zero 16
	.inst 0x386503bf // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:000 o3:0 Rs:5 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x829ec63e // ALDRSB-R.RRB-64 Rt:30 Rn:17 opc:01 S:0 option:110 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xc2c35160 // SEAL-C.CI-C Cd:0 Cn:11 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xc822477d // stxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:27 Rt2:10001 o0:0 Rs:2 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xa220483e // STR-C.RRB-C Ct:30 Rn:1 10:10 S:0 option:010 Rm:0 1:1 opc:00 10100010:10100010
	.inst 0x8b028862 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:3 imm6:100010 Rm:2 0:0 shift:00 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c211e0
	.zero 1048516
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc24011b1 // ldr c17, [x13, #4]
	.inst 0xc24015ba // ldr c26, [x13, #5]
	.inst 0xc24019bb // ldr c27, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x84
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ed // ldr c13, [c15, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826011ed // ldr c13, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x15, #0xf
	and x13, x13, x15
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001af // ldr c15, [x13, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24005af // ldr c15, [x13, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24009af // ldr c15, [x13, #2]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc24011af // ldr c15, [x13, #4]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc24015af // ldr c15, [x13, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc24019af // ldr c15, [x13, #6]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2401daf // ldr c15, [x13, #7]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24021af // ldr c15, [x13, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24025af // ldr c15, [x13, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001021
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001060
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ed0
	ldr x1, =check_data3
	ldr x2, =0x00001ed1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400020
	ldr x1, =check_data5
	ldr x2, =0x0040003c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408010
	ldr x1, =check_data6
	ldr x2, =0x00408020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
