.section data0, #alloc, #write
	.zero 512
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 1392
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2160
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0xfe, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa1, 0x44, 0x5d, 0xf8, 0xc2, 0x5b, 0x57, 0x3a, 0x02, 0x50, 0xc2, 0xc2, 0x20, 0x88, 0xdc, 0xc2
	.byte 0x4b, 0x04, 0x5e, 0xa2, 0xfd, 0x2b, 0xdf, 0xc2, 0x4c, 0xe8, 0x21, 0x38, 0x3f, 0x8a, 0x53, 0xd8
	.byte 0x7f, 0xa2, 0x7e, 0xb2, 0xbe, 0xb7, 0x65, 0x70, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000800000010005000000000040000d
	/* C2 */
	.octa 0xd0000000000200050000000000001200
	/* C5 */
	.octa 0x1788
	/* C12 */
	.octa 0x0
	/* C28 */
	.octa 0x308070000000000000001
final_cap_values:
	/* C0 */
	.octa 0xffe
	/* C1 */
	.octa 0xffe
	/* C2 */
	.octa 0xd0000000000200050000000000001000
	/* C5 */
	.octa 0x175c
	/* C11 */
	.octa 0x101800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C28 */
	.octa 0x308070000000000000001
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080000001000500000000004cb71b
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000020080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf85d44a1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:5 01:01 imm9:111010100 0:0 opc:01 111000:111000 size:11
	.inst 0x3a575bc2 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0010 0:0 Rn:30 10:10 cond:0101 imm5:10111 111010010:111010010 op:0 sf:0
	.inst 0xc2c25002 // RETS-C-C 00010:00010 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xc2dc8820 // CHKSSU-C.CC-C Cd:0 Cn:1 0010:0010 opc:10 Cm:28 11000010110:11000010110
	.inst 0xa25e044b // LDR-C.RIAW-C Ct:11 Rn:2 01:01 imm9:111100000 0:0 opc:01 10100010:10100010
	.inst 0xc2df2bfd // BICFLGS-C.CR-C Cd:29 Cn:31 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x3821e84c // strb_reg:aarch64/instrs/memory/single/general/register Rt:12 Rn:2 10:10 S:0 option:111 Rm:1 1:1 opc:00 111000:111000 size:00
	.inst 0xd8538a3f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0101001110001010001 011000:011000 opc:11
	.inst 0xb27ea27f // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:19 imms:101000 immr:111110 N:1 100100:100100 opc:01 sf:1
	.inst 0x7065b7be // ADR-C.I-C Rd:30 immhi:110010110110111101 P:0 10000:10000 immlo:11 op:0
	.inst 0xc2c21080
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e5 // ldr c5, [x7, #2]
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc24010fc // ldr c28, [x7, #4]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603087 // ldr c7, [c4, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601087 // ldr c7, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x4, #0xf
	and x7, x7, x4
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e4 // ldr c4, [x7, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24004e4 // ldr c4, [x7, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc24010e4 // ldr c4, [x7, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc24014e4 // ldr c4, [x7, #5]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc24018e4 // ldr c4, [x7, #6]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2401ce4 // ldr c4, [x7, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc24020e4 // ldr c4, [x7, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001210
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001788
	ldr x1, =check_data1
	ldr x2, =0x00001790
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
