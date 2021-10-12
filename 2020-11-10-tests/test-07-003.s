.section data0, #alloc, #write
	.byte 0x02, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3072
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 992
.data
check_data0:
	.byte 0x01, 0x00, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x3f, 0x10, 0x62, 0x82, 0x5f, 0x74, 0x52, 0x79, 0xdf, 0x23, 0x22, 0x78, 0x7f, 0x70, 0x6c, 0x38
	.byte 0x07, 0xf0, 0x8c, 0xf0, 0x01, 0x50, 0x35, 0xb8, 0x1f, 0x20, 0xc1, 0x9a, 0xdf, 0x63, 0x7f, 0xf8
	.byte 0xf4, 0xb0, 0xc0, 0xc2, 0x3a, 0x50, 0x72, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x90100000000100050000000000001c10
	/* C2 */
	.octa 0xc02
	/* C3 */
	.octa 0x1c11
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x80800001
	/* C21 */
	.octa 0x40000000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0xc02
	/* C3 */
	.octa 0x1c11
	/* C7 */
	.octa 0xffffffff1a203000
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x80800001
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005c150c1400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8262103f // ALDR-C.RI-C Ct:31 Rn:1 op:00 imm9:000100001 L:1 1000001001:1000001001
	.inst 0x7952745f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:010010011101 opc:01 111001:111001 size:01
	.inst 0x782223df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:010 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x386c707f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:111 o3:0 Rs:12 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf08cf007 // ADRP-C.IP-C Rd:7 immhi:000110011110000000 P:1 10000:10000 immlo:11 op:1
	.inst 0xb8355001 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:101 0:0 Rs:21 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x9ac1201f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:0 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xf87f63df // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c0b0f4 // GCSEAL-R.C-C Rd:20 Cn:7 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xb872503a // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:1 00:00 opc:101 0:0 Rs:18 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400fa3 // ldr c3, [x29, #3]
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc24017b2 // ldr c18, [x29, #5]
	.inst 0xc2401bb5 // ldr c21, [x29, #6]
	.inst 0xc2401fbe // ldr c30, [x29, #7]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851037
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331d // ldr c29, [c24, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260131d // ldr c29, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b8 // ldr c24, [x29, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24007b8 // ldr c24, [x29, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400bb8 // ldr c24, [x29, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400fb8 // ldr c24, [x29, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc24013b8 // ldr c24, [x29, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24017b8 // ldr c24, [x29, #5]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401bb8 // ldr c24, [x29, #6]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401fb8 // ldr c24, [x29, #7]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24023b8 // ldr c24, [x29, #8]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc24027b8 // ldr c24, [x29, #9]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2402bb8 // ldr c24, [x29, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000153c
	ldr x1, =check_data1
	ldr x2, =0x0000153e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c11
	ldr x1, =check_data2
	ldr x2, =0x00001c12
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e20
	ldr x1, =check_data3
	ldr x2, =0x00001e30
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
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
