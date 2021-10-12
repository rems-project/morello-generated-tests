.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3, 0xc2, 0x40, 0x13
.data
check_data3:
	.byte 0x2b, 0xda, 0x22, 0x9b, 0xe2, 0xc3, 0x65, 0xe2, 0xff, 0x03, 0x3b, 0x38, 0xbf, 0x19, 0xdd, 0xc2
	.byte 0xa2, 0x29, 0x22, 0x8b, 0xc2, 0x63, 0xc5, 0xc2, 0xe0, 0x6b, 0xc4, 0xc2, 0xe4, 0x11, 0xeb, 0xc2
	.byte 0x10, 0x29, 0xf9, 0xb7, 0x4f, 0x58, 0x32, 0xe2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0xff0000000000200b
	/* C13 */
	.octa 0xa06120670000000000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x100450057674800000000
final_cap_values:
	/* C2 */
	.octa 0x10045000000000000200b
	/* C4 */
	.octa 0x3fff800000005800000000000000
	/* C5 */
	.octa 0xff0000000000200b
	/* C13 */
	.octa 0xa06120670000000000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x100450057674800000000
initial_SP_EL3_value:
	.octa 0xc00000000003000700000000000013c0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000003790070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b22da2b // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:11 Rn:17 Ra:22 o0:1 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xe265c3e2 // ASTUR-V.RI-H Rt:2 Rn:31 op2:00 imm9:001011100 V:1 op1:01 11100010:11100010
	.inst 0x383b03ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:27 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2dd19bf // ALIGND-C.CI-C Cd:31 Cn:13 0110:0110 U:0 imm6:111010 11000010110:11000010110
	.inst 0x8b2229a2 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:13 imm3:010 option:001 Rm:2 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2c563c2 // SCOFF-C.CR-C Cd:2 Cn:30 000:000 opc:11 0:0 Rm:5 11000010110:11000010110
	.inst 0xc2c46be0 // ORRFLGS-C.CR-C Cd:0 Cn:31 1010:1010 opc:01 Rm:4 11000010110:11000010110
	.inst 0xc2eb11e4 // EORFLGS-C.CI-C Cd:4 Cn:15 0:0 10:10 imm8:01011000 11000010111:11000010111
	.inst 0xb7f92910 // tbnz:aarch64/instrs/branch/conditional/test Rt:16 imm14:00100101001000 b40:11111 op:1 011011:011011 b5:1
	.inst 0xe232584f // ASTUR-V.RI-Q Rt:15 Rn:2 op2:10 imm9:100100101 V:1 op1:00 11100010:11100010
	.inst 0xc2c21240
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
	ldr x24, =initial_cap_values
	.inst 0xc2400305 // ldr c5, [x24, #0]
	.inst 0xc240070d // ldr c13, [x24, #1]
	.inst 0xc2400b0f // ldr c15, [x24, #2]
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc240131b // ldr c27, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q2, =0x0
	ldr q15, =0x1340c2c3000000000000000000000000
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603258 // ldr c24, [c18, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601258 // ldr c24, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400312 // ldr c18, [x24, #0]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400712 // ldr c18, [x24, #1]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400b12 // ldr c18, [x24, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400f12 // ldr c18, [x24, #3]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2401312 // ldr c18, [x24, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401712 // ldr c18, [x24, #5]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2401b12 // ldr c18, [x24, #6]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2401f12 // ldr c18, [x24, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x18, v2.d[0]
	cmp x24, x18
	b.ne comparison_fail
	ldr x24, =0x0
	mov x18, v2.d[1]
	cmp x24, x18
	b.ne comparison_fail
	ldr x24, =0x0
	mov x18, v15.d[0]
	cmp x24, x18
	b.ne comparison_fail
	ldr x24, =0x1340c2c300000000
	mov x18, v15.d[1]
	cmp x24, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013c0
	ldr x1, =check_data0
	ldr x2, =0x000013c1
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000141c
	ldr x1, =check_data1
	ldr x2, =0x0000141e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f30
	ldr x1, =check_data2
	ldr x2, =0x00001f40
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
