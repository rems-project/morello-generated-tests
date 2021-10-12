.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x40, 0xa4, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x22, 0xf3, 0x17, 0x1b, 0xcc, 0xd0, 0xfe, 0xc2, 0xce, 0x13, 0xc1, 0xc2, 0x3b, 0x50, 0xbc, 0xb9
	.byte 0xe1, 0x54, 0xbe, 0x82, 0x5a, 0xb0, 0xc5, 0xc2, 0xc0, 0x47, 0x3f, 0x2b, 0xff, 0xaf, 0x82, 0xea
	.byte 0x82, 0xe3, 0x5e, 0x82, 0xc2, 0x1b, 0xd5, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xea440
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x40000000000100050000000000000000
	/* C23 */
	.octa 0x2755a666
	/* C25 */
	.octa 0x8faea005
	/* C28 */
	.octa 0x40000000000100050000000000000000
	/* C30 */
	.octa 0x10006c0030000000000000200
final_cap_values:
	/* C0 */
	.octa 0x200
	/* C1 */
	.octa 0xea440
	/* C2 */
	.octa 0x10006c0030000000000000000
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x40000000000100050000000000000000
	/* C12 */
	.octa 0x3fff80000000f600000000000000
	/* C14 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x2755a666
	/* C25 */
	.octa 0x8faea005
	/* C26 */
	.octa 0x200080004041000000000000a0400002
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000100050000000000000000
	/* C30 */
	.octa 0x10006c0030000000000000200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000380631470000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b17f322 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:25 Ra:28 o0:1 Rm:23 0011011000:0011011000 sf:0
	.inst 0xc2fed0cc // EORFLGS-C.CI-C Cd:12 Cn:6 0:0 10:10 imm8:11110110 11000010111:11000010111
	.inst 0xc2c113ce // GCLIM-R.C-C Rd:14 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xb9bc503b // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:1 imm12:111100010100 opc:10 111001:111001 size:10
	.inst 0x82be54e1 // ASTR-R.RRB-64 Rt:1 Rn:7 opc:01 S:1 option:010 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xc2c5b05a // CVTP-C.R-C Cd:26 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x2b3f47c0 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:30 imm3:001 option:010 Rm:31 01011001:01011001 S:1 op:0 sf:0
	.inst 0xea82afff // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:31 imm6:101011 Rm:2 N:0 shift:10 01010:01010 opc:11 sf:1
	.inst 0x825ee382 // ASTR-C.RI-C Ct:2 Rn:28 op:00 imm9:111101110 L:0 1000001001:1000001001
	.inst 0xc2d51bc2 // ALIGND-C.CI-C Cd:2 Cn:30 0110:0110 U:0 imm6:101010 11000010110:11000010110
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400eb7 // ldr c23, [x21, #3]
	.inst 0xc24012b9 // ldr c25, [x21, #4]
	.inst 0xc24016bc // ldr c28, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0xc
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d5 // ldr c21, [c22, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012d5 // ldr c21, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x22, #0xf
	and x21, x21, x22
	cmp x21, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b6 // ldr c22, [x21, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006b6 // ldr c22, [x21, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401eb6 // ldr c22, [x21, #7]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc24022b6 // ldr c22, [x21, #8]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc24026b6 // ldr c22, [x21, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402ab6 // ldr c22, [x21, #10]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402eb6 // ldr c22, [x21, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24032b6 // ldr c22, [x21, #12]
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
	ldr x0, =0x00001ee0
	ldr x1, =check_data1
	ldr x2, =0x00001ef0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402090
	ldr x1, =check_data3
	ldr x2, =0x00402094
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
