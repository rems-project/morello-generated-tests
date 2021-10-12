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
	.zero 16
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xd6, 0xef, 0x95, 0x78, 0xdf, 0x08, 0x33, 0xe2, 0xf3, 0x07, 0xdf, 0xc2, 0x1c, 0x7e, 0x57, 0x9b
	.byte 0xbe, 0x19, 0x39, 0x31, 0xe2, 0x6b, 0x85, 0x2d, 0x3e, 0x38, 0x55, 0x6b, 0x3e, 0x68, 0xe8, 0x62
	.byte 0xe1, 0x03, 0xc0, 0x5a, 0x5f, 0x30, 0xc0, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20d0
	/* C2 */
	.octa 0x1200d0000000000000000
	/* C6 */
	.octa 0x400000005404063c0000000000001140
	/* C30 */
	.octa 0x10e4
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1200d0000000000000000
	/* C6 */
	.octa 0x400000005404063c0000000000001140
	/* C19 */
	.octa 0xfe0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0xfe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001dd0
	.dword 0x0000000000001de0
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7895efd6 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:101011110 0:0 opc:10 111000:111000 size:01
	.inst 0xe23308df // ASTUR-V.RI-Q Rt:31 Rn:6 op2:10 imm9:100110000 V:1 op1:00 11100010:11100010
	.inst 0xc2df07f3 // BUILD-C.C-C Cd:19 Cn:31 001:001 opc:00 0:0 Cm:31 11000010110:11000010110
	.inst 0x9b577e1c // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:28 Rn:16 Ra:11111 0:0 Rm:23 10:10 U:0 10011011:10011011
	.inst 0x313919be // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:13 imm12:111001000110 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x2d856be2 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:2 Rn:31 Rt2:11010 imm7:0001010 L:0 1011011:1011011 opc:00
	.inst 0x6b55383e // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:1 imm6:001110 Rm:21 0:0 shift:01 01011:01011 S:1 op:1 sf:0
	.inst 0x62e8683e // LDP-C.RIBW-C Ct:30 Rn:1 Ct2:11010 imm7:1010000 L:1 011000101:011000101
	.inst 0x5ac003e1 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:1 Rn:31 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c0305f // GCLEN-R.C-C Rd:31 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400cbe // ldr c30, [x5, #3]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q2, =0x0
	ldr q26, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_csp_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x3085003a
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603185 // ldr c5, [c12, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601185 // ldr c5, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ac // ldr c12, [x5, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24004ac // ldr c12, [x5, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc24014ac // ldr c12, [x5, #5]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc24018ac // ldr c12, [x5, #6]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x12, v2.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v2.d[1]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v26.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v26.d[1]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v31.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v31.d[1]
	cmp x5, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001042
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001080
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dd0
	ldr x1, =check_data3
	ldr x2, =0x00001df0
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
