.section data0, #alloc, #write
	.zero 2064
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0xc0, 0x42, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 2016
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0xc0, 0x42, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x06, 0x10, 0xc7, 0xc2, 0x25, 0xfc, 0x9f, 0x48, 0x14, 0x10, 0x6c, 0xe2, 0xc6, 0x11, 0xc4, 0xc2
.data
check_data6:
	.byte 0x42, 0xf0, 0x66, 0xf2, 0x5c, 0xa0, 0x83, 0x38, 0x61, 0xd0, 0xe6, 0xc2, 0x35, 0x98, 0xff, 0xc2
	.byte 0x82, 0x72, 0x03, 0x12, 0x5e, 0xc0, 0xc5, 0x78, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000002006001700000000000017d1
	/* C1 */
	.octa 0x48
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x900000005a100a110000000000001800
	/* C20 */
	.octa 0x40
final_cap_values:
	/* C0 */
	.octa 0x400000002006001700000000000017d1
	/* C1 */
	.octa 0x3600000000000000
	/* C2 */
	.octa 0x40
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x900000005a100a110000000000001800
	/* C20 */
	.octa 0x40
	/* C21 */
	.octa 0x1
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005001100200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71006 // RRLEN-R.R-C Rd:6 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x489ffc25 // stlrh:aarch64/instrs/memory/ordered Rt:5 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe26c1014 // ASTUR-V.RI-H Rt:20 Rn:0 op2:00 imm9:011000001 V:1 op1:01 11100010:11100010
	.inst 0xc2c411c6 // LDPBR-C.C-C Ct:6 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 12
	.inst 0xf266f042 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:2 imms:111100 immr:100110 N:1 100100:100100 opc:11 sf:1
	.inst 0x3883a05c // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:2 00:00 imm9:000111010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2e6d061 // EORFLGS-C.CI-C Cd:1 Cn:3 0:0 10:10 imm8:00110110 11000010111:11000010111
	.inst 0xc2ff9835 // SUBS-R.CC-C Rd:21 Cn:1 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x12037282 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:20 imms:011100 immr:000011 N:0 100100:100100 opc:00 sf:0
	.inst 0x78c5c05e // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:001011100 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c21320
	.zero 1048520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d63 // ldr c3, [x11, #3]
	.inst 0xc2401165 // ldr c5, [x11, #4]
	.inst 0xc240156e // ldr c14, [x11, #5]
	.inst 0xc2401974 // ldr c20, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332b // ldr c11, [c25, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260132b // ldr c11, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x25, #0xf
	and x11, x11, x25
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400179 // ldr c25, [x11, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400579 // ldr c25, [x11, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400979 // ldr c25, [x11, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400d79 // ldr c25, [x11, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401579 // ldr c25, [x11, #5]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2401979 // ldr c25, [x11, #6]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401d79 // ldr c25, [x11, #7]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402179 // ldr c25, [x11, #8]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2402579 // ldr c25, [x11, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402979 // ldr c25, [x11, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x25, v20.d[0]
	cmp x11, x25
	b.ne comparison_fail
	ldr x11, =0x0
	mov x25, v20.d[1]
	cmp x11, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103c
	ldr x1, =check_data0
	ldr x2, =0x0000103d
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000104a
	ldr x1, =check_data1
	ldr x2, =0x0000104c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000109e
	ldr x1, =check_data2
	ldr x2, =0x000010a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001892
	ldr x1, =check_data4
	ldr x2, =0x00001894
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040001c
	ldr x1, =check_data6
	ldr x2, =0x00400038
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
