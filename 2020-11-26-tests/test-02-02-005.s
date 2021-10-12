.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe6, 0x0f
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe1, 0x0f, 0x35, 0x22, 0xa1, 0xf7, 0x2c, 0xa8, 0x01, 0x61, 0xd9, 0xc2, 0x32, 0x30, 0xc5, 0xc2
	.byte 0x51, 0xa1, 0x01, 0x38, 0x81, 0x84, 0xdf, 0xc2, 0xf7, 0xcb, 0x55, 0x38, 0xf4, 0x03, 0xb0, 0x78
	.byte 0xd5, 0x9f, 0x66, 0x51, 0xcb, 0x63, 0x6a, 0x78, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x700070000000000008001
	/* C8 */
	.octa 0x100001a0030012000000000000
	/* C10 */
	.octa 0xfe6
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C25 */
	.octa 0x12000000000000
	/* C29 */
	.octa 0x1248
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x100001a0030012000000000000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x700070000000000008001
	/* C8 */
	.octa 0x100001a0030012000000000000
	/* C10 */
	.octa 0xfe6
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xff65a000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x12000000000000
	/* C29 */
	.octa 0x1248
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x400100010000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000060100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000003000700ffe00000004060
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22350fe1 // STXP-R.CR-C Ct:1 Rn:31 Ct2:00011 0:0 Rs:21 1:1 L:0 001000100:001000100
	.inst 0xa82cf7a1 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:29 Rt2:11101 imm7:1011001 L:0 1010000:1010000 opc:10
	.inst 0xc2d96101 // SCOFF-C.CR-C Cd:1 Cn:8 000:000 opc:11 0:0 Rm:25 11000010110:11000010110
	.inst 0xc2c53032 // CVTP-R.C-C Rd:18 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x3801a151 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:10 00:00 imm9:000011010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2df8481 // CHKSS-_.CC-C 00001:00001 Cn:4 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0x3855cbf7 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:31 10:10 imm9:101011100 0:0 opc:01 111000:111000 size:00
	.inst 0x78b003f4 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:31 00:00 opc:000 0:0 Rs:16 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x51669fd5 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:30 imm12:100110100111 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x786a63cb // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:30 00:00 opc:110 0:0 Rs:10 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c21360
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
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2401b91 // ldr c17, [x28, #6]
	.inst 0xc2401f99 // ldr c25, [x28, #7]
	.inst 0xc240239d // ldr c29, [x28, #8]
	.inst 0xc240279e // ldr c30, [x28, #9]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337c // ldr c28, [c27, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260137c // ldr c28, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	mov x27, #0xf
	and x28, x28, x27
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039b // ldr c27, [x28, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240079b // ldr c27, [x28, #1]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc2400b9b // ldr c27, [x28, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400f9b // ldr c27, [x28, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240179b // ldr c27, [x28, #5]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240239b // ldr c27, [x28, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240279b // ldr c27, [x28, #9]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402b9b // ldr c27, [x28, #10]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc2402f9b // ldr c27, [x28, #11]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240339b // ldr c27, [x28, #12]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240379b // ldr c27, [x28, #13]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2403b9b // ldr c27, [x28, #14]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000175c
	ldr x1, =check_data2
	ldr x2, =0x0000175d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001802
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
