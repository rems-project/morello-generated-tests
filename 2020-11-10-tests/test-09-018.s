.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 8
.data
check_data4:
	.byte 0x22, 0x7d, 0x01, 0x48, 0x02, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0x9f, 0x99, 0x2c, 0xa9, 0xcf, 0x58, 0x61, 0x78, 0x13, 0x3b, 0xd5, 0x29, 0xe2, 0x93, 0x1e, 0xf8
	.byte 0x60, 0x32, 0xc0, 0xc2, 0xff, 0x93, 0xc5, 0xc2, 0xc5, 0x78, 0x2f, 0x54
.data
check_data6:
	.byte 0x08, 0x80, 0xd5, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080000003000700000000004210dc
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x1
	/* C9 */
	.octa 0x9
	/* C12 */
	.octa 0xd11
	/* C21 */
	.octa 0x1
	/* C24 */
	.octa 0x15
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x1
	/* C8 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x9
	/* C12 */
	.octa 0xd11
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x1
	/* C24 */
	.octa 0xbd
initial_SP_EL3_value:
	.octa 0xc00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000400900000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000780a140700ffffffffffe2a0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48017d22 // stxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:9 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c25002 // RETS-C-C 00010:00010 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 135380
	.inst 0xa92c999f // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:12 Rt2:00110 imm7:1011001 L:0 1010010:1010010 opc:10
	.inst 0x786158cf // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:15 Rn:6 10:10 S:1 option:010 Rm:1 1:1 opc:01 111000:111000 size:01
	.inst 0x29d53b13 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:24 Rt2:01110 imm7:0101010 L:1 1010011:1010011 opc:00
	.inst 0xf81e93e2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:111101001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c03260 // GCLEN-R.C-C Rd:0 Cn:19 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c593ff // CVTD-C.R-C Cd:31 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x542f78c5 // b_cond:aarch64/instrs/branch/conditional/cond cond:0101 0:0 imm19:0010111101111000110 01010100:01010100
	.zero 388884
	.inst 0xc2d58008 // SCTAG-C.CR-C Cd:8 Cn:0 000:000 0:0 10:10 Rm:21 11000010110:11000010110
	.inst 0xc2c21060
	.zero 524268
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085103d
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307b // ldr c27, [c3, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260107b // ldr c27, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x3, #0x8
	and x27, x27, x3
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400363 // ldr c3, [x27, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f63 // ldr c3, [x27, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401363 // ldr c3, [x27, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401763 // ldr c3, [x27, #5]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401b63 // ldr c3, [x27, #6]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401f63 // ldr c3, [x27, #7]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2402363 // ldr c3, [x27, #8]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2402763 // ldr c3, [x27, #9]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402b63 // ldr c3, [x27, #10]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402f63 // ldr c3, [x27, #11]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000140a
	ldr x1, =check_data0
	ldr x2, =0x0000140c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001410
	ldr x1, =check_data1
	ldr x2, =0x00001412
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014c4
	ldr x1, =check_data2
	ldr x2, =0x000014cc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004210dc
	ldr x1, =check_data5
	ldr x2, =0x004210f8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0048000c
	ldr x1, =check_data6
	ldr x2, =0x00480014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
