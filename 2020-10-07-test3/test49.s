.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3888
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data0:
	.zero 16
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xe1, 0x43, 0x5b, 0xa2, 0xe1, 0x91, 0xbe, 0x29, 0xe2, 0x7f, 0x0d, 0x2b, 0xfe, 0x12, 0xc5, 0xc2
	.byte 0x02, 0xa0, 0x6a, 0xa8, 0xd1, 0x0f, 0xdc, 0x9a, 0x84, 0xb1, 0x09, 0xb7
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x9b, 0x11, 0xc4, 0xc2
.data
check_data6:
	.byte 0x51, 0xa7, 0xd8, 0x38, 0xd0, 0x29, 0xc1, 0x1a, 0x60, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000000400200
	/* C4 */
	.octa 0x220000000
	/* C12 */
	.octa 0x90000000000b00050000000000001070
	/* C15 */
	.octa 0x40000000000100070000000000001294
	/* C23 */
	.octa 0x442002
	/* C26 */
	.octa 0xfe
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000000400200
	/* C1 */
	.octa 0x80000000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x220000000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x90000000000b00050000000000001070
	/* C15 */
	.octa 0x40000000000100070000000000001288
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x442002
	/* C26 */
	.octa 0x88
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x901000005fe20844000000000000200c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000081640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000682020020000000000446001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25b43e1 // LDUR-C.RI-C Ct:1 Rn:31 00:00 imm9:110110100 0:0 opc:01 10100010:10100010
	.inst 0x29be91e1 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:15 Rt2:00100 imm7:1111101 L:0 1010011:1010011 opc:00
	.inst 0x2b0d7fe2 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:31 imm6:011111 Rm:13 0:0 shift:00 01011:01011 S:1 op:0 sf:0
	.inst 0xc2c512fe // CVTD-R.C-C Rd:30 Cn:23 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xa86aa002 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:0 Rt2:01000 imm7:1010101 L:1 1010000:1010000 opc:10
	.inst 0x9adc0fd1 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:17 Rn:30 o1:1 00001:00001 Rm:28 0011010110:0011010110 sf:1
	.inst 0xb709b184 // tbnz:aarch64/instrs/branch/conditional/test Rt:4 imm14:00110110001100 b40:00001 op:1 011011:011011 b5:1
	.zero 13868
	.inst 0xc2c4119b // LDPBR-C.C-C Ct:27 Cn:12 100:100 opc:00 11000010110001000:11000010110001000
	.zero 18868
	.inst 0x38d8a751 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:26 01:01 imm9:110001010 0:0 opc:11 111000:111000 size:00
	.inst 0x1ac129d0 // asrv:aarch64/instrs/integer/shift/variable Rd:16 Rn:14 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2c21260
	.zero 1015796
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c4 // ldr c4, [x22, #1]
	.inst 0xc2400acc // ldr c12, [x22, #2]
	.inst 0xc2400ecf // ldr c15, [x22, #3]
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc24016da // ldr c26, [x22, #5]
	.inst 0xc2401adc // ldr c28, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603276 // ldr c22, [c19, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601276 // ldr c22, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x19, #0xf
	and x22, x22, x19
	cmp x22, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d3 // ldr c19, [x22, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24006d3 // ldr c19, [x22, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400ad3 // ldr c19, [x22, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400ed3 // ldr c19, [x22, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc24012d3 // ldr c19, [x22, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc24016d3 // ldr c19, [x22, #5]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401ad3 // ldr c19, [x22, #6]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401ed3 // ldr c19, [x22, #7]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc24022d3 // ldr c19, [x22, #8]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24026d3 // ldr c19, [x22, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402ad3 // ldr c19, [x22, #10]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402ed3 // ldr c19, [x22, #11]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc24032d3 // ldr c19, [x22, #12]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001090
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001288
	ldr x1, =check_data1
	ldr x2, =0x00001290
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000a8
	ldr x1, =check_data4
	ldr x2, =0x004000b8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403648
	ldr x1, =check_data5
	ldr x2, =0x0040364c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408000
	ldr x1, =check_data6
	ldr x2, =0x0040800c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00442100
	ldr x1, =check_data7
	ldr x2, =0x00442101
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
