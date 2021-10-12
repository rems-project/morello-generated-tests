.section data0, #alloc, #write
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x02, 0x00, 0x81
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x80, 0x80, 0x01, 0x00, 0x01
.data
check_data4:
	.byte 0x1e, 0x3c, 0x00, 0x1b, 0xa0, 0x33, 0xc7, 0xc2, 0xdf, 0x73, 0x36, 0x78, 0xad, 0xe2, 0x0e, 0xf9
	.byte 0xd0, 0xc3, 0x4a, 0xd1, 0x5e, 0xe8, 0x9c, 0x38, 0x42, 0x10, 0xe1, 0xf8, 0x53, 0xfc, 0x9f, 0x08
	.byte 0x21, 0x04, 0x62, 0x82, 0xff, 0x43, 0xf6, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000060040004000000000040fffe
	/* C2 */
	.octa 0x1100
	/* C13 */
	.octa 0x100018080000000
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x81
	/* C21 */
	.octa 0x80
	/* C22 */
	.octa 0x8000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1002
	/* C13 */
	.octa 0x100018080000000
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0xffffffffffd51000
	/* C19 */
	.octa 0x81
	/* C21 */
	.octa 0x80
	/* C22 */
	.octa 0x8000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b003c1e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:0 Ra:15 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc2c733a0 // RRMASK-R.R-C Rd:0 Rn:29 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x783673df // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf90ee2ad // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:21 imm12:001110111000 opc:00 111001:111001 size:11
	.inst 0xd14ac3d0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:30 imm12:001010110000 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x389ce85e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:2 10:10 imm9:111001110 0:0 opc:10 111000:111000 size:00
	.inst 0xf8e11042 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:2 00:00 opc:001 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x089ffc53 // stlrb:aarch64/instrs/memory/ordered Rt:19 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x82620421 // ALDRB-R.RI-B Rt:1 Rn:1 op:01 imm9:000100000 L:1 1000001001:1000001001
	.inst 0x38f643ff // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:100 0:0 Rs:22 1:1 R:1 A:1 111000:111000 size:00
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f6d // ldr c13, [x27, #3]
	.inst 0xc240136f // ldr c15, [x27, #4]
	.inst 0xc2401773 // ldr c19, [x27, #5]
	.inst 0xc2401b75 // ldr c21, [x27, #6]
	.inst 0xc2401f76 // ldr c22, [x27, #7]
	.inst 0xc240237d // ldr c29, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319b // ldr c27, [c12, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260119b // ldr c27, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036c // ldr c12, [x27, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240076c // ldr c12, [x27, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b6c // ldr c12, [x27, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f6c // ldr c12, [x27, #3]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc240176c // ldr c12, [x27, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401b6c // ldr c12, [x27, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401f6c // ldr c12, [x27, #7]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc240236c // ldr c12, [x27, #8]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240276c // ldr c12, [x27, #9]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402b6c // ldr c12, [x27, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ce
	ldr x1, =check_data1
	ldr x2, =0x000010cf
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e40
	ldr x1, =check_data3
	ldr x2, =0x00001e48
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
	ldr x0, =0x0041001e
	ldr x1, =check_data5
	ldr x2, =0x0041001f
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
