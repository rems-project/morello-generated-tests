.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x58, 0x68, 0x35
.data
check_data5:
	.byte 0xc2, 0x97, 0x81, 0x78, 0x9e, 0xb0, 0xc0, 0xc2, 0xc3, 0x53, 0xb4, 0x82, 0x02, 0x30, 0xa0, 0x38
	.byte 0x73, 0x0b, 0xa2, 0xac, 0x3e, 0x0a, 0x94, 0x78, 0x21, 0xe6, 0xa1, 0xc2, 0x01, 0x74, 0x18, 0xe2
	.byte 0x5f, 0xcc, 0x88, 0xf9, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000002700140000000000001100
	/* C1 */
	.octa 0x7f7
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C17 */
	.octa 0x800000005f5a009b0000000000002012
	/* C20 */
	.octa 0x400
	/* C27 */
	.octa 0x40000000000e00050000000000001000
	/* C30 */
	.octa 0x80000000000100070000000000001002
final_cap_values:
	/* C0 */
	.octa 0xc0000000002700140000000000001100
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C17 */
	.octa 0x800000005f5a009b0000000000002012
	/* C20 */
	.octa 0x400
	/* C27 */
	.octa 0x40000000000e00050000000000000c40
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x35685800 // cbnz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:0110100001011000000 op:1 011010:011010 sf:0
	.zero 854780
	.inst 0x788197c2 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:30 01:01 imm9:000011001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c0b09e // GCSEAL-R.C-C Rd:30 Cn:4 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x82b453c3 // ASTR-R.RRB-32 Rt:3 Rn:30 opc:00 S:1 option:010 Rm:20 1:1 L:0 100000101:100000101
	.inst 0x38a03002 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:0 00:00 opc:011 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xaca20b73 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:19 Rn:27 Rt2:00010 imm7:1000100 L:0 1011001:1011001 opc:10
	.inst 0x78940a3e // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:17 10:10 imm9:101000000 0:0 opc:10 111000:111000 size:01
	.inst 0xc2a1e621 // ADD-C.CRI-C Cd:1 Cn:17 imm3:001 option:111 Rm:1 11000010101:11000010101
	.inst 0xe2187401 // ALDURB-R.RI-32 Rt:1 Rn:0 op2:01 imm9:110000111 V:0 op1:00 11100010:11100010
	.inst 0xf988cc5f // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:001000110011 opc:10 111001:111001 size:11
	.inst 0xc2c21140
	.zero 193752
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc24012f1 // ldr c17, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2401afb // ldr c27, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q2, =0x10000000000000
	ldr q19, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603157 // ldr c23, [c10, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601157 // ldr c23, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ea // ldr c10, [x23, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eea // ldr c10, [x23, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24012ea // ldr c10, [x23, #4]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401aea // ldr c10, [x23, #6]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401eea // ldr c10, [x23, #7]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24022ea // ldr c10, [x23, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x10000000000000
	mov x10, v2.d[0]
	cmp x23, x10
	b.ne comparison_fail
	ldr x23, =0x0
	mov x10, v2.d[1]
	cmp x23, x10
	b.ne comparison_fail
	ldr x23, =0x0
	mov x10, v19.d[0]
	cmp x23, x10
	b.ne comparison_fail
	ldr x23, =0x0
	mov x10, v19.d[1]
	cmp x23, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001087
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001101
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f52
	ldr x1, =check_data3
	ldr x2, =0x00001f54
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004d0b00
	ldr x1, =check_data5
	ldr x2, =0x004d0b28
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
