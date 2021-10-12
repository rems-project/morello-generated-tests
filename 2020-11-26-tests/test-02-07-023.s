.section data0, #alloc, #write
	.zero 464
	.byte 0x01, 0x01, 0x01, 0x09, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.zero 3136
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 464
.data
check_data0:
	.byte 0x01, 0x01, 0x01, 0x09
.data
check_data1:
	.byte 0x00, 0x01, 0x01, 0x09, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x21, 0x98, 0x61, 0xa9, 0xf9, 0xff, 0xa1, 0xa2, 0xb9, 0x7d, 0xbe, 0xa2, 0x00, 0xbc, 0x77, 0x91
	.byte 0xc1, 0xfc, 0x3f, 0x42, 0x81, 0x31, 0xc5, 0xc2, 0xfd, 0x33, 0xc0, 0xc2, 0xfe, 0x03, 0xfe, 0x38
	.byte 0xff, 0xff, 0x78, 0x82, 0x4c, 0x46, 0xd9, 0x78, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000001d0180060000000000002000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0xdc0000000001000500000000004fffe0
	/* C18 */
	.octa 0x800000005006400b0000000000444ffc
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffffffffffffffffff00
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0xdc0000000001000500000000004fffe0
	/* C18 */
	.octa 0x800000005006400b0000000000444f90
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0xcc0000000001000500000000000011d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa9619821 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:1 Rt2:00110 imm7:1000011 L:1 1010010:1010010 opc:10
	.inst 0xa2a1fff9 // CASL-C.R-C Ct:25 Rn:31 11111:11111 R:1 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0xa2be7db9 // CAS-C.R-C Ct:25 Rn:13 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0x9177bc00 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:0 imm12:110111101111 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x423ffcc1 // ASTLR-R.R-32 Rt:1 Rn:6 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c53181 // CVTP-R.C-C Rd:1 Cn:12 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c033fd // GCLEN-R.C-C Rd:29 Cn:31 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x38fe03fe // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:31 00:00 opc:000 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8278ffff // ALDR-R.RI-64 Rt:31 Rn:31 op:11 imm9:110001111 L:1 1000001001:1000001001
	.inst 0x78d9464c // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:18 01:01 imm9:110010100 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c21340
	.zero 1048500
	.inst 0x000000ff
	.zero 28
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc240054c // ldr c12, [x10, #1]
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2400d52 // ldr c18, [x10, #3]
	.inst 0xc2401159 // ldr c25, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103d
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334a // ldr c10, [c26, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260134a // ldr c10, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x26, #0xf
	and x10, x10, x26
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015a // ldr c26, [x10, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240055a // ldr c26, [x10, #1]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240095a // ldr c26, [x10, #2]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240115a // ldr c26, [x10, #4]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401d5a // ldr c26, [x10, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x000011d0
	ldr x1, =check_data1
	ldr x2, =0x000011e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e18
	ldr x1, =check_data2
	ldr x2, =0x00001e28
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e48
	ldr x1, =check_data3
	ldr x2, =0x00001e50
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
	ldr x0, =0x00444ffc
	ldr x1, =check_data5
	ldr x2, =0x00444ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
