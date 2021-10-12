.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0x3b, 0x62, 0xd5, 0x38, 0xf4, 0x48, 0x7f, 0x78, 0x02, 0x30, 0xc0, 0xc2, 0x63, 0x62, 0x50, 0x82
	.byte 0xbe, 0x32, 0x5e, 0x78, 0xe1, 0x33, 0xc2, 0xc2, 0xc1, 0x33, 0xc2, 0xc2, 0x00, 0x0a, 0x20, 0x2b
	.byte 0xbe, 0x73, 0xc0, 0xc2, 0xdf, 0x0f, 0xc0, 0xda, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200100050000000000000000
	/* C3 */
	.octa 0x100000000000000000000000000
	/* C7 */
	.octa 0x410000
	/* C17 */
	.octa 0x40c02c
	/* C19 */
	.octa 0x4c000000000700040000000000000040
	/* C21 */
	.octa 0x41001d
	/* C29 */
	.octa 0x100070000000000000000
final_cap_values:
	/* C2 */
	.octa 0xffffffffffffffff
	/* C3 */
	.octa 0x100000000000000000000000000
	/* C7 */
	.octa 0x410000
	/* C17 */
	.octa 0x40c02c
	/* C19 */
	.octa 0x4c000000000700040000000000000040
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x41001d
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x100070000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000300011000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002007a00f0000000000408001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38d5623b // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:17 00:00 imm9:101010110 0:0 opc:11 111000:111000 size:00
	.inst 0x787f48f4 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:20 Rn:7 10:10 S:0 option:010 Rm:31 1:1 opc:01 111000:111000 size:01
	.inst 0xc2c03002 // GCLEN-R.C-C Rd:2 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x82506263 // ASTR-C.RI-C Ct:3 Rn:19 op:00 imm9:100000110 L:0 1000001001:1000001001
	.inst 0x785e32be // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:21 00:00 imm9:111100011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c233e1 // CHKTGD-C-C 00001:00001 Cn:31 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c233c1 // CHKTGD-C-C 00001:00001 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x2b200a00 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:16 imm3:010 option:000 Rm:0 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c073be // GCOFF-R.C-C Rd:30 Cn:29 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xdac00fdf // rev:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:30 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c91 // ldr c17, [x4, #3]
	.inst 0xc2401093 // ldr c19, [x4, #4]
	.inst 0xc2401495 // ldr c21, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603324 // ldr c4, [c25, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601324 // ldr c4, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x25, #0x3
	and x4, x4, x25
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400099 // ldr c25, [x4, #0]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400499 // ldr c25, [x4, #1]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400899 // ldr c25, [x4, #2]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2400c99 // ldr c25, [x4, #3]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401099 // ldr c25, [x4, #4]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401499 // ldr c25, [x4, #5]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2401899 // ldr c25, [x4, #6]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401c99 // ldr c25, [x4, #7]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402099 // ldr c25, [x4, #8]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402499 // ldr c25, [x4, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a0
	ldr x1, =check_data0
	ldr x2, =0x000010b0
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
	ldr x0, =0x0040bf82
	ldr x1, =check_data2
	ldr x2, =0x0040bf83
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410000
	ldr x1, =check_data3
	ldr x2, =0x00410002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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

	.balign 128
vector_table:
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
