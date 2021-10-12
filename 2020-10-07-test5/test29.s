.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xdf, 0x23, 0xde, 0xc2, 0xc3, 0x33, 0xc2, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xde, 0x4b, 0xd6, 0x82, 0x20, 0xc0, 0x31, 0xcb, 0xc6, 0x73, 0x3a, 0x79, 0x4c, 0x2e, 0x46, 0x38
	.byte 0xde, 0xd3, 0xc6, 0xc2, 0x1f, 0x90, 0xc0, 0xc2, 0x5e, 0x3c, 0x0f, 0x62, 0x20, 0xa4, 0xca, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20400002000300070000000000400008
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x40fb1e
	/* C22 */
	.octa 0x7
	/* C30 */
	.octa 0x2000000010079fff0000000000480000
final_cap_values:
	/* C1 */
	.octa 0x20400002000300070000000000400008
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x40fb80
	/* C22 */
	.octa 0x7
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000000010079fff0000000000480020
initial_RDDC_EL0_value:
	.octa 0xc00000002001c0050000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000440200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_RDDC_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de23df // SCBNDSE-C.CR-C Cd:31 Cn:30 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c233c3 // BLRR-C-C 00011:00011 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21340
	.zero 524276
	.inst 0x82d64bde // ALDRSH-R.RRB-32 Rt:30 Rn:30 opc:10 S:0 option:010 Rm:22 0:0 L:1 100000101:100000101
	.inst 0xcb31c020 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:1 imm3:000 option:110 Rm:17 01011001:01011001 S:0 op:1 sf:1
	.inst 0x793a73c6 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:30 imm12:111010011100 opc:00 111001:111001 size:01
	.inst 0x38462e4c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:18 11:11 imm9:001100010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c6d3de // CLRPERM-C.CI-C Cd:30 Cn:30 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0xc2c0901f // GCTAG-R.C-C Rd:31 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x620f3c5e // STNP-C.RIB-C Ct:30 Rn:2 Ct2:01111 imm7:0011110 L:0 011000100:011000100
	.inst 0xc2caa420 // BLRS-C.C-C 00000:00000 Cn:1 001:001 opc:01 1:1 Cm:10 11000010110:11000010110
	.zero 524256
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
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc24012af // ldr c15, [x21, #4]
	.inst 0xc24016b2 // ldr c18, [x21, #5]
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	ldr x21, =initial_RDDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28b4335 // msr RDDC_EL0, c21
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601355 // ldr c21, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ba // ldr c26, [x21, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24006ba // ldr c26, [x21, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400aba // ldr c26, [x21, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400eba // ldr c26, [x21, #3]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24026ba // ldr c26, [x21, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011e0
	ldr x1, =check_data0
	ldr x2, =0x00001200
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d38
	ldr x1, =check_data1
	ldr x2, =0x00001d3a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400010
	ldr x1, =check_data3
	ldr x2, =0x00400012
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040fb80
	ldr x1, =check_data4
	ldr x2, =0x0040fb81
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480020
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
