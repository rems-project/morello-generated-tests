.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x81
.data
check_data1:
	.byte 0x61
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xc0, 0x93, 0xc5, 0xc2, 0xc0, 0xc7, 0xc2, 0xc2
.data
check_data4:
	.byte 0x07, 0x0e, 0xd7, 0x1a, 0x3f, 0x98, 0x7f, 0x22, 0x02, 0x52, 0xc0, 0xc2, 0x80, 0x06, 0xc1, 0xc2
	.byte 0x1a, 0x51, 0xc1, 0xc2, 0xbf, 0x53, 0x60, 0x38, 0x25, 0xfc, 0x9f, 0x48, 0xe3, 0x63, 0x21, 0x38
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0100000000400070000000000001800
	/* C2 */
	.octa 0xc0400002000700030000000000001000
	/* C5 */
	.octa 0x0
	/* C20 */
	.octa 0x3fefc0005002c0430000000004ea0000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x2040800200018005000000000040e001
final_cap_values:
	/* C0 */
	.octa 0x3fefc0005002c0430000000004ea0000
	/* C1 */
	.octa 0xc0100000000400070000000000001800
	/* C3 */
	.octa 0x61
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C20 */
	.octa 0x3fefc0005002c0430000000004ea0000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0xc0400000000700030000000000001000
	/* C30 */
	.octa 0x2040800200018005000000000040e001
initial_SP_EL3_value:
	.octa 0xc0000000000100050000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000200000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x700070080000000010001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c593c0 // CVTD-C.R-C Cd:0 Rn:30 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c2c7c0 // RETS-C.C-C 00000:00000 Cn:30 001:001 opc:10 1:1 Cm:2 11000010110:11000010110
	.zero 57336
	.inst 0x1ad70e07 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:7 Rn:16 o1:1 00001:00001 Rm:23 0011010110:0011010110 sf:0
	.inst 0x227f983f // LDAXP-C.R-C Ct:31 Rn:1 Ct2:00110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c05202 // GCVALUE-R.C-C Rd:2 Cn:16 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c10680 // BUILD-C.C-C Cd:0 Cn:20 001:001 opc:00 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c1511a // CFHI-R.C-C Rd:26 Cn:8 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x386053bf // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:101 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x489ffc25 // stlrh:aarch64/instrs/memory/ordered Rt:5 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x382163e3 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:31 00:00 opc:110 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c212c0
	.zero 991196
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d54 // ldr c20, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103d
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ca // ldr c10, [c22, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402156 // ldr c22, [x10, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402556 // ldr c22, [x10, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040e000
	ldr x1, =check_data4
	ldr x2, =0x0040e024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
