.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe1, 0xca, 0x73, 0xbc, 0x68, 0xea, 0xfd, 0x38, 0x80, 0x53, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xe0, 0x7f, 0x5f, 0x22, 0xff, 0x25, 0x65, 0x82, 0xf0, 0xab, 0xc1, 0xc2, 0xfd, 0x47, 0x82, 0xb8
	.byte 0xc4, 0xef, 0x76, 0x91, 0x5e, 0xe2, 0x80, 0x22, 0x3f, 0xc4, 0x54, 0x78, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000500600090000000000001000
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x4c000000400202110000000000001000
	/* C19 */
	.octa 0x80000000000000000000000000000001
	/* C23 */
	.octa 0x80000000000100050000000000402e27
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x200080001047c057000000000047ffe9
	/* C29 */
	.octa 0x4ffffd
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000500600090000000000000f4c
	/* C4 */
	.octa 0xdbb000
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x80000000580108020000000000001000
	/* C18 */
	.octa 0x4c000000400202110000000000001010
	/* C19 */
	.octa 0x80000000000000000000000000000001
	/* C23 */
	.octa 0x80000000000100050000000000402e27
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x200080001047c057000000000047ffe9
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000000000
initial_SP_EL3_value:
	.octa 0x80000000580108020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005801000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbc73cae1 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:1 Rn:23 10:10 S:0 option:110 Rm:19 1:1 opc:01 111100:111100 size:10
	.inst 0x38fdea68 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:8 Rn:19 10:10 S:0 option:111 Rm:29 1:1 opc:11 111000:111000 size:00
	.inst 0xc2c25380 // RET-C-C 00000:00000 Cn:28 100:100 opc:10 11000010110000100:11000010110000100
	.zero 524252
	.inst 0x225f7fe0 // LDXR-C.R-C Ct:0 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x826525ff // ALDRB-R.RI-B Rt:31 Rn:15 op:01 imm9:001010010 L:1 1000001001:1000001001
	.inst 0xc2c1abf0 // 0xc2c1abf0
	.inst 0xb88247fd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:31 01:01 imm9:000100100 0:0 opc:10 111000:111000 size:10
	.inst 0x9176efc4 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:4 Rn:30 imm12:110110111011 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x2280e25e // STP-CC.RIAW-C Ct:30 Rn:18 Ct2:11000 imm7:0000001 L:0 001000101:001000101
	.inst 0x7854c43f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:1 01:01 imm9:101001100 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c21160
	.zero 524280
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc240074f // ldr c15, [x26, #1]
	.inst 0xc2400b52 // ldr c18, [x26, #2]
	.inst 0xc2400f53 // ldr c19, [x26, #3]
	.inst 0xc2401357 // ldr c23, [x26, #4]
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2401b5c // ldr c28, [x26, #6]
	.inst 0xc2401f5d // ldr c29, [x26, #7]
	.inst 0xc240235e // ldr c30, [x26, #8]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085103f
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317a // ldr c26, [c11, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260117a // ldr c26, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034b // ldr c11, [x26, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401b4b // ldr c11, [x26, #6]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2401f4b // ldr c11, [x26, #7]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240234b // ldr c11, [x26, #8]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240274b // ldr c11, [x26, #9]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc2402b4b // ldr c11, [x26, #10]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2402f4b // ldr c11, [x26, #11]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240334b // ldr c11, [x26, #12]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x11, v1.d[0]
	cmp x26, x11
	b.ne comparison_fail
	ldr x26, =0x0
	mov x11, v1.d[1]
	cmp x26, x11
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
	ldr x0, =0x00001052
	ldr x1, =check_data1
	ldr x2, =0x00001053
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402e28
	ldr x1, =check_data3
	ldr x2, =0x00402e2c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047ffe8
	ldr x1, =check_data4
	ldr x2, =0x00480008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
