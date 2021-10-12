.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0xc1, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
	.byte 0xc1, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data0:
	.byte 0xc0, 0x1f
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xc0, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xc0, 0x5f, 0xdb, 0x3c, 0xdf, 0x63, 0x7e, 0x78, 0xd0, 0x03, 0x02, 0x5a, 0x80, 0x48, 0x75, 0xf8
	.byte 0xcb, 0x6b, 0x4e, 0x7a, 0x3f, 0x20, 0xce, 0x78, 0x7d, 0x29, 0xd4, 0xc2, 0x9d, 0xed, 0xd7, 0xd2
	.byte 0x00, 0x07, 0x63, 0xe2, 0x3d, 0x61, 0x7e, 0x78, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000001f1a
	/* C4 */
	.octa 0x80000000000000000000000000000000
	/* C9 */
	.octa 0xc0000000400000090000000000001004
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x47fff0
	/* C24 */
	.octa 0x1e8c
	/* C30 */
	.octa 0xc000000000010005000000000000200b
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001f1a
	/* C4 */
	.octa 0x80000000000000000000000000000000
	/* C9 */
	.octa 0xc0000000400000090000000000001004
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x47fff0
	/* C24 */
	.octa 0x1e8c
	/* C29 */
	.octa 0xfc1
	/* C30 */
	.octa 0xc0000000000100050000000000001fc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cdb5fc0 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:110110101 0:0 opc:11 111100:111100 size:00
	.inst 0x787e63df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x5a0203d0 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:16 Rn:30 000000:000000 Rm:2 11010000:11010000 S:0 op:1 sf:0
	.inst 0xf8754880 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:4 10:10 S:0 option:010 Rm:21 1:1 opc:01 111000:111000 size:11
	.inst 0x7a4e6bcb // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1011 0:0 Rn:30 10:10 cond:0110 imm5:01110 111010010:111010010 op:1 sf:0
	.inst 0x78ce203f // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:011100010 0:0 opc:11 111000:111000 size:01
	.inst 0xc2d4297d // BICFLGS-C.CR-C Cd:29 Cn:11 1010:1010 opc:00 Rm:20 11000010110:11000010110
	.inst 0xd2d7ed9d // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:1011111101101100 hw:10 100101:100101 opc:10 sf:1
	.inst 0xe2630700 // ALDUR-V.RI-H Rt:0 Rn:24 op2:01 imm9:000110000 V:1 op1:01 11100010:11100010
	.inst 0x787e613d // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:9 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400784 // ldr c4, [x28, #1]
	.inst 0xc2400b89 // ldr c9, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc2401798 // ldr c24, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x10000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032dc // ldr c28, [c22, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826012dc // ldr c28, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x22, #0xf
	and x28, x28, x22
	cmp x28, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400396 // ldr c22, [x28, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400796 // ldr c22, [x28, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b96 // ldr c22, [x28, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400f96 // ldr c22, [x28, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401396 // ldr c22, [x28, #4]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401796 // ldr c22, [x28, #5]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401b96 // ldr c22, [x28, #6]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401f96 // ldr c22, [x28, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402396 // ldr c22, [x28, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x22, v0.d[0]
	cmp x28, x22
	b.ne comparison_fail
	ldr x28, =0x0
	mov x22, v0.d[1]
	cmp x28, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ebc
	ldr x1, =check_data1
	ldr x2, =0x00001ebe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x0047fff0
	ldr x1, =check_data5
	ldr x2, =0x0047fff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
