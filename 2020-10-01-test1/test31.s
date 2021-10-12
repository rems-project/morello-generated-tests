.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x03, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x20, 0x7c, 0x3f, 0x42, 0x5e, 0xec, 0x48, 0x82, 0xde, 0xd3, 0xcf, 0xe2, 0xd0, 0x3b, 0xc5, 0xc2
	.byte 0x98, 0xff, 0x0f, 0xe2, 0xb2, 0xae, 0x66, 0x82, 0xdc, 0xdc, 0x46, 0xf8, 0xfd, 0xe7, 0x35, 0xb1
	.byte 0xf2, 0x67, 0xc0, 0xc2, 0x3d, 0xe8, 0x65, 0xf8, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000400200210000000000001040
	/* C2 */
	.octa 0xb90
	/* C5 */
	.octa 0x38
	/* C6 */
	.octa 0x80000000000700070000000000400003
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x800300070000000000000f03
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000400200210000000000001040
	/* C2 */
	.octa 0xb90
	/* C5 */
	.octa 0x38
	/* C6 */
	.octa 0x80000000000700070000000000400070
	/* C16 */
	.octa 0xcf0d0f030000000000000f03
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x800300070000000000000f03
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000510600000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000001980
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x423f7c20 // ASTLRB-R.R-B Rt:0 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x8248ec5e // ASTR-R.RI-64 Rt:30 Rn:2 op:11 imm9:010001110 L:0 1000001001:1000001001
	.inst 0xe2cfd3de // ASTUR-R.RI-64 Rt:30 Rn:30 op2:00 imm9:011111101 V:0 op1:11 11100010:11100010
	.inst 0xc2c53bd0 // SCBNDS-C.CI-C Cd:16 Cn:30 1110:1110 S:0 imm6:001010 11000010110:11000010110
	.inst 0xe20fff98 // ALDURSB-R.RI-32 Rt:24 Rn:28 op2:11 imm9:011111111 V:0 op1:00 11100010:11100010
	.inst 0x8266aeb2 // ALDR-R.RI-64 Rt:18 Rn:21 op:11 imm9:001101010 L:1 1000001001:1000001001
	.inst 0xf846dcdc // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:28 Rn:6 11:11 imm9:001101101 0:0 opc:01 111000:111000 size:11
	.inst 0xb135e7fd // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:29 Rn:31 imm12:110101111001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c067f2 // CPYVALUE-C.C-C Cd:18 Cn:31 001:001 opc:11 0:0 Cm:0 11000010110:11000010110
	.inst 0xf865e83d // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:29 Rn:1 10:10 S:0 option:111 Rm:5 1:1 opc:01 111000:111000 size:11
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2401286 // ldr c6, [x20, #4]
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2401a9c // ldr c28, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d4 // ldr c20, [c22, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x826012d4 // ldr c20, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400296 // ldr c22, [x20, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400696 // ldr c22, [x20, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a96 // ldr c22, [x20, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400e96 // ldr c22, [x20, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401296 // ldr c22, [x20, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401696 // ldr c22, [x20, #5]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401a96 // ldr c22, [x20, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401e96 // ldr c22, [x20, #7]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402296 // ldr c22, [x20, #8]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402696 // ldr c22, [x20, #9]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402a96 // ldr c22, [x20, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402e96 // ldr c22, [x20, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001041
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001078
	ldr x1, =check_data2
	ldr x2, =0x00001080
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010ff
	ldr x1, =check_data3
	ldr x2, =0x00001100
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001350
	ldr x1, =check_data4
	ldr x2, =0x00001358
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
	ldr x0, =0x00400070
	ldr x1, =check_data6
	ldr x2, =0x00400078
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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
