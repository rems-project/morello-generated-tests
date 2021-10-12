.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x02, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0xe2, 0x93, 0x42, 0x82, 0xf1, 0x47, 0x00, 0x1b, 0x40, 0x70, 0xc0, 0xc2, 0x47, 0xd0, 0xc5, 0xc2
	.byte 0x92, 0x90, 0xc1, 0xc2, 0x61, 0x33, 0xc2, 0xc2, 0x1f, 0x5f, 0x56, 0xe2, 0x41, 0xa5, 0xc2, 0xc2
	.byte 0x3e, 0xcd, 0x3e, 0x10, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000006300070000000000480000
	/* C2 */
	.octa 0x300070000000800000000
	/* C10 */
	.octa 0x300070000000800000000
	/* C24 */
	.octa 0x80000000500110040000000000001401
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800000000
	/* C2 */
	.octa 0x300070000000800000000
	/* C7 */
	.octa 0xc001600400000043ffff6004
	/* C10 */
	.octa 0x300070000000800000000
	/* C24 */
	.octa 0x80000000500110040000000000001401
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x4fd9c4
initial_csp_value:
	.octa 0x40000000000500070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00160040000003c00000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25002 // RETS-C-C 00010:00010 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 524284
	.inst 0x824293e2 // ASTR-C.RI-C Ct:2 Rn:31 op:00 imm9:000101001 L:0 1000001001:1000001001
	.inst 0x1b0047f1 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:17 Rn:31 Ra:17 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc2c07040 // GCOFF-R.C-C Rd:0 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c5d047 // CVTDZ-C.R-C Cd:7 Rn:2 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c19092 // CLRTAG-C.C-C Cd:18 Cn:4 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c23361 // CHKTGD-C-C 00001:00001 Cn:27 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe2565f1f // ALDURSH-R.RI-32 Rt:31 Rn:24 op2:11 imm9:101100101 V:0 op1:01 11100010:11100010
	.inst 0xc2c2a541 // CHKEQ-_.CC-C 00001:00001 Cn:10 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.inst 0x103ecd3e // ADR-C.I-C Rd:30 immhi:011111011001101001 P:0 10000:10000 immlo:00 op:0
	.inst 0xc2c210c0
	.zero 524248
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x1, cptr_el3
	orr x1, x1, #0x200
	msr cptr_el3, x1
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
	ldr x1, =initial_cap_values
	.inst 0xc2400020 // ldr c0, [x1, #0]
	.inst 0xc2400422 // ldr c2, [x1, #1]
	.inst 0xc240082a // ldr c10, [x1, #2]
	.inst 0xc2400c38 // ldr c24, [x1, #3]
	.inst 0xc240103b // ldr c27, [x1, #4]
	/* Set up flags and system registers */
	mov x1, #0x00000000
	msr nzcv, x1
	ldr x1, =initial_csp_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2c1d03f // cpy c31, c1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30850038
	msr SCTLR_EL3, x1
	ldr x1, =0xc
	msr S3_6_C1_C2_2, x1 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c1 // ldr c1, [c6, #3]
	.inst 0xc28b4121 // msr ddc_el3, c1
	isb
	.inst 0x826010c1 // ldr c1, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21020 // br c1
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr ddc_el3, c1
	isb
	/* Check processor flags */
	mrs x1, nzcv
	ubfx x1, x1, #28, #4
	mov x6, #0xf
	and x1, x1, x6
	cmp x1, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc2400026 // ldr c6, [x1, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400426 // ldr c6, [x1, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400826 // ldr c6, [x1, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400c26 // ldr c6, [x1, #3]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401026 // ldr c6, [x1, #4]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401426 // ldr c6, [x1, #5]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2401826 // ldr c6, [x1, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000012a0
	ldr x1, =check_data0
	ldr x2, =0x000012b0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001366
	ldr x1, =check_data1
	ldr x2, =0x00001368
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00480000
	ldr x1, =check_data3
	ldr x2, =0x00480028
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
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr ddc_el3, c1
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
