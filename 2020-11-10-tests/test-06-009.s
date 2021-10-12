.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xfd, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xff, 0xff, 0xff, 0xfd
.data
check_data3:
	.byte 0xff
.data
check_data4:
	.byte 0x7a, 0x89, 0xf3, 0xd2, 0xc1, 0x0a, 0xc0, 0xda, 0x40, 0x30, 0xb2, 0xb8, 0xe1, 0xc3, 0x43, 0xa2
	.byte 0x64, 0x45, 0xaf, 0xe2, 0x41, 0x10, 0xc1, 0xc2, 0xe1, 0x89, 0x02, 0x9b, 0x3f, 0xc3, 0xa0, 0x82
	.byte 0xf9, 0x94, 0x3c, 0x11, 0xc0, 0xff, 0xb6, 0x08, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x30000000000001108
	/* C11 */
	.octa 0x80000000000100050000000000403f04
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x40000000000100050000000002001001
	/* C30 */
	.octa 0x1ffe
final_cap_values:
	/* C0 */
	.octa 0xfdffffff
	/* C2 */
	.octa 0x30000000000001108
	/* C11 */
	.octa 0x80000000000100050000000000403f04
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x9c4b000000000000
	/* C30 */
	.octa 0x1ffe
initial_SP_EL3_value:
	.octa 0x1024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd2f3897a // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:26 imm16:1001110001001011 hw:11 100101:100101 opc:10 sf:1
	.inst 0xdac00ac1 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:22 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb8b23040 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:2 00:00 opc:011 0:0 Rs:18 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xa243c3e1 // LDUR-C.RI-C Ct:1 Rn:31 00:00 imm9:000111100 0:0 opc:01 10100010:10100010
	.inst 0xe2af4564 // ALDUR-V.RI-S Rt:4 Rn:11 op2:01 imm9:011110100 V:1 op1:10 11100010:11100010
	.inst 0xc2c11041 // GCLIM-R.C-C Rd:1 Cn:2 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x9b0289e1 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:15 Ra:2 o0:1 Rm:2 0011011000:0011011000 sf:1
	.inst 0x82a0c33f // ASTR-R.RRB-32 Rt:31 Rn:25 opc:00 S:0 option:110 Rm:0 1:1 L:0 100000101:100000101
	.inst 0x113c94f9 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:25 Rn:7 imm12:111100100101 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x08b6ffc0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:30 11111:11111 o0:1 Rs:22 1:1 L:0 0010001:0010001 size:00
	.inst 0xc2c210c0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004ab // ldr c11, [x5, #1]
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2400cb6 // ldr c22, [x5, #3]
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc24014be // ldr c30, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c5 // ldr c5, [c6, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826010c5 // ldr c5, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a6 // ldr c6, [x5, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24004a6 // ldr c6, [x5, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc24010a6 // ldr c6, [x5, #4]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24014a6 // ldr c6, [x5, #5]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc24018a6 // ldr c6, [x5, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x6, v4.d[0]
	cmp x5, x6
	b.ne comparison_fail
	ldr x5, =0x0
	mov x6, v4.d[1]
	cmp x5, x6
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001108
	ldr x1, =check_data2
	ldr x2, =0x0000110c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x00403ff8
	ldr x1, =check_data5
	ldr x2, =0x00403ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
