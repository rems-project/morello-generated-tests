.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf8, 0xff, 0x4f, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xfd, 0x71, 0xc0, 0xc2, 0x5f, 0xa0, 0xaa, 0xc2, 0x34, 0x5b, 0xe1, 0xc2, 0x01, 0xe8, 0xc0, 0xc2
	.byte 0x20, 0x7e, 0x9f, 0x88, 0x48, 0xd3, 0xc5, 0xc2, 0x09, 0x7c, 0xdf, 0x88, 0x2d, 0x03, 0x41, 0xa2
	.byte 0xae, 0x20, 0xc1, 0x38, 0x84, 0x74, 0xdc, 0x54, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffff8
	/* C1 */
	.octa 0xffffffffffe208
	/* C2 */
	.octa 0x20040002000007fffffffffc000
	/* C5 */
	.octa 0x80000000000100050000000000001fec
	/* C10 */
	.octa 0x4000
	/* C15 */
	.octa 0x400000000000000000000000
	/* C17 */
	.octa 0x40000000400400220000000000001040
	/* C25 */
	.octa 0x801000005f811a000000000000001f40
	/* C26 */
	.octa 0x1402400
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffff8
	/* C1 */
	.octa 0x4ffff800000000004ffff8
	/* C2 */
	.octa 0x20040002000007fffffffffc000
	/* C5 */
	.octa 0x80000000000100050000000000001fec
	/* C8 */
	.octa 0x80006381500001c07c2206400
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x4000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x400000000000000000000000
	/* C17 */
	.octa 0x40000000400400220000000000001040
	/* C20 */
	.octa 0x801000005f811a0000fffffffffffc08
	/* C25 */
	.octa 0x801000005f811a000000000000001f40
	/* C26 */
	.octa 0x1402400
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80006381500001c07c1fffff1
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c071fd // GCOFF-R.C-C Rd:29 Cn:15 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2aaa05f // ADD-C.CRI-C Cd:31 Cn:2 imm3:000 option:101 Rm:10 11000010101:11000010101
	.inst 0xc2e15b34 // CVTZ-C.CR-C Cd:20 Cn:25 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c0e801 // CTHI-C.CR-C Cd:1 Cn:0 1010:1010 opc:11 Rm:0 11000010110:11000010110
	.inst 0x889f7e20 // stllr:aarch64/instrs/memory/ordered Rt:0 Rn:17 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c5d348 // CVTDZ-C.R-C Cd:8 Rn:26 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x88df7c09 // ldlar:aarch64/instrs/memory/ordered Rt:9 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xa241032d // LDUR-C.RI-C Ct:13 Rn:25 00:00 imm9:000010000 0:0 opc:01 10100010:10100010
	.inst 0x38c120ae // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:5 00:00 imm9:000010010 0:0 opc:11 111000:111000 size:00
	.inst 0x54dc7484 // b_cond:aarch64/instrs/branch/conditional/cond cond:0100 0:0 imm19:1101110001110100100 01010100:01010100
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc240126a // ldr c10, [x19, #4]
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2401a71 // ldr c17, [x19, #6]
	.inst 0xc2401e79 // ldr c25, [x19, #7]
	.inst 0xc240227a // ldr c26, [x19, #8]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b3 // ldr c19, [c21, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012b3 // ldr c19, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x21, #0x8
	and x19, x19, x21
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400275 // ldr c21, [x19, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400675 // ldr c21, [x19, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a75 // ldr c21, [x19, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401275 // ldr c21, [x19, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401a75 // ldr c21, [x19, #6]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401e75 // ldr c21, [x19, #7]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2402275 // ldr c21, [x19, #8]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2402675 // ldr c21, [x19, #9]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2402a75 // ldr c21, [x19, #10]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2402e75 // ldr c21, [x19, #11]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2403275 // ldr c21, [x19, #12]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2403675 // ldr c21, [x19, #13]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2403a75 // ldr c21, [x19, #14]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001044
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f50
	ldr x1, =check_data1
	ldr x2, =0x00001f60
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
