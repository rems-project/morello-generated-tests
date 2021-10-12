.section data0, #alloc, #write
	.byte 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 96
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.byte 0x00, 0x20, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe1, 0xb0, 0x46, 0xa2, 0xa0, 0xc7, 0xc8, 0xc2
.data
check_data5:
	.byte 0x3f, 0x60, 0x7d, 0x78, 0x1e, 0xd0, 0xf4, 0xc2, 0x3f, 0x40, 0xe7, 0xb8, 0xe2, 0x03, 0xc2, 0xc2
	.byte 0xe1, 0x47, 0x42, 0xa2, 0x3e, 0xd0, 0xc5, 0xc2, 0xde, 0x13, 0xc0, 0xc2, 0x09, 0xf1, 0x97, 0x38
	.byte 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x1005
	/* C8 */
	.octa 0x400004000000000000000000002000
	/* C29 */
	.octa 0x20408004210180060000000000410000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x1005
	/* C8 */
	.octa 0x400004000000000000000000002000
	/* C9 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000002000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000600070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000047c0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000600030000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001070
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa246b0e1 // LDUR-C.RI-C Ct:1 Rn:7 00:00 imm9:001101011 0:0 opc:01 10100010:10100010
	.inst 0xc2c8c7a0 // RETS-C.C-C 00000:00000 Cn:29 001:001 opc:10 1:1 Cm:8 11000010110:11000010110
	.zero 65528
	.inst 0x787d603f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2f4d01e // EORFLGS-C.CI-C Cd:30 Cn:0 0:0 10:10 imm8:10100110 11000010111:11000010111
	.inst 0xb8e7403f // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:100 0:0 Rs:7 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2c203e2 // SCBNDS-C.CR-C Cd:2 Cn:31 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0xa24247e1 // LDR-C.RIAW-C Ct:1 Rn:31 01:01 imm9:000100100 0:0 opc:01 10100010:10100010
	.inst 0xc2c5d03e // CVTDZ-C.R-C Cd:30 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c013de // GCBASE-R.C-C Rd:30 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x3897f109 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:8 00:00 imm9:101111111 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21300
	.zero 983004
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2400d5d // ldr c29, [x10, #3]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103d
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330a // ldr c10, [c24, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260130a // ldr c10, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400158 // ldr c24, [x10, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400558 // ldr c24, [x10, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400958 // ldr c24, [x10, #2]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2400d58 // ldr c24, [x10, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401158 // ldr c24, [x10, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401558 // ldr c24, [x10, #5]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401958 // ldr c24, [x10, #6]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001080
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f7f
	ldr x1, =check_data3
	ldr x2, =0x00001f80
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
