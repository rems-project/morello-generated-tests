.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x01, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc2, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0xc2, 0xc2
	.zero 912
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3088
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x01, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc2, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xe0, 0x68, 0xdd, 0x62, 0x22, 0x78, 0x7e, 0x38, 0xb9, 0x1e, 0xd3, 0x78, 0xc0, 0x57, 0x7f, 0x22
	.byte 0x21, 0x10, 0xc2, 0xc2, 0x80, 0x2e, 0xdf, 0x9a, 0xbe, 0x1b, 0x4b, 0x29, 0xd6, 0x42, 0xb0, 0xc2
	.byte 0xaf, 0x42, 0xdd, 0xc2, 0x00, 0x9b, 0xfd, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000000000004feffe
	/* C7 */
	.octa 0x1010
	/* C16 */
	.octa 0x80000000
	/* C21 */
	.octa 0x20af
	/* C22 */
	.octa 0x72004007fffff80000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0xfb4
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x8000000000000000004feffe
	/* C2 */
	.octa 0xc2
	/* C6 */
	.octa 0xffffe001
	/* C7 */
	.octa 0x13b0
	/* C15 */
	.octa 0xc2c20000400100000000000000000fb4
	/* C16 */
	.octa 0x80000000
	/* C21 */
	.octa 0xc2c2000040010000c2ffffffffffe001
	/* C22 */
	.octa 0x720040080000000000000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xffffc2c2
	/* C26 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C29 */
	.octa 0xfb4
	/* C30 */
	.octa 0xc2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x00000000000013c0
	.dword initial_cap_values + 96
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62dd68e0 // LDP-C.RIBW-C Ct:0 Rn:7 Ct2:11010 imm7:0111010 L:1 011000101:011000101
	.inst 0x387e7822 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:1 10:10 S:1 option:011 Rm:30 1:1 opc:01 111000:111000 size:00
	.inst 0x78d31eb9 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:25 Rn:21 11:11 imm9:100110001 0:0 opc:11 111000:111000 size:01
	.inst 0x227f57c0 // LDXP-C.R-C Ct:0 Rn:30 Ct2:10101 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x9adf2e80 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:20 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x294b1bbe // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:29 Rt2:00110 imm7:0010110 L:1 1010010:1010010 opc:00
	.inst 0xc2b042d6 // ADD-C.CRI-C Cd:22 Cn:22 imm3:000 option:010 Rm:16 11000010101:11000010101
	.inst 0xc2dd42af // SCVALUE-C.CR-C Cd:15 Cn:21 000:000 opc:10 0:0 Rm:29 11000010110:11000010110
	.inst 0xc2fd9b00 // SUBS-R.CC-C Rd:0 Cn:24 100110:100110 Cm:29 11000010111:11000010111
	.inst 0xc2c21140
	.zero 1048528
	.inst 0x00c20000
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
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2400a50 // ldr c16, [x18, #2]
	.inst 0xc2400e55 // ldr c21, [x18, #3]
	.inst 0xc2401256 // ldr c22, [x18, #4]
	.inst 0xc2401658 // ldr c24, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603152 // ldr c18, [c10, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601152 // ldr c18, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	mov x10, #0xf
	and x18, x18, x10
	cmp x18, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024a // ldr c10, [x18, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a4a // ldr c10, [x18, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240124a // ldr c10, [x18, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240164a // ldr c10, [x18, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401a4a // ldr c10, [x18, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401e4a // ldr c10, [x18, #7]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240224a // ldr c10, [x18, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240264a // ldr c10, [x18, #9]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2402a4a // ldr c10, [x18, #10]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2402e4a // ldr c10, [x18, #11]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240324a // ldr c10, [x18, #12]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240364a // ldr c10, [x18, #13]
	.inst 0xc2caa7c1 // chkeq c30, c10
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
	ldr x0, =0x000013b0
	ldr x1, =check_data1
	ldr x2, =0x000013d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001fe2
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
