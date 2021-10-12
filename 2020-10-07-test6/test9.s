.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xff, 0xff
.data
check_data4:
	.byte 0x57, 0x2f, 0x22, 0x90, 0xe2, 0x7b, 0x24, 0x52, 0xff, 0x1d, 0x5d, 0xad, 0xe8, 0x03, 0x01, 0x1a
	.byte 0x62, 0x9e, 0x12, 0x78, 0xe6, 0x33, 0x83, 0x42, 0x37, 0x49, 0xfa, 0xc2, 0xdc, 0x13, 0x5f, 0xe2
	.byte 0xa0, 0xff, 0x3f, 0x42, 0x58, 0x86, 0x37, 0x9b, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x2027
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000420008040000000000001000
	/* C30 */
	.octa 0x400000000007008f000000000000100f
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xf7ffffff
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x1f50
	/* C23 */
	.octa 0x3fff80000000d200000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000420008040000000000001000
	/* C30 */
	.octa 0x400000000007008f000000000000100f
initial_SP_EL3_value:
	.octa 0x1040
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007002600ffffffffffc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x90222f57 // ADRP-C.I-C Rd:23 immhi:010001000101111010 P:0 10000:10000 immlo:00 op:1
	.inst 0x52247be2 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:31 imms:011110 immr:100100 N:0 100100:100100 opc:10 sf:0
	.inst 0xad5d1dff // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:15 Rt2:00111 imm7:0111010 L:1 1011010:1011010 opc:10
	.inst 0x1a0103e8 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:8 Rn:31 000000:000000 Rm:1 11010000:11010000 S:0 op:0 sf:0
	.inst 0x78129e62 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:19 11:11 imm9:100101001 0:0 opc:00 111000:111000 size:01
	.inst 0x428333e6 // STP-C.RIB-C Ct:6 Rn:31 Ct2:01100 imm7:0000110 L:0 010000101:010000101
	.inst 0xc2fa4937 // ORRFLGS-C.CI-C Cd:23 Cn:9 0:0 01:01 imm8:11010010 11000010111:11000010111
	.inst 0xe25f13dc // ASTURH-R.RI-32 Rt:28 Rn:30 op2:00 imm9:111110001 V:0 op1:01 11100010:11100010
	.inst 0x423fffa0 // ASTLR-R.R-32 Rt:0 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x9b378658 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:24 Rn:18 Ra:1 o0:1 Rm:23 01:01 U:0 10011011:10011011
	.inst 0xc2c210a0
	.zero 1048532
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400686 // ldr c6, [x20, #1]
	.inst 0xc2400a89 // ldr c9, [x20, #2]
	.inst 0xc2400e8c // ldr c12, [x20, #3]
	.inst 0xc240128f // ldr c15, [x20, #4]
	.inst 0xc2401693 // ldr c19, [x20, #5]
	.inst 0xc2401a9c // ldr c28, [x20, #6]
	.inst 0xc2401e9d // ldr c29, [x20, #7]
	.inst 0xc240229e // ldr c30, [x20, #8]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b4 // ldr c20, [c5, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402a85 // ldr c5, [x20, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x5, v7.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v7.d[1]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v31.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v31.d[1]
	cmp x20, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x00001100
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013e0
	ldr x1, =check_data2
	ldr x2, =0x00001400
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f90
	ldr x1, =check_data3
	ldr x2, =0x00001f92
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
