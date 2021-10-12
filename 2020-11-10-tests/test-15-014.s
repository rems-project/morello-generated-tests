.section data0, #alloc, #write
	.zero 832
	.byte 0x41, 0x98, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3248
.data
check_data0:
	.zero 40
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x41, 0x98
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x9f, 0xba, 0xc0, 0x6d, 0x01, 0x85, 0xc1, 0xc2, 0x46, 0x50, 0xbe, 0x78, 0xd8, 0x03, 0x1d, 0xe2
	.byte 0x18, 0x02, 0x19, 0x7a, 0x2f, 0xa8, 0xc0, 0xc2, 0xf6, 0xc7, 0x20, 0x22, 0x5f, 0xb4, 0xe6, 0x42
	.byte 0xe2, 0x11, 0xc7, 0xc2, 0xd2, 0x65, 0x03, 0xe2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x580056000000000000002000
	/* C2 */
	.octa 0xd0000000535400010000000000001340
	/* C8 */
	.octa 0x201120070000000000000001
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000000100050000000000001000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x1840
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x580056000000000000002000
	/* C2 */
	.octa 0x2000
	/* C6 */
	.octa 0x9841
	/* C8 */
	.octa 0x201120070000000000000001
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0x580056000000000000002000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000000100050000000000001008
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1840
initial_SP_EL3_value:
	.octa 0x4c000000500040010000000000404400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005c0100000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6dc0ba9f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:31 Rn:20 Rt2:01110 imm7:0000001 L:1 1011011:1011011 opc:01
	.inst 0xc2c18501 // CHKSS-_.CC-C 00001:00001 Cn:8 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x78be5046 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:2 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xe21d03d8 // ASTURB-R.RI-32 Rt:24 Rn:30 op2:00 imm9:111010000 V:0 op1:00 11100010:11100010
	.inst 0x7a190218 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:24 Rn:16 000000:000000 Rm:25 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c0a82f // EORFLGS-C.CR-C Cd:15 Cn:1 1010:1010 opc:10 Rm:0 11000010110:11000010110
	.inst 0x2220c7f6 // STLXP-R.CR-C Ct:22 Rn:31 Ct2:10001 1:1 Rs:0 1:1 L:0 001000100:001000100
	.inst 0x42e6b45f // LDP-C.RIB-C Ct:31 Rn:2 Ct2:01101 imm7:1001101 L:1 010000101:010000101
	.inst 0xc2c711e2 // RRLEN-R.R-C Rd:2 Rn:15 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xe20365d2 // ALDURB-R.RI-32 Rt:18 Rn:14 op2:01 imm9:000110110 V:0 op1:00 11100010:11100010
	.inst 0xc2c212e0
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc2401551 // ldr c17, [x10, #5]
	.inst 0xc2401954 // ldr c20, [x10, #6]
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2402158 // ldr c24, [x10, #8]
	.inst 0xc240255e // ldr c30, [x10, #9]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103f
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ea // ldr c10, [c23, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ea // ldr c10, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	.inst 0xc2400157 // ldr c23, [x10, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400557 // ldr c23, [x10, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400957 // ldr c23, [x10, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401557 // ldr c23, [x10, #5]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401d57 // ldr c23, [x10, #7]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2402157 // ldr c23, [x10, #8]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402557 // ldr c23, [x10, #9]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402957 // ldr c23, [x10, #10]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2402d57 // ldr c23, [x10, #11]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2403157 // ldr c23, [x10, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x23, v14.d[0]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x0
	mov x23, v14.d[1]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x0
	mov x23, v31.d[0]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x0
	mov x23, v31.d[1]
	cmp x10, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001036
	ldr x1, =check_data1
	ldr x2, =0x00001037
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001340
	ldr x1, =check_data2
	ldr x2, =0x00001342
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001811
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
