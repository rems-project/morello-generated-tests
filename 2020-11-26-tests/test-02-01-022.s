.section data0, #alloc, #write
	.byte 0xfd, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0xfd, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3920
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xfd, 0x1f
.data
check_data4:
	.byte 0xdf, 0x62, 0x7d, 0x78, 0x03, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xff, 0x03, 0x21, 0x78, 0xfd, 0x53, 0x3e, 0x88, 0xfe, 0x5b, 0xec, 0x82, 0x20, 0x20, 0x46, 0xf8
	.byte 0xb7, 0x43, 0xfd, 0x78, 0x7d, 0x09, 0x41, 0xe2, 0x80, 0xa0, 0xc0, 0xc2, 0xa0, 0xaf, 0x21, 0x0b
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000800b00070000000000450000
	/* C1 */
	.octa 0x1006
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x80000000000100050000000000403fec
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x10a4
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x8030
	/* C1 */
	.octa 0x1006
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x80000000000100050000000000403fec
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x10a4
	/* C23 */
	.octa 0x9ffd
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_RDDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_RSP_EL0_value:
	.octa 0x80000000000700340000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000510401e400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword initial_RDDC_EL0_value
	.dword initial_RSP_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d62df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:110 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21003 // BRR-C-C 00011:00011 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 327672
	.inst 0x782103ff // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x883e53fd // stxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:31 Rt2:10100 o0:0 Rs:30 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x82ec5bfe // ALDR-V.RRB-D Rt:30 Rn:31 opc:10 S:1 option:010 Rm:12 1:1 L:1 100000101:100000101
	.inst 0xf8462020 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:001100010 0:0 opc:01 111000:111000 size:11
	.inst 0x78fd43b7 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:29 00:00 opc:100 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xe241097d // ALDURSH-R.RI-64 Rt:29 Rn:11 op2:10 imm9:000010000 V:0 op1:01 11100010:11100010
	.inst 0xc2c0a080 // CLRPERM-C.CR-C Cd:0 Cn:4 000:000 1:1 10:10 Rm:0 11000010110:11000010110
	.inst 0x0b21afa0 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:29 imm3:011 option:101 Rm:1 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2c21340
	.zero 720860
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	ldr x19, =initial_RDDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28b4333 // msr RDDC_EL0, c19
	ldr x19, =initial_RSP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28f4173 // msr RSP_EL0, c19
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603353 // ldr c19, [c26, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x6
	mov x26, v30.d[0]
	cmp x19, x26
	b.ne comparison_fail
	ldr x19, =0x0
	mov x26, v30.d[1]
	cmp x19, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010a4
	ldr x1, =check_data3
	ldr x2, =0x000010a6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ffc
	ldr x1, =check_data5
	ldr x2, =0x00403ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00450000
	ldr x1, =check_data6
	ldr x2, =0x00450024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
