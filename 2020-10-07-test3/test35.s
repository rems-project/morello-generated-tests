.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdd, 0x70, 0x87, 0x52, 0x40, 0xa7, 0xd9, 0xc2, 0x15, 0x0c, 0x52, 0xf1, 0x00, 0x20, 0x5f, 0x82
	.byte 0x68, 0xd7, 0xf6, 0x54, 0x41, 0xea, 0xca, 0xc2, 0xf4, 0x1b, 0xd9, 0xc2, 0xe1, 0x67, 0x0d, 0x78
	.byte 0xdf, 0x5b, 0x89, 0xab, 0x1e, 0xcc, 0x26, 0xab, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x400008000000000000000000000000
	/* C26 */
	.octa 0x20408008000100070000000000400009
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000100070000000000000000
	/* C21 */
	.octa 0xffffffffffb7d000
	/* C25 */
	.octa 0x400008000000000000000000000000
	/* C26 */
	.octa 0x20408008000100070000000000400009
	/* C29 */
	.octa 0x400000000000000000000000000000
initial_SP_EL3_value:
	.octa 0x400000000001000700000000000017f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c000000000600020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x528770dd // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:0011101110000110 hw:00 100101:100101 opc:10 sf:0
	.inst 0xc2d9a740 // BLRS-C.C-C 00000:00000 Cn:26 001:001 opc:01 1:1 Cm:25 11000010110:11000010110
	.inst 0xf1520c15 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:0 imm12:010010000011 sh:1 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x825f2000 // ASTR-C.RI-C Ct:0 Rn:0 op:00 imm9:111110010 L:0 1000001001:1000001001
	.inst 0x54f6d768 // b_cond:aarch64/instrs/branch/conditional/cond cond:1000 0:0 imm19:1111011011010111011 01010100:01010100
	.inst 0xc2caea41 // CTHI-C.CR-C Cd:1 Cn:18 1010:1010 opc:11 Rm:10 11000010110:11000010110
	.inst 0xc2d91bf4 // ALIGND-C.CI-C Cd:20 Cn:31 0110:0110 U:0 imm6:110010 11000010110:11000010110
	.inst 0x780d67e1 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:011010110 0:0 opc:00 111000:111000 size:01
	.inst 0xab895bdf // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:30 imm6:010110 Rm:9 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0xab26cc1e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:0 imm3:011 option:110 Rm:6 01011001:01011001 S:1 op:0 sf:1
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005b2 // ldr c18, [x13, #1]
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2400dba // ldr c26, [x13, #3]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850038
	msr SCTLR_EL3, x13
	ldr x13, =0x84
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338d // ldr c13, [c28, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x28, #0x3
	and x13, x13, x28
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017f0
	ldr x1, =check_data0
	ldr x2, =0x000017f2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f20
	ldr x1, =check_data1
	ldr x2, =0x00001f30
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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

	.balign 128
vector_table:
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
