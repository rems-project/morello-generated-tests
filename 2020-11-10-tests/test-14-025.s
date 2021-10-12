.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x10, 0xab, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xe0, 0x5f, 0xcb, 0x69, 0x20, 0x00, 0x1f, 0xd6
.data
check_data5:
	.byte 0x5f, 0x3b, 0x03, 0xd5, 0x64, 0x02, 0x1e, 0x3a, 0x42, 0x44, 0x19, 0xc2, 0x20, 0xea, 0x28, 0xc8
	.byte 0x5f, 0x64, 0x80, 0x1a, 0x60, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0xdf, 0x79, 0x8a, 0x39, 0x1f, 0xf0, 0xa2, 0x9b, 0x40, 0x01, 0x5f, 0xd6
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400208
	/* C2 */
	.octa 0x400000000000ffffffffffffab10
	/* C10 */
	.octa 0x400010
	/* C14 */
	.octa 0x1060
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x40000000
	/* C30 */
	.octa 0x40000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400208
	/* C2 */
	.octa 0x400000000000ffffffffffffab10
	/* C4 */
	.octa 0x80000000
	/* C8 */
	.octa 0x1
	/* C10 */
	.octa 0x400010
	/* C14 */
	.octa 0x1060
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x40000000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000
initial_SP_EL3_value:
	.octa 0x12e4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005b01002400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x69cb5fe0 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:31 Rt2:10111 imm7:0010110 L:1 1010011:1010011 opc:01
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 8
	.inst 0xd5033b5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1011 11010101000000110011:11010101000000110011
	.inst 0x3a1e0264 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:4 Rn:19 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2194442 // STR-C.RIB-C Ct:2 Rn:2 imm12:011001010001 L:0 110000100:110000100
	.inst 0xc828ea20 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:17 Rt2:11010 o0:1 Rs:8 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x1a80645f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:2 o2:1 0:0 cond:0110 Rm:0 011010100:011010100 op:0 sf:0
	.inst 0xc2c21160
	.zero 480
	.inst 0x398a79df // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:14 imm12:001010011110 opc:10 111001:111001 size:00
	.inst 0x9ba2f01f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:28 o0:1 Rm:2 01:01 U:1 10011011:10011011
	.inst 0xd65f0140 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:10 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 1048044
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
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2400eae // ldr c14, [x21, #3]
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc24016b3 // ldr c19, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603175 // ldr c21, [c11, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601175 // ldr c21, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x21, x21, x11
	cmp x21, #0x9
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ab // ldr c11, [x21, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006ab // ldr c11, [x21, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400aab // ldr c11, [x21, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400eab // ldr c11, [x21, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc24012ab // ldr c11, [x21, #4]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24016ab // ldr c11, [x21, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401aab // ldr c11, [x21, #6]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401eab // ldr c11, [x21, #7]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc24022ab // ldr c11, [x21, #8]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc24026ab // ldr c11, [x21, #9]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2402aab // ldr c11, [x21, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x2, =0x00001030
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
	ldr x0, =0x0000133c
	ldr x1, =check_data3
	ldr x2, =0x00001344
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400010
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400208
	ldr x1, =check_data6
	ldr x2, =0x00400214
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
