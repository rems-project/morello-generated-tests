.section data0, #alloc, #write
	.zero 752
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3328
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x02, 0x80
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x86, 0xf0, 0x93, 0x54, 0x94, 0x62, 0x21, 0xc8, 0x3f, 0xff, 0x3f, 0x42, 0x5f, 0x50, 0x3b, 0x78
	.byte 0x0d, 0x04, 0x61, 0x92, 0x5e, 0x10, 0xc0, 0x5a, 0xeb, 0x71, 0x5b, 0x70, 0x1b, 0x04, 0x1e, 0x9b
	.byte 0xfe, 0xc3, 0xdf, 0xc2, 0x5f, 0x51, 0xda, 0x42, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xc00000000001000500000000000012f8
	/* C10 */
	.octa 0x90000000000100050000000000001000
	/* C20 */
	.octa 0x40000000000100050000000000001000
	/* C25 */
	.octa 0x1020
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0xc00000000001000500000000000012f8
	/* C10 */
	.octa 0x90000000000100050000000000001000
	/* C11 */
	.octa 0x200080000000400000000000004b6e57
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x1020
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400400050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001340
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5493f086 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:1001001111110000100 01010100:01010100
	.inst 0xc8216294 // stxp:aarch64/instrs/memory/exclusive/pair Rt:20 Rn:20 Rt2:11000 o0:0 Rs:1 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x423fff3f // ASTLR-R.R-32 Rt:31 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x783b505f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:101 o3:0 Rs:27 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x9261040d // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:13 Rn:0 imms:000001 immr:100001 N:1 100100:100100 opc:00 sf:1
	.inst 0x5ac0105e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:2 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x705b71eb // ADR-C.I-C Rd:11 immhi:101101101110001111 P:0 10000:10000 immlo:11 op:0
	.inst 0x9b1e041b // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:27 Rn:0 Ra:1 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0xc2dfc3fe // CVT-R.CC-C Rd:30 Cn:31 110000:110000 Cm:31 11000010110:11000010110
	.inst 0x42da515f // LDP-C.RIB-C Ct:31 Rn:10 Ct2:10100 imm7:0110100 L:1 010000101:010000101
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
	ldr x18, =initial_cap_values
	.inst 0xc2400242 // ldr c2, [x18, #0]
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2400a54 // ldr c20, [x18, #2]
	.inst 0xc2400e59 // ldr c25, [x18, #3]
	.inst 0xc240125b // ldr c27, [x18, #4]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d2 // ldr c18, [c6, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010d2 // ldr c18, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x6, #0xf
	and x18, x18, x6
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400246 // ldr c6, [x18, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400646 // ldr c6, [x18, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401246 // ldr c6, [x18, #4]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401646 // ldr c6, [x18, #5]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2401a46 // ldr c6, [x18, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f8
	ldr x1, =check_data2
	ldr x2, =0x000012fa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001340
	ldr x1, =check_data3
	ldr x2, =0x00001360
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
