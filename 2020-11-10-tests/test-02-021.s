.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xff, 0x01, 0x00
.data
check_data0:
	.byte 0x80, 0xff, 0x01
.data
check_data1:
	.byte 0xfe, 0xa3, 0xd7, 0xc2, 0xbf, 0x2a, 0x68, 0xa9, 0xbe, 0x1e, 0x3f, 0x8a, 0x42, 0x10, 0xba, 0x78
	.byte 0x5b, 0xbd, 0x26, 0xf0, 0x03, 0x73, 0x22, 0x38, 0x09, 0x7c, 0x02, 0x48, 0x81, 0xfb, 0xb9, 0xf8
	.byte 0x22, 0x7c, 0x5f, 0x48, 0xc9, 0x4f, 0xa9, 0x8a, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000004ffffc
	/* C1 */
	.octa 0x800000000001000500000000004ffffc
	/* C2 */
	.octa 0xc0000000000100050000000000001ffc
	/* C21 */
	.octa 0x800000000001000500000000004c0038
	/* C24 */
	.octa 0xc0000000000100050000000000001ffe
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000004ffffc
	/* C1 */
	.octa 0x800000000001000500000000004ffffc
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1
	/* C10 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000001000500000000004c0038
	/* C24 */
	.octa 0xc0000000000100050000000000001ffe
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x80056007010000002d7b1000
	/* C30 */
	.octa 0x4c0038
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8005600700ffffffe0006000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d7a3fe // CLRPERM-C.CR-C Cd:30 Cn:31 000:000 1:1 10:10 Rm:23 11000010110:11000010110
	.inst 0xa9682abf // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:21 Rt2:01010 imm7:1010000 L:1 1010010:1010010 opc:10
	.inst 0x8a3f1ebe // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:21 imm6:000111 Rm:31 N:1 shift:00 01010:01010 opc:00 sf:1
	.inst 0x78ba1042 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:2 00:00 opc:001 0:0 Rs:26 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf026bd5b // ADRDP-C.ID-C Rd:27 immhi:010011010111101010 P:0 10000:10000 immlo:11 op:1
	.inst 0x38227303 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:24 00:00 opc:111 0:0 Rs:2 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x48027c09 // stxrh:aarch64/instrs/memory/exclusive/single Rt:9 Rn:0 Rt2:11111 o0:0 Rs:2 0:0 L:0 0010000:0010000 size:01
	.inst 0xf8b9fb81 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:28 10:10 S:1 option:111 Rm:25 1:1 opc:10 111000:111000 size:11
	.inst 0x485f7c22 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x8aa94fc9 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:30 imm6:010011 Rm:9 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2c211e0
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2400d95 // ldr c21, [x12, #3]
	.inst 0xc2401198 // ldr c24, [x12, #4]
	.inst 0xc240159a // ldr c26, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ec // ldr c12, [c15, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ec // ldr c12, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018f // ldr c15, [x12, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240058f // ldr c15, [x12, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240198f // ldr c15, [x12, #6]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc2401d8f // ldr c15, [x12, #7]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240218f // ldr c15, [x12, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240258f // ldr c15, [x12, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffc
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004bfeb8
	ldr x1, =check_data2
	ldr x2, =0x004bfec8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
