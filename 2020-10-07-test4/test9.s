.section data0, #alloc, #write
	.zero 528
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xec, 0xff, 0x47, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xe0, 0x00, 0xe0, 0x00, 0x80, 0x80, 0x20
	.zero 3536
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xec, 0xff, 0x47, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xe0, 0x00, 0xe0, 0x00, 0x80, 0x80, 0x20
.data
check_data1:
	.zero 16
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x87, 0x52, 0xc0, 0xc2, 0x97, 0x10, 0xc4, 0xc2
.data
check_data3:
	.byte 0x19, 0x50, 0x98, 0xf8, 0x9f, 0x86, 0x80, 0x42, 0xdc, 0x7f, 0xdf, 0x9b, 0xef, 0x48, 0xdf, 0xc2
	.byte 0x5c, 0x62, 0xc0, 0xc2, 0xf2, 0x2b, 0xd4, 0x1a, 0x3f, 0xb0, 0xc0, 0xc2, 0xea, 0x83, 0xd7, 0xc2
	.byte 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C1 */
	.octa 0x1000000100000000000000000010
	/* C4 */
	.octa 0x90000000400002380000000000001210
	/* C18 */
	.octa 0x10400034010000000000000000
	/* C20 */
	.octa 0x1780
final_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C1 */
	.octa 0x1000000100000000000000000010
	/* C4 */
	.octa 0x90000000400002380000000000001210
	/* C7 */
	.octa 0x1780
	/* C15 */
	.octa 0x1780
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1780
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x10400034010080000000003401
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000e0700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c0000000817000400ffffffffff0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword 0x0000000000001220
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c05287 // GCVALUE-R.C-C Rd:7 Cn:20 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c41097 // LDPBR-C.C-C Ct:23 Cn:4 100:100 opc:00 11000010110001000:11000010110001000
	.zero 524260
	.inst 0xf8985019 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:0 00:00 imm9:110000101 0:0 opc:10 111000:111000 size:11
	.inst 0x4280869f // STP-C.RIB-C Ct:31 Rn:20 Ct2:00001 imm7:0000001 L:0 010000101:010000101
	.inst 0x9bdf7fdc // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:28 Rn:30 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc2df48ef // UNSEAL-C.CC-C Cd:15 Cn:7 0010:0010 opc:01 Cm:31 11000010110:11000010110
	.inst 0xc2c0625c // SCOFF-C.CR-C Cd:28 Cn:18 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0x1ad42bf2 // asrv:aarch64/instrs/integer/shift/variable Rd:18 Rn:31 op2:10 0010:0010 Rm:20 0011010110:0011010110 sf:0
	.inst 0xc2c0b03f // GCSEAL-R.C-C Rd:31 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2d783ea // SCTAG-C.CR-C Cd:10 Cn:31 000:000 0:0 10:10 Rm:23 11000010110:11000010110
	.inst 0xc2c21300
	.zero 524272
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e72 // ldr c18, [x19, #3]
	.inst 0xc2401274 // ldr c20, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603313 // ldr c19, [c24, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601313 // ldr c19, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400278 // ldr c24, [x19, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400678 // ldr c24, [x19, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a78 // ldr c24, [x19, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400e78 // ldr c24, [x19, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401278 // ldr c24, [x19, #4]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401a78 // ldr c24, [x19, #6]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402278 // ldr c24, [x19, #8]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001210
	ldr x1, =check_data0
	ldr x2, =0x00001230
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001790
	ldr x1, =check_data1
	ldr x2, =0x000017b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0047ffec
	ldr x1, =check_data3
	ldr x2, =0x00480010
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
