.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x5e, 0x60, 0xda, 0x78, 0x43, 0xc2, 0x70, 0xe2, 0x41, 0x00, 0x3f, 0xcb, 0xe0, 0xfd, 0x6a, 0x82
	.byte 0x58, 0x3e, 0x99, 0xb8, 0x22, 0x10, 0xc5, 0xc2, 0xc0, 0x0f, 0xfd, 0x02, 0x1f, 0x78, 0x3d, 0x9b
	.byte 0xe2, 0xa1, 0x23, 0x39, 0x24, 0x09, 0xc0, 0x5a, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1e01
	/* C15 */
	.octa 0x80000000400000040000000000000ac0
	/* C18 */
	.octa 0x40000000000200070000000000001400
final_cap_values:
	/* C0 */
	.octa 0xffffffffff0bd000
	/* C1 */
	.octa 0x1e01
	/* C2 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000400000040000000000000ac0
	/* C18 */
	.octa 0x1393
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000002000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fd002190000000000008001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78da605e // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:110100110 0:0 opc:11 111000:111000 size:01
	.inst 0xe270c243 // ASTUR-V.RI-H Rt:3 Rn:18 op2:00 imm9:100001100 V:1 op1:01 11100010:11100010
	.inst 0xcb3f0041 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:2 imm3:000 option:000 Rm:31 01011001:01011001 S:0 op:1 sf:1
	.inst 0x826afde0 // ALDR-R.RI-64 Rt:0 Rn:15 op:11 imm9:010101111 L:1 1000001001:1000001001
	.inst 0xb8993e58 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:18 11:11 imm9:110010011 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c51022 // CVTD-R.C-C Rd:2 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x02fd0fc0 // SUB-C.CIS-C Cd:0 Cn:30 imm12:111101000011 sh:1 A:1 00000010:00000010
	.inst 0x9b3d781f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:30 o0:0 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x3923a1e2 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:15 imm12:100011101000 opc:00 111001:111001 size:00
	.inst 0x5ac00924 // rev:aarch64/instrs/integer/arithmetic/rev Rd:4 Rn:9 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400162 // ldr c2, [x11, #0]
	.inst 0xc240056f // ldr c15, [x11, #1]
	.inst 0xc2400972 // ldr c18, [x11, #2]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322b // ldr c11, [c17, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260122b // ldr c11, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x17, #0xf
	and x11, x11, x17
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400171 // ldr c17, [x11, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400571 // ldr c17, [x11, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400971 // ldr c17, [x11, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x17, v3.d[0]
	cmp x11, x17
	b.ne comparison_fail
	ldr x11, =0x0
	mov x17, v3.d[1]
	cmp x11, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000130c
	ldr x1, =check_data1
	ldr x2, =0x0000130e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015ac
	ldr x1, =check_data2
	ldr x2, =0x000015b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000015c1
	ldr x1, =check_data3
	ldr x2, =0x000015c2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fc2
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
