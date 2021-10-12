.section data0, #alloc, #write
	.zero 272
	.byte 0x31, 0x00, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00
	.zero 3808
.data
check_data0:
	.byte 0x31, 0x00, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x31, 0x00, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x22, 0xfe, 0x5f, 0x42, 0x42, 0x7f, 0xf9, 0xa2, 0xc5, 0xe7, 0xb4, 0xe2, 0x1f, 0xf8, 0x59, 0x78
	.byte 0x3e, 0x74, 0x80, 0xda, 0x5e, 0x58, 0xee, 0xc2, 0x20, 0xc8, 0x79, 0xb1, 0x20, 0xe1, 0x06, 0xe2
	.byte 0xe2, 0x03, 0x0d, 0x7a, 0xbf, 0x53, 0x34, 0x38, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2021
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x40000000600410020000000000001000
	/* C14 */
	.octa 0x7fffffffffe000
	/* C17 */
	.octa 0x1110
	/* C20 */
	.octa 0x70
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x80000000600200060000000000002032
final_cap_values:
	/* C0 */
	.octa 0xe72000
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x40000000600410020000000000001000
	/* C14 */
	.octa 0x7fffffffffe000
	/* C17 */
	.octa 0x1110
	/* C20 */
	.octa 0x70
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40010002007fffffffffe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000006000000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 144
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425ffe22 // LDAR-C.R-C Ct:2 Rn:17 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xa2f97f42 // CASA-C.R-C Ct:2 Rn:26 11111:11111 R:0 Cs:25 1:1 L:1 1:1 10100010:10100010
	.inst 0xe2b4e7c5 // ALDUR-V.RI-S Rt:5 Rn:30 op2:01 imm9:101001110 V:1 op1:10 11100010:11100010
	.inst 0x7859f81f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:110011111 0:0 opc:01 111000:111000 size:01
	.inst 0xda80743e // csneg:aarch64/instrs/integer/conditional/select Rd:30 Rn:1 o2:1 0:0 cond:0111 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xc2ee585e // CVTZ-C.CR-C Cd:30 Cn:2 0110:0110 1:1 0:0 Rm:14 11000010111:11000010111
	.inst 0xb179c820 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:1 imm12:111001110010 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xe206e120 // ASTURB-R.RI-32 Rt:0 Rn:9 op2:00 imm9:001101110 V:0 op1:00 11100010:11100010
	.inst 0x7a0d03e2 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:31 000000:000000 Rm:13 11010000:11010000 S:1 op:1 sf:0
	.inst 0x383453bf // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:101 o3:0 Rs:20 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c212c0
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
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2400f6e // ldr c14, [x27, #3]
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2401f7a // ldr c26, [x27, #7]
	.inst 0xc240237d // ldr c29, [x27, #8]
	.inst 0xc240277e // ldr c30, [x27, #9]
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032db // ldr c27, [c22, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826012db // ldr c27, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0x3
	and x27, x27, x22
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400376 // ldr c22, [x27, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400776 // ldr c22, [x27, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b76 // ldr c22, [x27, #2]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2400f76 // ldr c22, [x27, #3]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401776 // ldr c22, [x27, #5]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401f76 // ldr c22, [x27, #7]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402376 // ldr c22, [x27, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402776 // ldr c22, [x27, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x22, v5.d[0]
	cmp x27, x22
	b.ne comparison_fail
	ldr x27, =0x0
	mov x22, v5.d[1]
	cmp x27, x22
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
	ldr x0, =0x0000106e
	ldr x1, =check_data1
	ldr x2, =0x0000106f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001110
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f84
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fc2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
