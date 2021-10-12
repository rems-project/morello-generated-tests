.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
	.byte 0x28, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2f, 0x00, 0x0f, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
	.byte 0x28, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2f, 0x00, 0x0f, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff, 0xd3, 0x9f, 0xda, 0x00, 0x30, 0xc4, 0xc2
.data
check_data4:
	.byte 0x3e, 0x30, 0xc0, 0xc2, 0x41, 0x7c, 0xd3, 0x9b, 0x2d, 0xf8, 0x2e, 0xa8, 0xa2, 0x56, 0x82, 0xe2
	.byte 0x1f, 0x4f, 0x3e, 0xb9, 0x1e, 0xc0, 0xdf, 0xc2, 0xdf, 0xf8, 0x1f, 0x1b, 0xbd, 0x55, 0x11, 0xf8
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000510102420000000000001000
	/* C1 */
	.octa 0x2010005f0000000000000001
	/* C2 */
	.octa 0x1000000000000000
	/* C13 */
	.octa 0x1000
	/* C19 */
	.octa 0x12180
	/* C21 */
	.octa 0x800000000000c0000000000000000fe7
	/* C24 */
	.octa 0xffffffffffffe10c
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000
	/* C1 */
	.octa 0x1218
	/* C2 */
	.octa 0x80
	/* C13 */
	.octa 0xf15
	/* C19 */
	.octa 0x12180
	/* C21 */
	.octa 0x800000000000c0000000000000000fe7
	/* C24 */
	.octa 0xffffffffffffe10c
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000180060080000000007001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda9fd3ff // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:31 o2:0 0:0 cond:1101 Rm:31 011010100:011010100 op:1 sf:1
	.inst 0xc2c43000 // LDPBLR-C.C-C Ct:0 Cn:0 100:100 opc:01 11000010110001000:11000010110001000
	.zero 32
	.inst 0xc2c0303e // GCLEN-R.C-C Rd:30 Cn:1 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x9bd37c41 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:2 Ra:11111 0:0 Rm:19 10:10 U:1 10011011:10011011
	.inst 0xa82ef82d // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:13 Rn:1 Rt2:11110 imm7:1011101 L:0 1010000:1010000 opc:10
	.inst 0xe28256a2 // ALDUR-R.RI-32 Rt:2 Rn:21 op2:01 imm9:000100101 V:0 op1:10 11100010:11100010
	.inst 0xb93e4f1f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:24 imm12:111110010011 opc:00 111001:111001 size:10
	.inst 0xc2dfc01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:31 11000010110:11000010110
	.inst 0x1b1ff8df // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:6 Ra:30 o0:1 Rm:31 0011011000:0011011000 sf:0
	.inst 0xf81155bd // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:13 01:01 imm9:100010101 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c211e0
	.zero 1048500
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e0d // ldr c13, [x16, #3]
	.inst 0xc2401213 // ldr c19, [x16, #4]
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x80000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f0 // ldr c16, [c15, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826011f0 // ldr c16, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x15, #0xf
	and x16, x16, x15
	cmp x16, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020f // ldr c15, [x16, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240060f // ldr c15, [x16, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a0f // ldr c15, [x16, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400e0f // ldr c15, [x16, #3]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240120f // ldr c15, [x16, #4]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc2401a0f // ldr c15, [x16, #6]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc2401e0f // ldr c15, [x16, #7]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240220f // ldr c15, [x16, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f58
	ldr x1, =check_data2
	ldr x2, =0x00001f5c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400028
	ldr x1, =check_data4
	ldr x2, =0x0040004c
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
