.section data0, #alloc, #write
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3552
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x01
.data
check_data5:
	.byte 0xe1, 0xc7, 0x86, 0x1a, 0x9f, 0xd0, 0xc0, 0xc2, 0x0f, 0x7f, 0x5f, 0x22, 0xb4, 0xbb, 0x1c, 0x78
	.byte 0xe3, 0x81, 0xa0, 0xa2, 0x23, 0xfc, 0x00, 0x22, 0x80, 0xc3, 0xbf, 0x38, 0x9f, 0x20, 0x60, 0x38
	.byte 0x81, 0xa5, 0xc0, 0xc2, 0x00, 0xda, 0xf1, 0xb4, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000001
	/* C4 */
	.octa 0x1200
	/* C6 */
	.octa 0x157f
	/* C12 */
	.octa 0xfffffffffffffffffffffffffffffffe
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C28 */
	.octa 0x1ff8
	/* C29 */
	.octa 0x1215
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1580
	/* C3 */
	.octa 0x2
	/* C4 */
	.octa 0x1200
	/* C6 */
	.octa 0x157f
	/* C12 */
	.octa 0xfffffffffffffffffffffffffffffffe
	/* C15 */
	.octa 0x1200
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C28 */
	.octa 0x1ff8
	/* C29 */
	.octa 0x1215
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc100000400401040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1a86c7e1 // csinc:aarch64/instrs/integer/conditional/select Rd:1 Rn:31 o2:1 0:0 cond:1100 Rm:6 011010100:011010100 op:0 sf:0
	.inst 0xc2c0d09f // GCPERM-R.C-C Rd:31 Cn:4 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x225f7f0f // 0x225f7f0f
	.inst 0x781cbbb4 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:29 10:10 imm9:111001011 0:0 opc:00 111000:111000 size:01
	.inst 0xa2a081e3 // SWPA-CC.R-C Ct:3 Rn:15 100000:100000 Cs:0 1:1 R:0 A:1 10100010:10100010
	.inst 0x2200fc23 // 0x2200fc23
	.inst 0x38bfc380 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:0 Rn:28 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x3860209f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:010 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c0a581 // CHKEQ-_.CC-C 00001:00001 Cn:12 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.inst 0xb4f1da00 // cbz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:1111000111011010000 op:0 011010:011010 sf:1
	.inst 0xc2c210a0
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2401a1c // ldr c28, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x40000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b0 // ldr c16, [c5, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826010b0 // ldr c16, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x5, #0xf
	and x16, x16, x5
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400205 // ldr c5, [x16, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401205 // ldr c5, [x16, #4]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401605 // ldr c5, [x16, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401a05 // ldr c5, [x16, #6]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401e05 // ldr c5, [x16, #7]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402205 // ldr c5, [x16, #8]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402605 // ldr c5, [x16, #9]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2402a05 // ldr c5, [x16, #10]
	.inst 0xc2c5a7a1 // chkeq c29, c5
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
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001580
	ldr x1, =check_data3
	ldr x2, =0x00001590
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ff9
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
