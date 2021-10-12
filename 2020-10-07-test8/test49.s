.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x08, 0x69, 0x5a, 0xa2, 0x1a, 0xf0, 0x02, 0xa2, 0x20, 0x81, 0x6d, 0xe2, 0x41, 0x3d, 0x83, 0xb8
	.byte 0x21, 0x67, 0x08, 0xe2, 0x9f, 0xcc, 0x94, 0xe2, 0x05, 0x24, 0x69, 0xb1, 0xfd, 0x37, 0xd5, 0xe2
	.byte 0x43, 0x60, 0x19, 0xf8, 0xd1, 0x67, 0x99, 0xe2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 16
.data
check_data9:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x48000000000300070000000000000fd1
	/* C2 */
	.octa 0x4000000000020007000000000000182a
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1814
	/* C8 */
	.octa 0x80000000000300070000000000400600
	/* C9 */
	.octa 0x1000
	/* C10 */
	.octa 0x80000000000700070000000000001051
	/* C25 */
	.octa 0x1009
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x4e57a6
final_cap_values:
	/* C0 */
	.octa 0x48000000000300070000000000000fd1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000000020007000000000000182a
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1814
	/* C5 */
	.octa 0xa49fd1
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C10 */
	.octa 0x80000000000700070000000000001084
	/* C17 */
	.octa 0x0
	/* C25 */
	.octa 0x1009
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4e57a6
initial_SP_EL3_value:
	.octa 0x200d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000500070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25a6908 // LDTR-C.RIB-C Ct:8 Rn:8 10:10 imm9:110100110 0:0 opc:01 10100010:10100010
	.inst 0xa202f01a // STUR-C.RI-C Ct:26 Rn:0 00:00 imm9:000101111 0:0 opc:00 10100010:10100010
	.inst 0xe26d8120 // ASTUR-V.RI-H Rt:0 Rn:9 op2:00 imm9:011011000 V:1 op1:01 11100010:11100010
	.inst 0xb8833d41 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:10 11:11 imm9:000110011 0:0 opc:10 111000:111000 size:10
	.inst 0xe2086721 // ALDURB-R.RI-32 Rt:1 Rn:25 op2:01 imm9:010000110 V:0 op1:00 11100010:11100010
	.inst 0xe294cc9f // ASTUR-C.RI-C Ct:31 Rn:4 op2:11 imm9:101001100 V:0 op1:10 11100010:11100010
	.inst 0xb1692405 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:5 Rn:0 imm12:101001001001 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xe2d537fd // ALDUR-R.RI-64 Rt:29 Rn:31 op2:01 imm9:101010011 V:0 op1:11 11100010:11100010
	.inst 0xf8196043 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:2 00:00 imm9:110010110 0:0 opc:00 111000:111000 size:11
	.inst 0xe29967d1 // ALDUR-R.RI-32 Rt:17 Rn:30 op2:01 imm9:110010110 V:0 op1:10 11100010:11100010
	.inst 0xc2c212e0
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
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400da4 // ldr c4, [x13, #3]
	.inst 0xc24011a8 // ldr c8, [x13, #4]
	.inst 0xc24015a9 // ldr c9, [x13, #5]
	.inst 0xc24019aa // ldr c10, [x13, #6]
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc24021ba // ldr c26, [x13, #8]
	.inst 0xc24025be // ldr c30, [x13, #9]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ed // ldr c13, [c23, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ed // ldr c13, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x13, x13, x23
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b7 // ldr c23, [x13, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005b7 // ldr c23, [x13, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24009b7 // ldr c23, [x13, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401db7 // ldr c23, [x13, #7]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24021b7 // ldr c23, [x13, #8]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc24025b7 // ldr c23, [x13, #9]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc24029b7 // ldr c23, [x13, #10]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402db7 // ldr c23, [x13, #11]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc24031b7 // ldr c23, [x13, #12]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24035b7 // ldr c23, [x13, #13]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x23, v0.d[0]
	cmp x13, x23
	b.ne comparison_fail
	ldr x13, =0x0
	mov x23, v0.d[1]
	cmp x13, x23
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
	ldr x0, =0x00001084
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000108f
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010d8
	ldr x1, =check_data3
	ldr x2, =0x000010da
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001760
	ldr x1, =check_data4
	ldr x2, =0x00001770
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000017c0
	ldr x1, =check_data5
	ldr x2, =0x000017c8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001f60
	ldr x1, =check_data6
	ldr x2, =0x00001f68
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400060
	ldr x1, =check_data8
	ldr x2, =0x00400070
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x004e573c
	ldr x1, =check_data9
	ldr x2, =0x004e5740
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
