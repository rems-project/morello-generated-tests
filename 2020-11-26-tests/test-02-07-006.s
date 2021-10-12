.section data0, #alloc, #write
	.zero 4000
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xa0, 0x02
.data
check_data7:
	.byte 0xa1, 0xb6, 0x9a, 0xf9, 0x61, 0x7f, 0x5f, 0x42, 0xd6, 0x7f, 0x1f, 0x88, 0x21, 0xd7, 0x9d, 0x5a
	.byte 0x1e, 0x33, 0x49, 0x38, 0xeb, 0xd3, 0x1d, 0xa2, 0xfd, 0x72, 0xb1, 0x78, 0x55, 0x80, 0x3a, 0x78
	.byte 0x20, 0xbc, 0x85, 0xb8, 0xc7, 0x32, 0x5a, 0x7a, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1000
	/* C11 */
	.octa 0x200000000000000080
	/* C17 */
	.octa 0x8000
	/* C23 */
	.octa 0x1fa8
	/* C24 */
	.octa 0x1712
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x901000005ffa0ffc0000000000001020
	/* C29 */
	.octa 0xffffeffb
	/* C30 */
	.octa 0x1038
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1060
	/* C2 */
	.octa 0x1000
	/* C11 */
	.octa 0x200000000000000080
	/* C17 */
	.octa 0x8000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x1fa8
	/* C24 */
	.octa 0x1712
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x901000005ffa0ffc0000000000001020
	/* C29 */
	.octa 0x2a0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1fa3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000407a40f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000401701f70000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf99ab6a1 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:21 imm12:011010101101 opc:10 111001:111001 size:11
	.inst 0x425f7f61 // ALDAR-C.R-C Ct:1 Rn:27 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x881f7fd6 // stxr:aarch64/instrs/memory/exclusive/single Rt:22 Rn:30 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:10
	.inst 0x5a9dd721 // csneg:aarch64/instrs/integer/conditional/select Rd:1 Rn:25 o2:1 0:0 cond:1101 Rm:29 011010100:011010100 op:1 sf:0
	.inst 0x3849331e // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:24 00:00 imm9:010010011 0:0 opc:01 111000:111000 size:00
	.inst 0xa21dd3eb // STUR-C.RI-C Ct:11 Rn:31 00:00 imm9:111011101 0:0 opc:00 10100010:10100010
	.inst 0x78b172fd // lduminh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:23 00:00 opc:111 0:0 Rs:17 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x783a8055 // swph:aarch64/instrs/memory/atomicops/swp Rt:21 Rn:2 100000:100000 Rs:26 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xb885bc20 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:001011011 0:0 opc:10 111000:111000 size:10
	.inst 0x7a5a32c7 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:22 00:00 cond:0011 Rm:26 111010010:111010010 op:1 sf:0
	.inst 0xc2c21180
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
	ldr x19, =initial_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2401278 // ldr c24, [x19, #4]
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2401a7b // ldr c27, [x19, #6]
	.inst 0xc2401e7d // ldr c29, [x19, #7]
	.inst 0xc240227e // ldr c30, [x19, #8]
	/* Set up flags and system registers */
	mov x19, #0x20000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603193 // ldr c19, [c12, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601193 // ldr c19, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x12, #0xf
	and x19, x19, x12
	cmp x19, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026c // ldr c12, [x19, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240066c // ldr c12, [x19, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240166c // ldr c12, [x19, #5]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc2401a6c // ldr c12, [x19, #6]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc2401e6c // ldr c12, [x19, #7]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc240226c // ldr c12, [x19, #8]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240266c // ldr c12, [x19, #9]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402a6c // ldr c12, [x19, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402e6c // ldr c12, [x19, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x00001038
	ldr x1, =check_data2
	ldr x2, =0x0000103c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001060
	ldr x1, =check_data3
	ldr x2, =0x00001064
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017a5
	ldr x1, =check_data4
	ldr x2, =0x000017a6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f80
	ldr x1, =check_data5
	ldr x2, =0x00001f90
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fa8
	ldr x1, =check_data6
	ldr x2, =0x00001faa
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
