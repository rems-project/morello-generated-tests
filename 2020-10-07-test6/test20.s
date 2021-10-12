.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x56, 0x6d, 0xd5, 0xac, 0xe8, 0x78, 0x05, 0xe2, 0x01, 0x20, 0xde, 0xc2, 0x91, 0x86, 0x00, 0x78
	.byte 0x80, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0xcc, 0x6b, 0x78, 0x38, 0x60, 0x0e, 0x47, 0xa2, 0x5e, 0x78, 0xff, 0x78, 0x78, 0x82, 0xde, 0xc2
	.byte 0x21, 0x00, 0xc0, 0x5a, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800300070000000000000000
	/* C2 */
	.octa 0x80000000000708070000000000001000
	/* C7 */
	.octa 0x80000000200200070000000000403727
	/* C10 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x80100000000100070000000000000ca0
	/* C20 */
	.octa 0x1800
	/* C24 */
	.octa 0x400000
	/* C28 */
	.octa 0x20008000000080080000000000402001
	/* C30 */
	.octa 0x800000002086200f0000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000708070000000000001000
	/* C7 */
	.octa 0x80000000200200070000000000403727
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x12a0
	/* C12 */
	.octa 0x56
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x801000000001000700000000000013a0
	/* C20 */
	.octa 0x1808
	/* C24 */
	.octa 0x801000000001000700000000000013a0
	/* C28 */
	.octa 0x20008000000080080000000000402001
	/* C30 */
	.octa 0x81
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001f8100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000007024000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xacd56d56 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:22 Rn:10 Rt2:11011 imm7:0101010 L:1 1011001:1011001 opc:10
	.inst 0xe20578e8 // ALDURSB-R.RI-64 Rt:8 Rn:7 op2:10 imm9:001010111 V:0 op1:00 11100010:11100010
	.inst 0xc2de2001 // SCBNDSE-C.CR-C Cd:1 Cn:0 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0x78008691 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:20 01:01 imm9:000001000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21380 // BR-C-C 00000:00000 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.zero 8172
	.inst 0x38786bcc // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:12 Rn:30 10:10 S:0 option:011 Rm:24 1:1 opc:01 111000:111000 size:00
	.inst 0xa2470e60 // LDR-C.RIBW-C Ct:0 Rn:19 11:11 imm9:001110000 0:0 opc:01 10100010:10100010
	.inst 0x78ff785e // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:2 10:10 S:1 option:011 Rm:31 1:1 opc:11 111000:111000 size:01
	.inst 0xc2de8278 // SCTAG-C.CR-C Cd:24 Cn:19 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0x5ac00021 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:1 Rn:1 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c213a0
	.zero 1040360
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d3 // ldr c19, [x6, #5]
	.inst 0xc24018d4 // ldr c20, [x6, #6]
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc24020dc // ldr c28, [x6, #8]
	.inst 0xc24024de // ldr c30, [x6, #9]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a6 // ldr c6, [c29, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826013a6 // ldr c6, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000dd // ldr c29, [x6, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004dd // ldr c29, [x6, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24008dd // ldr c29, [x6, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400cdd // ldr c29, [x6, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc24010dd // ldr c29, [x6, #4]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc24014dd // ldr c29, [x6, #5]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc24018dd // ldr c29, [x6, #6]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc24020dd // ldr c29, [x6, #8]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc24024dd // ldr c29, [x6, #9]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc24028dd // ldr c29, [x6, #10]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc2402cdd // ldr c29, [x6, #11]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc24030dd // ldr c29, [x6, #12]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x81
	mov x29, v22.d[0]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v22.d[1]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v27.d[0]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v27.d[1]
	cmp x6, x29
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
	ldr x0, =0x000013a0
	ldr x1, =check_data1
	ldr x2, =0x000013b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040377e
	ldr x1, =check_data5
	ldr x2, =0x0040377f
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
