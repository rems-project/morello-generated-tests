.section data0, #alloc, #write
	.byte 0x04, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
	.zero 32
	.byte 0x30, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x04, 0x10
.data
check_data3:
	.byte 0xa0, 0x7c, 0xff, 0xa2, 0xff, 0x23, 0x3e, 0x78, 0x3c, 0x00, 0xc3, 0xc2, 0x3f, 0x52, 0xc1, 0xc2
	.byte 0x1d, 0x80, 0xd6, 0xc2, 0xc1, 0x89, 0xde, 0xc2, 0xfd, 0x07, 0x48, 0x78, 0x20, 0x10, 0xc0, 0xc2
	.byte 0xde, 0x37, 0x1a, 0x79, 0x2c, 0xfd, 0xa9, 0xa2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400000000000000000000000
	/* C5 */
	.octa 0x1000
	/* C9 */
	.octa 0x1030
	/* C12 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x204d20170000000000000001
	/* C22 */
	.octa 0x1
	/* C30 */
	.octa 0x200200000000000000001004
final_cap_values:
	/* C0 */
	.octa 0x20100000
	/* C1 */
	.octa 0x204d20170000000000000001
	/* C5 */
	.octa 0x1000
	/* C9 */
	.octa 0x1030
	/* C12 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x204d20170000000000000001
	/* C22 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200200000000000000001004
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2ff7ca0 // CASA-C.R-C Ct:0 Rn:5 11111:11111 R:0 Cs:31 1:1 L:1 1:1 10100010:10100010
	.inst 0x783e23ff // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c3003c // SCBNDS-C.CR-C Cd:28 Cn:1 000:000 opc:00 0:0 Rm:3 11000010110:11000010110
	.inst 0xc2c1523f // CFHI-R.C-C Rd:31 Cn:17 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2d6801d // SCTAG-C.CR-C Cd:29 Cn:0 000:000 0:0 10:10 Rm:22 11000010110:11000010110
	.inst 0xc2de89c1 // CHKSSU-C.CC-C Cd:1 Cn:14 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0x784807fd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:31 01:01 imm9:010000000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c01020 // GCBASE-R.C-C Rd:0 Cn:1 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x791a37de // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:011010001101 opc:00 111001:111001 size:01
	.inst 0xa2a9fd2c // CASL-C.R-C Ct:12 Rn:9 11111:11111 R:1 Cs:9 1:1 L:0 1:1 10100010:10100010
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc240150e // ldr c14, [x8, #5]
	.inst 0xc2401916 // ldr c22, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c8 // ldr c8, [c6, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826010c8 // ldr c8, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x6, #0xf
	and x8, x8, x6
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400106 // ldr c6, [x8, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400d06 // ldr c6, [x8, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401106 // ldr c6, [x8, #4]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401506 // ldr c6, [x8, #5]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401906 // ldr c6, [x8, #6]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401d06 // ldr c6, [x8, #7]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402106 // ldr c6, [x8, #8]
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d1e
	ldr x1, =check_data2
	ldr x2, =0x00001d20
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
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
