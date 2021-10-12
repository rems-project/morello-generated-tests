.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x14, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x74, 0x75, 0xe2, 0xc0, 0xc4, 0x04, 0xb8, 0xdf, 0x43, 0x9c, 0x82, 0x14, 0x08, 0xfe, 0xc2
	.byte 0x1c, 0x5c, 0xab, 0xa9, 0xc2, 0x91, 0xc1, 0xc2, 0x9e, 0x8b, 0xce, 0x78, 0xa0, 0x00, 0x1f, 0xd6
.data
check_data5:
	.byte 0xa1, 0x85, 0xc2, 0xc2, 0x15, 0xa0, 0xc2, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1400
	/* C1 */
	.octa 0x800000000000000000000000000010a9
	/* C5 */
	.octa 0x408000
	/* C6 */
	.octa 0x1000
	/* C13 */
	.octa 0x79007f0000000000000001
	/* C14 */
	.octa 0x200380090040000000000001
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x400000000001000500000000000009e0
final_cap_values:
	/* C0 */
	.octa 0x12b0
	/* C1 */
	.octa 0x800000000000000000000000000010a9
	/* C2 */
	.octa 0x200380090040000000000001
	/* C5 */
	.octa 0x408000
	/* C6 */
	.octa 0x104c
	/* C13 */
	.octa 0x79007f0000000000000001
	/* C14 */
	.octa 0x200380090040000000000001
	/* C20 */
	.octa 0xf000000000001400
	/* C21 */
	.octa 0x12b0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100180050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe275743e // ALDUR-V.RI-H Rt:30 Rn:1 op2:01 imm9:101010111 V:1 op1:01 11100010:11100010
	.inst 0xb804c4c0 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:6 01:01 imm9:001001100 0:0 opc:00 111000:111000 size:10
	.inst 0x829c43df // ASTRB-R.RRB-B Rt:31 Rn:30 opc:00 S:0 option:010 Rm:28 0:0 L:0 100000101:100000101
	.inst 0xc2fe0814 // ORRFLGS-C.CI-C Cd:20 Cn:0 0:0 01:01 imm8:11110000 11000010111:11000010111
	.inst 0xa9ab5c1c // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:28 Rn:0 Rt2:10111 imm7:1010110 L:0 1010011:1010011 opc:10
	.inst 0xc2c191c2 // CLRTAG-C.C-C Cd:2 Cn:14 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x78ce8b9e // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:28 10:10 imm9:011101000 0:0 opc:11 111000:111000 size:01
	.inst 0xd61f00a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 32736
	.inst 0xc2c285a1 // CHKSS-_.CC-C 00001:00001 Cn:13 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2c2a015 // CLRPERM-C.CR-C Cd:21 Cn:0 000:000 1:1 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1015796
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f66 // ldr c6, [x27, #3]
	.inst 0xc240136d // ldr c13, [x27, #4]
	.inst 0xc240176e // ldr c14, [x27, #5]
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2401f7c // ldr c28, [x27, #7]
	.inst 0xc240237e // ldr c30, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x8
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313b // ldr c27, [c9, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x8260113b // ldr c27, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x9, #0xf
	and x27, x27, x9
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400369 // ldr c9, [x27, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400769 // ldr c9, [x27, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401769 // ldr c9, [x27, #5]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401b69 // ldr c9, [x27, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401f69 // ldr c9, [x27, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402369 // ldr c9, [x27, #8]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402769 // ldr c9, [x27, #9]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402b69 // ldr c9, [x27, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402f69 // ldr c9, [x27, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x9, v30.d[0]
	cmp x27, x9
	b.ne comparison_fail
	ldr x27, =0x0
	mov x9, v30.d[1]
	cmp x27, x9
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
	ldr x0, =0x000010e8
	ldr x1, =check_data1
	ldr x2, =0x000010ea
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012b0
	ldr x1, =check_data2
	ldr x2, =0x000012c0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019e0
	ldr x1, =check_data3
	ldr x2, =0x000019e1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408000
	ldr x1, =check_data5
	ldr x2, =0x0040800c
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
