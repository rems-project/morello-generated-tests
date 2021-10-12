.section data0, #alloc, #write
	.zero 4080
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.byte 0x20, 0x00, 0x3f, 0xd6
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x1d, 0x38, 0xe9, 0x69, 0x61, 0x2d, 0x7f, 0xc8, 0xfc, 0x43, 0x2a, 0x78, 0xc1, 0x11, 0x58, 0x82
	.byte 0xf0, 0x53, 0xc1, 0xc2, 0x8b, 0xe3, 0x5e, 0xfa, 0x3f, 0x8b, 0xcd, 0x92, 0xa0, 0xd7, 0x8f, 0xda
	.byte 0xfe, 0x30, 0xc6, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000004004400500000000004040c4
	/* C1 */
	.octa 0x410000
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x800000002607e4430000000000404020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x10
	/* C16 */
	.octa 0xc000000000010005
	/* C28 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x3fff800000000000000000000000
initial_SP_EL3_value:
	.octa 0xc0000000000100050000000000001ff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0020 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 16396
	.inst 0x00000010
	.zero 49132
	.inst 0x69e9381d // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:0 Rt2:01110 imm7:1010010 L:1 1010011:1010011 opc:01
	.inst 0xc87f2d61 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:11 Rt2:01011 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x782a43fc // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:31 00:00 opc:100 0:0 Rs:10 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x825811c1 // ASTR-C.RI-C Ct:1 Rn:14 op:00 imm9:110000001 L:0 1000001001:1000001001
	.inst 0xc2c153f0 // 0xc2c153f0
	.inst 0xfa5ee38b // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:28 00:00 cond:1110 Rm:30 111010010:111010010 op:1 sf:1
	.inst 0x92cd8b3f // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:0110110001011001 hw:10 100101:100101 opc:00 sf:1
	.inst 0xda8fd7a0 // csneg:aarch64/instrs/integer/conditional/select Rd:0 Rn:29 o2:1 0:0 cond:1101 Rm:15 011010100:011010100 op:1 sf:1
	.inst 0xc2c630fe // CLRPERM-C.CI-C Cd:30 Cn:7 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0xc2c21120
	.zero 983000
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b47 // ldr c7, [x26, #2]
	.inst 0xc2400f4a // ldr c10, [x26, #3]
	.inst 0xc240134b // ldr c11, [x26, #4]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085103f
	msr SCTLR_EL3, x26
	ldr x26, =0x88
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313a // ldr c26, [c9, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260113a // ldr c26, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x9, #0xf
	and x26, x26, x9
	cmp x26, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401749 // ldr c9, [x26, #5]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401b49 // ldr c9, [x26, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401f49 // ldr c9, [x26, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402349 // ldr c9, [x26, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402749 // ldr c9, [x26, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001820
	ldr x1, =check_data0
	ldr x2, =0x00001830
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff2
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
	ldr x0, =0x0040400c
	ldr x1, =check_data3
	ldr x2, =0x00404014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404020
	ldr x1, =check_data4
	ldr x2, =0x00404030
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
