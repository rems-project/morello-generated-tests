.section data0, #alloc, #write
	.zero 16
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc6, 0xdb, 0xed, 0x82, 0x02, 0x04, 0x5f, 0x7c, 0x97, 0x75, 0xb4, 0xb9, 0x16, 0x54, 0xf2, 0x68
	.byte 0x3e, 0xfc, 0xa0, 0x9b, 0x40, 0xd0, 0x42, 0x7a, 0x20, 0x10, 0xc2, 0xc2, 0x41, 0x7b, 0xbe, 0xb8
	.byte 0xe2, 0x95, 0x67, 0xa8, 0xa2, 0x53, 0xc0, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400000120000000000001020
	/* C1 */
	.octa 0x20008000e0010009000000000040001c
	/* C12 */
	.octa 0x8000000030078017000000000042ab90
	/* C13 */
	.octa 0x200
	/* C15 */
	.octa 0x483480
	/* C26 */
	.octa 0xfa04f0300
	/* C30 */
	.octa 0x482508
final_cap_values:
	/* C0 */
	.octa 0x80000000400000120000000000000fa0
	/* C1 */
	.octa 0xffffffffc2c2c2c2
	/* C5 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C12 */
	.octa 0x8000000030078017000000000042ab90
	/* C13 */
	.octa 0x200
	/* C15 */
	.octa 0x483480
	/* C21 */
	.octa 0xffffffffc2c2c2c2
	/* C22 */
	.octa 0xffffffffc2c2c2c2
	/* C23 */
	.octa 0xffffffffc2c2c2c2
	/* C26 */
	.octa 0xfa04f0300
	/* C30 */
	.octa 0xfffffffc17fe4a80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000790020fc0000000000480001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82eddbc6 // ALDR-V.RRB-D Rt:6 Rn:30 opc:10 S:1 option:110 Rm:13 1:1 L:1 100000101:100000101
	.inst 0x7c5f0402 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:111110000 0:0 opc:01 111100:111100 size:01
	.inst 0xb9b47597 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:12 imm12:110100011101 opc:10 111001:111001 size:10
	.inst 0x68f25416 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:22 Rn:0 Rt2:10101 imm7:1100100 L:1 1010001:1010001 opc:01
	.inst 0x9ba0fc3e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:31 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x7a42d040 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:2 00:00 cond:1101 Rm:2 111010010:111010010 op:1 sf:0
	.inst 0xc2c21020 // BR-C-C 00000:00000 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xb8be7b41 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:26 10:10 S:1 option:011 Rm:30 1:1 opc:10 111000:111000 size:10
	.inst 0xa86795e2 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:15 Rt2:00101 imm7:1001111 L:1 1010000:1010000 opc:10
	.inst 0xc2c053a2 // GCVALUE-R.C-C Rd:2 Cn:29 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21140
	.zero 188376
	.inst 0xc2c2c2c2
	.zero 347384
	.inst 0xc2c2c2c2
	.zero 1524
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 512
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 510704
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
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a4c // ldr c12, [x18, #2]
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x40000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603152 // ldr c18, [c10, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601152 // ldr c18, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc240024a // ldr c10, [x18, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a4a // ldr c10, [x18, #2]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc240124a // ldr c10, [x18, #4]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240164a // ldr c10, [x18, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401a4a // ldr c10, [x18, #6]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401e4a // ldr c10, [x18, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240224a // ldr c10, [x18, #8]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240264a // ldr c10, [x18, #9]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402a4a // ldr c10, [x18, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0xc2c2
	mov x10, v2.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v2.d[1]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0xc2c2c2c2c2c2c2c2
	mov x10, v6.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v6.d[1]
	cmp x18, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0042e004
	ldr x1, =check_data3
	ldr x2, =0x0042e008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00482d00
	ldr x1, =check_data4
	ldr x2, =0x00482d04
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004832f8
	ldr x1, =check_data5
	ldr x2, =0x00483308
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00483508
	ldr x1, =check_data6
	ldr x2, =0x00483510
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
