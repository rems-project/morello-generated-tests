.section data0, #alloc, #write
	.zero 512
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1264
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
	.zero 2288
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
	.zero 16
.data
check_data6:
	.byte 0x08, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.byte 0xa0, 0x66, 0xf8, 0x42, 0xc0, 0x33, 0x60, 0xb8, 0xdf, 0x52, 0x7b, 0xf8, 0xe6, 0xdb, 0x61, 0x78
	.byte 0x31, 0x10, 0xc7, 0xc2, 0x35, 0x14, 0xc0, 0x5a, 0xfe, 0xb7, 0x38, 0x6d, 0xef, 0x49, 0x3e, 0xa8
	.byte 0xbf, 0x73, 0x0b, 0xb5, 0x5e, 0xbc, 0x13, 0xa2, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x56
	/* C2 */
	.octa 0x1d20
	/* C15 */
	.octa 0x2008
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1800
	/* C22 */
	.octa 0x1200
	/* C27 */
	.octa 0x4000000000000000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x56
	/* C2 */
	.octa 0x10d0
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x2008
	/* C17 */
	.octa 0x56
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x18
	/* C22 */
	.octa 0x1200
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x1198
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008740000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc000000600400020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001700
	.dword initial_cap_values + 112
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42f866a0 // LDP-C.RIB-C Ct:0 Rn:21 Ct2:11001 imm7:1110000 L:1 010000101:010000101
	.inst 0xb86033c0 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xf87b52df // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:22 00:00 opc:101 0:0 Rs:27 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x7861dbe6 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:31 10:10 S:1 option:110 Rm:1 1:1 opc:01 111000:111000 size:01
	.inst 0xc2c71031 // RRLEN-R.R-C Rd:17 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x5ac01435 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:21 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0x6d38b7fe // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:31 Rt2:01101 imm7:1110001 L:0 1011010:1011010 opc:01
	.inst 0xa83e49ef // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:15 Rn:15 Rt2:10010 imm7:1111100 L:0 1010000:1010000 opc:10
	.inst 0xb50b73bf // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0000101101110011101 op:1 011010:011010 sf:1
	.inst 0xa213bc5e // STR-C.RIBW-C Ct:30 Rn:2 11:11 imm9:100111011 0:0 opc:00 10100010:10100010
	.inst 0xc2c21260
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
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2400d32 // ldr c18, [x9, #3]
	.inst 0xc2401135 // ldr c21, [x9, #4]
	.inst 0xc2401536 // ldr c22, [x9, #5]
	.inst 0xc240193b // ldr c27, [x9, #6]
	.inst 0xc2401d3e // ldr c30, [x9, #7]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q13, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603269 // ldr c9, [c19, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601269 // ldr c9, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400133 // ldr c19, [x9, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400533 // ldr c19, [x9, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400933 // ldr c19, [x9, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d33 // ldr c19, [x9, #3]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401533 // ldr c19, [x9, #5]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401933 // ldr c19, [x9, #6]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401d33 // ldr c19, [x9, #7]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402133 // ldr c19, [x9, #8]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402533 // ldr c19, [x9, #9]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402933 // ldr c19, [x9, #10]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402d33 // ldr c19, [x9, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x19, v13.d[0]
	cmp x9, x19
	b.ne comparison_fail
	ldr x9, =0x0
	mov x19, v13.d[1]
	cmp x9, x19
	b.ne comparison_fail
	ldr x9, =0x0
	mov x19, v30.d[0]
	cmp x9, x19
	b.ne comparison_fail
	ldr x9, =0x0
	mov x19, v30.d[1]
	cmp x9, x19
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
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001208
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001244
	ldr x1, =check_data4
	ldr x2, =0x00001246
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001700
	ldr x1, =check_data5
	ldr x2, =0x00001720
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fe8
	ldr x1, =check_data6
	ldr x2, =0x00001ff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
