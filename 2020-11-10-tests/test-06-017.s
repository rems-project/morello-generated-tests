.section data0, #alloc, #write
	.zero 1024
	.byte 0x98, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x98, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x60, 0x03, 0x3f, 0xd6
.data
check_data4:
	.byte 0x44, 0x60, 0x41, 0xfa, 0x80, 0x35, 0x81, 0x1a, 0xfc, 0xc7, 0x0e, 0xa2, 0xc0, 0x24, 0x8a, 0xe2
	.byte 0x54, 0x10, 0xc5, 0xc2, 0x22, 0xc2, 0x3f, 0xa2, 0x45, 0x18, 0x56, 0x7a, 0x49, 0x8c, 0xcd, 0xe2
	.byte 0xe2, 0xe3, 0xc1, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x4fff56
	/* C17 */
	.octa 0x80100000580008020000000000001400
	/* C27 */
	.octa 0x420410
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x4000000040020003ff00000000001ec0
	/* C6 */
	.octa 0x4fff56
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x80100000580008020000000000001400
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x420410
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000880100060000000000400005
initial_SP_EL3_value:
	.octa 0x40000000400200030000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0360 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:27 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 132108
	.inst 0xfa416044 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0100 0:0 Rn:2 00:00 cond:0110 Rm:1 111010010:111010010 op:1 sf:1
	.inst 0x1a813580 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:12 o2:1 0:0 cond:0011 Rm:1 011010100:011010100 op:0 sf:0
	.inst 0xa20ec7fc // STR-C.RIAW-C Ct:28 Rn:31 01:01 imm9:011101100 0:0 opc:00 10100010:10100010
	.inst 0xe28a24c0 // ALDUR-R.RI-32 Rt:0 Rn:6 op2:01 imm9:010100010 V:0 op1:10 11100010:11100010
	.inst 0xc2c51054 // CVTD-R.C-C Rd:20 Cn:2 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xa23fc222 // LDAPR-C.R-C Ct:2 Rn:17 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x7a561845 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:2 10:10 cond:0001 imm5:10110 111010010:111010010 op:1 sf:0
	.inst 0xe2cd8c49 // ALDUR-C.RI-C Ct:9 Rn:2 op2:11 imm9:011011000 V:0 op1:11 11100010:11100010
	.inst 0xc2c1e3e2 // SCFLGS-C.CR-C Cd:2 Cn:31 111000:111000 Rm:1 11000010110:11000010110
	.inst 0xc2c21300
	.zero 916424
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
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc240127b // ldr c27, [x19, #4]
	.inst 0xc240167c // ldr c28, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x10000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0x88
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603313 // ldr c19, [c24, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601313 // ldr c19, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0xf
	and x19, x19, x24
	cmp x19, #0x5
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400278 // ldr c24, [x19, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400678 // ldr c24, [x19, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a78 // ldr c24, [x19, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400e78 // ldr c24, [x19, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401278 // ldr c24, [x19, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401a78 // ldr c24, [x19, #6]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402278 // ldr c24, [x19, #8]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402678 // ldr c24, [x19, #9]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e70
	ldr x1, =check_data2
	ldr x2, =0x00001e80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00420410
	ldr x1, =check_data4
	ldr x2, =0x00420438
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
