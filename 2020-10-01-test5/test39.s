.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x80, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x10, 0xc2, 0xc2, 0x3f, 0xa2, 0x52, 0x38, 0x80, 0x03, 0x1f, 0xd6
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x02, 0x22, 0xce, 0xc2, 0x1b, 0x41, 0x44, 0x82, 0x4b, 0xe8, 0xa1, 0x38, 0x5f, 0xd7, 0xd7, 0x98
	.byte 0x64, 0x7f, 0xdf, 0x48, 0x5f, 0xd8, 0xcf, 0xc2, 0x8b, 0xd7, 0xd0, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0xefffffff80c3c7e0
	/* C8 */
	.octa 0x4c0000005501000c0000000000001040
	/* C14 */
	.octa 0x3e0
	/* C16 */
	.octa 0x2000070007100000007f808020
	/* C17 */
	.octa 0x448100
	/* C27 */
	.octa 0x448000
	/* C28 */
	.octa 0x445004
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0xefffffff80c3c7e0
	/* C2 */
	.octa 0x2044008020100000007f808020
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x4c0000005501000c0000000000001040
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x3e0
	/* C16 */
	.octa 0x2000070007100000007f808020
	/* C17 */
	.octa 0x448100
	/* C27 */
	.octa 0x448000
	/* C28 */
	.octa 0x444f11
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000060600f70000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000188744070000000000444001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21001 // CHKSLD-C-C 00001:00001 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x3852a23f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:17 00:00 imm9:100101010 0:0 opc:01 111000:111000 size:00
	.inst 0xd61f0380 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:28 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 344056
	.inst 0xc2ce2202 // SCBNDSE-C.CR-C Cd:2 Cn:16 000:000 opc:01 0:0 Rm:14 11000010110:11000010110
	.inst 0x8244411b // ASTR-C.RI-C Ct:27 Rn:8 op:00 imm9:001000100 L:0 1000001001:1000001001
	.inst 0x38a1e84b // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:11 Rn:2 10:10 S:0 option:111 Rm:1 1:1 opc:10 111000:111000 size:00
	.inst 0x98d7d75f // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1101011111010111010 011000:011000 opc:10
	.inst 0x48df7f64 // ldlarh:aarch64/instrs/memory/ordered Rt:4 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2cfd85f // ALIGNU-C.CI-C Cd:31 Cn:2 0110:0110 U:1 imm6:011111 11000010110:11000010110
	.inst 0x78d0d78b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:11 Rn:28 01:01 imm9:100001101 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c21060
	.zero 704476
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a48 // ldr c8, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2401651 // ldr c17, [x18, #5]
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x8
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603072 // ldr c18, [c3, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601072 // ldr c18, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x3, #0xf
	and x18, x18, x3
	cmp x18, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400243 // ldr c3, [x18, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a43 // ldr c3, [x18, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401243 // ldr c3, [x18, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401643 // ldr c3, [x18, #5]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401a43 // ldr c3, [x18, #6]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401e43 // ldr c3, [x18, #7]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402243 // ldr c3, [x18, #8]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2402643 // ldr c3, [x18, #9]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2402a43 // ldr c3, [x18, #10]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001480
	ldr x1, =check_data0
	ldr x2, =0x00001490
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040000c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00403af8
	ldr x1, =check_data2
	ldr x2, =0x00403afc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00444800
	ldr x1, =check_data3
	ldr x2, =0x00444801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00445004
	ldr x1, =check_data4
	ldr x2, =0x00445006
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00448000
	ldr x1, =check_data5
	ldr x2, =0x00448002
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0044802a
	ldr x1, =check_data6
	ldr x2, =0x0044802b
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00454004
	ldr x1, =check_data7
	ldr x2, =0x00454024
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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
