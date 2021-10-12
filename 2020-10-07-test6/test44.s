.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x93, 0x00, 0x82, 0x00, 0x00, 0x3f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x3f
	.byte 0x9a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0xc2, 0xc2, 0x3e, 0x00, 0x3e, 0x3e, 0x3e
	.byte 0x81, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x93, 0x00, 0x82, 0x00, 0x00, 0x3f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x3f
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x60, 0x30, 0xc5, 0xc2, 0x57, 0x44, 0xdf, 0xc2, 0xba, 0x26, 0xdb, 0x38, 0x2d, 0xd8, 0x4c, 0x38
	.byte 0x01, 0x28, 0x9d, 0x22, 0x20, 0x2b, 0xc8, 0xc2, 0xca, 0xc0, 0x9a, 0x62, 0x92, 0x5c, 0xcb, 0xc2
	.byte 0x3e, 0x88, 0xa6, 0x9b, 0x3e, 0x06, 0x8c, 0xe2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xf81
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0xc90
	/* C10 */
	.octa 0x3f3e000000000000403f000082009300
	/* C16 */
	.octa 0x3e3e3e003ec2c200c20000000000009a
	/* C17 */
	.octa 0x800000006001e04200000000003fff80
	/* C21 */
	.octa 0x1000
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xf81
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0xfe0
	/* C10 */
	.octa 0x3f3e000000000000403f000082009300
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x3e3e3e003ec2c200c20000000000009a
	/* C17 */
	.octa 0x800000006001e04200000000003fff80
	/* C21 */
	.octa 0xfb2
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000007000d00ffffffffff8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c53060 // CVTP-R.C-C Rd:0 Cn:3 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2df4457 // CSEAL-C.C-C Cd:23 Cn:2 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0x38db26ba // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:21 01:01 imm9:110110010 0:0 opc:11 111000:111000 size:00
	.inst 0x384cd82d // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:13 Rn:1 10:10 imm9:011001101 0:0 opc:01 111000:111000 size:00
	.inst 0x229d2801 // STP-CC.RIAW-C Ct:1 Rn:0 Ct2:01010 imm7:0111010 L:0 001000101:001000101
	.inst 0xc2c82b20 // BICFLGS-C.CR-C Cd:0 Cn:25 1010:1010 opc:00 Rm:8 11000010110:11000010110
	.inst 0x629ac0ca // STP-C.RIBW-C Ct:10 Rn:6 Ct2:10000 imm7:0110101 L:0 011000101:011000101
	.inst 0xc2cb5c92 // CSEL-C.CI-C Cd:18 Cn:4 11:11 cond:0101 Cm:11 11000010110:11000010110
	.inst 0x9ba6883e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:2 o0:1 Rm:6 01:01 U:1 10011011:10011011
	.inst 0xe28c063e // ALDUR-R.RI-32 Rt:30 Rn:17 op2:01 imm9:011000000 V:0 op1:10 11100010:11100010
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e6a // ldr c10, [x19, #3]
	.inst 0xc2401270 // ldr c16, [x19, #4]
	.inst 0xc2401671 // ldr c17, [x19, #5]
	.inst 0xc2401a75 // ldr c21, [x19, #6]
	.inst 0xc2401e79 // ldr c25, [x19, #7]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603293 // ldr c19, [c20, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601293 // ldr c19, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x20, #0xf
	and x19, x19, x20
	cmp x19, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400274 // ldr c20, [x19, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400674 // ldr c20, [x19, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401a74 // ldr c20, [x19, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402274 // ldr c20, [x19, #8]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2402674 // ldr c20, [x19, #9]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402a74 // ldr c20, [x19, #10]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402e74 // ldr c20, [x19, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000106e
	ldr x1, =check_data1
	ldr x2, =0x0000106f
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
	ldr x0, =0x00400040
	ldr x1, =check_data3
	ldr x2, =0x00400044
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
