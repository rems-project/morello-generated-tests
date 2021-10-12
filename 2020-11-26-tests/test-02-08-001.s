.section data0, #alloc, #write
	.byte 0xe6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xe6
.data
check_data1:
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x5f, 0x22, 0x21, 0x78, 0x29, 0x65, 0xbe, 0x82, 0x21, 0x00, 0xdc, 0xc2, 0x7d, 0x33, 0x3e, 0x38
	.byte 0x24, 0x08, 0xc0, 0xda, 0x57, 0xc7, 0x5f, 0xeb, 0x2f, 0x28, 0x5d, 0xba, 0x00, 0xbd, 0x1b, 0xe2
	.byte 0xa2, 0x69, 0x1e, 0x82, 0xbe, 0x53, 0xc1, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000000000000000000000
	/* C8 */
	.octa 0x80000000600000010000000000002006
	/* C9 */
	.octa 0x400000000106000f0000000000000020
	/* C18 */
	.octa 0x1400
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000600000010000000000002006
	/* C9 */
	.octa 0x400000000106000f0000000000000020
	/* C18 */
	.octa 0x1400
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0xe6
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080003ffb00060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000028100ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821225f // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:010 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x82be6529 // ASTR-R.RRB-64 Rt:9 Rn:9 opc:01 S:0 option:011 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xc2dc0021 // SCBNDS-C.CR-C Cd:1 Cn:1 000:000 opc:00 0:0 Rm:28 11000010110:11000010110
	.inst 0x383e337d // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:27 00:00 opc:011 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xdac00824 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:4 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xeb5fc757 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:23 Rn:26 imm6:110001 Rm:31 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xba5d282f // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:1 10:10 cond:0010 imm5:11101 111010010:111010010 op:0 sf:1
	.inst 0xe21bbd00 // ALDURSB-R.RI-32 Rt:0 Rn:8 op2:11 imm9:110111011 V:0 op1:00 11100010:11100010
	.inst 0x821e69a2 // LDR-C.I-C Ct:2 imm17:01111001101001101 1000001000:1000001000
	.inst 0xc2c153be // CFHI-R.C-C Rd:30 Cn:29 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21140
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a8 // ldr c8, [x21, #1]
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2400eb2 // ldr c18, [x21, #3]
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc24016be // ldr c30, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603155 // ldr c21, [c10, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601155 // ldr c21, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x10, #0xf
	and x21, x21, x10
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002aa // ldr c10, [x21, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006aa // ldr c10, [x21, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24012aa // ldr c10, [x21, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24016aa // ldr c10, [x21, #5]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401aaa // ldr c10, [x21, #6]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc2401eaa // ldr c10, [x21, #7]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24022aa // ldr c10, [x21, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc1
	ldr x1, =check_data3
	ldr x2, =0x00001fc2
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
	ldr x0, =0x004f34f0
	ldr x1, =check_data5
	ldr x2, =0x004f3500
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
