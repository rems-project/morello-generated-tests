.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xe1, 0xa7, 0xdf, 0xc2, 0x96, 0xc4, 0xb9, 0x82, 0x50, 0x42, 0x8a, 0xb8, 0xbf, 0x30, 0x20, 0xab
	.byte 0x3f, 0x99, 0xea, 0xc2, 0x42, 0xcf, 0x15, 0x71, 0xc0, 0x85, 0x1a, 0xd1, 0x41, 0x89, 0xde, 0xc2
	.byte 0xbd, 0x00, 0x0f, 0x3a, 0x5e, 0x25, 0xda, 0x1a, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x801000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x77bd8000000120050000000000008000
	/* C18 */
	.octa 0x80000000580008010000000000001000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0xff800100
	/* C30 */
	.octa 0x7800f0000000000006001
final_cap_values:
	/* C1 */
	.octa 0x77bd8000000120050000000000008000
	/* C4 */
	.octa 0x801000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x77bd8000000120050000000000008000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000580008010000000000001000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0xff800100
initial_SP_EL3_value:
	.octa 0xffffffffffffffffffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005401050900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dfa7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0x82b9c496 // ASTR-R.RRB-64 Rt:22 Rn:4 opc:01 S:0 option:110 Rm:25 1:1 L:0 100000101:100000101
	.inst 0xb88a4250 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:18 00:00 imm9:010100100 0:0 opc:10 111000:111000 size:10
	.inst 0xab2030bf // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:5 imm3:100 option:001 Rm:0 01011001:01011001 S:1 op:0 sf:1
	.inst 0xc2ea993f // SUBS-R.CC-C Rd:31 Cn:9 100110:100110 Cm:10 11000010111:11000010111
	.inst 0x7115cf42 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:26 imm12:010101110011 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xd11a85c0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:14 imm12:011010100001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2de8941 // CHKSSU-C.CC-C Cd:1 Cn:10 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0x3a0f00bd // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:5 000000:000000 Rm:15 11010000:11010000 S:1 op:0 sf:0
	.inst 0x1ada255e // lsrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:10 op2:01 0010:0010 Rm:26 0011010110:0011010110 sf:0
	.inst 0xc2c210c0
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
	.inst 0xc24002a4 // ldr c4, [x21, #0]
	.inst 0xc24006a9 // ldr c9, [x21, #1]
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2400eb2 // ldr c18, [x21, #3]
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a4
	ldr x1, =check_data0
	ldr x2, =0x000010a8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
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
