.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x8c, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x29, 0x00, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x8c, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xc0, 0xe8, 0x43, 0x3a, 0x20, 0xfd, 0x5c, 0xa8, 0xf2, 0x83, 0x5d, 0xfc, 0x7a, 0x81, 0x1a, 0xe2
	.byte 0x5e, 0x10, 0xc0, 0x5a, 0xa0, 0x6b, 0x71, 0x0a, 0xfe, 0x4c, 0xdf, 0x82, 0x3a, 0xeb, 0x3f, 0x62
	.byte 0xfa, 0x9d, 0x8d, 0x28, 0xc6, 0x17, 0x96, 0x9a, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0xfffffffd
	/* C7 */
	.octa 0x80000000000100050000000000400800
	/* C9 */
	.octa 0xfffffffffffffe80
	/* C11 */
	.octa 0x40000000000100050000000000002004
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x10
	/* C26 */
	.octa 0x8c00000d00000000290000000000
final_cap_values:
	/* C7 */
	.octa 0x80000000000100050000000000400800
	/* C9 */
	.octa 0xfffffffffffffe80
	/* C11 */
	.octa 0x40000000000100050000000000002004
	/* C15 */
	.octa 0x6c
	/* C25 */
	.octa 0x10
	/* C26 */
	.octa 0x8c00000d00000000290000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040001f8000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a43e8c0 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0000 0:0 Rn:6 10:10 cond:1110 imm5:00011 111010010:111010010 op:0 sf:0
	.inst 0xa85cfd20 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:9 Rt2:11111 imm7:0111001 L:1 1010000:1010000 opc:10
	.inst 0xfc5d83f2 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:18 Rn:31 00:00 imm9:111011000 0:0 opc:01 111100:111100 size:11
	.inst 0xe21a817a // ASTURB-R.RI-32 Rt:26 Rn:11 op2:00 imm9:110101000 V:0 op1:00 11100010:11100010
	.inst 0x5ac0105e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:2 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x0a716ba0 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:29 imm6:011010 Rm:17 N:1 shift:01 01010:01010 opc:00 sf:0
	.inst 0x82df4cfe // ALDRH-R.RRB-32 Rt:30 Rn:7 opc:11 S:0 option:010 Rm:31 0:0 L:1 100000101:100000101
	.inst 0x623feb3a // STNP-C.RIB-C Ct:26 Rn:25 Ct2:11010 imm7:1111111 L:0 011000100:011000100
	.inst 0x288d9dfa // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:26 Rn:15 Rt2:00111 imm7:0011011 L:0 1010001:1010001 opc:00
	.inst 0x9a9617c6 // csinc:aarch64/instrs/integer/conditional/select Rd:6 Rn:30 o2:1 0:0 cond:0001 Rm:22 011010100:011010100 op:0 sf:1
	.inst 0xc2c21200
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
	.inst 0xc2400286 // ldr c6, [x20, #0]
	.inst 0xc2400687 // ldr c7, [x20, #1]
	.inst 0xc2400a89 // ldr c9, [x20, #2]
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc240128f // ldr c15, [x20, #4]
	.inst 0xc2401699 // ldr c25, [x20, #5]
	.inst 0xc2401a9a // ldr c26, [x20, #6]
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
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603214 // ldr c20, [c16, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601214 // ldr c20, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x16, #0xf
	and x20, x20, x16
	cmp x20, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400290 // ldr c16, [x20, #0]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2400690 // ldr c16, [x20, #1]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2401a90 // ldr c16, [x20, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x16, v18.d[0]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0x0
	mov x16, v18.d[1]
	cmp x20, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f80
	ldr x1, =check_data0
	ldr x2, =0x00001fa0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fac
	ldr x1, =check_data1
	ldr x2, =0x00001fad
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc8
	ldr x1, =check_data2
	ldr x2, =0x00001fd8
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
	ldr x0, =0x00400800
	ldr x1, =check_data4
	ldr x2, =0x00400802
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
