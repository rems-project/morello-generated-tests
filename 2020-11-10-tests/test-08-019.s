.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x01
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xdf, 0x62, 0x3f, 0x78, 0x21, 0xed, 0x9f, 0x8a, 0x1c, 0xd0, 0xc0, 0xc2, 0x10, 0x7f, 0x1f, 0x42
	.byte 0x5e, 0x24, 0xd1, 0xc2, 0x41, 0x36, 0x46, 0xb8, 0xb5, 0x7c, 0x5f, 0x42, 0x22, 0x10, 0xc5, 0xc2
	.byte 0x08, 0x38, 0xdf, 0xa9, 0x21, 0x38, 0xd1, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1a08
	/* C2 */
	.octa 0x6002800400ffffffffff8000
	/* C5 */
	.octa 0x900000000001000500000000004fffe0
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1ff8
	/* C22 */
	.octa 0x1028
	/* C24 */
	.octa 0x48000000400000040000000000001120
final_cap_values:
	/* C0 */
	.octa 0x1bf8
	/* C1 */
	.octa 0x402200000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x900000000001000500000000004fffe0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x205b
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1028
	/* C24 */
	.octa 0x48000000400000040000000000001120
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x60028004ffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807004400ffffffffff0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783f62df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x8a9fed21 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:9 imm6:111011 Rm:31 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2c0d01c // GCPERM-R.C-C Rd:28 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x421f7f10 // ASTLR-C.R-C Ct:16 Rn:24 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2d1245e // CPYTYPE-C.C-C Cd:30 Cn:2 001:001 opc:01 0:0 Cm:17 11000010110:11000010110
	.inst 0xb8463641 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:18 01:01 imm9:001100011 0:0 opc:01 111000:111000 size:10
	.inst 0x425f7cb5 // ALDAR-C.R-C Ct:21 Rn:5 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c51022 // CVTD-R.C-C Rd:2 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xa9df3808 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:0 Rt2:01110 imm7:0111110 L:1 1010011:1010011 opc:10
	.inst 0xc2d13821 // SCBNDS-C.CI-C Cd:1 Cn:1 1110:1110 S:0 imm6:100010 11000010110:11000010110
	.inst 0xc2c21080
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2401772 // ldr c18, [x27, #5]
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2401f78 // ldr c24, [x27, #7]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260309b // ldr c27, [c4, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260109b // ldr c27, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	mov x4, #0xf
	and x27, x27, x4
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401364 // ldr c4, [x27, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401764 // ldr c4, [x27, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401b64 // ldr c4, [x27, #6]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401f64 // ldr c4, [x27, #7]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2402364 // ldr c4, [x27, #8]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2402764 // ldr c4, [x27, #9]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2402b64 // ldr c4, [x27, #10]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2402f64 // ldr c4, [x27, #11]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2403364 // ldr c4, [x27, #12]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2403764 // ldr c4, [x27, #13]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x0000102a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001130
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bf8
	ldr x1, =check_data2
	ldr x2, =0x00001c08
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
