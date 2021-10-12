.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x41, 0x40, 0x00, 0xc2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xc2, 0xef, 0x4c, 0x82, 0xe6, 0x28, 0x4f, 0xc2, 0xe5, 0xe5, 0x1d, 0x39, 0xe2, 0xfb, 0x83, 0xb8
	.byte 0xa2, 0x92, 0x9b, 0xf8, 0x45, 0x24, 0xc1, 0x9a, 0xe1, 0xf7, 0x4b, 0xd3, 0x2d, 0x46, 0xf9, 0xc2
	.byte 0x41, 0x33, 0xc2, 0xc2, 0xc2, 0x51, 0xc3, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x90000000000080080000000000400000
	/* C13 */
	.octa 0xc2004041000000c2c200000000000000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x400000004004000a0000000000001097
	/* C17 */
	.octa 0x101c
	/* C25 */
	.octa 0x4
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xaa0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000000000000000000000000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x90000000000080080000000000400000
	/* C13 */
	.octa 0xc2004041000000c2c200000000000000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x400000004004000a0000000000001097
	/* C17 */
	.octa 0x101c
	/* C25 */
	.octa 0x4
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xaa0
initial_SP_EL3_value:
	.octa 0x800000000003000700000000003ffff9
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000000044380000000ad8f8f009
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x824cefc2 // ASTR-R.RI-64 Rt:2 Rn:30 op:11 imm9:011001110 L:0 1000001001:1000001001
	.inst 0xc24f28e6 // LDR-C.RIB-C Ct:6 Rn:7 imm12:001111001010 L:1 110000100:110000100
	.inst 0x391de5e5 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:5 Rn:15 imm12:011101111001 opc:00 111001:111001 size:00
	.inst 0xb883fbe2 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:31 10:10 imm9:000111111 0:0 opc:10 111000:111000 size:10
	.inst 0xf89b92a2 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:21 00:00 imm9:110111001 0:0 opc:10 111000:111000 size:11
	.inst 0x9ac12445 // lsrv:aarch64/instrs/integer/shift/variable Rd:5 Rn:2 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xd34bf7e1 // ubfm:aarch64/instrs/integer/bitfield Rd:1 Rn:31 imms:111101 immr:001011 N:1 100110:100110 opc:10 sf:1
	.inst 0xc2f9462d // ASTR-C.RRB-C Ct:13 Rn:17 1:1 L:0 S:0 option:010 Rm:25 11000010111:11000010111
	.inst 0xc2c23341 // CHKTGD-C-C 00001:00001 Cn:26 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c351c2 // SEAL-C.CI-C Cd:2 Cn:14 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400585 // ldr c5, [x12, #1]
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2401991 // ldr c17, [x12, #6]
	.inst 0xc2401d99 // ldr c25, [x12, #7]
	.inst 0xc240219a // ldr c26, [x12, #8]
	.inst 0xc240259e // ldr c30, [x12, #9]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cc // ldr c12, [c22, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x22, #0xf
	and x12, x12, x22
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2402196 // ldr c22, [x12, #8]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402596 // ldr c22, [x12, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402996 // ldr c22, [x12, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001118
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001811
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
	ldr x0, =0x00400038
	ldr x1, =check_data4
	ldr x2, =0x0040003c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ca0
	ldr x1, =check_data5
	ldr x2, =0x00403cb0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
