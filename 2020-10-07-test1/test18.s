.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x3f, 0x18, 0x82, 0xeb, 0x75, 0x91, 0x5f, 0xe2, 0x44, 0x9c, 0x8d, 0x28, 0x5e, 0xeb, 0xde, 0xc2
	.byte 0xbf, 0x08, 0x33, 0xd2, 0xff, 0x03, 0x07, 0x9b, 0x02, 0x58, 0xfb, 0xc2, 0x02, 0xa6, 0x4d, 0x02
	.byte 0x82, 0x53, 0xc2, 0xc2
.data
check_data2:
	.byte 0xbe, 0x4d, 0x92, 0x36, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800100170000000000000000
	/* C2 */
	.octa 0x40000000400101040000000000001000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0xf09
	/* C16 */
	.octa 0x320070000ffff00000000
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x40000
	/* C27 */
	.octa 0xf0000000000000
	/* C28 */
	.octa 0x20008000480700000000000000480000
final_cap_values:
	/* C0 */
	.octa 0x800100170000000000000000
	/* C2 */
	.octa 0x320070000ffff00369000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0xf09
	/* C16 */
	.octa 0x320070000ffff00000000
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x40000
	/* C27 */
	.octa 0xf0000000000000
	/* C28 */
	.octa 0x20008000480700000000000000480000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000200700130000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 144
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb82183f // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:1 imm6:000110 Rm:2 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xe25f9175 // ASTURH-R.RI-32 Rt:21 Rn:11 op2:00 imm9:111111001 V:0 op1:01 11100010:11100010
	.inst 0x288d9c44 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:4 Rn:2 Rt2:00111 imm7:0011011 L:0 1010001:1010001 opc:00
	.inst 0xc2deeb5e // CTHI-C.CR-C Cd:30 Cn:26 1010:1010 opc:11 Rm:30 11000010110:11000010110
	.inst 0xd23308bf // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:5 imms:000010 immr:110011 N:0 100100:100100 opc:10 sf:1
	.inst 0x9b0703ff // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:31 Ra:0 o0:0 Rm:7 0011011000:0011011000 sf:1
	.inst 0xc2fb5802 // CVTZ-C.CR-C Cd:2 Cn:0 0110:0110 1:1 0:0 Rm:27 11000010111:11000010111
	.inst 0x024da602 // ADD-C.CIS-C Cd:2 Cn:16 imm12:001101101001 sh:1 A:0 00000010:00000010
	.inst 0xc2c25382 // RETS-C-C 00010:00010 Cn:28 100:100 opc:10 11000010110000100:11000010110000100
	.zero 524252
	.inst 0x36924dbe // tbz:aarch64/instrs/branch/conditional/test Rt:30 imm14:01001001101101 b40:10010 op:0 011011:011011 b5:0
	.inst 0xc2c21100
	.zero 524280
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ec7 // ldr c7, [x22, #3]
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2401eda // ldr c26, [x22, #7]
	.inst 0xc24022db // ldr c27, [x22, #8]
	.inst 0xc24026dc // ldr c28, [x22, #9]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850032
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603116 // ldr c22, [c8, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601116 // ldr c22, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c8 // ldr c8, [x22, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24006c8 // ldr c8, [x22, #1]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400ac8 // ldr c8, [x22, #2]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc24012c8 // ldr c8, [x22, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc24016c8 // ldr c8, [x22, #5]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401ac8 // ldr c8, [x22, #6]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401ec8 // ldr c8, [x22, #7]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc24022c8 // ldr c8, [x22, #8]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc24026c8 // ldr c8, [x22, #9]
	.inst 0xc2c8a781 // chkeq c28, c8
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00480000
	ldr x1, =check_data2
	ldr x2, =0x00480008
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
