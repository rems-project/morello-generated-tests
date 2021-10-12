.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x5c, 0x60, 0xb9, 0x42, 0x3f, 0xea, 0x8b, 0xd0, 0xe0, 0xc0, 0xe2, 0x02, 0x00, 0x00, 0x06, 0x1a
	.byte 0x41, 0x30, 0xc0, 0xc2, 0xf8, 0xa6, 0xab, 0xb6, 0x0c, 0x08, 0xc0, 0x5a, 0xee, 0x8b, 0x55, 0xba
	.byte 0xe0, 0xd9, 0x9b, 0x38, 0x5f, 0x3d, 0x03, 0xd5, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4c000000000180060000000000001810
	/* C7 */
	.octa 0x800680070000000020227a00
	/* C15 */
	.octa 0x80000000400100580000000000002002
	/* C24 */
	.octa 0x20000000000000
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x4c000000000180060000000000001810
	/* C7 */
	.octa 0x800680070000000020227a00
	/* C15 */
	.octa 0x80000000400100580000000000002002
	/* C24 */
	.octa 0x20000000000000
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800020c7e0060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42b9605c // STP-C.RIB-C Ct:28 Rn:2 Ct2:11000 imm7:1110010 L:0 010000101:010000101
	.inst 0xd08bea3f // ADRP-C.I-C Rd:31 immhi:000101111101010001 P:1 10000:10000 immlo:10 op:1
	.inst 0x02e2c0e0 // SUB-C.CIS-C Cd:0 Cn:7 imm12:100010110000 sh:1 A:1 00000010:00000010
	.inst 0x1a060000 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:0 000000:000000 Rm:6 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c03041 // GCLEN-R.C-C Rd:1 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xb6aba6f8 // tbz:aarch64/instrs/branch/conditional/test Rt:24 imm14:01110100110111 b40:10101 op:0 011011:011011 b5:1
	.inst 0x5ac0080c // rev:aarch64/instrs/integer/arithmetic/rev Rd:12 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xba558bee // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:31 10:10 cond:1000 imm5:10101 111010010:111010010 op:0 sf:1
	.inst 0x389bd9e0 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:15 10:10 imm9:110111101 0:0 opc:10 111000:111000 size:00
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400222 // ldr c2, [x17, #0]
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2400a2f // ldr c15, [x17, #2]
	.inst 0xc2400e38 // ldr c24, [x17, #3]
	.inst 0xc240123c // ldr c28, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x20000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601151 // ldr c17, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x10, #0xf
	and x17, x17, x10
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022a // ldr c10, [x17, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240062a // ldr c10, [x17, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a2a // ldr c10, [x17, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240122a // ldr c10, [x17, #4]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240162a // ldr c10, [x17, #5]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401a2a // ldr c10, [x17, #6]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001730
	ldr x1, =check_data0
	ldr x2, =0x00001750
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fbf
	ldr x1, =check_data1
	ldr x2, =0x00001fc0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
