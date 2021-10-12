.section data0, #alloc, #write
	.zero 1104
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2976
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x10
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x1e, 0x00, 0x4d, 0x78, 0xcf, 0x59, 0x80, 0x82, 0x4c, 0x18, 0x55, 0x38, 0x8a, 0x25, 0xd6, 0x9a
	.byte 0x92, 0x14, 0x5b, 0x79, 0xde, 0x7f, 0x9f, 0x08, 0x27, 0x54, 0x41, 0x02, 0xe7, 0x00, 0x01, 0x3a
	.byte 0xd6, 0x63, 0x18, 0xa8, 0x5e, 0x08, 0xc9, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1382
	/* C1 */
	.octa 0x8007a004007ffffffffc0000
	/* C2 */
	.octa 0x2000
	/* C4 */
	.octa 0x278
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000408884
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1382
	/* C1 */
	.octa 0x8007a004007ffffffffc0000
	/* C2 */
	.octa 0x2000
	/* C4 */
	.octa 0x278
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000408884
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000044100e840000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784d001e // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:011010000 0:0 opc:01 111000:111000 size:01
	.inst 0x828059cf // ALDRSH-R.RRB-64 Rt:15 Rn:14 opc:10 S:1 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x3855184c // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:2 10:10 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0x9ad6258a // lsrv:aarch64/instrs/integer/shift/variable Rd:10 Rn:12 op2:01 0010:0010 Rm:22 0011010110:0011010110 sf:1
	.inst 0x795b1492 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:4 imm12:011011000101 opc:01 111001:111001 size:01
	.inst 0x089f7fde // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x02415427 // ADD-C.CIS-C Cd:7 Cn:1 imm12:000001010101 sh:1 A:0 00000010:00000010
	.inst 0x3a0100e7 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:7 000000:000000 Rm:1 11010000:11010000 S:1 op:0 sf:0
	.inst 0xa81863d6 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:22 Rn:30 Rt2:11000 imm7:0110000 L:0 1010000:1010000 opc:10
	.inst 0xc2c9085e // SEAL-C.CC-C Cd:30 Cn:2 0010:0010 opc:00 Cm:9 11000010110:11000010110
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e24 // ldr c4, [x17, #3]
	.inst 0xc2401229 // ldr c9, [x17, #4]
	.inst 0xc240162e // ldr c14, [x17, #5]
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2401e38 // ldr c24, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d1 // ldr c17, [c6, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x826010d1 // ldr c17, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x6, #0xf
	and x17, x17, x6
	cmp x17, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400226 // ldr c6, [x17, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400626 // ldr c6, [x17, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400e26 // ldr c6, [x17, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401226 // ldr c6, [x17, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401626 // ldr c6, [x17, #5]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401a26 // ldr c6, [x17, #6]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401e26 // ldr c6, [x17, #7]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2402226 // ldr c6, [x17, #8]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2402626 // ldr c6, [x17, #9]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2402a26 // ldr c6, [x17, #10]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2402e26 // ldr c6, [x17, #11]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2403226 // ldr c6, [x17, #12]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001002
	ldr x1, =check_data1
	ldr x2, =0x00001004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001180
	ldr x1, =check_data2
	ldr x2, =0x00001190
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001452
	ldr x1, =check_data3
	ldr x2, =0x00001454
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f51
	ldr x1, =check_data4
	ldr x2, =0x00001f52
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040af88
	ldr x1, =check_data6
	ldr x2, =0x0040af8a
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
