.section data0, #alloc, #write
	.zero 3552
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 528
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xff, 0xfb, 0x8e, 0xb8, 0x41, 0x07, 0x0c, 0x38, 0x9e, 0x11, 0x9d, 0xe2, 0x20, 0x92, 0xdb, 0xc2
	.byte 0x5e, 0xd1, 0xc1, 0xc2, 0x5f, 0x10, 0xc9, 0x38, 0x04, 0xb2, 0xc0, 0xc2, 0x20, 0x7f, 0xdf, 0x48
	.byte 0xe0, 0x43, 0xc0, 0xc2, 0x9f, 0x4a, 0xc2, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000000000000004fff6d
	/* C12 */
	.octa 0x400000000005000400000000000015cf
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x90100000600000210000000000002020
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x4ffffa
	/* C26 */
	.octa 0x1ff8
	/* C30 */
	.octa 0x80000000
final_cap_values:
	/* C0 */
	.octa 0x4000120270000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000000000000004fff6d
	/* C4 */
	.octa 0x1
	/* C12 */
	.octa 0x400000000005000400000000000015cf
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x90100000600000210000000000002020
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x4ffffa
	/* C26 */
	.octa 0x20b8
initial_csp_value:
	.octa 0x4000120270000000000401f19
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001de0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88efbff // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:011101111 0:0 opc:10 111000:111000 size:10
	.inst 0x380c0741 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:26 01:01 imm9:011000000 0:0 opc:00 111000:111000 size:00
	.inst 0xe29d119e // ASTUR-R.RI-32 Rt:30 Rn:12 op2:00 imm9:111010001 V:0 op1:10 11100010:11100010
	.inst 0xc2db9220 // BR-CI-C 0:0 0000:0000 Cn:17 100:100 imm7:1011100 110000101101:110000101101
	.inst 0xc2c1d15e // CPY-C.C-C Cd:30 Cn:10 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x38c9105f // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:2 00:00 imm9:010010001 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c0b204 // GCSEAL-R.C-C Rd:4 Cn:16 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x48df7f20 // ldlarh:aarch64/instrs/memory/ordered Rt:0 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c043e0 // SCVALUE-C.CR-C Cd:0 Cn:31 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c24a9f // UNSEAL-C.CC-C Cd:31 Cn:20 0010:0010 opc:01 Cm:2 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2401979 // ldr c25, [x11, #6]
	.inst 0xc2401d7a // ldr c26, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312b // ldr c11, [c9, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260112b // ldr c11, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400169 // ldr c9, [x11, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400969 // ldr c9, [x11, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401569 // ldr c9, [x11, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401969 // ldr c9, [x11, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401d69 // ldr c9, [x11, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402169 // ldr c9, [x11, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402569 // ldr c9, [x11, #9]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015a0
	ldr x1, =check_data0
	ldr x2, =0x000015a4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001de0
	ldr x1, =check_data1
	ldr x2, =0x00001df0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ff9
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
	ldr x0, =0x00402008
	ldr x1, =check_data4
	ldr x2, =0x0040200c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffa
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
