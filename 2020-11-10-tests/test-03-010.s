.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xc8, 0x33, 0xc0, 0xc2, 0xdf, 0x1e, 0x52, 0xb9, 0xf9, 0x37, 0x14, 0xe2, 0x32, 0xf1, 0xc0, 0xc2
	.byte 0xc0, 0x13, 0xc5, 0xc2, 0x20, 0x41, 0x6c, 0xb8, 0x3f, 0x52, 0x6f, 0x82, 0xd2, 0x7e, 0x5f, 0x08
	.byte 0x8e, 0x6a, 0x8f, 0x38, 0x55, 0xbf, 0x4a, 0xa2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C9 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x901000005fa003a20000000000001040
	/* C20 */
	.octa 0x404008
	/* C22 */
	.octa 0x400000
	/* C26 */
	.octa 0x800
	/* C30 */
	.octa 0x124070000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C8 */
	.octa 0x5c00000000000000
	/* C9 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x901000005fa003a20000000000001040
	/* C18 */
	.octa 0xc8
	/* C20 */
	.octa 0x404008
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x400000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x12b0
	/* C30 */
	.octa 0x124070000000000000000
initial_SP_EL3_value:
	.octa 0x80000000000300070000000000500000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000006000500ffffffff800001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012b0
	.dword 0x0000000000001f90
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c033c8 // GCLEN-R.C-C Rd:8 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xb9521edf // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:22 imm12:010010000111 opc:01 111001:111001 size:10
	.inst 0xe21437f9 // ALDURB-R.RI-32 Rt:25 Rn:31 op2:01 imm9:101000011 V:0 op1:00 11100010:11100010
	.inst 0xc2c0f132 // GCTYPE-R.C-C Rd:18 Cn:9 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c513c0 // CVTD-R.C-C Rd:0 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xb86c4120 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:9 00:00 opc:100 0:0 Rs:12 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826f523f // ALDR-C.RI-C Ct:31 Rn:17 op:00 imm9:011110101 L:1 1000001001:1000001001
	.inst 0x085f7ed2 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:18 Rn:22 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x388f6a8e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:14 Rn:20 10:10 imm9:011110110 0:0 opc:10 111000:111000 size:00
	.inst 0xa24abf55 // LDR-C.RIBW-C Ct:21 Rn:26 11:11 imm9:010101011 0:0 opc:01 10100010:10100010
	.inst 0xc2c21060
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
	.inst 0xc2400389 // ldr c9, [x28, #0]
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2400b91 // ldr c17, [x28, #2]
	.inst 0xc2400f94 // ldr c20, [x28, #3]
	.inst 0xc2401396 // ldr c22, [x28, #4]
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307c // ldr c28, [c3, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260107c // ldr c28, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x3, #0xf
	and x28, x28, x3
	cmp x28, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400383 // ldr c3, [x28, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400f83 // ldr c3, [x28, #3]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401383 // ldr c3, [x28, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401783 // ldr c3, [x28, #5]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401b83 // ldr c3, [x28, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401f83 // ldr c3, [x28, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402383 // ldr c3, [x28, #8]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402783 // ldr c3, [x28, #9]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2402b83 // ldr c3, [x28, #10]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402f83 // ldr c3, [x28, #11]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2403383 // ldr c3, [x28, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x000012b0
	ldr x1, =check_data1
	ldr x2, =0x000012c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f90
	ldr x1, =check_data2
	ldr x2, =0x00001fa0
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
	ldr x0, =0x0040121c
	ldr x1, =check_data4
	ldr x2, =0x00401220
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004040fe
	ldr x1, =check_data5
	ldr x2, =0x004040ff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fff43
	ldr x1, =check_data6
	ldr x2, =0x004fff44
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
