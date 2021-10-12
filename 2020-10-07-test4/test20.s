.section data0, #alloc, #write
	.zero 2720
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 1360
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xb3, 0xad, 0x5a, 0xa2, 0x21, 0xa8, 0xcc, 0xc2, 0x21, 0x43, 0x4e, 0xb8, 0xdf, 0x2f, 0x47, 0x69
	.byte 0xc0, 0x12, 0x4c, 0x71, 0x07, 0xe2, 0xb4, 0x54, 0x61, 0x03, 0x45, 0xe2, 0x02, 0x94, 0xbe, 0xca
	.byte 0x2e, 0xf9, 0x7b, 0xa2, 0xdf, 0x07, 0x6c, 0x82, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x4ef720
	/* C13 */
	.octa 0x2000
	/* C22 */
	.octa 0x80000000
	/* C25 */
	.octa 0x1f14
	/* C27 */
	.octa 0x4000000000010005000000000000108c
	/* C30 */
	.octa 0x80000000000100050000000000001734
final_cap_values:
	/* C0 */
	.octa 0x7fcfc000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffff80303fff
	/* C9 */
	.octa 0x4ef720
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x1aa0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x101800000000000000000000000
	/* C22 */
	.octa 0x80000000
	/* C25 */
	.octa 0x1f14
	/* C27 */
	.octa 0x4000000000010005000000000000108c
	/* C30 */
	.octa 0x80000000000100050000000000001734
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001aa0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25aadb3 // LDR-C.RIBW-C Ct:19 Rn:13 11:11 imm9:110101010 0:0 opc:01 10100010:10100010
	.inst 0xc2cca821 // EORFLGS-C.CR-C Cd:1 Cn:1 1010:1010 opc:10 Rm:12 11000010110:11000010110
	.inst 0xb84e4321 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:25 00:00 imm9:011100100 0:0 opc:01 111000:111000 size:10
	.inst 0x69472fdf // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:30 Rt2:01011 imm7:0001110 L:1 1010010:1010010 opc:01
	.inst 0x714c12c0 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:22 imm12:001100000100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x54b4e207 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:1011010011100010000 01010100:01010100
	.inst 0xe2450361 // ASTURH-R.RI-32 Rt:1 Rn:27 op2:00 imm9:001010000 V:0 op1:01 11100010:11100010
	.inst 0xcabe9402 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:0 imm6:100101 Rm:30 N:1 shift:10 01010:01010 opc:10 sf:1
	.inst 0xa27bf92e // LDR-C.RRB-C Ct:14 Rn:9 10:10 S:1 option:111 Rm:27 1:1 opc:01 10100010:10100010
	.inst 0x826c07df // ALDRB-R.RI-B Rt:31 Rn:30 op:01 imm9:011000000 L:1 1000001001:1000001001
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e9 // ldr c9, [x15, #1]
	.inst 0xc24009ed // ldr c13, [x15, #2]
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fb // ldr c27, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334f // ldr c15, [c26, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260134f // ldr c15, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x26, #0xf
	and x15, x15, x26
	cmp x15, #0x3
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fa // ldr c26, [x15, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005fa // ldr c26, [x15, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009fa // ldr c26, [x15, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dfa // ldr c26, [x15, #3]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc24011fa // ldr c26, [x15, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc24021fa // ldr c26, [x15, #8]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc24025fa // ldr c26, [x15, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc24029fa // ldr c26, [x15, #10]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc2402dfa // ldr c26, [x15, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010dc
	ldr x1, =check_data0
	ldr x2, =0x000010de
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000176c
	ldr x1, =check_data1
	ldr x2, =0x00001774
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f4
	ldr x1, =check_data2
	ldr x2, =0x000017f5
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001aa0
	ldr x1, =check_data3
	ldr x2, =0x00001ab0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
