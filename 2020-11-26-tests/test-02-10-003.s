.section data0, #alloc, #write
	.byte 0xfa, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfa, 0x08
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xdd, 0x7f, 0x5f, 0x88, 0x03, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x1d, 0x34, 0x90, 0x38, 0x9c, 0xff, 0xf0, 0x48, 0xe0, 0x73, 0xc2, 0xc2, 0x3f, 0x20, 0x19, 0xf8
	.byte 0xb5, 0xc4, 0x4b, 0x92, 0xa0, 0xeb, 0xc0, 0xc2, 0xfd, 0x83, 0x05, 0x1b, 0x2d, 0x52, 0xbe, 0x78
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000900f401f0000000000407fe8
	/* C1 */
	.octa 0x40000000000100050000000000002006
	/* C16 */
	.octa 0xffff
	/* C17 */
	.octa 0xc0000000000300050000000000001000
	/* C28 */
	.octa 0x4ffffc
	/* C30 */
	.octa 0x18f8
final_cap_values:
	/* C0 */
	.octa 0x407eeb000000000000001d
	/* C1 */
	.octa 0x40000000000100050000000000002006
	/* C13 */
	.octa 0x8fa
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0xc0000000000300050000000000001000
	/* C28 */
	.octa 0x4ffffc
	/* C29 */
	.octa 0x1d
	/* C30 */
	.octa 0x18f8
initial_RDDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000059090c8400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x885f7fdd // ldxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc2c25003 // RETR-C-C 00011:00011 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 32736
	.inst 0x3890341d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:0 01:01 imm9:100000011 0:0 opc:10 111000:111000 size:00
	.inst 0x48f0ff9c // cash:aarch64/instrs/memory/atomicops/cas/single Rt:28 Rn:28 11111:11111 o0:1 Rs:16 1:1 L:1 0010001:0010001 size:01
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xf819203f // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:110010010 0:0 opc:00 111000:111000 size:11
	.inst 0x924bc4b5 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:5 imms:110001 immr:001011 N:1 100100:100100 opc:00 sf:1
	.inst 0xc2c0eba0 // CTHI-C.CR-C Cd:0 Cn:29 1010:1010 opc:11 Rm:0 11000010110:11000010110
	.inst 0x1b0583fd // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:31 Ra:0 o0:1 Rm:5 0011011000:0011011000 sf:0
	.inst 0x78be522d // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:17 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2c21280
	.zero 1015796
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
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d11 // ldr c17, [x8, #3]
	.inst 0xc240111c // ldr c28, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	ldr x8, =initial_RDDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28b4328 // msr RDDC_EL0, c8
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603288 // ldr c8, [c20, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601288 // ldr c8, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400114 // ldr c20, [x8, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400514 // ldr c20, [x8, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400914 // ldr c20, [x8, #2]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2400d14 // ldr c20, [x8, #3]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401114 // ldr c20, [x8, #4]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401514 // ldr c20, [x8, #5]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2401914 // ldr c20, [x8, #6]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2401d14 // ldr c20, [x8, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x000018f8
	ldr x1, =check_data1
	ldr x2, =0x000018fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f98
	ldr x1, =check_data2
	ldr x2, =0x00001fa0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407fe8
	ldr x1, =check_data4
	ldr x2, =0x0040800c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
