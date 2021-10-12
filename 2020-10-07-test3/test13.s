.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xff, 0x47, 0xd6, 0xe2, 0xbe, 0x5f, 0x8f, 0xb8, 0xc2, 0x75, 0xdd, 0x3c, 0xdf, 0x1b, 0xfe, 0xc2
	.byte 0xdf, 0x4f, 0x20, 0x02, 0x5e, 0xdc, 0xbe, 0x82, 0x98, 0xff, 0xdf, 0x08, 0x81, 0xa1, 0x50, 0xe2
	.byte 0xe0, 0x31, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0xe1, 0x0f, 0xd6, 0x38, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data8:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffd880
	/* C12 */
	.octa 0x2000
	/* C14 */
	.octa 0x800000007402e17400000000004ced70
	/* C15 */
	.octa 0x20008000000090000000000000440000
	/* C28 */
	.octa 0x80000000000640070000000000401000
	/* C29 */
	.octa 0x80000000000500070000000000000f0b
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffd880
	/* C12 */
	.octa 0x2000
	/* C14 */
	.octa 0x800000007402e17400000000004ced47
	/* C15 */
	.octa 0x20008000000090000000000000440000
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000640070000000000401000
	/* C29 */
	.octa 0x80000000000500070000000000001000
	/* C30 */
	.octa 0x20008000100000400000000000400025
initial_SP_EL3_value:
	.octa 0x1104
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000400000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d647ff // ALDUR-R.RI-64 Rt:31 Rn:31 op2:01 imm9:101100100 V:0 op1:11 11100010:11100010
	.inst 0xb88f5fbe // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:29 11:11 imm9:011110101 0:0 opc:10 111000:111000 size:10
	.inst 0x3cdd75c2 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:14 01:01 imm9:111010111 0:0 opc:11 111100:111100 size:00
	.inst 0xc2fe1bdf // CVT-C.CR-C Cd:31 Cn:30 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0x02204fdf // ADD-C.CIS-C Cd:31 Cn:30 imm12:100000010011 sh:0 A:0 00000010:00000010
	.inst 0x82bedc5e // ASTR-V.RRB-S Rt:30 Rn:2 opc:11 S:1 option:110 Rm:30 1:1 L:0 100000101:100000101
	.inst 0x08dfff98 // ldarb:aarch64/instrs/memory/ordered Rt:24 Rn:28 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xe250a181 // ASTURH-R.RI-32 Rt:1 Rn:12 op2:00 imm9:100001010 V:0 op1:01 11100010:11100010
	.inst 0xc2c231e0 // BLR-C-C 00000:00000 Cn:15 100:100 opc:01 11000010110000100:11000010110000100
	.zero 262108
	.inst 0x38d60fe1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:31 11:11 imm9:101100000 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c210c0
	.zero 786424
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a4c // ldr c12, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d2 // ldr c18, [c6, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010d2 // ldr c18, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400246 // ldr c6, [x18, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400646 // ldr c6, [x18, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401246 // ldr c6, [x18, #4]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401646 // ldr c6, [x18, #5]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401a46 // ldr c6, [x18, #6]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2401e46 // ldr c6, [x18, #7]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402246 // ldr c6, [x18, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x6, v2.d[0]
	cmp x18, x6
	b.ne comparison_fail
	ldr x18, =0x0
	mov x6, v2.d[1]
	cmp x18, x6
	b.ne comparison_fail
	ldr x18, =0x0
	mov x6, v30.d[0]
	cmp x18, x6
	b.ne comparison_fail
	ldr x18, =0x0
	mov x6, v30.d[1]
	cmp x18, x6
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
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001773
	ldr x1, =check_data2
	ldr x2, =0x00001774
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001880
	ldr x1, =check_data3
	ldr x2, =0x00001884
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f0a
	ldr x1, =check_data4
	ldr x2, =0x00001f0c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401001
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00440000
	ldr x1, =check_data7
	ldr x2, =0x00440008
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ced70
	ldr x1, =check_data8
	ldr x2, =0x004ced80
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
