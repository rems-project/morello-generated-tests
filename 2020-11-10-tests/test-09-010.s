.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xdb, 0x9b, 0x96, 0x28, 0x32, 0xf4, 0x97, 0x82, 0x94, 0xee, 0x6f, 0x82, 0x55, 0xc9, 0x4d, 0xf2
	.byte 0xfa, 0xdb, 0x51, 0x78, 0x7b, 0xbc, 0xd3, 0xc2, 0x61, 0x81, 0x82, 0x9a, 0x9f, 0x89, 0x42, 0x11
	.byte 0x20, 0x70, 0xc0, 0xc2, 0x00, 0x0a, 0xd4, 0x1a, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000002007200700000000004e1000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000001
	/* C20 */
	.octa 0x80000000600000020000000000001010
	/* C23 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1400
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000001
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x8000000000001
	/* C23 */
	.octa 0x1000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x14b4
initial_SP_EL3_value:
	.octa 0x2009
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000044040a4a00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28969bdb // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:27 Rn:30 Rt2:00110 imm7:0101101 L:0 1010001:1010001 opc:00
	.inst 0x8297f432 // ALDRSB-R.RRB-64 Rt:18 Rn:1 opc:01 S:1 option:111 Rm:23 0:0 L:0 100000101:100000101
	.inst 0x826fee94 // ALDR-R.RI-64 Rt:20 Rn:20 op:11 imm9:011111110 L:1 1000001001:1000001001
	.inst 0xf24dc955 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:10 imms:110010 immr:001101 N:1 100100:100100 opc:11 sf:1
	.inst 0x7851dbfa // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:26 Rn:31 10:10 imm9:100011101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2d3bc7b // CSEL-C.CI-C Cd:27 Cn:3 11:11 cond:1011 Cm:19 11000010110:11000010110
	.inst 0x9a828161 // csel:aarch64/instrs/integer/conditional/select Rd:1 Rn:11 o2:0 0:0 cond:1000 Rm:2 011010100:011010100 op:0 sf:1
	.inst 0x1142899f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:12 imm12:000010100010 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c07020 // GCOFF-R.C-C Rd:0 Cn:1 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x1ad40a00 // udiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:16 o1:0 00001:00001 Rm:20 0011010110:0011010110 sf:0
	.inst 0xc2c210a0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2400c94 // ldr c20, [x4, #3]
	.inst 0xc2401097 // ldr c23, [x4, #4]
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a4 // ldr c4, [c5, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826010a4 // ldr c4, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x5, #0xf
	and x4, x4, x5
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400085 // ldr c5, [x4, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2400c85 // ldr c5, [x4, #3]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401085 // ldr c5, [x4, #4]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2401485 // ldr c5, [x4, #5]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401885 // ldr c5, [x4, #6]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401c85 // ldr c5, [x4, #7]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402085 // ldr c5, [x4, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001408
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f26
	ldr x1, =check_data2
	ldr x2, =0x00001f28
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
	ldr x0, =0x004e2000
	ldr x1, =check_data4
	ldr x2, =0x004e2001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
