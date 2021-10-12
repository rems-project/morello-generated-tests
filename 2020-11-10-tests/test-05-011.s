.section data0, #alloc, #write
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 800
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.zero 3200
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x10
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x01, 0x0c, 0x4e, 0xf8, 0x5b, 0x50, 0x21, 0xc8, 0xac, 0x12, 0x5d, 0xba, 0xe3, 0x7f, 0x51, 0xa2
	.byte 0x01, 0xc5, 0x1a, 0xa2, 0xc7, 0xea, 0x8b, 0xb8, 0x9b, 0x43, 0xc0, 0xc2, 0x02, 0x2b, 0xd9, 0xc2
	.byte 0xff, 0xd0, 0xc5, 0xc2, 0xd9, 0x15, 0xc0, 0xda, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400010
	/* C2 */
	.octa 0x1b80
	/* C8 */
	.octa 0x1000
	/* C22 */
	.octa 0xf82
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x100070000000000000001
final_cap_values:
	/* C0 */
	.octa 0x4000f0
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x101000000000000000000000000
	/* C7 */
	.octa 0x10000000
	/* C8 */
	.octa 0xac0
	/* C22 */
	.octa 0xf82
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x1000700000000004000f0
	/* C28 */
	.octa 0x100070000000000000001
initial_SP_EL3_value:
	.octa 0x2200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000002100070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001370
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf84e0c01 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:011100000 0:0 opc:01 111000:111000 size:11
	.inst 0xc821505b // stxp:aarch64/instrs/memory/exclusive/pair Rt:27 Rn:2 Rt2:10100 o0:0 Rs:1 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xba5d12ac // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1100 0:0 Rn:21 00:00 cond:0001 Rm:29 111010010:111010010 op:0 sf:1
	.inst 0xa2517fe3 // LDR-C.RIBW-C Ct:3 Rn:31 11:11 imm9:100010111 0:0 opc:01 10100010:10100010
	.inst 0xa21ac501 // STR-C.RIAW-C Ct:1 Rn:8 01:01 imm9:110101100 0:0 opc:00 10100010:10100010
	.inst 0xb88beac7 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:7 Rn:22 10:10 imm9:010111110 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c0439b // SCVALUE-C.CR-C Cd:27 Cn:28 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2d92b02 // BICFLGS-C.CR-C Cd:2 Cn:24 1010:1010 opc:00 Rm:25 11000010110:11000010110
	.inst 0xc2c5d0ff // CVTDZ-C.R-C Cd:31 Rn:7 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xdac015d9 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:25 Rn:14 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c211e0
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2400d76 // ldr c22, [x11, #3]
	.inst 0xc2401178 // ldr c24, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085103d
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031eb // ldr c11, [c15, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826011eb // ldr c11, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016f // ldr c15, [x11, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240056f // ldr c15, [x11, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240096f // ldr c15, [x11, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc240116f // ldr c15, [x11, #4]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc240156f // ldr c15, [x11, #5]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240196f // ldr c15, [x11, #6]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401d6f // ldr c15, [x11, #7]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc240216f // ldr c15, [x11, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240256f // ldr c15, [x11, #9]
	.inst 0xc2cfa781 // chkeq c28, c15
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001370
	ldr x1, =check_data2
	ldr x2, =0x00001380
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b80
	ldr x1, =check_data3
	ldr x2, =0x00001b90
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
	ldr x0, =0x004000f0
	ldr x1, =check_data5
	ldr x2, =0x004000f8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
