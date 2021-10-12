.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x29
.data
check_data2:
	.byte 0x29, 0x00, 0x40, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x21, 0x84, 0xc2, 0xc2, 0x01, 0xb8, 0x0a, 0x39, 0x8a, 0x5a, 0xe0, 0xc2, 0x63, 0x59, 0x91, 0x22
	.byte 0xe3, 0x51, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe2, 0x13, 0xc7, 0xc2, 0x81, 0x18, 0x4e, 0x82, 0x00, 0x12, 0xc2, 0xc2
.data
check_data6:
	.byte 0xf4, 0x91, 0xc5, 0xc2, 0x52, 0xd0, 0x01, 0x3c, 0x23, 0x30, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400400080000000000000e1c
	/* C1 */
	.octa 0x20008000000100070000000000400029
	/* C2 */
	.octa 0x192170000000000001000
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1000
	/* C11 */
	.octa 0x48000000200000080000000000001870
	/* C15 */
	.octa 0x20008000800300050000000000400080
	/* C20 */
	.octa 0x400000a2008000000000e001
	/* C22 */
	.octa 0x20000
final_cap_values:
	/* C0 */
	.octa 0x40000000400400080000000000000e1c
	/* C1 */
	.octa 0x20008000000100070000000000400029
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1000
	/* C10 */
	.octa 0x400000a20000000000000e1c
	/* C11 */
	.octa 0x48000000200000080000000000001a90
	/* C15 */
	.octa 0x20008000800300050000000000400080
	/* C20 */
	.octa 0x40000000400100020000000000400080
	/* C22 */
	.octa 0x20000
	/* C30 */
	.octa 0x2000800000030005000000000040008c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000207c0060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004001000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c28421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0x390ab801 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:0 imm12:001010101110 opc:00 111001:111001 size:00
	.inst 0xc2e05a8a // CVTZ-C.CR-C Cd:10 Cn:20 0110:0110 1:1 0:0 Rm:0 11000010111:11000010111
	.inst 0x22915963 // STP-CC.RIAW-C Ct:3 Rn:11 Ct2:10110 imm7:0100010 L:0 001000101:001000101
	.inst 0xc2c251e3 // RETR-C-C 00011:00011 Cn:15 100:100 opc:10 11000010110000100:11000010110000100
	.zero 20
	.inst 0xc2c713e2 // RRLEN-R.R-C Rd:2 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x824e1881 // ASTR-R.RI-32 Rt:1 Rn:4 op:10 imm9:011100001 L:0 1000001001:1000001001
	.inst 0xc2c21200
	.zero 76
	.inst 0xc2c591f4 // CVTD-C.R-C Cd:20 Rn:15 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x3c01d052 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:18 Rn:2 00:00 imm9:000011101 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1048436
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
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2401244 // ldr c4, [x18, #4]
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2401e54 // ldr c20, [x18, #7]
	.inst 0xc2402256 // ldr c22, [x18, #8]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603212 // ldr c18, [c16, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601212 // ldr c18, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	mov x16, #0xf
	and x18, x18, x16
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400250 // ldr c16, [x18, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400650 // ldr c16, [x18, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a50 // ldr c16, [x18, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401650 // ldr c16, [x18, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401a50 // ldr c16, [x18, #6]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401e50 // ldr c16, [x18, #7]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2402250 // ldr c16, [x18, #8]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2402650 // ldr c16, [x18, #9]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402a50 // ldr c16, [x18, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x16, v18.d[0]
	cmp x18, x16
	b.ne comparison_fail
	ldr x18, =0x0
	mov x16, v18.d[1]
	cmp x18, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101d
	ldr x1, =check_data0
	ldr x2, =0x0000101e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ca
	ldr x1, =check_data1
	ldr x2, =0x000010cb
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001384
	ldr x1, =check_data2
	ldr x2, =0x00001388
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001870
	ldr x1, =check_data3
	ldr x2, =0x00001890
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400028
	ldr x1, =check_data5
	ldr x2, =0x00400034
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x0040008c
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
