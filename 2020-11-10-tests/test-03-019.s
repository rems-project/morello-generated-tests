.section data0, #alloc, #write
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x7b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x02, 0x00, 0x00, 0x00, 0x60, 0x10, 0xc3, 0x02
.data
check_data3:
	.byte 0x16, 0x20, 0xfe, 0xf8, 0x48, 0x23, 0xc2, 0xc2, 0x5d, 0x30, 0xbf, 0xf8, 0x92, 0x2e, 0x48, 0x82
	.byte 0xc1, 0x43, 0xc5, 0xc2, 0x7d, 0xe2, 0x8a, 0xda, 0xc0, 0x23, 0x60, 0x38, 0xe1, 0xcf, 0x07, 0x38
	.byte 0x3e, 0x60, 0xc0, 0xc2, 0xe9, 0xeb, 0x8b, 0xa8, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7f
	/* C2 */
	.octa 0xff
	/* C5 */
	.octa 0x60000000000400
	/* C9 */
	.octa 0x5000000000000000
	/* C18 */
	.octa 0x400
	/* C20 */
	.octa 0x40000000600100040000000000000c70
	/* C26 */
	.octa 0x4000003000702c3106000000002
	/* C30 */
	.octa 0x1380130870000000000000100
final_cap_values:
	/* C0 */
	.octa 0x4
	/* C1 */
	.octa 0x1380130870060000000000400
	/* C2 */
	.octa 0xff
	/* C5 */
	.octa 0x60000000000400
	/* C8 */
	.octa 0x4004101000202c3106000000002
	/* C9 */
	.octa 0x5000000000000000
	/* C18 */
	.octa 0x400
	/* C20 */
	.octa 0x40000000600100040000000000000c70
	/* C22 */
	.octa 0x100
	/* C26 */
	.octa 0x4000003000702c3106000000002
	/* C30 */
	.octa 0x1380130873080000000000004
initial_SP_EL3_value:
	.octa 0xf83
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000081c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fc40f8100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8fe2016 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:0 00:00 opc:010 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xc2c22348 // SCBNDSE-C.CR-C Cd:8 Cn:26 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0xf8bf305d // ldset:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:2 00:00 opc:011 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x82482e92 // ASTR-R.RI-64 Rt:18 Rn:20 op:11 imm9:010000010 L:0 1000001001:1000001001
	.inst 0xc2c543c1 // SCVALUE-C.CR-C Cd:1 Cn:30 000:000 opc:10 0:0 Rm:5 11000010110:11000010110
	.inst 0xda8ae27d // csinv:aarch64/instrs/integer/conditional/select Rd:29 Rn:19 o2:0 0:0 cond:1110 Rm:10 011010100:011010100 op:1 sf:1
	.inst 0x386023c0 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:010 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x3807cfe1 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:31 11:11 imm9:001111100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c0603e // SCOFF-C.CR-C Cd:30 Cn:1 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0xa88bebe9 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:9 Rn:31 Rt2:11010 imm7:0010111 L:0 1010001:1010001 opc:10
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603070 // ldr c16, [c3, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601070 // ldr c16, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401203 // ldr c3, [x16, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401603 // ldr c3, [x16, #5]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401a03 // ldr c3, [x16, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401e03 // ldr c3, [x16, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402203 // ldr c3, [x16, #8]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2402603 // ldr c3, [x16, #9]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2402a03 // ldr c3, [x16, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
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
