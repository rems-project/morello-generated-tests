.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff, 0x00, 0x01, 0xff
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0xff
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xff, 0x01, 0x6e, 0xb8, 0xf4, 0x37, 0x09, 0x38, 0x69, 0x73, 0x7f, 0x22, 0x34, 0x7d, 0x9f, 0x48
	.byte 0xbf, 0x03, 0xbf, 0x78, 0x83, 0x04, 0x20, 0x22, 0x3e, 0x72, 0x51, 0x62, 0x34, 0xff, 0x00, 0xb8
	.byte 0x20, 0x98, 0x04, 0x2d, 0x7f, 0x13, 0x64, 0xb8, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000001000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x411800
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1040
	/* C17 */
	.octa 0x1010
	/* C20 */
	.octa 0xff0100ff
	/* C25 */
	.octa 0x1201
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x1800
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x4000000000000000000000001000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x411800
	/* C9 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1040
	/* C17 */
	.octa 0x1010
	/* C20 */
	.octa 0xff0100ff
	/* C25 */
	.octa 0x1210
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1800
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc1000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001230
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86e01ff // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:000 o3:0 Rs:14 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x380937f4 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:20 Rn:31 01:01 imm9:010010011 0:0 opc:00 111000:111000 size:00
	.inst 0x227f7369 // 0x227f7369
	.inst 0x489f7d34 // stllrh:aarch64/instrs/memory/ordered Rt:20 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x78bf03bf // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:29 00:00 opc:000 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x22200483 // 0x22200483
	.inst 0x6251723e // LDNP-C.RIB-C Ct:30 Rn:17 Ct2:11100 imm7:0100010 L:1 011000100:011000100
	.inst 0xb800ff34 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:25 11:11 imm9:000001111 0:0 opc:00 111000:111000 size:10
	.inst 0x2d049820 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:1 Rt2:00110 imm7:0001001 L:0 1011010:1011010 opc:00
	.inst 0xb864137f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:001 o3:0 Rs:4 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21180
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c3 // ldr c3, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc24012cf // ldr c15, [x22, #4]
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2401ad4 // ldr c20, [x22, #6]
	.inst 0xc2401ed9 // ldr c25, [x22, #7]
	.inst 0xc24022db // ldr c27, [x22, #8]
	.inst 0xc24026dd // ldr c29, [x22, #9]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q0, =0x0
	ldr q6, =0x800
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x3085103d
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603196 // ldr c22, [c12, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601196 // ldr c22, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cc // ldr c12, [x22, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400acc // ldr c12, [x22, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400ecc // ldr c12, [x22, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc24012cc // ldr c12, [x22, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc24016cc // ldr c12, [x22, #5]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401acc // ldr c12, [x22, #6]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2401ecc // ldr c12, [x22, #7]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24022cc // ldr c12, [x22, #8]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24026cc // ldr c12, [x22, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2402acc // ldr c12, [x22, #10]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402ecc // ldr c12, [x22, #11]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24032cc // ldr c12, [x22, #12]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24036cc // ldr c12, [x22, #13]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x12, v0.d[0]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x0
	mov x12, v0.d[1]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x800
	mov x12, v6.d[0]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x0
	mov x12, v6.d[1]
	cmp x22, x12
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x0000102c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001210
	ldr x1, =check_data3
	ldr x2, =0x00001214
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001230
	ldr x1, =check_data4
	ldr x2, =0x00001250
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001400
	ldr x1, =check_data5
	ldr x2, =0x00001401
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001800
	ldr x1, =check_data6
	ldr x2, =0x00001802
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
