.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x5f, 0x19, 0xe1, 0xc2, 0xc0, 0xbf, 0xee, 0x02, 0x24, 0xf0, 0xeb, 0x42, 0xe1, 0x7f, 0x5f, 0x08
	.byte 0x20, 0x27, 0xc9, 0x1a, 0x42, 0xc0, 0xb5, 0xe2, 0x42, 0x68, 0xfe, 0x3c, 0x02, 0x93, 0x4c, 0x29
	.byte 0xe7, 0x0b, 0x1a, 0x38, 0xfc, 0x6e, 0xbe, 0x82, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90000000000300070000000000430c20
	/* C2 */
	.octa 0x80000000000700070000000000002008
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x200070185007fffffffbfea00
	/* C23 */
	.octa 0x2400
	/* C24 */
	.octa 0x800000000000c0000000000000001800
	/* C30 */
	.octa 0x8000070005ffffffffffffeff8
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x200070185007fffffffbfea00
	/* C23 */
	.octa 0x2400
	/* C24 */
	.octa 0x800000000000c0000000000000001800
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x8000070005ffffffffffffeff8
initial_SP_EL3_value:
	.octa 0xc0000000000700070000000000001060
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000030000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e1195f // CVT-C.CR-C Cd:31 Cn:10 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0x02eebfc0 // SUB-C.CIS-C Cd:0 Cn:30 imm12:101110101111 sh:1 A:1 00000010:00000010
	.inst 0x42ebf024 // LDP-C.RIB-C Ct:4 Rn:1 Ct2:11100 imm7:1010111 L:1 010000101:010000101
	.inst 0x085f7fe1 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x1ac92720 // lsrv:aarch64/instrs/integer/shift/variable Rd:0 Rn:25 op2:01 0010:0010 Rm:9 0011010110:0011010110 sf:0
	.inst 0xe2b5c042 // ASTUR-V.RI-S Rt:2 Rn:2 op2:00 imm9:101011100 V:1 op1:10 11100010:11100010
	.inst 0x3cfe6842 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:2 10:10 S:0 option:011 Rm:30 1:1 opc:11 111100:111100 size:00
	.inst 0x294c9302 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:2 Rn:24 Rt2:00100 imm7:0011001 L:1 1010010:1010010 opc:00
	.inst 0x381a0be7 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:7 Rn:31 10:10 imm9:110100000 0:0 opc:00 111000:111000 size:00
	.inst 0x82be6efc // ASTR-V.RRB-S Rt:28 Rn:23 opc:11 S:0 option:011 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xc2c211a0
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc2401237 // ldr c23, [x17, #4]
	.inst 0xc2401638 // ldr c24, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q2, =0x0
	ldr q28, =0xc2000000
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b1 // ldr c17, [c13, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826011b1 // ldr c17, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022d // ldr c13, [x17, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240062d // ldr c13, [x17, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2401a2d // ldr c13, [x17, #6]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc2401e2d // ldr c13, [x17, #7]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240222d // ldr c13, [x17, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x13, v2.d[0]
	cmp x17, x13
	b.ne comparison_fail
	ldr x17, =0x0
	mov x13, v2.d[1]
	cmp x17, x13
	b.ne comparison_fail
	ldr x17, =0xc2000000
	mov x13, v28.d[0]
	cmp x17, x13
	b.ne comparison_fail
	ldr x17, =0x0
	mov x13, v28.d[1]
	cmp x17, x13
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001061
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f8
	ldr x1, =check_data2
	ldr x2, =0x000013fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001864
	ldr x1, =check_data3
	ldr x2, =0x0000186c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f64
	ldr x1, =check_data4
	ldr x2, =0x00001f68
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
	ldr x0, =0x00430990
	ldr x1, =check_data6
	ldr x2, =0x004309b0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
