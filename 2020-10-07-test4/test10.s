.section data0, #alloc, #write
	.zero 3920
	.byte 0x00, 0x00, 0x00, 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 160
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x40, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xf0
.data
check_data4:
	.byte 0xb6, 0x3a, 0xa9, 0x2d, 0xe3, 0x7b, 0x3b, 0x9b, 0x42, 0x3c, 0x9c, 0xb9, 0x9e, 0x47, 0x63, 0x82
	.byte 0x62, 0x42, 0xc2, 0xc2, 0xc2, 0xd7, 0x49, 0x62, 0x21, 0x10, 0xc0, 0xc2, 0xa8, 0x3a, 0x44, 0x7a
	.byte 0x9f, 0xc6, 0xdd, 0xf0, 0x89, 0x7f, 0x5f, 0x42, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x300070000000000000000
	/* C2 */
	.octa 0xffffffffffffe5e8
	/* C19 */
	.octa 0x8001216f0044000000020003
	/* C21 */
	.octa 0x418
	/* C28 */
	.octa 0x80000000400200240000000000001f20
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0x8001216f0044000000020003
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000400200240000000000001f20
	/* C30 */
	.octa 0xf0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd010000040010de00000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2da93ab6 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:22 Rn:21 Rt2:01110 imm7:1010010 L:0 1011011:1011011 opc:00
	.inst 0x9b3b7be3 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:31 Ra:30 o0:0 Rm:27 01:01 U:0 10011011:10011011
	.inst 0xb99c3c42 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:2 imm12:011100001111 opc:10 111001:111001 size:10
	.inst 0x8263479e // ALDRB-R.RI-B Rt:30 Rn:28 op:01 imm9:000110100 L:1 1000001001:1000001001
	.inst 0xc2c24262 // SCVALUE-C.CR-C Cd:2 Cn:19 000:000 opc:10 0:0 Rm:2 11000010110:11000010110
	.inst 0x6249d7c2 // LDNP-C.RIB-C Ct:2 Rn:30 Ct2:10101 imm7:0010011 L:1 011000100:011000100
	.inst 0xc2c01021 // GCBASE-R.C-C Rd:1 Cn:1 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x7a443aa8 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1000 0:0 Rn:21 10:10 cond:0011 imm5:00100 111010010:111010010 op:1 sf:0
	.inst 0xf0ddc69f // ADRP-C.IP-C Rd:31 immhi:101110111000110100 P:1 10000:10000 immlo:11 op:1
	.inst 0x425f7f89 // ALDAR-C.R-C Ct:9 Rn:28 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400bb3 // ldr c19, [x29, #2]
	.inst 0xc2400fb5 // ldr c21, [x29, #3]
	.inst 0xc24013bc // ldr c28, [x29, #4]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q14, =0x400000
	ldr q22, =0x8000000
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0xc
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031bd // ldr c29, [c13, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826011bd // ldr c29, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x13, #0xf
	and x29, x29, x13
	cmp x29, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ad // ldr c13, [x29, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24007ad // ldr c13, [x29, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400bad // ldr c13, [x29, #2]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc2400fad // ldr c13, [x29, #3]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc24013ad // ldr c13, [x29, #4]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc24017ad // ldr c13, [x29, #5]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2401bad // ldr c13, [x29, #6]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x400000
	mov x13, v14.d[0]
	cmp x29, x13
	b.ne comparison_fail
	ldr x29, =0x0
	mov x13, v14.d[1]
	cmp x29, x13
	b.ne comparison_fail
	ldr x29, =0x8000000
	mov x13, v22.d[0]
	cmp x29, x13
	b.ne comparison_fail
	ldr x29, =0x0
	mov x13, v22.d[1]
	cmp x29, x13
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
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f20
	ldr x1, =check_data2
	ldr x2, =0x00001f30
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f54
	ldr x1, =check_data3
	ldr x2, =0x00001f55
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
