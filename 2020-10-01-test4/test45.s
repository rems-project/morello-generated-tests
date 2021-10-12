.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x08, 0x88, 0x5c, 0xb8, 0x5c, 0x20, 0xc2, 0xc2, 0x1a, 0xa4, 0xb1, 0xc2, 0x5f, 0x14, 0xd9, 0x93
	.byte 0xd5, 0x0f, 0xc1, 0x1a, 0x71, 0x07, 0x52, 0xf8, 0xff, 0x56, 0xe2, 0x0a, 0xd1, 0x01, 0x04, 0xba
	.byte 0x04, 0xe4, 0xc1, 0x82, 0x1f, 0x24, 0xdf, 0x9a, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000420004
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800100070000000000000000
	/* C17 */
	.octa 0x0
	/* C27 */
	.octa 0x800000006001800000000000004f8000
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000420004
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800100070000000000000000
	/* C4 */
	.octa 0xffffffc2
	/* C8 */
	.octa 0xc2c2c2c2
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000100050000000000420004
	/* C27 */
	.octa 0x800000006001800000000000004f7f20
	/* C28 */
	.octa 0xc00000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010600070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb85c8808 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:8 Rn:0 10:10 imm9:111001000 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c2205c // SCBNDSE-C.CR-C Cd:28 Cn:2 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2b1a41a // ADD-C.CRI-C Cd:26 Cn:0 imm3:001 option:101 Rm:17 11000010101:11000010101
	.inst 0x93d9145f // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:31 Rn:2 imms:000101 Rm:25 0:0 N:1 00100111:00100111 sf:1
	.inst 0x1ac10fd5 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:21 Rn:30 o1:1 00001:00001 Rm:1 0011010110:0011010110 sf:0
	.inst 0xf8520771 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:27 01:01 imm9:100100000 0:0 opc:01 111000:111000 size:11
	.inst 0x0ae256ff // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:23 imm6:010101 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:0
	.inst 0xba0401d1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:14 000000:000000 Rm:4 11010000:11010000 S:1 op:0 sf:1
	.inst 0x82c1e404 // ALDRSB-R.RRB-32 Rt:4 Rn:0 opc:01 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x9adf241f // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:0 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c213a0
	.zero 130976
	.inst 0xc2c2c2c2
	.zero 52
	.inst 0x000000c2
	.zero 884728
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 32760
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
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400cb1 // ldr c17, [x5, #3]
	.inst 0xc24010bb // ldr c27, [x5, #4]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a5 // ldr c5, [c29, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x826013a5 // ldr c5, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
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
	.inst 0xc24000bd // ldr c29, [x5, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004bd // ldr c29, [x5, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24008bd // ldr c29, [x5, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400cbd // ldr c29, [x5, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24010bd // ldr c29, [x5, #4]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc24018bd // ldr c29, [x5, #6]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc24020bd // ldr c29, [x5, #8]
	.inst 0xc2dda781 // chkeq c28, c29
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
	ldr x0, =0x0041ffcc
	ldr x1, =check_data1
	ldr x2, =0x0041ffd0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00420004
	ldr x1, =check_data2
	ldr x2, =0x00420005
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004f8000
	ldr x1, =check_data3
	ldr x2, =0x004f8008
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
