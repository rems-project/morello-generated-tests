.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x3c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x38, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1f, 0x32, 0x3f, 0x38, 0x02, 0x84, 0x79, 0x28, 0xb7, 0xaf, 0xfb, 0x22, 0xf0, 0xbb, 0x0e, 0x38
	.byte 0x9f, 0x62, 0x60, 0x78, 0xdd, 0x11, 0xbf, 0xc2, 0x9e, 0x38, 0x3c, 0x71, 0xbe, 0x65, 0x0a, 0x11
	.byte 0x1f, 0x60, 0x31, 0x38, 0xbe, 0x73, 0x11, 0x38, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1038
	/* C13 */
	.octa 0x67
	/* C14 */
	.octa 0x200400000000000020e7
	/* C16 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x1004
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1038
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x3c
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x67
	/* C14 */
	.octa 0x200400000000000020e7
	/* C16 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x1004
	/* C23 */
	.octa 0x3c00000000
	/* C29 */
	.octa 0x200400000000000020e7
	/* C30 */
	.octa 0x300
initial_SP_EL3_value:
	.octa 0x1110
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x383f321f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:011 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x28798402 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:0 Rt2:00001 imm7:1110011 L:1 1010000:1010000 opc:00
	.inst 0x22fbafb7 // LDP-CC.RIAW-C Ct:23 Rn:29 Ct2:01011 imm7:1110111 L:1 001000101:001000101
	.inst 0x380ebbf0 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:31 10:10 imm9:011101011 0:0 opc:00 111000:111000 size:00
	.inst 0x7860629f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:110 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2bf11dd // ADD-C.CRI-C Cd:29 Cn:14 imm3:100 option:000 Rm:31 11000010101:11000010101
	.inst 0x713c389e // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:4 imm12:111100001110 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x110a65be // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:13 imm12:001010011001 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x3831601f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:110 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x381173be // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:29 00:00 imm9:100010111 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21320
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc240098e // ldr c14, [x12, #2]
	.inst 0xc2400d90 // ldr c16, [x12, #3]
	.inst 0xc2401191 // ldr c17, [x12, #4]
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc240199d // ldr c29, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103f
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332c // ldr c12, [c25, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260132c // ldr c12, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400199 // ldr c25, [x12, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400599 // ldr c25, [x12, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400999 // ldr c25, [x12, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400d99 // ldr c25, [x12, #3]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401199 // ldr c25, [x12, #4]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401599 // ldr c25, [x12, #5]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401999 // ldr c25, [x12, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401d99 // ldr c25, [x12, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2402199 // ldr c25, [x12, #8]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402599 // ldr c25, [x12, #9]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402999 // ldr c25, [x12, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402d99 // ldr c25, [x12, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x00001039
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011fb
	ldr x1, =check_data2
	ldr x2, =0x000011fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
