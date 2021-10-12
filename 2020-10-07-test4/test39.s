.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x33, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xf2, 0xe3, 0xfd, 0xc2, 0x00, 0x28, 0xc0, 0xc2, 0x11, 0xc4, 0x54, 0x78, 0x5f, 0x98, 0x6d, 0xc2
	.byte 0x80, 0xdd, 0x18, 0xe2, 0x7f, 0x58, 0x2a, 0x78, 0x22, 0xf0, 0x73, 0xe2, 0x41, 0x87, 0x12, 0xa2
	.byte 0x80, 0x7e, 0x7f, 0x42, 0x63, 0x51, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000401e00
	/* C1 */
	.octa 0x1233
	/* C2 */
	.octa 0x900000001e07040600000000004001c0
	/* C3 */
	.octa 0x40000000600000000000000000000824
	/* C10 */
	.octa 0xaca
	/* C11 */
	.octa 0x2000000060066041000000000040a000
	/* C12 */
	.octa 0x10a0
	/* C20 */
	.octa 0x17ee
	/* C26 */
	.octa 0x4c000000580100040000000000001080
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1233
	/* C2 */
	.octa 0x900000001e07040600000000004001c0
	/* C3 */
	.octa 0x40000000600000000000000000000824
	/* C10 */
	.octa 0xaca
	/* C11 */
	.octa 0x2000000060066041000000000040a000
	/* C12 */
	.octa 0x10a0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x17ee
	/* C26 */
	.octa 0x4c000000580100040000000000000300
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000403100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000584400120000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fde3f2 // BICFLGS-C.CI-C Cd:18 Cn:31 0:0 00:00 imm8:11101111 11000010111:11000010111
	.inst 0xc2c02800 // BICFLGS-C.CR-C Cd:0 Cn:0 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0x7854c411 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:0 01:01 imm9:101001100 0:0 opc:01 111000:111000 size:01
	.inst 0xc26d985f // LDR-C.RIB-C Ct:31 Rn:2 imm12:101101100110 L:1 110000100:110000100
	.inst 0xe218dd80 // ALDURSB-R.RI-32 Rt:0 Rn:12 op2:11 imm9:110001101 V:0 op1:00 11100010:11100010
	.inst 0x782a587f // strh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:3 10:10 S:1 option:010 Rm:10 1:1 opc:00 111000:111000 size:01
	.inst 0xe273f022 // ASTUR-V.RI-H Rt:2 Rn:1 op2:00 imm9:100111111 V:1 op1:01 11100010:11100010
	.inst 0xa2128741 // STR-C.RIAW-C Ct:1 Rn:26 01:01 imm9:100101000 0:0 opc:00 10100010:10100010
	.inst 0x427f7e80 // ALDARB-R.R-B Rt:0 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c25163 // RETR-C-C 00011:00011 Cn:11 100:100 opc:10 11000010110000100:11000010110000100
	.zero 40920
	.inst 0xc2c21200
	.zero 1007612
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc24014ab // ldr c11, [x5, #5]
	.inst 0xc24018ac // ldr c12, [x5, #6]
	.inst 0xc2401cb4 // ldr c20, [x5, #7]
	.inst 0xc24020ba // ldr c26, [x5, #8]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603205 // ldr c5, [c16, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601205 // ldr c5, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b0 // ldr c16, [x5, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004b0 // ldr c16, [x5, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24018b0 // ldr c16, [x5, #6]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401cb0 // ldr c16, [x5, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc24020b0 // ldr c16, [x5, #8]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24024b0 // ldr c16, [x5, #9]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24028b0 // ldr c16, [x5, #10]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x16, v2.d[0]
	cmp x5, x16
	b.ne comparison_fail
	ldr x5, =0x0
	mov x16, v2.d[1]
	cmp x5, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103f
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001184
	ldr x1, =check_data2
	ldr x2, =0x00001186
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001db8
	ldr x1, =check_data4
	ldr x2, =0x00001dba
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401e00
	ldr x1, =check_data6
	ldr x2, =0x00401e02
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040a000
	ldr x1, =check_data7
	ldr x2, =0x0040a004
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0040b820
	ldr x1, =check_data8
	ldr x2, =0x0040b830
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
