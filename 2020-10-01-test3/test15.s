.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe0, 0xf0, 0x40, 0x00
.data
check_data1:
	.byte 0x3e, 0x7c, 0x5f, 0x42, 0x31, 0x2c, 0x17, 0x0a, 0xde, 0x63, 0x91, 0xb8, 0x1e, 0xa8, 0x81, 0x38
	.byte 0x6f, 0xf0, 0xc5, 0xc2, 0x1f, 0x5c, 0xd8, 0xc2, 0xa2, 0x33, 0xc1, 0xc2, 0xe1, 0x42, 0x99, 0xe2
	.byte 0x20, 0x02, 0x3f, 0xd6
.data
check_data2:
	.byte 0x3e, 0x24, 0xc9, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xd2, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4fffe4
	/* C1 */
	.octa 0x8000000000010007000000000040f0e0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C23 */
	.octa 0x400000000001000500000000000019d0
final_cap_values:
	/* C0 */
	.octa 0x4fffe4
	/* C1 */
	.octa 0x8000000000010007000000000040f0e0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x408000
	/* C23 */
	.octa 0x400000000001000500000000000019d0
	/* C30 */
	.octa 0x8000000000010007ffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000009c0050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7c3e // ALDAR-C.R-C Ct:30 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x0a172c31 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:17 Rn:1 imm6:001011 Rm:23 N:0 shift:00 01010:01010 opc:00 sf:0
	.inst 0xb89163de // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:100010110 0:0 opc:10 111000:111000 size:10
	.inst 0x3881a81e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:0 10:10 imm9:000011010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c5f06f // CVTPZ-C.R-C Cd:15 Rn:3 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2d85c1f // CSEL-C.CI-C Cd:31 Cn:0 11:11 cond:0101 Cm:24 11000010110:11000010110
	.inst 0xc2c133a2 // GCFLGS-R.C-C Rd:2 Cn:29 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xe29942e1 // ASTUR-R.RI-32 Rt:1 Rn:23 op2:00 imm9:110010100 V:0 op1:10 11100010:11100010
	.inst 0xd63f0220 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:17 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 32732
	.inst 0xc2c9243e // CPYTYPE-C.C-C Cd:30 Cn:1 001:001 opc:01 0:0 Cm:9 11000010110:11000010110
	.inst 0xc2c21140
	.zero 28888
	.inst 0x005000d2
	.zero 986908
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x80000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603155 // ldr c21, [c10, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601155 // ldr c21, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x10, #0x8
	and x21, x21, x10
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002aa // ldr c10, [x21, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006aa // ldr c10, [x21, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24012aa // ldr c10, [x21, #4]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc24016aa // ldr c10, [x21, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401aaa // ldr c10, [x21, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401eaa // ldr c10, [x21, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001964
	ldr x1, =check_data0
	ldr x2, =0x00001968
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00408000
	ldr x1, =check_data2
	ldr x2, =0x00408008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040f0e0
	ldr x1, =check_data3
	ldr x2, =0x0040f0f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fffe8
	ldr x1, =check_data4
	ldr x2, =0x004fffec
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
