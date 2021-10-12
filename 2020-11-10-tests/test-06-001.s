.section data0, #alloc, #write
	.byte 0x00, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 128
	.byte 0xf0, 0xff, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0xd0, 0x00, 0x50, 0x00, 0x80, 0x00, 0x20
	.zero 1120
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 2800
.data
check_data0:
	.byte 0x00, 0x1f, 0x00, 0x00
.data
check_data1:
	.byte 0xf0, 0xff, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0xd0, 0x00, 0x50, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x21, 0x82, 0xde, 0xc2, 0x5f, 0xe8, 0xde, 0xc2, 0x01, 0x7c, 0x5f, 0x42, 0xc0, 0x33, 0xd1, 0xc2
.data
check_data5:
	.byte 0x60, 0x32, 0xe0, 0x78, 0x1f, 0xfc, 0xbe, 0x48, 0xff, 0x30, 0x7e, 0xb8, 0xba, 0xfc, 0x02, 0xc8
	.byte 0x29, 0x70, 0xc6, 0xc2, 0x02, 0xc4, 0x4c, 0xf8, 0x80, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1500
	/* C5 */
	.octa 0x4ffa10
	/* C7 */
	.octa 0x1000
	/* C19 */
	.octa 0x1000
	/* C30 */
	.octa 0x90000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1fcc
	/* C1 */
	.octa 0x101800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x4ffa10
	/* C7 */
	.octa 0x1000
	/* C9 */
	.octa 0x101800000000000000000000000
	/* C19 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001e0640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000090000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001090
	.dword initial_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de8221 // SCTAG-C.CR-C Cd:1 Cn:17 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0xc2dee85f // CTHI-C.CR-C Cd:31 Cn:2 1010:1010 opc:11 Rm:30 11000010110:11000010110
	.inst 0x425f7c01 // ALDAR-C.R-C Ct:1 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2d133c0 // BR-CI-C 0:0 0000:0000 Cn:30 100:100 imm7:0001001 110000101101:110000101101
	.zero 65504
	.inst 0x78e03260 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:19 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x48befc1f // cash:aarch64/instrs/memory/atomicops/cas/single Rt:31 Rn:0 11111:11111 o0:1 Rs:30 1:1 L:0 0010001:0010001 size:01
	.inst 0xb87e30ff // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:011 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc802fcba // stlxr:aarch64/instrs/memory/exclusive/single Rt:26 Rn:5 Rt2:11111 o0:1 Rs:2 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c67029 // CLRPERM-C.CI-C Cd:9 Cn:1 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0xf84cc402 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:011001100 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c21380
	.zero 983028
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc240131e // ldr c30, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603398 // ldr c24, [c28, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601398 // ldr c24, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031c // ldr c28, [x24, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240071c // ldr c28, [x24, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b1c // ldr c28, [x24, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f1c // ldr c28, [x24, #3]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240131c // ldr c28, [x24, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401b1c // ldr c28, [x24, #6]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001500
	ldr x1, =check_data2
	ldr x2, =0x00001510
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f00
	ldr x1, =check_data3
	ldr x2, =0x00001f08
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
	ldr x0, =0x0040fff0
	ldr x1, =check_data5
	ldr x2, =0x0041000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffa10
	ldr x1, =check_data6
	ldr x2, =0x004ffa18
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
