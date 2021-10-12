.section data0, #alloc, #write
	.zero 3072
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.byte 0xdf, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc0, 0x97, 0x5e, 0xf8, 0x7e, 0x9a, 0xe1, 0xc2, 0x14, 0x50, 0xc0, 0xc2, 0x01, 0x60, 0x88, 0xf8
	.byte 0x60, 0x31, 0xb4, 0x54, 0xd6, 0x51, 0xc6, 0xc2, 0x80, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0xbf, 0x00, 0x7b, 0x78, 0xe1, 0x83, 0x70, 0x39, 0x5b, 0x10, 0x21, 0x78, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1c02
	/* C4 */
	.octa 0x20008000800100070000000000400100
	/* C5 */
	.octa 0x1c02
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0xc0df
	/* C30 */
	.octa 0x800000001007a00f0000000000400000
final_cap_values:
	/* C0 */
	.octa 0xc2e19a7ef85e97c0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1c02
	/* C4 */
	.octa 0x20008000800100070000000000400100
	/* C5 */
	.octa 0x1c02
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xc2e19a7ef85e97c0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0xdf
	/* C30 */
	.octa 0x200080002a210007000000000040001d
initial_SP_EL3_value:
	.octa 0x13de
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002a2100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200100050000000000fc0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf85e97c0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:111101001 0:0 opc:01 111000:111000 size:11
	.inst 0xc2e19a7e // SUBS-R.CC-C Rd:30 Cn:19 100110:100110 Cm:1 11000010111:11000010111
	.inst 0xc2c05014 // GCVALUE-R.C-C Rd:20 Cn:0 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xf8886001 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:010000110 0:0 opc:10 111000:111000 size:11
	.inst 0x54b43160 // b_cond:aarch64/instrs/branch/conditional/cond cond:0000 0:0 imm19:1011010000110001011 01010100:01010100
	.inst 0xc2c651d6 // CLRPERM-C.CI-C Cd:22 Cn:14 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0xc2c23080 // BLR-C-C 00000:00000 Cn:4 100:100 opc:01 11000010110000100:11000010110000100
	.zero 228
	.inst 0x787b00bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:000 o3:0 Rs:27 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x397083e1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:110000100000 opc:01 111001:111001 size:00
	.inst 0x7821105b // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:2 00:00 opc:001 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c21180
	.zero 1048304
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc240110e // ldr c14, [x8, #4]
	.inst 0xc2401513 // ldr c19, [x8, #5]
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603188 // ldr c8, [c12, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601188 // ldr c8, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x12, #0xf
	and x8, x8, x12
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010c // ldr c12, [x8, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240050c // ldr c12, [x8, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240150c // ldr c12, [x8, #5]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240190c // ldr c12, [x8, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401d0c // ldr c12, [x8, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240210c // ldr c12, [x8, #8]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240250c // ldr c12, [x8, #9]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc240290c // ldr c12, [x8, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001c02
	ldr x1, =check_data0
	ldr x2, =0x00001c04
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400100
	ldr x1, =check_data3
	ldr x2, =0x00400110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
