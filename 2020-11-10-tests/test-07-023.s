.section data0, #alloc, #write
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1504
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2544
.data
check_data0:
	.byte 0xff, 0xff
.data
check_data1:
	.byte 0xff
.data
check_data2:
	.byte 0x70
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x76, 0x6c, 0x41, 0x38, 0x01, 0x57, 0x50, 0x38, 0x6f, 0xff, 0xa0, 0x88, 0x72, 0x10, 0x2a, 0x38
	.byte 0x1f, 0x10, 0x73, 0x78, 0xd4, 0xa8, 0xd9, 0xc2, 0xa2, 0x5a, 0xf2, 0xc2, 0xdf, 0x73, 0x21, 0xc8
	.byte 0xd4, 0x20, 0x0c, 0x38, 0xc2, 0x23, 0xbf, 0x38, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C3 */
	.octa 0x1001
	/* C6 */
	.octa 0x800000000000000000001070
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x800320070000000000000000
	/* C24 */
	.octa 0x11f2
	/* C27 */
	.octa 0x1600
	/* C30 */
	.octa 0x1140
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1017
	/* C6 */
	.octa 0x800000000000000000001070
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0xff
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x800320070000000000000000
	/* C22 */
	.octa 0xff
	/* C24 */
	.octa 0x10f7
	/* C27 */
	.octa 0x1600
	/* C30 */
	.octa 0x1140
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000801c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000e00060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38416c76 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:3 11:11 imm9:000010110 0:0 opc:01 111000:111000 size:00
	.inst 0x38505701 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:24 01:01 imm9:100000101 0:0 opc:01 111000:111000 size:00
	.inst 0x88a0ff6f // cas:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:27 11111:11111 o0:1 Rs:0 1:1 L:0 0010001:0010001 size:10
	.inst 0x382a1072 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:3 00:00 opc:001 0:0 Rs:10 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x7873101f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:001 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2d9a8d4 // EORFLGS-C.CR-C Cd:20 Cn:6 1010:1010 opc:10 Rm:25 11000010110:11000010110
	.inst 0xc2f25aa2 // CVTZ-C.CR-C Cd:2 Cn:21 0110:0110 1:1 0:0 Rm:18 11000010111:11000010111
	.inst 0xc82173df // stxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:30 Rt2:11100 o0:0 Rs:1 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x380c20d4 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:6 00:00 imm9:011000010 0:0 opc:00 111000:111000 size:00
	.inst 0x38bf23c2 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:30 00:00 opc:010 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c21120
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc24021db // ldr c27, [x14, #8]
	.inst 0xc24025de // ldr c30, [x14, #9]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312e // ldr c14, [c9, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260112e // ldr c14, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c9 // ldr c9, [x14, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24005c9 // ldr c9, [x14, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24009c9 // ldr c9, [x14, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc24015c9 // ldr c9, [x14, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24019c9 // ldr c9, [x14, #6]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401dc9 // ldr c9, [x14, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24021c9 // ldr c9, [x14, #8]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc24025c9 // ldr c9, [x14, #9]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24029c9 // ldr c9, [x14, #10]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402dc9 // ldr c9, [x14, #11]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc24031c9 // ldr c9, [x14, #12]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc24035c9 // ldr c9, [x14, #13]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001017
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001132
	ldr x1, =check_data2
	ldr x2, =0x00001133
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001140
	ldr x1, =check_data3
	ldr x2, =0x00001150
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000011f2
	ldr x1, =check_data4
	ldr x2, =0x000011f3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001600
	ldr x1, =check_data5
	ldr x2, =0x00001604
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
