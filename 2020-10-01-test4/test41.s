.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xa0, 0xfc, 0x50, 0xb8, 0xfe, 0xab, 0x40, 0xa2, 0xde, 0xab, 0xdd, 0xc2, 0x3e, 0x78, 0xa2, 0x8a
	.byte 0x01, 0x7c, 0x5f, 0x9b, 0x15, 0x53, 0xc1, 0xc2, 0x1e, 0x3c, 0x0e, 0x9b, 0x1f, 0xe8, 0xdd, 0xc2
	.byte 0x5f, 0x34, 0x03, 0xd5, 0x02, 0xac, 0xa6, 0x28, 0x20, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x410005
	/* C11 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xf34
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x40ff14
	/* C11 */
	.octa 0x0
initial_csp_value:
	.octa 0x1180
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000024700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000004000000fff00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001220
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb850fca0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:5 11:11 imm9:100001111 0:0 opc:01 111000:111000 size:10
	.inst 0xa240abfe // LDTR-C.RIB-C Ct:30 Rn:31 10:10 imm9:000001010 0:0 opc:01 10100010:10100010
	.inst 0xc2ddabde // EORFLGS-C.CR-C Cd:30 Cn:30 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0x8aa2783e // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:011110 Rm:2 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0x9b5f7c01 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:0 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xc2c15315 // CFHI-R.C-C Rd:21 Cn:24 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x9b0e3c1e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:0 Ra:15 o0:0 Rm:14 0011011000:0011011000 sf:1
	.inst 0xc2dde81f // CTHI-C.CR-C Cd:31 Cn:0 1010:1010 opc:11 Rm:29 11000010110:11000010110
	.inst 0xd503345f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0100 11010101000000110011:11010101000000110011
	.inst 0x28a6ac02 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:0 Rt2:01011 imm7:1001101 L:0 1010001:1010001 opc:00
	.inst 0xc2c21320
	.zero 65256
	.inst 0x00001000
	.zero 983272
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400282 // ldr c2, [x20, #0]
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_csp_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x3085003a
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603334 // ldr c20, [c25, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601334 // ldr c20, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400299 // ldr c25, [x20, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400699 // ldr c25, [x20, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a99 // ldr c25, [x20, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400e99 // ldr c25, [x20, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
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
	ldr x0, =0x00001220
	ldr x1, =check_data1
	ldr x2, =0x00001230
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
	ldr x0, =0x0040ff14
	ldr x1, =check_data3
	ldr x2, =0x0040ff18
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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
