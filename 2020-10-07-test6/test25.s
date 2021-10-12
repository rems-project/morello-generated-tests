.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf6, 0xa2, 0xc5, 0xc2, 0xf7, 0xf4, 0x15, 0x78, 0x3e, 0xe4, 0x00, 0x9b, 0x46, 0x00, 0xc0, 0x5a
	.byte 0x2f, 0xb8, 0x0a, 0xe2, 0x21, 0xfc, 0xde, 0x82, 0xe2, 0x1b, 0xca, 0x69, 0x21, 0xfc, 0x7f, 0x42
	.byte 0xc1, 0x7e, 0x1f, 0x42, 0xe2, 0xef, 0x5f, 0xe2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C7 */
	.octa 0x40000000000500040000000000001000
	/* C23 */
	.octa 0xc00
	/* C25 */
	.octa 0x7ffffffffffffe00
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc00
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000500040000000000000f5f
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0xc00
	/* C23 */
	.octa 0xc00
	/* C25 */
	.octa 0x7ffffffffffffe00
	/* C30 */
	.octa 0x7ffffffffffffe00
initial_SP_EL3_value:
	.octa 0x80000000000010000000000000000fb0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480900000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001007040700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5a2f6 // CLRPERM-C.CR-C Cd:22 Cn:23 000:000 1:1 10:10 Rm:5 11000010110:11000010110
	.inst 0x7815f4f7 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:23 Rn:7 01:01 imm9:101011111 0:0 opc:00 111000:111000 size:01
	.inst 0x9b00e43e // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:1 Ra:25 o0:1 Rm:0 0011011000:0011011000 sf:1
	.inst 0x5ac00046 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:6 Rn:2 101101011000000000000:101101011000000000000 sf:0
	.inst 0xe20ab82f // ALDURSB-R.RI-64 Rt:15 Rn:1 op2:10 imm9:010101011 V:0 op1:00 11100010:11100010
	.inst 0x82defc21 // ALDRH-R.RRB-32 Rt:1 Rn:1 opc:11 S:1 option:111 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x69ca1be2 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:31 Rt2:00110 imm7:0010100 L:1 1010011:1010011 opc:01
	.inst 0x427ffc21 // ALDAR-R.R-32 Rt:1 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x421f7ec1 // ASTLR-C.R-C Ct:1 Rn:22 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe25fefe2 // ALDURSH-R.RI-32 Rt:2 Rn:31 op2:11 imm9:111111110 V:0 op1:01 11100010:11100010
	.inst 0xc2c21180
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
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba7 // ldr c7, [x29, #2]
	.inst 0xc2400fb7 // ldr c23, [x29, #3]
	.inst 0xc24013b9 // ldr c25, [x29, #4]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850038
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319d // ldr c29, [c12, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260119d // ldr c29, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ac // ldr c12, [x29, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24007ac // ldr c12, [x29, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400bac // ldr c12, [x29, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400fac // ldr c12, [x29, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc24017ac // ldr c12, [x29, #5]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2401bac // ldr c12, [x29, #6]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2401fac // ldr c12, [x29, #7]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc24023ac // ldr c12, [x29, #8]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc24027ac // ldr c12, [x29, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013fe
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014ab
	ldr x1, =check_data2
	ldr x2, =0x000014ac
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
