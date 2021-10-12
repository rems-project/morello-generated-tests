.section data0, #alloc, #write
	.byte 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 624
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3440
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x81, 0x09, 0x58, 0x38, 0xc1, 0x0f, 0xc2, 0x9a, 0x5f, 0x88, 0x42, 0xa2, 0x42, 0xa0, 0xbe, 0xaa
	.byte 0xc1, 0xff, 0xdf, 0x08, 0x01, 0x50, 0x5f, 0x3a, 0x56, 0x84, 0xa1, 0x9b, 0x02, 0x30, 0xc1, 0xc2
	.byte 0x02, 0x6a, 0xc0, 0xc2, 0xfe, 0xc8, 0xde, 0x82, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000100780050000000000420000
	/* C12 */
	.octa 0x47f184
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xc2
	/* C7 */
	.octa 0x80000000100780050000000000420000
	/* C12 */
	.octa 0x47f184
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0xffffff3e00000184
	/* C30 */
	.octa 0xffffc2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000000006000e00ffffffffc00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001280
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38580981 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:12 10:10 imm9:110000000 0:0 opc:01 111000:111000 size:00
	.inst 0x9ac20fc1 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:30 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0xa242885f // LDTR-C.RIB-C Ct:31 Rn:2 10:10 imm9:000101000 0:0 opc:01 10100010:10100010
	.inst 0xaabea042 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:101000 Rm:30 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0x08dfffc1 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x3a5f5001 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:0 00:00 cond:0101 Rm:31 111010010:111010010 op:0 sf:0
	.inst 0x9ba18456 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:22 Rn:2 Ra:1 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xc2c13002 // GCFLGS-R.C-C Rd:2 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c06a02 // ORRFLGS-C.CR-C Cd:2 Cn:16 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x82dec8fe // ALDRSH-R.RRB-32 Rt:30 Rn:7 opc:10 S:0 option:110 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xc2c211c0
	.zero 131028
	.inst 0x0000c2c2
	.zero 393472
	.inst 0x000000c2
	.zero 524024
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
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc24010be // ldr c30, [x5, #4]
	/* Set up flags and system registers */
	mov x5, #0x80000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c5 // ldr c5, [c14, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826011c5 // ldr c5, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	mov x14, #0xf
	and x5, x5, x14
	cmp x5, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ae // ldr c14, [x5, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24004ae // ldr c14, [x5, #1]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24008ae // ldr c14, [x5, #2]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2400cae // ldr c14, [x5, #3]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24010ae // ldr c14, [x5, #4]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc24014ae // ldr c14, [x5, #5]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001280
	ldr x1, =check_data1
	ldr x2, =0x00001290
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
	ldr x0, =0x00420000
	ldr x1, =check_data3
	ldr x2, =0x00420002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480104
	ldr x1, =check_data4
	ldr x2, =0x00480105
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
