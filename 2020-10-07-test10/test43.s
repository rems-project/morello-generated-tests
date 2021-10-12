.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x66, 0xf1, 0x80, 0x82, 0x22, 0x85, 0xa4, 0x79, 0xd0, 0xff, 0x7f, 0x42, 0x20, 0x74, 0xf3, 0xc2
	.byte 0x40, 0x18, 0xfe, 0xc2, 0xff, 0xdb, 0xba, 0xf9, 0xf5, 0x7b, 0x7c, 0x11, 0xff, 0xcb, 0xb5, 0x52
	.byte 0xee, 0x1e, 0x02, 0x78, 0x89, 0x28, 0x81, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x42000000000000000000000000000000
	/* C1 */
	.octa 0xf80
	/* C4 */
	.octa 0x80000000000740070000000000403ff0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000201620070000000000400000
	/* C11 */
	.octa 0xf80
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000040900070000000000000fdf
	/* C30 */
	.octa 0x1280
final_cap_values:
	/* C0 */
	.octa 0x1280
	/* C1 */
	.octa 0xf80
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000740070000000000403ff0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0xf80
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000040900070000000000001000
	/* C30 */
	.octa 0x1280
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000b000000000000b0c0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8280f166 // ASTRB-R.RRB-B Rt:6 Rn:11 opc:00 S:1 option:111 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x79a48522 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:9 imm12:100100100001 opc:10 111001:111001 size:01
	.inst 0x427fffd0 // ALDAR-R.R-32 Rt:16 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2f37420 // ASTR-C.RRB-C Ct:0 Rn:1 1:1 L:0 S:1 option:011 Rm:19 11000010111:11000010111
	.inst 0xc2fe1840 // CVT-C.CR-C Cd:0 Cn:2 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0xf9badbff // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:111010110110 opc:10 111001:111001 size:11
	.inst 0x117c7bf5 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:31 imm12:111100011110 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x52b5cbff // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1010111001011111 hw:01 100101:100101 opc:10 sf:0
	.inst 0x78021eee // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:14 Rn:23 11:11 imm9:000100001 0:0 opc:00 111000:111000 size:01
	.inst 0x78812889 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:4 10:10 imm9:000010010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2401f53 // ldr c19, [x26, #7]
	.inst 0xc2402357 // ldr c23, [x26, #8]
	.inst 0xc240275e // ldr c30, [x26, #9]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307a // ldr c26, [c3, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260107a // ldr c26, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400343 // ldr c3, [x26, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f43 // ldr c3, [x26, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401343 // ldr c3, [x26, #4]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401743 // ldr c3, [x26, #5]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401b43 // ldr c3, [x26, #6]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401f43 // ldr c3, [x26, #7]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2402343 // ldr c3, [x26, #8]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402743 // ldr c3, [x26, #9]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402b43 // ldr c3, [x26, #10]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402f43 // ldr c3, [x26, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001304
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401242
	ldr x1, =check_data3
	ldr x2, =0x00401244
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404002
	ldr x1, =check_data4
	ldr x2, =0x00404004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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

	.balign 128
vector_table:
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
