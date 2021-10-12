.section data0, #alloc, #write
	.zero 1024
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xa0, 0x60, 0xbf, 0xf8, 0x36, 0x71, 0x7e, 0x38, 0x0f, 0x7f, 0x5f, 0x22, 0xfd, 0x0f, 0xc0, 0x9a
	.byte 0xdf, 0x61, 0xdf, 0xc2, 0x23, 0xfc, 0x00, 0x22, 0x9f, 0x31, 0x61, 0x38, 0x1d, 0x48, 0x2e, 0x18
	.byte 0xeb, 0x42, 0xdf, 0xc2, 0x1d, 0x79, 0x1f, 0x9b, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4c000000000100050000000000001400
	/* C3 */
	.octa 0x40000000000000004010000000000000
	/* C5 */
	.octa 0xc000000058810c8a0000000000001800
	/* C9 */
	.octa 0xc00000001007000f0000000000001000
	/* C12 */
	.octa 0xc0000000000100050000000000001404
	/* C14 */
	.octa 0x280070000000000000008
	/* C23 */
	.octa 0xc084c88100ffffffffffc000
	/* C24 */
	.octa 0x80100000000500040000000000001400
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c000000000100050000000000001400
	/* C3 */
	.octa 0x40000000000000004010000000000000
	/* C5 */
	.octa 0xc000000058810c8a0000000000001800
	/* C9 */
	.octa 0xc00000001007000f0000000000001000
	/* C11 */
	.octa 0xc084c8810000000000000000
	/* C12 */
	.octa 0xc0000000000100050000000000001404
	/* C14 */
	.octa 0x280070000000000000008
	/* C15 */
	.octa 0x200000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xc084c88100ffffffffffc000
	/* C24 */
	.octa 0x80100000000500040000000000001400
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000100600070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8bf60a0 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:5 00:00 opc:110 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x387e7136 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:9 00:00 opc:111 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x225f7f0f // 0x225f7f0f
	.inst 0x9ac00ffd // sdiv:aarch64/instrs/integer/arithmetic/div Rd:29 Rn:31 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2df61df // SCOFF-C.CR-C Cd:31 Cn:14 000:000 opc:11 0:0 Rm:31 11000010110:11000010110
	.inst 0x2200fc23 // 0x2200fc23
	.inst 0x3861319f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:011 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x182e481d // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:29 imm19:0010111001001000000 011000:011000 opc:00
	.inst 0xc2df42eb // SCVALUE-C.CR-C Cd:11 Cn:23 000:000 opc:10 0:0 Rm:31 11000010110:11000010110
	.inst 0x9b1f791d // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:8 Ra:30 o0:0 Rm:31 0011011000:0011011000 sf:1
	.inst 0xc2c21200
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc240124c // ldr c12, [x18, #4]
	.inst 0xc240164e // ldr c14, [x18, #5]
	.inst 0xc2401a57 // ldr c23, [x18, #6]
	.inst 0xc2401e58 // ldr c24, [x18, #7]
	.inst 0xc240225e // ldr c30, [x18, #8]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601212 // ldr c18, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400250 // ldr c16, [x18, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400650 // ldr c16, [x18, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a50 // ldr c16, [x18, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401650 // ldr c16, [x18, #5]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401a50 // ldr c16, [x18, #6]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401e50 // ldr c16, [x18, #7]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2402250 // ldr c16, [x18, #8]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2402650 // ldr c16, [x18, #9]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402a50 // ldr c16, [x18, #10]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402e50 // ldr c16, [x18, #11]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2403250 // ldr c16, [x18, #12]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403650 // ldr c16, [x18, #13]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001808
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
	ldr x0, =0x0045c91c
	ldr x1, =check_data4
	ldr x2, =0x0045c920
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
