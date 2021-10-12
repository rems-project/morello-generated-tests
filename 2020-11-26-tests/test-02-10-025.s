.section data0, #alloc, #write
	.zero 304
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3776
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x1f, 0x38, 0x49, 0x38, 0xd0, 0x5b, 0xfe, 0xc2, 0xa0, 0x03, 0x1f, 0xd6, 0x0c, 0x9c, 0x47, 0x78
	.byte 0xe3, 0x77, 0xe3, 0xe2, 0xbf, 0x6b, 0x69, 0x11, 0x6f, 0x59, 0xff, 0xc2, 0x12, 0x24, 0xc6, 0x9a
	.byte 0xd4, 0xab, 0x3f, 0x9b, 0xfa, 0x83, 0xdc, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100060000000000401f83
	/* C11 */
	.octa 0x0
	/* C28 */
	.octa 0x1
	/* C29 */
	.octa 0x40000c
	/* C30 */
	.octa 0x800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x80000000000100060000000000401ffc
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xc2c2
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0xe5a00c
	/* C28 */
	.octa 0x1
	/* C29 */
	.octa 0x40000c
	/* C30 */
	.octa 0x800000000000000000000000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000500100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000580a010100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3849381f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:010010011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2fe5bd0 // CVTZ-C.CR-C Cd:16 Cn:30 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0xd61f03a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0x78479c0c // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:0 11:11 imm9:001111001 0:0 opc:01 111000:111000 size:01
	.inst 0xe2e377e3 // ALDUR-V.RI-D Rt:3 Rn:31 op2:01 imm9:000110111 V:1 op1:11 11100010:11100010
	.inst 0x11696bbf // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:29 imm12:101001011010 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2ff596f // CVTZ-C.CR-C Cd:15 Cn:11 0110:0110 1:1 0:0 Rm:31 11000010111:11000010111
	.inst 0x9ac62412 // lsrv:aarch64/instrs/integer/shift/variable Rd:18 Rn:0 op2:01 0010:0010 Rm:6 0011010110:0011010110 sf:1
	.inst 0x9b3fabd4 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:20 Rn:30 Ra:10 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0xc2dc83fa // SCTAG-C.CR-C Cd:26 Cn:31 000:000 0:0 10:10 Rm:28 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 8144
	.inst 0x0000c2c2
	.zero 20
	.inst 0x00c20000
	.zero 1040360
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
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc240048b // ldr c11, [x4, #1]
	.inst 0xc240089c // ldr c28, [x4, #2]
	.inst 0xc2400c9d // ldr c29, [x4, #3]
	.inst 0xc240109e // ldr c30, [x4, #4]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085103d
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e4 // ldr c4, [c7, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826010e4 // ldr c4, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	.inst 0xc2400087 // ldr c7, [x4, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400487 // ldr c7, [x4, #1]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401087 // ldr c7, [x4, #4]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401487 // ldr c7, [x4, #5]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2401887 // ldr c7, [x4, #6]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2401c87 // ldr c7, [x4, #7]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402087 // ldr c7, [x4, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0xc2c2c2c2c2c2c2c2
	mov x7, v3.d[0]
	cmp x4, x7
	b.ne comparison_fail
	ldr x4, =0x0
	mov x7, v3.d[1]
	cmp x4, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001138
	ldr x1, =check_data0
	ldr x2, =0x00001140
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00401ffc
	ldr x1, =check_data2
	ldr x2, =0x00401ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402016
	ldr x1, =check_data3
	ldr x2, =0x00402017
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
