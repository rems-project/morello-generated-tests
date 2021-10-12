.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe0, 0x00
.data
check_data3:
	.byte 0xdf, 0xd2, 0xc0, 0xc2, 0x21, 0x48, 0x80, 0x8b, 0x01, 0x10, 0xc2, 0xc2, 0x02, 0x03, 0xdc, 0xc2
	.byte 0xe0, 0x33, 0xc0, 0xc2, 0xe4, 0x04, 0xe9, 0x69, 0xa1, 0xe9, 0x19, 0x78, 0x46, 0xf0, 0x72, 0xe2
	.byte 0x81, 0x5d, 0xa8, 0x4a, 0x1e, 0xd8, 0x45, 0xe2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x800000000007800e0000000000410804
	/* C13 */
	.octa 0x40000000000180060000000000002000
	/* C24 */
	.octa 0x400070006000000000000184f
final_cap_values:
	/* C0 */
	.octa 0x1005
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x800000000007800e000000000041074c
	/* C13 */
	.octa 0x40000000000180060000000000002000
	/* C24 */
	.octa 0x400070006000000000000184f
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x6005100000ffffffffffe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004030c0340000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000003710370000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0d2df // GCPERM-R.C-C Rd:31 Cn:22 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x8b804821 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:1 imm6:010010 Rm:0 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c21001 // CHKSLD-C-C 00001:00001 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2dc0302 // SCBNDS-C.CR-C Cd:2 Cn:24 000:000 opc:00 0:0 Rm:28 11000010110:11000010110
	.inst 0xc2c033e0 // GCLEN-R.C-C Rd:0 Cn:31 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x69e904e4 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:4 Rn:7 Rt2:00001 imm7:1010010 L:1 1010011:1010011 opc:01
	.inst 0x7819e9a1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:13 10:10 imm9:110011110 0:0 opc:00 111000:111000 size:01
	.inst 0xe272f046 // ASTUR-V.RI-H Rt:6 Rn:2 op2:00 imm9:100101111 V:1 op1:01 11100010:11100010
	.inst 0x4aa85d81 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:12 imm6:010111 Rm:8 N:1 shift:10 01010:01010 opc:10 sf:0
	.inst 0xe245d81e // ALDURSH-R.RI-64 Rt:30 Rn:0 op2:10 imm9:001011101 V:0 op1:01 11100010:11100010
	.inst 0xc2c213a0
	.zero 67364
	.inst 0x000000e0
	.zero 981164
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
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc24008ad // ldr c13, [x5, #2]
	.inst 0xc2400cb8 // ldr c24, [x5, #3]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q6, =0x0
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
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a5 // ldr c5, [c29, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826013a5 // ldr c5, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x29, #0xf
	and x5, x5, x29
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000bd // ldr c29, [x5, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004bd // ldr c29, [x5, #1]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24008bd // ldr c29, [x5, #2]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc2400cbd // ldr c29, [x5, #3]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc24010bd // ldr c29, [x5, #4]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x29, v6.d[0]
	cmp x5, x29
	b.ne comparison_fail
	ldr x5, =0x0
	mov x29, v6.d[1]
	cmp x5, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001062
	ldr x1, =check_data0
	ldr x2, =0x00001064
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000177e
	ldr x1, =check_data1
	ldr x2, =0x00001780
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f9e
	ldr x1, =check_data2
	ldr x2, =0x00001fa0
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
	ldr x0, =0x0041074c
	ldr x1, =check_data4
	ldr x2, =0x00410754
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
