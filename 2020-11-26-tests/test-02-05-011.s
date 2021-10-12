.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x73, 0x7d, 0xa8, 0xc8, 0xc2, 0x53, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x1f, 0xfc, 0x3f, 0x42, 0x6b, 0xf4, 0x70, 0xf9, 0x5d, 0x84, 0xc7, 0x78, 0xee, 0xfb, 0x16, 0x39
	.byte 0x09, 0xfc, 0x5f, 0x42, 0x0c, 0x7b, 0x12, 0x38, 0x1d, 0x00, 0x01, 0x5a, 0x4e, 0xf7, 0x8e, 0xf2
	.byte 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010a0
	/* C2 */
	.octa 0x4ffffc
	/* C3 */
	.octa 0x406108
	/* C8 */
	.octa 0xffffffffffffffff
	/* C11 */
	.octa 0xc0000000400000010000000000001000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C24 */
	.octa 0x10d9
	/* C30 */
	.octa 0x20008000200740030000000000480000
final_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010a0
	/* C2 */
	.octa 0x500074
	/* C3 */
	.octa 0x406108
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x77ba
	/* C24 */
	.octa 0x10d9
	/* C30 */
	.octa 0x20008000200740030000000000480000
initial_SP_EL3_value:
	.octa 0xd0c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8a87d73 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:19 Rn:11 11111:11111 o0:0 Rs:8 1:1 L:0 0010001:0010001 size:11
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 524280
	.inst 0x423ffc1f // ASTLR-R.R-32 Rt:31 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xf970f46b // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:3 imm12:110000111101 opc:01 111001:111001 size:11
	.inst 0x78c7845d // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:2 01:01 imm9:001111000 0:0 opc:11 111000:111000 size:01
	.inst 0x3916fbee // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:31 imm12:010110111110 opc:00 111001:111001 size:00
	.inst 0x425ffc09 // LDAR-C.R-C Ct:9 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x38127b0c // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:24 10:10 imm9:100100111 0:0 opc:00 111000:111000 size:00
	.inst 0x5a01001d // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:0 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:0
	.inst 0xf28ef74e // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:0111011110111010 hw:00 100101:100101 opc:11 sf:1
	.inst 0xc2c21240
	.zero 524252
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc24018ee // ldr c14, [x7, #6]
	.inst 0xc2401cf8 // ldr c24, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603247 // ldr c7, [c18, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601247 // ldr c7, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f2 // ldr c18, [x7, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004f2 // ldr c18, [x7, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc24008f2 // ldr c18, [x7, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400cf2 // ldr c18, [x7, #3]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc24010f2 // ldr c18, [x7, #4]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc24014f2 // ldr c18, [x7, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc24018f2 // ldr c18, [x7, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401cf2 // ldr c18, [x7, #7]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc24020f2 // ldr c18, [x7, #8]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc24024f2 // ldr c18, [x7, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x000010a0
	ldr x1, =check_data1
	ldr x2, =0x000010b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012ca
	ldr x1, =check_data2
	ldr x2, =0x000012cb
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040c2f0
	ldr x1, =check_data4
	ldr x2, =0x0040c2f8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
