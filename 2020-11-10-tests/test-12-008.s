.section data0, #alloc, #write
	.zero 256
	.byte 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x8f
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x10, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x45, 0x16, 0x80, 0x9a, 0xc1, 0x13, 0x20, 0x38, 0x04, 0x92, 0x66, 0x91, 0x95, 0xbd, 0x1b, 0xb8
	.byte 0x5f, 0xfc, 0xa0, 0x48, 0xb1, 0xba, 0x08, 0xa2, 0x1f, 0x39, 0xbf, 0xaa, 0x30, 0xb0, 0xc5, 0xc2
	.byte 0x4f, 0x33, 0x7f, 0x88, 0xde, 0x13, 0xc0, 0xda, 0x20, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0x02, 0x00
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xc00000004100d0040000000000400030
	/* C12 */
	.octa 0x4000000049820fae0000000000002031
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000401200140000000000001010
	/* C26 */
	.octa 0x800000000001000500000000004ffff0
	/* C30 */
	.octa 0xc0000000000700030000000000001100
final_cap_values:
	/* C0 */
	.octa 0x2
	/* C1 */
	.octa 0x8f
	/* C2 */
	.octa 0xc00000004100d0040000000000400030
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x20008000402c0000000000000000008f
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000401200140000000000001010
	/* C26 */
	.octa 0x800000000001000500000000004ffff0
	/* C30 */
	.octa 0x33
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402c00000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a801645 // csinc:aarch64/instrs/integer/conditional/select Rd:5 Rn:18 o2:1 0:0 cond:0001 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0x382013c1 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x91669204 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:4 Rn:16 imm12:100110100100 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xb81bbd95 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:12 11:11 imm9:110111011 0:0 opc:00 111000:111000 size:10
	.inst 0x48a0fc5f // cash:aarch64/instrs/memory/atomicops/cas/single Rt:31 Rn:2 11111:11111 o0:1 Rs:0 1:1 L:0 0010001:0010001 size:01
	.inst 0xa208bab1 // STTR-C.RIB-C Ct:17 Rn:21 10:10 imm9:010001011 0:0 opc:00 10100010:10100010
	.inst 0xaabf391f // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:8 imm6:001110 Rm:31 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c5b030 // CVTP-C.R-C Cd:16 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x887f334f // ldxp:aarch64/instrs/memory/exclusive/pair Rt:15 Rn:26 Rt2:01100 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xdac013de // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:30 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c21120
	.zero 4
	.inst 0x00000002
	.zero 1048524
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2400f91 // ldr c17, [x28, #3]
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260113c // ldr c28, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x9, #0x4
	and x28, x28, x9
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400389 // ldr c9, [x28, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400789 // ldr c9, [x28, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b89 // ldr c9, [x28, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401389 // ldr c9, [x28, #4]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401789 // ldr c9, [x28, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401b89 // ldr c9, [x28, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401f89 // ldr c9, [x28, #7]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402389 // ldr c9, [x28, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402789 // ldr c9, [x28, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001101
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000018c0
	ldr x1, =check_data1
	ldr x2, =0x000018d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fec
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400030
	ldr x1, =check_data4
	ldr x2, =0x00400032
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
