.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x50
.data
check_data5:
	.byte 0xdc, 0x23, 0xc6, 0xa8, 0x4c, 0x5d, 0x6b, 0xb4, 0x64, 0x12, 0xc9, 0x3c, 0xbe, 0xf6, 0x65, 0xd1
	.byte 0x5e, 0xc3, 0x16, 0x78, 0x40, 0xfc, 0x9f, 0x88, 0xe5, 0xb2, 0x80, 0x1a, 0x3e, 0x90, 0xc1, 0xc2
	.byte 0xe2, 0x2f, 0x48, 0x78, 0x41, 0x89, 0xc2, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xfc0
	/* C10 */
	.octa 0x400280010000000000010001
	/* C12 */
	.octa 0xffffffffffffffff
	/* C19 */
	.octa 0x108f
	/* C21 */
	.octa 0x2000
	/* C26 */
	.octa 0x1f94
	/* C30 */
	.octa 0xf80
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400280010000000000010001
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x400280010000000000010001
	/* C12 */
	.octa 0xffffffffffffffff
	/* C19 */
	.octa 0x108f
	/* C21 */
	.octa 0x2000
	/* C26 */
	.octa 0x1f94
	/* C28 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x11d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600200800000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8c623dc // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:28 Rn:30 Rt2:01000 imm7:0001100 L:1 1010001:1010001 opc:10
	.inst 0xb46b5d4c // cbz:aarch64/instrs/branch/conditional/compare Rt:12 imm19:0110101101011101010 op:0 011010:011010 sf:1
	.inst 0x3cc91264 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:4 Rn:19 00:00 imm9:010010001 0:0 opc:11 111100:111100 size:00
	.inst 0xd165f6be // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:21 imm12:100101111101 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x7816c35e // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:26 00:00 imm9:101101100 0:0 opc:00 111000:111000 size:01
	.inst 0x889ffc40 // stlr:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x1a80b2e5 // csel:aarch64/instrs/integer/conditional/select Rd:5 Rn:23 o2:0 0:0 cond:1011 Rm:0 011010100:011010100 op:0 sf:0
	.inst 0xc2c1903e // CLRTAG-C.C-C Cd:30 Cn:1 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x78482fe2 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:31 11:11 imm9:010000010 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c28941 // CHKSSU-C.CC-C Cd:1 Cn:10 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2400dcc // ldr c12, [x14, #3]
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ce // ldr c14, [c22, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826012ce // ldr c14, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x22, #0xf
	and x14, x14, x22
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d6 // ldr c22, [x14, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005d6 // ldr c22, [x14, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009d6 // ldr c22, [x14, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400dd6 // ldr c22, [x14, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24011d6 // ldr c22, [x14, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401dd6 // ldr c22, [x14, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc24021d6 // ldr c22, [x14, #8]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc24025d6 // ldr c22, [x14, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc24029d6 // ldr c22, [x14, #10]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x22, v4.d[0]
	cmp x14, x22
	b.ne comparison_fail
	ldr x14, =0x0
	mov x22, v4.d[1]
	cmp x14, x22
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a0
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012d2
	ldr x1, =check_data3
	ldr x2, =0x000012d4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f82
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
