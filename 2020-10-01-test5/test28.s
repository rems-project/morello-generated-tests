.section data0, #alloc, #write
	.zero 2416
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1648
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x8a, 0xd9, 0xe2, 0x69, 0x30, 0x26, 0xdf, 0x1a, 0x53, 0x33, 0x53, 0xd1, 0x20, 0x2c, 0x3e, 0xe2
	.byte 0xc2, 0xd9, 0xfa, 0x78, 0x8a, 0x44, 0x03, 0xd0, 0xe2, 0x83, 0xd3, 0xc2, 0x3e, 0xd2, 0xc5, 0xc2
	.byte 0xa6, 0x01, 0x1e, 0x9a, 0x1e, 0x43, 0x17, 0x0b, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4ffffe
	/* C12 */
	.octa 0x80000000000300060000000000001a68
	/* C14 */
	.octa 0x80000000000100050000000000000002
	/* C17 */
	.octa 0xffe0000000e001
	/* C26 */
	.octa 0x27fffd
final_cap_values:
	/* C1 */
	.octa 0x4ffffe
	/* C10 */
	.octa 0x80000000000300070000c40007092000
	/* C12 */
	.octa 0x8000000000030006000000000000197c
	/* C14 */
	.octa 0x80000000000100050000000000000002
	/* C16 */
	.octa 0xe001
	/* C17 */
	.octa 0xffe0000000e001
	/* C19 */
	.octa 0xffffffffffdb3ffd
	/* C22 */
	.octa 0xffffffffc2c2c2c2
	/* C26 */
	.octa 0x27fffd
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x208080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000300070000c40000800020
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x69e2d98a // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:10 Rn:12 Rt2:10110 imm7:1000101 L:1 1010011:1010011 opc:01
	.inst 0x1adf2630 // lsrv:aarch64/instrs/integer/shift/variable Rd:16 Rn:17 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xd1533353 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:26 imm12:010011001100 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xe23e2c20 // ALDUR-V.RI-Q Rt:0 Rn:1 op2:11 imm9:111100010 V:1 op1:00 11100010:11100010
	.inst 0x78fad9c2 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:14 10:10 S:1 option:110 Rm:26 1:1 opc:11 111000:111000 size:01
	.inst 0xd003448a // ADRP-C.I-C Rd:10 immhi:000001101000100100 P:0 10000:10000 immlo:10 op:1
	.inst 0xc2d383e2 // SCTAG-C.CR-C Cd:2 Cn:31 000:000 0:0 10:10 Rm:19 11000010110:11000010110
	.inst 0xc2c5d23e // CVTDZ-C.R-C Cd:30 Rn:17 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x9a1e01a6 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:6 Rn:13 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:1
	.inst 0x0b17431e // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:24 imm6:010000 Rm:23 0:0 shift:00 01011:01011 S:0 op:0 sf:0
	.inst 0xc2c213a0
	.zero 1048500
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 12
	.inst 0x0000c2c2
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
	.inst 0xc24005ec // ldr c12, [x15, #1]
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc24011fa // ldr c26, [x15, #4]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033af // ldr c15, [c29, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x826013af // ldr c15, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
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
	.inst 0xc24001fd // ldr c29, [x15, #0]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24005fd // ldr c29, [x15, #1]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc24009fd // ldr c29, [x15, #2]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc2400dfd // ldr c29, [x15, #3]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc24011fd // ldr c29, [x15, #4]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24015fd // ldr c29, [x15, #5]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc24019fd // ldr c29, [x15, #6]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc24021fd // ldr c29, [x15, #8]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0xc2c2c2c2c2c2c2c2
	mov x29, v0.d[0]
	cmp x15, x29
	b.ne comparison_fail
	ldr x15, =0xc2c2c2c2c2c2c2c2
	mov x29, v0.d[1]
	cmp x15, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000197c
	ldr x1, =check_data0
	ldr x2, =0x00001984
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004fffe0
	ldr x1, =check_data2
	ldr x2, =0x004ffff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffe
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
