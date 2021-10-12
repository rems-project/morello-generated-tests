.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x66
.data
check_data1:
	.byte 0xa1, 0xb7, 0x41, 0x38, 0x5c, 0x6f, 0x57, 0x28, 0xa1, 0x60, 0x29, 0xe2, 0xfe, 0x5f, 0x01, 0xe2
	.byte 0x23, 0x31, 0xc2, 0xc2
.data
check_data2:
	.byte 0xd1, 0x9c, 0xde, 0xb0, 0x1e, 0x84, 0xad, 0x39, 0xd2, 0xcb, 0x69, 0x38, 0x86, 0x65, 0x6c, 0x54
	.byte 0x1e, 0xd8, 0x37, 0x38, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x66
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40749d
	/* C5 */
	.octa 0x1f68
	/* C9 */
	.octa 0x20000000d001000d0000000000400018
	/* C23 */
	.octa 0xffbfab61
	/* C26 */
	.octa 0x800000000007000e0000000000480004
	/* C29 */
	.octa 0x8000000000050007000000000040ffec
final_cap_values:
	/* C0 */
	.octa 0x40749d
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x1f68
	/* C9 */
	.octa 0x20000000d001000d0000000000400018
	/* C17 */
	.octa 0xffffffffbd799000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0xffbfab61
	/* C26 */
	.octa 0x800000000007000e0000000000480004
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000500070000000000410007
	/* C30 */
	.octa 0x66
initial_SP_EL3_value:
	.octa 0x403fe9
initial_RDDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000940050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3841b7a1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:29 01:01 imm9:000011011 0:0 opc:01 111000:111000 size:00
	.inst 0x28576f5c // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:28 Rn:26 Rt2:11011 imm7:0101110 L:1 1010000:1010000 opc:00
	.inst 0xe22960a1 // ASTUR-V.RI-B Rt:1 Rn:5 op2:00 imm9:010010110 V:1 op1:00 11100010:11100010
	.inst 0xe2015ffe // ALDURSB-R.RI-32 Rt:30 Rn:31 op2:11 imm9:000010101 V:0 op1:00 11100010:11100010
	.inst 0xc2c23123 // BLRR-C-C 00011:00011 Cn:9 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0xb0de9cd1 // ADRP-C.IP-C Rd:17 immhi:101111010011100110 P:1 10000:10000 immlo:01 op:1
	.inst 0x39ad841e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:101101100001 opc:10 111001:111001 size:00
	.inst 0x3869cbd2 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:18 Rn:30 10:10 S:0 option:110 Rm:9 1:1 opc:01 111000:111000 size:00
	.inst 0x546c6586 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:0110110001100101100 01010100:01010100
	.inst 0x3837d81e // strb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:0 10:10 S:1 option:110 Rm:23 1:1 opc:00 111000:111000 size:00
	.inst 0xc2c210c0
	.zero 32716
	.inst 0x00660000
	.zero 1015808
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
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x80
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	ldr x19, =initial_RDDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28b4333 // msr RDDC_EL0, c19
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d3 // ldr c19, [c6, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826010d3 // ldr c19, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	mov x6, #0x1
	and x19, x19, x6
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400266 // ldr c6, [x19, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401266 // ldr c6, [x19, #4]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401666 // ldr c6, [x19, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401a66 // ldr c6, [x19, #6]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401e66 // ldr c6, [x19, #7]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402266 // ldr c6, [x19, #8]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402666 // ldr c6, [x19, #9]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402a66 // ldr c6, [x19, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402e66 // ldr c6, [x19, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x6, v1.d[0]
	cmp x19, x6
	b.ne comparison_fail
	ldr x19, =0x0
	mov x6, v1.d[1]
	cmp x19, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400018
	ldr x1, =check_data2
	ldr x2, =0x00400030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040007e
	ldr x1, =check_data3
	ldr x2, =0x0040007f
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ffe
	ldr x1, =check_data4
	ldr x2, =0x00403fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00407ffe
	ldr x1, =check_data5
	ldr x2, =0x00407fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040ffec
	ldr x1, =check_data6
	ldr x2, =0x0040ffed
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004800bc
	ldr x1, =check_data7
	ldr x2, =0x004800c4
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
