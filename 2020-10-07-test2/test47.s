.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xd8, 0x13, 0xc1, 0xc2, 0xe2, 0xa7, 0x05, 0xe2, 0xff, 0x40, 0xc5, 0xc2, 0xc8, 0x2f, 0x02, 0xa2
	.byte 0x20, 0x00, 0xdf, 0xc2, 0x41, 0x88, 0x7b, 0xb3, 0x24, 0x7d, 0x9f, 0x48, 0x9f, 0xaa, 0xd4, 0xd0
	.byte 0x41, 0x30, 0xc2, 0xc2, 0x41, 0x4c, 0xf7, 0x6a, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000400000000000000000000000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x100000100030000000000000000
	/* C8 */
	.octa 0xc200000000000000
	/* C9 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x600040000000000000e00
final_cap_values:
	/* C0 */
	.octa 0x1000400000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x100000100030000000000000000
	/* C8 */
	.octa 0xc200000000000000
	/* C9 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000
	/* C30 */
	.octa 0x1020
initial_SP_EL3_value:
	.octa 0x80000000410440190000000000404000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000201900060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000880000000fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c113d8 // GCLIM-R.C-C Rd:24 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xe205a7e2 // ALDURB-R.RI-32 Rt:2 Rn:31 op2:01 imm9:001011010 V:0 op1:00 11100010:11100010
	.inst 0xc2c540ff // SCVALUE-C.CR-C Cd:31 Cn:7 000:000 opc:10 0:0 Rm:5 11000010110:11000010110
	.inst 0xa2022fc8 // STR-C.RIBW-C Ct:8 Rn:30 11:11 imm9:000100010 0:0 opc:00 10100010:10100010
	.inst 0xc2df0020 // SCBNDS-C.CR-C Cd:0 Cn:1 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0xb37b8841 // bfm:aarch64/instrs/integer/bitfield Rd:1 Rn:2 imms:100010 immr:111011 N:1 100110:100110 opc:01 sf:1
	.inst 0x489f7d24 // stllrh:aarch64/instrs/memory/ordered Rt:4 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xd0d4aa9f // ADRP-C.I-C Rd:31 immhi:101010010101010100 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x6af74c41 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:2 imm6:010011 Rm:23 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc2401329 // ldr c9, [x25, #4]
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085003a
	msr SCTLR_EL3, x25
	ldr x25, =0xc
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d9 // ldr c25, [c22, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826012d9 // ldr c25, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x22, #0xf
	and x25, x25, x22
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400336 // ldr c22, [x25, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400736 // ldr c22, [x25, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b36 // ldr c22, [x25, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400f36 // ldr c22, [x25, #3]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2401336 // ldr c22, [x25, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401b36 // ldr c22, [x25, #6]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401f36 // ldr c22, [x25, #7]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402336 // ldr c22, [x25, #8]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402736 // ldr c22, [x25, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
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
	ldr x0, =0x0040405a
	ldr x1, =check_data3
	ldr x2, =0x0040405b
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
