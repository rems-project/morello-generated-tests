.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x11, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x5e, 0x66, 0x51, 0x78, 0x40, 0xe0, 0xcd, 0xc2, 0x53, 0x11, 0xe2, 0x68, 0x26, 0x02, 0x07, 0x1a
	.byte 0x54, 0x44, 0x25, 0x39, 0x20, 0x02, 0x3f, 0xd6
.data
check_data4:
	.byte 0x67, 0x23, 0xc2, 0x1a, 0x3e, 0x18, 0xe1, 0xc2, 0xe0, 0xd3, 0xc7, 0xe2, 0x89, 0xf9, 0xc3, 0xc2
	.byte 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x7000f0000000000007000
	/* C2 */
	.octa 0x1011
	/* C10 */
	.octa 0x1800
	/* C12 */
	.octa 0x200000300070000000000000000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x41bfa8
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1011
	/* C1 */
	.octa 0x7000f0000000000007000
	/* C2 */
	.octa 0x1011
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x200407000000000000000000000
	/* C10 */
	.octa 0x1710
	/* C12 */
	.octa 0x200000300070000000000000000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x41bfa8
	/* C18 */
	.octa 0xf16
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x7000f0000000000007008
initial_csp_value:
	.octa 0x40000000000002000000000000000f83
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000000fffffff0000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7851665e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:18 01:01 imm9:100010110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2cde040 // SCFLGS-C.CR-C Cd:0 Cn:2 111000:111000 Rm:13 11000010110:11000010110
	.inst 0x68e21153 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:19 Rn:10 Rt2:00100 imm7:1000100 L:1 1010001:1010001 opc:01
	.inst 0x1a070226 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:6 Rn:17 000000:000000 Rm:7 11010000:11010000 S:0 op:0 sf:0
	.inst 0x39254454 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:2 imm12:100101010001 opc:00 111001:111001 size:00
	.inst 0xd63f0220 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:17 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 114576
	.inst 0x1ac22367 // lslv:aarch64/instrs/integer/shift/variable Rd:7 Rn:27 op2:00 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0xc2e1183e // CVT-C.CR-C Cd:30 Cn:1 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0xe2c7d3e0 // ASTUR-R.RI-64 Rt:0 Rn:31 op2:00 imm9:001111101 V:0 op1:11 11100010:11100010
	.inst 0xc2c3f989 // SCBNDS-C.CI-S Cd:9 Cn:12 1110:1110 S:1 imm6:000111 11000010110:11000010110
	.inst 0xc2c21100
	.zero 933956
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_csp_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0xc
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310f // ldr c15, [c8, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x8260110f // ldr c15, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e8 // ldr c8, [x15, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005e8 // ldr c8, [x15, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009e8 // ldr c8, [x15, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc24015e8 // ldr c8, [x15, #5]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc24019e8 // ldr c8, [x15, #6]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401de8 // ldr c8, [x15, #7]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc24021e8 // ldr c8, [x15, #8]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc24025e8 // ldr c8, [x15, #9]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc24029e8 // ldr c8, [x15, #10]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc2402de8 // ldr c8, [x15, #11]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc24031e8 // ldr c8, [x15, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001962
	ldr x1, =check_data2
	ldr x2, =0x00001963
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0041bfa8
	ldr x1, =check_data4
	ldr x2, =0x0041bfbc
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
