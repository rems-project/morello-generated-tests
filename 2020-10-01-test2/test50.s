.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x5e, 0x10, 0xc5, 0xc2, 0xc2, 0x80, 0x82, 0xcb, 0xc1, 0xeb, 0x60, 0x78, 0x02, 0x4c, 0x3c, 0xe2
	.byte 0xe1, 0xdf, 0x13, 0xe2, 0x5f, 0xf7, 0xc5, 0x38, 0x22, 0x98, 0x3e, 0xb4, 0x1e, 0x00, 0xbf, 0x9b
	.byte 0x20, 0xf8, 0x7b, 0xf8, 0x2b, 0x12, 0xc0, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000008008000000000048000c
	/* C2 */
	.octa 0xfffffffffffc7ff4
	/* C6 */
	.octa 0x0
	/* C17 */
	.octa 0x100050000000000000000
	/* C26 */
	.octa 0x448000
	/* C27 */
	.octa 0x88800
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x100050000000000000000
	/* C26 */
	.octa 0x44805f
	/* C27 */
	.octa 0x88800
	/* C30 */
	.octa 0x48000c
initial_csp_value:
	.octa 0x800000007ffdfb800000000000410040
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000100720070000000000440001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5105e // CVTD-R.C-C Rd:30 Cn:2 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xcb8280c2 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:6 imm6:100000 Rm:2 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x7860ebc1 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:30 10:10 S:0 option:111 Rm:0 1:1 opc:01 111000:111000 size:01
	.inst 0xe23c4c02 // ALDUR-V.RI-Q Rt:2 Rn:0 op2:11 imm9:111000100 V:1 op1:00 11100010:11100010
	.inst 0xe213dfe1 // ALDURSB-R.RI-32 Rt:1 Rn:31 op2:11 imm9:100111101 V:0 op1:00 11100010:11100010
	.inst 0x38c5f75f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:26 01:01 imm9:001011111 0:0 opc:11 111000:111000 size:00
	.inst 0xb43e9822 // cbz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:0011111010011000001 op:0 011010:011010 sf:1
	.inst 0x9bbf001e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:0 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xf87bf820 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:1 10:10 S:1 option:111 Rm:27 1:1 opc:01 111000:111000 size:11
	.inst 0xc2c0122b // GCBASE-R.C-C Rd:11 Cn:17 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c211a0
	.zero 278484
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 16376
	.inst 0x0000c2c2
	.zero 229324
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 524320
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400986 // ldr c6, [x12, #2]
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc240119a // ldr c26, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850038
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ac // ldr c12, [c13, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x13, #0xf
	and x12, x12, x13
	cmp x12, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0xc2c2c2c2c2c2c2c2
	mov x13, v2.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0xc2c2c2c2c2c2c2c2
	mov x13, v2.d[1]
	cmp x12, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0040ff7d
	ldr x1, =check_data1
	ldr x2, =0x0040ff7e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00444000
	ldr x1, =check_data2
	ldr x2, =0x00444008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00448000
	ldr x1, =check_data3
	ldr x2, =0x00448002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047ffd0
	ldr x1, =check_data4
	ldr x2, =0x0047ffe0
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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
