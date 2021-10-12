.section data0, #alloc, #write
	.byte 0x41, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
.data
check_data0:
	.byte 0xc1, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x80
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.byte 0xf0, 0x27, 0x3e, 0xd1, 0x0c, 0xfe, 0xdb, 0x38, 0x1a, 0x2e, 0xc0, 0x9a, 0x33, 0x50, 0xbe, 0x78
	.byte 0x9c, 0x43, 0xe1, 0x38, 0xbf, 0x51, 0x7f, 0x78, 0xe1, 0x9b, 0x02, 0xab, 0x2a, 0x00, 0xa8, 0xf8
	.byte 0xe1, 0x63, 0x28, 0x38, 0x22, 0xfc, 0xa1, 0x9b, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x80
	/* C13 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2
	/* C2 */
	.octa 0xfffffffffffffffc
	/* C8 */
	.octa 0x80
	/* C10 */
	.octa 0x8041
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x6
	/* C19 */
	.octa 0x8001
	/* C26 */
	.octa 0x6
	/* C28 */
	.octa 0x41
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xfd0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000e00ffffffffc00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd13e27f0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:31 imm12:111110001001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x38dbfe0c // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:16 11:11 imm9:110111111 0:0 opc:11 111000:111000 size:00
	.inst 0x9ac02e1a // rorv:aarch64/instrs/integer/shift/variable Rd:26 Rn:16 op2:11 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x78be5033 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x38e1439c // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:28 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x787f51bf // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:101 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xab029be1 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:31 imm6:100110 Rm:2 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0xf8a8002a // ldadd:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:1 00:00 opc:000 0:0 Rs:8 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x382863e1 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:110 0:0 Rs:8 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x9ba1fc22 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:1 Ra:31 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xc2c21220
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x3085103d
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
	mov x17, #0xf
	and x15, x15, x17
	cmp x15, #0x4
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
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401df1 // ldr c17, [x15, #7]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24021f1 // ldr c17, [x15, #8]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc24025f1 // ldr c17, [x15, #9]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24029f1 // ldr c17, [x15, #10]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402df1 // ldr c17, [x15, #11]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001fd1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
