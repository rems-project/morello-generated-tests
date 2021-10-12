.section data0, #alloc, #write
	.zero 48
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3440
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0d, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 160
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x0d, 0x20, 0x00, 0x00
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xff, 0x73, 0x88, 0xab, 0x00, 0xfc, 0xdf, 0x88, 0x5f, 0x34, 0x82, 0xda, 0x19, 0xf8, 0x54, 0xe2
	.byte 0x63, 0x30, 0xc2, 0xc2
.data
check_data4:
	.byte 0x01, 0x58, 0xbf, 0xf8, 0x9b, 0xf7, 0x46, 0x8b, 0x4c, 0x6f, 0x8d, 0x4b, 0xfe, 0x4c, 0x58, 0xb8
	.byte 0x6b, 0xca, 0xe6, 0x42, 0x20, 0x12, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000700060000000000001dc8
	/* C3 */
	.octa 0x20008000000100050000000000400018
	/* C7 */
	.octa 0x408074
	/* C19 */
	.octa 0x1360
final_cap_values:
	/* C0 */
	.octa 0x200d
	/* C3 */
	.octa 0x20008000000100050000000000400018
	/* C7 */
	.octa 0x407ff8
	/* C11 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x1360
	/* C25 */
	.octa 0xffffffffffffc2c2
	/* C30 */
	.octa 0xc2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword 0x0000000000001040
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xab8873ff // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:31 imm6:011100 Rm:8 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0x88dffc00 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xda82345f // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:2 o2:1 0:0 cond:0011 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0xe254f819 // ALDURSH-R.RI-64 Rt:25 Rn:0 op2:10 imm9:101001111 V:0 op1:01 11100010:11100010
	.inst 0xc2c23063 // BLRR-C-C 00011:00011 Cn:3 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0xf8bf5801 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:1 option:010 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0x8b46f79b // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:27 Rn:28 imm6:111101 Rm:6 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0x4b8d6f4c // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:12 Rn:26 imm6:011011 Rm:13 0:0 shift:10 01011:01011 S:0 op:1 sf:0
	.inst 0xb8584cfe // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:7 11:11 imm9:110000100 0:0 opc:01 111000:111000 size:10
	.inst 0x42e6ca6b // LDP-C.RIB-C Ct:11 Rn:19 Ct2:10010 imm7:1001101 L:1 010000101:010000101
	.inst 0xc2c21220
	.zero 32712
	.inst 0xc2c2c2c2
	.zero 1015812
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a3 // ldr c3, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400eb3 // ldr c19, [x21, #3]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603235 // ldr c21, [c17, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601235 // ldr c21, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x17, #0x3
	and x21, x21, x17
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b1 // ldr c17, [x21, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006b1 // ldr c17, [x21, #1]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400ab1 // ldr c17, [x21, #2]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2400eb1 // ldr c17, [x21, #3]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24016b1 // ldr c17, [x21, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401ab1 // ldr c17, [x21, #6]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401eb1 // ldr c17, [x21, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001dc8
	ldr x1, =check_data1
	ldr x2, =0x00001dcc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f5c
	ldr x1, =check_data2
	ldr x2, =0x00001f5e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400018
	ldr x1, =check_data4
	ldr x2, =0x00400030
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00407ff8
	ldr x1, =check_data5
	ldr x2, =0x00407ffc
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
	.inst 0xc28b4135 // msr ddc_el3, c21
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
