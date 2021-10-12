.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xb5, 0x10, 0xc7, 0xc2, 0x5f, 0x61, 0x73, 0xf8, 0x6d, 0x62, 0x50, 0xfa, 0xf2, 0x01, 0x0d, 0x3a
	.byte 0xe1, 0xdb, 0x72, 0xa9, 0x1f, 0x4a, 0x6a, 0xa2, 0x3d, 0x18, 0x99, 0x02, 0xc1, 0x17, 0x50, 0x78
	.byte 0xe1, 0x84, 0xd7, 0xc2, 0xd1, 0x57, 0x8d, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x843003fffffff
	/* C7 */
	.octa 0x200f6016007fffffffff0001
	/* C10 */
	.octa 0x1000
	/* C16 */
	.octa 0xfe0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x4000c0000040000000000001
	/* C30 */
	.octa 0x4100fc
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x843003fffffff
	/* C7 */
	.octa 0x200f6016007fffffffff0001
	/* C10 */
	.octa 0x1000
	/* C16 */
	.octa 0xfe0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x8440000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x4000c0000040000000000001
	/* C29 */
	.octa 0xfffffffffffff9bb
	/* C30 */
	.octa 0x4100d2
initial_SP_EL3_value:
	.octa 0x10d8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c710b5 // RRLEN-R.R-C Rd:21 Rn:5 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xf873615f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:110 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xfa50626d // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1101 0:0 Rn:19 00:00 cond:0110 Rm:16 111010010:111010010 op:1 sf:1
	.inst 0x3a0d01f2 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:18 Rn:15 000000:000000 Rm:13 11010000:11010000 S:1 op:0 sf:0
	.inst 0xa972dbe1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:31 Rt2:10110 imm7:1100101 L:1 1010010:1010010 opc:10
	.inst 0xa26a4a1f // LDR-C.RRB-C Ct:31 Rn:16 10:10 S:0 option:010 Rm:10 1:1 opc:01 10100010:10100010
	.inst 0x0299183d // SUB-C.CIS-C Cd:29 Cn:1 imm12:011001000110 sh:0 A:1 00000010:00000010
	.inst 0x785017c1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:30 01:01 imm9:100000001 0:0 opc:01 111000:111000 size:01
	.inst 0xc2d784e1 // CHKSS-_.CC-C 00001:00001 Cn:7 001:001 opc:00 1:1 Cm:23 11000010110:11000010110
	.inst 0x388d57d1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:30 01:01 imm9:011010101 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21180
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
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2400527 // ldr c7, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2401537 // ldr c23, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x10000000
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
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603189 // ldr c9, [c12, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601189 // ldr c9, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	mov x12, #0xf
	and x9, x9, x12
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012c // ldr c12, [x9, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240052c // ldr c12, [x9, #1]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240092c // ldr c12, [x9, #2]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2400d2c // ldr c12, [x9, #3]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc240112c // ldr c12, [x9, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240152c // ldr c12, [x9, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240192c // ldr c12, [x9, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401d2c // ldr c12, [x9, #7]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc240212c // ldr c12, [x9, #8]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240252c // ldr c12, [x9, #9]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240292c // ldr c12, [x9, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402d2c // ldr c12, [x9, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040fffd
	ldr x1, =check_data3
	ldr x2, =0x0040fffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004100fc
	ldr x1, =check_data4
	ldr x2, =0x004100fe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
