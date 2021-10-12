.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x12
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xff, 0x71, 0x7e, 0x38, 0x61, 0xc5, 0x43, 0xa2, 0xfe, 0xb0, 0xa1, 0xe2, 0xd3, 0xc3, 0xbf, 0x38
	.byte 0x20, 0x7c, 0xd5, 0x9b, 0x01, 0xf0, 0x27, 0x11, 0x64, 0x81, 0x33, 0xb8, 0x15, 0xc2, 0xbf, 0x78
	.byte 0x40, 0xfc, 0x5f, 0xc8, 0xc3, 0x7f, 0x9f, 0x08, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000400210020000000000001005
	/* C11 */
	.octa 0x1000
	/* C15 */
	.octa 0x1081
	/* C16 */
	.octa 0x1800
	/* C30 */
	.octa 0x1090
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x9fc
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000400210020000000000001005
	/* C11 */
	.octa 0x13c0
	/* C15 */
	.octa 0x1081
	/* C16 */
	.octa 0x1800
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x1090
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410c00000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000007000200fffffffffc0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x387e71ff // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:111 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xa243c561 // LDR-C.RIAW-C Ct:1 Rn:11 01:01 imm9:000111100 0:0 opc:01 10100010:10100010
	.inst 0xe2a1b0fe // ASTUR-V.RI-S Rt:30 Rn:7 op2:00 imm9:000011011 V:1 op1:10 11100010:11100010
	.inst 0x38bfc3d3 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:19 Rn:30 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x9bd57c20 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:1 Ra:11111 0:0 Rm:21 10:10 U:1 10011011:10011011
	.inst 0x1127f001 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:0 imm12:100111111100 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xb8338164 // swp:aarch64/instrs/memory/atomicops/swp Rt:4 Rn:11 100000:100000 Rs:19 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x78bfc215 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:16 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc85ffc40 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0x089f7fc3 // stllrb:aarch64/instrs/memory/ordered Rt:3 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851037
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603225 // ldr c5, [c17, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601225 // ldr c5, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b1 // ldr c17, [x5, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004b1 // ldr c17, [x5, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008b1 // ldr c17, [x5, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400cb1 // ldr c17, [x5, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc24014b1 // ldr c17, [x5, #5]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc24018b1 // ldr c17, [x5, #6]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401cb1 // ldr c17, [x5, #7]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc24020b1 // ldr c17, [x5, #8]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24024b1 // ldr c17, [x5, #9]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc24028b1 // ldr c17, [x5, #10]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402cb1 // ldr c17, [x5, #11]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x17, v30.d[0]
	cmp x5, x17
	b.ne comparison_fail
	ldr x5, =0x0
	mov x17, v30.d[1]
	cmp x5, x17
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001081
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001090
	ldr x1, =check_data3
	ldr x2, =0x00001091
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013c0
	ldr x1, =check_data4
	ldr x2, =0x000013c4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001802
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
