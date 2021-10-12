.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x13, 0x28, 0xde, 0xc2, 0x41, 0xc3, 0x8c, 0x38, 0xbe, 0xcd, 0x82, 0x3c, 0x00, 0x50, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x2e, 0x50, 0xc1, 0xc2, 0x60, 0xab, 0x5e, 0xe2, 0xc2, 0x30, 0x8e, 0xda, 0x0d, 0x08, 0x43, 0x7a
	.byte 0xdb, 0xf3, 0xc0, 0xc2, 0xe2, 0x7f, 0x9f, 0x48, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800100050000000000420001
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000000100070000000000001054
	/* C26 */
	.octa 0x800000000001000700000000000014aa
	/* C27 */
	.octa 0x400200
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000000100070000000000001080
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000800100050000000000420001
	/* C26 */
	.octa 0x800000000001000700000000000014aa
initial_SP_EL3_value:
	.octa 0x4000000047bc07f80000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004000010100000000003fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de2813 // BICFLGS-C.CR-C Cd:19 Cn:0 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0x388cc341 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:26 00:00 imm9:011001100 0:0 opc:10 111000:111000 size:00
	.inst 0x3c82cdbe // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:30 Rn:13 11:11 imm9:000101100 0:0 opc:10 111100:111100 size:00
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 131056
	.inst 0xc2c1502e // CFHI-R.C-C Rd:14 Cn:1 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xe25eab60 // ALDURSH-R.RI-64 Rt:0 Rn:27 op2:10 imm9:111101010 V:0 op1:01 11100010:11100010
	.inst 0xda8e30c2 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:6 o2:0 0:0 cond:0011 Rm:14 011010100:011010100 op:1 sf:1
	.inst 0x7a43080d // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:0 10:10 cond:0000 imm5:00011 111010010:111010010 op:1 sf:0
	.inst 0xc2c0f3db // GCTYPE-R.C-C Rd:27 Cn:30 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x489f7fe2 // stllrh:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c21200
	.zero 917476
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc240115b // ldr c27, [x10, #4]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q30, =0x1020000000000000000000000000000
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320a // ldr c10, [c16, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260120a // ldr c10, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x16, #0xf
	and x10, x10, x16
	cmp x10, #0xd
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400150 // ldr c16, [x10, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400550 // ldr c16, [x10, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400950 // ldr c16, [x10, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d50 // ldr c16, [x10, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401150 // ldr c16, [x10, #4]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401550 // ldr c16, [x10, #5]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401950 // ldr c16, [x10, #6]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401d50 // ldr c16, [x10, #7]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x16, v30.d[0]
	cmp x10, x16
	b.ne comparison_fail
	ldr x10, =0x102000000000000
	mov x16, v30.d[1]
	cmp x10, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001576
	ldr x1, =check_data2
	ldr x2, =0x00001577
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004001ea
	ldr x1, =check_data4
	ldr x2, =0x004001ec
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00420000
	ldr x1, =check_data5
	ldr x2, =0x0042001c
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
