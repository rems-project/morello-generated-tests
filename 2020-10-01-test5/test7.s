.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
	.byte 0x01, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x20, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 544
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x04, 0x00, 0x00, 0x00
	.zero 3504
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
	.byte 0x01, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x20, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0xbc, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x04, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x0c
.data
check_data5:
	.byte 0x3f, 0x33, 0xc5, 0xc2, 0x5e, 0xbb, 0x73, 0x82, 0x1e, 0x08, 0x42, 0x6c, 0x41, 0x10, 0xc4, 0xc2
.data
check_data6:
	.byte 0xe2, 0xa8, 0x20, 0x0b, 0x21, 0x10, 0xc2, 0xc2, 0xba, 0xeb, 0x22, 0x38, 0x22, 0x2a, 0x06, 0xa8
	.byte 0xde, 0x57, 0x81, 0x9a, 0xc2, 0x7f, 0x5f, 0x42, 0x20, 0x11, 0xc2, 0xc2
.data
check_data7:
	.byte 0x40, 0x12, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1a08
	/* C2 */
	.octa 0x90000000200500030000000000001000
	/* C7 */
	.octa 0xffffb79c
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x400000000001000500000000000011a0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000070007000000000040000c
	/* C29 */
	.octa 0x40000000000100050000000000000020
final_cap_values:
	/* C0 */
	.octa 0x1a08
	/* C1 */
	.octa 0x10800000000000000000000000
	/* C2 */
	.octa 0x4080000000000000000000000
	/* C7 */
	.octa 0xffffb79c
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x400000000001000500000000000011a0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000070007000000000040000c
	/* C29 */
	.octa 0x40000000000100050000000000000020
	/* C30 */
	.octa 0x1240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000001007026700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001240
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5333f // CVTP-R.C-C Rd:31 Cn:25 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x8273bb5e // ALDR-R.RI-32 Rt:30 Rn:26 op:10 imm9:100111011 L:1 1000001001:1000001001
	.inst 0x6c42081e // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:30 Rn:0 Rt2:00010 imm7:0000100 L:1 1011000:1011000 opc:01
	.inst 0xc2c41041 // LDPBR-C.C-C Ct:1 Cn:2 100:100 opc:00 11000010110001000:11000010110001000
	.zero 496
	.inst 0x0b20a8e2 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:7 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x3822ebba // strb_reg:aarch64/instrs/memory/single/general/register Rt:26 Rn:29 10:10 S:0 option:111 Rm:2 1:1 opc:00 111000:111000 size:00
	.inst 0xa8062a22 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:17 Rt2:01010 imm7:0001100 L:0 1010000:1010000 opc:10
	.inst 0x9a8157de // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:30 o2:1 0:0 cond:0101 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0x425f7fc2 // ALDAR-C.R-C Ct:2 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c21120
	.zero 732
	.inst 0x00001240
	.zero 1047300
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400eea // ldr c10, [x23, #3]
	.inst 0xc24012f1 // ldr c17, [x23, #4]
	.inst 0xc24016f9 // ldr c25, [x23, #5]
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2401efd // ldr c29, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603137 // ldr c23, [c9, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601137 // ldr c23, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x9, #0xf
	and x23, x23, x9
	cmp x23, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e9 // ldr c9, [x23, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ee9 // ldr c9, [x23, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24016e9 // ldr c9, [x23, #5]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401ae9 // ldr c9, [x23, #6]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2401ee9 // ldr c9, [x23, #7]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24022e9 // ldr c9, [x23, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc24026e9 // ldr c9, [x23, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x9, v2.d[0]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v2.d[1]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v30.d[0]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v30.d[1]
	cmp x23, x9
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001240
	ldr x1, =check_data2
	ldr x2, =0x00001250
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a28
	ldr x1, =check_data3
	ldr x2, =0x00001a38
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fdc
	ldr x1, =check_data4
	ldr x2, =0x00001fdd
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400200
	ldr x1, =check_data6
	ldr x2, =0x0040021c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004004f8
	ldr x1, =check_data7
	ldr x2, =0x004004fc
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
