.section data0, #alloc, #write
	.byte 0x22, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x08, 0xff, 0xff, 0xff
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x08, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xdf, 0x7f, 0xdf, 0xc8, 0x5e, 0x00, 0x00, 0xba, 0xe2, 0x53, 0x62, 0x38, 0xff, 0x13, 0x24, 0xb8
	.byte 0x42, 0x72, 0x31, 0x78, 0x9f, 0x0d, 0xa8, 0x62, 0x01, 0xc4, 0x00, 0xab, 0x3f, 0xec, 0xe1, 0xca
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x01, 0x84, 0xca, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1613fed008000000001c001
	/* C2 */
	.octa 0x8
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x600120010080000000002001
	/* C12 */
	.octa 0x2000
	/* C17 */
	.octa 0x8000
	/* C18 */
	.octa 0x1200
	/* C30 */
	.octa 0x10d8
final_cap_values:
	/* C0 */
	.octa 0x1613fed008000000001c001
	/* C1 */
	.octa 0x808200000001c001
	/* C2 */
	.octa 0x8
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x600120010080000000002001
	/* C12 */
	.octa 0x1d00
	/* C17 */
	.octa 0x8000
	/* C18 */
	.octa 0x1200
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000090007008004feb6bee001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8df7fdf // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xba00005e // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:2 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0x386253e2 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:101 0:0 Rs:2 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xb82413ff // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:001 o3:0 Rs:4 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x78317242 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:18 00:00 opc:111 0:0 Rs:17 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x62a80d9f // STP-C.RIBW-C Ct:31 Rn:12 Ct2:00011 imm7:1010000 L:0 011000101:011000101
	.inst 0xab00c401 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:0 imm6:110001 Rm:0 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0xcae1ec3f // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:111011 Rm:1 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2ca8401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:10 11000010110:11000010110
	.inst 0xc2c21280
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc24015ec // ldr c12, [x15, #5]
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2401df2 // ldr c18, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103d
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328f // ldr c15, [c20, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x20, #0xf
	and x15, x15, x20
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f4 // ldr c20, [x15, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc24021f4 // ldr c20, [x15, #8]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d8
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001202
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d00
	ldr x1, =check_data3
	ldr x2, =0x00001d20
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
