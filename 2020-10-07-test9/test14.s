.section data0, #alloc, #write
	.zero 464
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 64
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 352
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00
	.zero 2608
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 544
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xbf, 0xae, 0xf5, 0x79, 0xd5, 0xcf, 0x5b, 0x3c, 0xfe, 0x17, 0xf1, 0x4a, 0x3e, 0xc0, 0x9d, 0x78
	.byte 0x1e, 0x10, 0xc0, 0xc2, 0xde, 0x09, 0xc0, 0xda, 0xe2, 0xd1, 0xc1, 0xc2, 0xff, 0x6f, 0x2b, 0x2b
	.byte 0x20, 0x08, 0x44, 0x69, 0x22, 0xc4, 0x79, 0x82, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x300070000000000000000
	/* C1 */
	.octa 0x80000000000100050000000000001200
	/* C21 */
	.octa 0x80000000600400020000000000000308
	/* C30 */
	.octa 0x80000000400180020000000000408204
final_cap_values:
	/* C0 */
	.octa 0xffffffffc2c2c2c2
	/* C1 */
	.octa 0x80000000000100050000000000001200
	/* C2 */
	.octa 0xc2
	/* C21 */
	.octa 0x80000000600400020000000000000308
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79f5aebf // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:21 imm12:110101101011 opc:11 111001:111001 size:01
	.inst 0x3c5bcfd5 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:21 Rn:30 11:11 imm9:110111100 0:0 opc:01 111100:111100 size:00
	.inst 0x4af117fe // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:000101 Rm:17 N:1 shift:11 01010:01010 opc:10 sf:0
	.inst 0x789dc03e // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:1 00:00 imm9:111011100 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c0101e // GCBASE-R.C-C Rd:30 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xdac009de // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:14 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c1d1e2 // CPY-C.C-C Cd:2 Cn:15 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x2b2b6fff // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:31 imm3:011 option:011 Rm:11 01011001:01011001 S:1 op:0 sf:0
	.inst 0x69440820 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:1 Rt2:00010 imm7:0001000 L:1 1010010:1010010 opc:01
	.inst 0x8279c422 // ALDRB-R.RI-B Rt:2 Rn:1 op:01 imm9:110011100 L:1 1000001001:1000001001
	.inst 0xc2c21240
	.zero 33172
	.inst 0x000000c2
	.zero 1015356
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400935 // ldr c21, [x9, #2]
	.inst 0xc2400d3e // ldr c30, [x9, #3]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603249 // ldr c9, [c18, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601249 // ldr c9, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400132 // ldr c18, [x9, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400532 // ldr c18, [x9, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400932 // ldr c18, [x9, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d32 // ldr c18, [x9, #3]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2
	mov x18, v21.d[0]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v21.d[1]
	cmp x9, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011dc
	ldr x1, =check_data0
	ldr x2, =0x000011de
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001220
	ldr x1, =check_data1
	ldr x2, =0x00001228
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000139c
	ldr x1, =check_data2
	ldr x2, =0x0000139d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dde
	ldr x1, =check_data3
	ldr x2, =0x00001de0
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
	ldr x0, =0x004081c0
	ldr x1, =check_data5
	ldr x2, =0x004081c1
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
