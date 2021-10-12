.section data0, #alloc, #write
	.byte 0x1f, 0x50, 0x27, 0xf8, 0x9f, 0xff, 0x82, 0xf1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x1f, 0x50, 0x27, 0xf8, 0x1d, 0xff, 0x82, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xe0, 0xfd, 0x80, 0xeb, 0xca, 0x7f, 0xa1, 0xa2, 0xc0, 0x7c, 0xdf, 0x08, 0xe0, 0x33, 0xc1, 0xc2
	.byte 0xfe, 0xa2, 0x9c, 0x38, 0xc0, 0x11, 0xc0, 0xc2, 0x7e, 0x57, 0xd7, 0x82, 0xe1, 0x03, 0x09, 0x3a
	.byte 0x1f, 0x10, 0x27, 0xf8, 0x9d, 0x59, 0x82, 0xf0, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffffffffffff0e7d006007d8afe0
	/* C6 */
	.octa 0x4ffffe
	/* C7 */
	.octa 0x8100008200000000
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x7080600ffffffffffc001
	/* C23 */
	.octa 0x4ffffd
	/* C27 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C6 */
	.octa 0x4ffffe
	/* C7 */
	.octa 0x8100008200000000
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x7080600ffffffffffc001
	/* C23 */
	.octa 0x4ffffd
	/* C27 */
	.octa 0x80000000000100050000000000000001
	/* C29 */
	.octa 0xffffffff04f33000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb80fde0 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:15 imm6:111111 Rm:0 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xa2a17fca // CAS-C.R-C Ct:10 Rn:30 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0x08df7cc0 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c133e0 // GCFLGS-R.C-C Rd:0 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x389ca2fe // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:23 00:00 imm9:111001010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c011c0 // GCBASE-R.C-C Rd:0 Cn:14 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x82d7577e // ALDRSB-R.RRB-32 Rt:30 Rn:27 opc:01 S:1 option:010 Rm:23 0:0 L:1 100000101:100000101
	.inst 0x3a0903e1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:31 000000:000000 Rm:9 11010000:11010000 S:1 op:0 sf:0
	.inst 0xf827101f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:001 o3:0 Rs:7 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xf082599d // ADRP-C.IP-C Rd:29 immhi:000001001011001100 P:1 10000:10000 immlo:11 op:1
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
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc2401497 // ldr c23, [x4, #5]
	.inst 0xc240189b // ldr c27, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x8
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
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400085 // ldr c5, [x4, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400c85 // ldr c5, [x4, #3]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401085 // ldr c5, [x4, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401485 // ldr c5, [x4, #5]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401885 // ldr c5, [x4, #6]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2401c85 // ldr c5, [x4, #7]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402085 // ldr c5, [x4, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x004fffc7
	ldr x1, =check_data2
	ldr x2, =0x004fffc8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
