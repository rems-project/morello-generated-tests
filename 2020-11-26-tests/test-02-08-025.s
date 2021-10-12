.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 4080
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x3e, 0x04, 0x58, 0xc2, 0xbd, 0x03, 0x1e, 0x3a, 0xbd, 0xa3, 0xca, 0xc2, 0x00, 0x32, 0x4a, 0x3d
	.byte 0xe1, 0x43, 0x39, 0xeb, 0xe0, 0x43, 0x74, 0x39, 0xe1, 0xc3, 0x4e, 0x29, 0xc5, 0x2d, 0xda, 0x1a
	.byte 0x8f, 0x66, 0x02, 0x91, 0x25, 0x59, 0xd5, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000040007ffffffffffffaff0
	/* C9 */
	.octa 0x8005048700fffdffe0000001
	/* C16 */
	.octa 0x80000000000100050000000000403d72
	/* C26 */
	.octa 0x10
final_cap_values:
	/* C0 */
	.octa 0xc2
	/* C1 */
	.octa 0x397443e0
	/* C5 */
	.octa 0x800504870100000000000000
	/* C9 */
	.octa 0x8005048700fffdffe0000001
	/* C16 */
	.octa 0x294ec3e1
	/* C26 */
	.octa 0x10
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
initial_SP_EL3_value:
	.octa 0x800000000001000600000000003fffa0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc258043e // LDR-C.RIB-C Ct:30 Rn:1 imm12:011000000001 L:1 110000100:110000100
	.inst 0x3a1e03bd // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:29 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2caa3bd // CLRPERM-C.CR-C Cd:29 Cn:29 000:000 1:1 10:10 Rm:10 11000010110:11000010110
	.inst 0x3d4a3200 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:16 imm12:001010001100 opc:01 111101:111101 size:00
	.inst 0xeb3943e1 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:31 imm3:000 option:010 Rm:25 01011001:01011001 S:1 op:1 sf:1
	.inst 0x397443e0 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:31 imm12:110100010000 opc:01 111001:111001 size:00
	.inst 0x294ec3e1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:31 Rt2:10000 imm7:0011101 L:1 1010010:1010010 opc:00
	.inst 0x1ada2dc5 // rorv:aarch64/instrs/integer/shift/variable Rd:5 Rn:14 op2:11 0010:0010 Rm:26 0011010110:0011010110 sf:0
	.inst 0x9102668f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:20 imm12:000010011001 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xc2d55925 // ALIGNU-C.CI-C Cd:5 Cn:9 0110:0110 U:1 imm6:101010 11000010110:11000010110
	.inst 0xc2c21180
	.zero 3204
	.inst 0x000000c2
	.zero 13128
	.inst 0x00c20000
	.zero 1032192
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
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2400d7a // ldr c26, [x11, #3]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260118b // ldr c11, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	.inst 0xc240016c // ldr c12, [x11, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240056c // ldr c12, [x11, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240156c // ldr c12, [x11, #5]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240196c // ldr c12, [x11, #6]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0xc2
	mov x12, v0.d[0]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v0.d[1]
	cmp x11, x12
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
	ldr x0, =0x00400cb0
	ldr x1, =check_data2
	ldr x2, =0x00400cb1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403ffe
	ldr x1, =check_data3
	ldr x2, =0x00403fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
