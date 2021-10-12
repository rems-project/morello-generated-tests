.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0xff
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x03, 0x10, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xfd, 0xf3, 0x2d, 0x29, 0x7e, 0x13, 0xc1, 0xc2, 0x3e, 0x69, 0x3d, 0x38, 0xd8, 0xa1, 0x4e, 0x38
	.byte 0xf7, 0x47, 0xdf, 0x78, 0x81, 0x13, 0x0a, 0x78, 0x9c, 0x15, 0x53, 0xb8, 0x2f, 0xe4, 0x7f, 0x22
	.byte 0x95, 0x97, 0xc6, 0xa8, 0x3f, 0x60, 0x2b, 0x38, 0x60, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C9 */
	.octa 0x1040
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x10a4
	/* C14 */
	.octa 0x400000
	/* C27 */
	.octa 0x4004c00a0000000000000000
	/* C28 */
	.octa 0x1003
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x200000000000
	/* C9 */
	.octa 0x1040
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xfd5
	/* C14 */
	.octa 0x400000
	/* C15 */
	.octa 0x2000000000000000000000000000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000000000000000
	/* C27 */
	.octa 0x4004c00a0000000000000000
	/* C28 */
	.octa 0x1068
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x1490
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x292df3fd // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:29 Rn:31 Rt2:11100 imm7:1011011 L:0 1010010:1010010 opc:00
	.inst 0xc2c1137e // GCLIM-R.C-C Rd:30 Cn:27 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x383d693e // strb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:9 10:10 S:0 option:011 Rm:29 1:1 opc:00 111000:111000 size:00
	.inst 0x384ea1d8 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:24 Rn:14 00:00 imm9:011101010 0:0 opc:01 111000:111000 size:00
	.inst 0x78df47f7 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:23 Rn:31 01:01 imm9:111110100 0:0 opc:11 111000:111000 size:01
	.inst 0x780a1381 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:28 00:00 imm9:010100001 0:0 opc:00 111000:111000 size:01
	.inst 0xb853159c // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:28 Rn:12 01:01 imm9:100110001 0:0 opc:01 111000:111000 size:10
	.inst 0x227fe42f // LDAXP-C.R-C Ct:15 Rn:1 Ct2:11001 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xa8c69795 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:21 Rn:28 Rt2:00101 imm7:0001101 L:1 1010001:1010001 opc:10
	.inst 0x382b603f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:00
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc240189c // ldr c28, [x4, #6]
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085103f
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603064 // ldr c4, [c3, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601064 // ldr c4, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400083 // ldr c3, [x4, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400c83 // ldr c3, [x4, #3]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401083 // ldr c3, [x4, #4]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401483 // ldr c3, [x4, #5]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401883 // ldr c3, [x4, #6]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401c83 // ldr c3, [x4, #7]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402083 // ldr c3, [x4, #8]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402483 // ldr c3, [x4, #9]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2402883 // ldr c3, [x4, #10]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402c83 // ldr c3, [x4, #11]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2403083 // ldr c3, [x4, #12]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2403483 // ldr c3, [x4, #13]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2403883 // ldr c3, [x4, #14]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001041
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a4
	ldr x1, =check_data2
	ldr x2, =0x000010a8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013fc
	ldr x1, =check_data3
	ldr x2, =0x00001404
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001490
	ldr x1, =check_data4
	ldr x2, =0x00001492
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
	ldr x0, =0x004000ea
	ldr x1, =check_data6
	ldr x2, =0x004000eb
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
