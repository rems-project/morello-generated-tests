.section data0, #alloc, #write
	.zero 208
	.byte 0xfd, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
	.byte 0xf2, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xfd, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 24
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc0, 0xc3, 0x60, 0x82, 0x15, 0xc8, 0x34, 0x9b, 0xe6, 0x69, 0x20, 0x38, 0x1a, 0xac, 0x47, 0x31
	.byte 0x5f, 0x3a, 0x03, 0xd5, 0xe2, 0xff, 0x5f, 0x42, 0xc1, 0xa7, 0x54, 0x78, 0xbd, 0x53, 0x61, 0xf8
	.byte 0x9e, 0x03, 0x74, 0x82, 0xfd, 0xdb, 0x7d, 0xf8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000000100050000000000000001
	/* C28 */
	.octa 0xbe0
	/* C29 */
	.octa 0xc0000000000100050000000000001ff0
	/* C30 */
	.octa 0x800000002001c0050000000000001010
final_cap_values:
	/* C0 */
	.octa 0x1ffd
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000000100050000000000000001
	/* C26 */
	.octa 0x1ecffd
	/* C28 */
	.octa 0xbe0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004f0060
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080200000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8260c3c0 // ALDR-C.RI-C Ct:0 Rn:30 op:00 imm9:000001100 L:1 1000001001:1000001001
	.inst 0x9b34c815 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:0 Ra:18 o0:1 Rm:20 01:01 U:0 10011011:10011011
	.inst 0x382069e6 // strb_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:15 10:10 S:0 option:011 Rm:0 1:1 opc:00 111000:111000 size:00
	.inst 0x3147ac1a // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:26 Rn:0 imm12:000111101011 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xd5033a5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1010 11010101000000110011:11010101000000110011
	.inst 0x425fffe2 // LDAR-C.R-C Ct:2 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x7854a7c1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:30 01:01 imm9:101001010 0:0 opc:01 111000:111000 size:01
	.inst 0xf86153bd // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:101 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x8274039e // ALDR-C.RI-C Ct:30 Rn:28 op:00 imm9:101000000 L:1 1000001001:1000001001
	.inst 0xf87ddbfd // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:29 Rn:31 10:10 S:1 option:110 Rm:29 1:1 opc:01 111000:111000 size:11
	.inst 0xc2c21220
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
	ldr x9, =initial_cap_values
	.inst 0xc2400126 // ldr c6, [x9, #0]
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2400d3d // ldr c29, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085103f
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603229 // ldr c9, [c17, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601229 // ldr c9, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x17, #0xf
	and x9, x9, x17
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400131 // ldr c17, [x9, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400531 // ldr c17, [x9, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400931 // ldr c17, [x9, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401131 // ldr c17, [x9, #4]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401531 // ldr c17, [x9, #5]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2401931 // ldr c17, [x9, #6]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2401d31 // ldr c17, [x9, #7]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402131 // ldr c17, [x9, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x004f0060
	ldr x1, =check_data5
	ldr x2, =0x004f0070
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
