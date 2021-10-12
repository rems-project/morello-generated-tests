.section data0, #alloc, #write
	.zero 1024
	.byte 0xf1, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf0, 0x1f
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data5:
	.byte 0x9f, 0x66, 0x1e, 0x9b, 0x03, 0x42, 0xa0, 0x78, 0xd4, 0x03, 0xa9, 0x38, 0xca, 0x7d, 0xdf, 0xc8
	.byte 0xe2, 0x13, 0x17, 0x79, 0xda, 0x7b, 0xc0, 0xc2, 0x28, 0x74, 0xc6, 0x68, 0x1e, 0x7c, 0xdf, 0x88
	.byte 0x5e, 0x6c, 0x27, 0x11, 0x0d, 0x50, 0xe1, 0xf8, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1ff0
	/* C1 */
	.octa 0x17ec
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x1ff0
	/* C16 */
	.octa 0x1400
	/* C30 */
	.octa 0x1400000000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1ff0
	/* C1 */
	.octa 0x181c
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x9ff1
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000010101
	/* C13 */
	.octa 0x8000000000010101
	/* C14 */
	.octa 0x1ff0
	/* C16 */
	.octa 0x1400
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0x1500010000000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x9db
initial_SP_EL3_value:
	.octa 0x1410
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b1e669f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:20 Ra:25 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0x78a04203 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:16 00:00 opc:100 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x38a903d4 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:30 00:00 opc:000 0:0 Rs:9 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc8df7dca // ldlar:aarch64/instrs/memory/ordered Rt:10 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x791713e2 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:010111000100 opc:00 111001:111001 size:01
	.inst 0xc2c07bda // SCBNDS-C.CI-S Cd:26 Cn:30 1110:1110 S:1 imm6:000000 11000010110:11000010110
	.inst 0x68c67428 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:8 Rn:1 Rt2:11101 imm7:0001100 L:1 1010001:1010001 opc:01
	.inst 0x88df7c1e // ldlar:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x11276c5e // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:2 imm12:100111011011 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xf8e1500d // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:0 00:00 opc:101 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xc2c21240
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103d
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260325c // ldr c28, [c18, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260125c // ldr c28, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400392 // ldr c18, [x28, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400792 // ldr c18, [x28, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b92 // ldr c18, [x28, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401392 // ldr c18, [x28, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401792 // ldr c18, [x28, #5]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401b92 // ldr c18, [x28, #6]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401f92 // ldr c18, [x28, #7]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2402392 // ldr c18, [x28, #8]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2402792 // ldr c18, [x28, #9]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2402b92 // ldr c18, [x28, #10]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402f92 // ldr c18, [x28, #11]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2403392 // ldr c18, [x28, #12]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403792 // ldr c18, [x28, #13]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001402
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017ec
	ldr x1, =check_data2
	ldr x2, =0x000017f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f98
	ldr x1, =check_data3
	ldr x2, =0x00001f9a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
