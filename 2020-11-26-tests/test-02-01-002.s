.section data0, #alloc, #write
	.byte 0xc1, 0x13, 0x08, 0x10, 0x00, 0x80, 0x50, 0xc0, 0x00, 0x5c, 0x0a, 0x80, 0x49, 0x0a, 0x80, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x04, 0x10, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xed, 0x13, 0xc1, 0xc2, 0x21, 0x7c, 0xdf, 0xc8, 0x5d, 0x5d, 0x0a, 0xe2, 0x49, 0x6b, 0xc0, 0xc2
	.byte 0xd9, 0xb3, 0xc0, 0xc2, 0x6e, 0x83, 0xa7, 0xa2, 0x5f, 0x60, 0x22, 0x78, 0x3f, 0x6b, 0xd7, 0x92
	.byte 0xc0, 0x7f, 0xa0, 0xa2, 0x68, 0x66, 0xff, 0xb7, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000540400010000000000001140
	/* C2 */
	.octa 0xc0000000510800040000000000001000
	/* C7 */
	.octa 0x2000010800000100400000080
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1259
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0xcc100000600400050000000000001000
	/* C30 */
	.octa 0xdc000000000300070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x2000010800000100400001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc0000000510800040000000000001000
	/* C7 */
	.octa 0x2000010800000100400000080
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x1259
	/* C13 */
	.octa 0xffffffffffffffff
	/* C14 */
	.octa 0x800a49800a5c00c0508000100813c1
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0xcc100000600400050000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xdc000000000300070000000000001000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600300000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005800000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 176
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c113ed // GCLIM-R.C-C Rd:13 Cn:31 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc8df7c21 // ldlar:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xe20a5d5d // ALDURSB-R.RI-32 Rt:29 Rn:10 op2:11 imm9:010100101 V:0 op1:00 11100010:11100010
	.inst 0xc2c06b49 // ORRFLGS-C.CR-C Cd:9 Cn:26 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0xc2c0b3d9 // GCSEAL-R.C-C Rd:25 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xa2a7836e // SWPA-CC.R-C Ct:14 Rn:27 100000:100000 Cs:7 1:1 R:0 A:1 10100010:10100010
	.inst 0x7822605f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:110 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x92d76b3f // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1011101101011001 hw:10 100101:100101 opc:00 sf:1
	.inst 0xa2a07fc0 // CAS-C.R-C Ct:0 Rn:30 11111:11111 R:0 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xb7ff6668 // tbnz:aarch64/instrs/branch/conditional/test Rt:8 imm14:11101100110011 b40:11111 op:1 011011:011011 b5:1
	.inst 0xc2c212e0
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e87 // ldr c7, [x20, #3]
	.inst 0xc2401288 // ldr c8, [x20, #4]
	.inst 0xc240168a // ldr c10, [x20, #5]
	.inst 0xc2401a9a // ldr c26, [x20, #6]
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	.inst 0xc240229e // ldr c30, [x20, #8]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f4 // ldr c20, [c23, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826012f4 // ldr c20, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400297 // ldr c23, [x20, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400697 // ldr c23, [x20, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a97 // ldr c23, [x20, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e97 // ldr c23, [x20, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401697 // ldr c23, [x20, #5]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401a97 // ldr c23, [x20, #6]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401e97 // ldr c23, [x20, #7]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2402297 // ldr c23, [x20, #8]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2402697 // ldr c23, [x20, #9]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402a97 // ldr c23, [x20, #10]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402e97 // ldr c23, [x20, #11]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2403297 // ldr c23, [x20, #12]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2403697 // ldr c23, [x20, #13]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012fe
	ldr x1, =check_data2
	ldr x2, =0x000012ff
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
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
