.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x41, 0xa4, 0xcd, 0xc2, 0x7f, 0x58, 0xfb, 0xc2, 0xde, 0xdc, 0xc4, 0xe2, 0x52, 0xf5, 0xbb, 0x34
	.byte 0x80, 0x79, 0x02, 0x2b, 0x06, 0x60, 0xd4, 0xc2, 0x9f, 0xb3, 0xc5, 0xc2, 0xc6, 0xd0, 0xc5, 0xc2
	.byte 0x5d, 0x65, 0xda, 0x68, 0x73, 0x61, 0x5e, 0xe2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40001a00300c0000000000000
	/* C6 */
	.octa 0x80100000000500070000000000001803
	/* C10 */
	.octa 0x1580
	/* C11 */
	.octa 0x40000000000100050000000000002016
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffff
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xffffffffffe000
	/* C27 */
	.octa 0xc0000000000000
	/* C28 */
	.octa 0x400808
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40001a00300c0000000000000
	/* C6 */
	.octa 0x800000006002048400ffffffffffe484
	/* C10 */
	.octa 0x1650
	/* C11 */
	.octa 0x40000000000100050000000000002016
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffff
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xffffffffffe000
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0xc0000000000000
	/* C28 */
	.octa 0x400808
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600204840000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cda441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:13 11000010110:11000010110
	.inst 0xc2fb587f // CVTZ-C.CR-C Cd:31 Cn:3 0110:0110 1:1 0:0 Rm:27 11000010111:11000010111
	.inst 0xe2c4dcde // ALDUR-C.RI-C Ct:30 Rn:6 op2:11 imm9:001001101 V:0 op1:11 11100010:11100010
	.inst 0x34bbf552 // cbz:aarch64/instrs/branch/conditional/compare Rt:18 imm19:1011101111110101010 op:0 011010:011010 sf:0
	.inst 0x2b027980 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:12 imm6:011110 Rm:2 0:0 shift:00 01011:01011 S:1 op:0 sf:0
	.inst 0xc2d46006 // SCOFF-C.CR-C Cd:6 Cn:0 000:000 opc:11 0:0 Rm:20 11000010110:11000010110
	.inst 0xc2c5b39f // CVTP-C.R-C Cd:31 Rn:28 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c5d0c6 // CVTDZ-C.R-C Cd:6 Rn:6 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x68da655d // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:10 Rt2:11001 imm7:0110100 L:1 1010001:1010001 opc:01
	.inst 0xe25e6173 // ASTURH-R.RI-32 Rt:19 Rn:11 op2:00 imm9:111100110 V:0 op1:01 11100010:11100010
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c2 // ldr c2, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc24015cd // ldr c13, [x14, #5]
	.inst 0xc24019d2 // ldr c18, [x14, #6]
	.inst 0xc2401dd3 // ldr c19, [x14, #7]
	.inst 0xc24021d4 // ldr c20, [x14, #8]
	.inst 0xc24025db // ldr c27, [x14, #9]
	.inst 0xc24029dc // ldr c28, [x14, #10]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0xc
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308e // ldr c14, [c4, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x4, #0x3
	and x14, x14, x4
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc24021c4 // ldr c4, [x14, #8]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24025c4 // ldr c4, [x14, #9]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc24029c4 // ldr c4, [x14, #10]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402dc4 // ldr c4, [x14, #11]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24031c4 // ldr c4, [x14, #12]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc24035c4 // ldr c4, [x14, #13]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001850
	ldr x1, =check_data0
	ldr x2, =0x00001860
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a04
	ldr x1, =check_data1
	ldr x2, =0x00001a0c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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
