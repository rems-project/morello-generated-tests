.section data0, #alloc, #write
	.byte 0xc9, 0xf2, 0x3f, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc9, 0xf2, 0xc9, 0x81
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xbe, 0xbb, 0x83, 0x38, 0x6e, 0x7c, 0x5f, 0x08, 0xde, 0x53, 0x7d, 0xb8, 0x3d, 0xfc, 0x5f, 0x88
	.byte 0xfe, 0x4a, 0x3d, 0x38, 0xc0, 0x17, 0x7e, 0x4a, 0xc5, 0xd3, 0xc1, 0xc2, 0x01, 0xcc, 0xd9, 0xf0
	.byte 0xbd, 0x33, 0xc0, 0xc2, 0x3c, 0xe8, 0x66, 0xa2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x02, 0x80, 0x40, 0x2e
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4d85a0
	/* C3 */
	.octa 0x3e6
	/* C6 */
	.octa 0x4c27d7e0
	/* C23 */
	.octa 0xffffffffd1bf8000
	/* C29 */
	.octa 0x41efc8
final_cap_values:
	/* C0 */
	.octa 0x7ac9f2a0
	/* C1 */
	.octa 0xffffffffb3d83000
	/* C3 */
	.octa 0x3e6
	/* C5 */
	.octa 0x813ff2c9
	/* C6 */
	.octa 0x4c27d7e0
	/* C14 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffd1bf8000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x813ff2c9
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000101600170000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3883bbbe // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:29 10:10 imm9:000111011 0:0 opc:10 111000:111000 size:00
	.inst 0x085f7c6e // ldxrb:aarch64/instrs/memory/exclusive/single Rt:14 Rn:3 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xb87d53de // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x885ffc3d // ldaxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x383d4afe // strb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:23 10:10 S:0 option:010 Rm:29 1:1 opc:00 111000:111000 size:00
	.inst 0x4a7e17c0 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:30 imm6:000101 Rm:30 N:1 shift:01 01010:01010 opc:10 sf:0
	.inst 0xc2c1d3c5 // CPY-C.C-C Cd:5 Cn:30 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xf0d9cc01 // ADRP-C.IP-C Rd:1 immhi:101100111001100000 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2c033bd // GCLEN-R.C-C Rd:29 Cn:29 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xa266e83c // LDR-C.RRB-C Ct:28 Rn:1 10:10 S:0 option:111 Rm:6 1:1 opc:01 10100010:10100010
	.inst 0xc2c211e0
	.zero 890228
	.inst 0x2e408002
	.zero 158300
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2400b26 // ldr c6, [x25, #2]
	.inst 0xc2400f37 // ldr c23, [x25, #3]
	.inst 0xc240133d // ldr c29, [x25, #4]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851037
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f9 // ldr c25, [c15, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826011f9 // ldr c25, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032f // ldr c15, [x25, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240072f // ldr c15, [x25, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400b2f // ldr c15, [x25, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400f2f // ldr c15, [x25, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240132f // ldr c15, [x25, #4]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240172f // ldr c15, [x25, #5]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401b2f // ldr c15, [x25, #6]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc2401f2f // ldr c15, [x25, #7]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240232f // ldr c15, [x25, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240272f // ldr c15, [x25, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x000013e6
	ldr x1, =check_data1
	ldr x2, =0x000013e7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e0
	ldr x1, =check_data2
	ldr x2, =0x000017f0
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
	ldr x0, =0x00420003
	ldr x1, =check_data4
	ldr x2, =0x00420004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004d95a0
	ldr x1, =check_data5
	ldr x2, =0x004d95a4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
