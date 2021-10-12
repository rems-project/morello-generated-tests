.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x89, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x10, 0x00, 0x40, 0x00, 0x40, 0x00, 0x48
.data
check_data3:
	.byte 0x80, 0x3e, 0x0e, 0xb5, 0x14, 0xf0, 0xc0, 0xc2, 0x00, 0xa1, 0xd5, 0xc2, 0x0f, 0x88, 0x45, 0xfa
	.byte 0x2f, 0x92, 0x47, 0xc2, 0x1f, 0xd0, 0xc1, 0xc2, 0xde, 0x73, 0x09, 0xa2, 0x56, 0xa0, 0xc0, 0xc2
	.byte 0x62, 0xab, 0x01, 0x38, 0x9f, 0xa5, 0x01, 0x38, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x40000000000100050000000000001000
	/* C17 */
	.octa 0x901000003e8700a700000000004ae800
	/* C27 */
	.octa 0x40000000080704060000000000001000
	/* C30 */
	.octa 0x48004000400010020000000000000f89
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x4000000000010005000000000000101a
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x901000003e8700a700000000004ae800
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000080704060000000000001000
	/* C30 */
	.octa 0x48004000400010020000000000000f89
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb50e3e80 // cbnz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:0000111000111110100 op:1 011010:011010 sf:1
	.inst 0xc2c0f014 // GCTYPE-R.C-C Rd:20 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2d5a100 // CLRPERM-C.CR-C Cd:0 Cn:8 000:000 1:1 10:10 Rm:21 11000010110:11000010110
	.inst 0xfa45880f // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:0 10:10 cond:1000 imm5:00101 111010010:111010010 op:1 sf:1
	.inst 0xc247922f // LDR-C.RIB-C Ct:15 Rn:17 imm12:000111100100 L:1 110000100:110000100
	.inst 0xc2c1d01f // CPY-C.C-C Cd:31 Cn:0 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa20973de // STUR-C.RI-C Ct:30 Rn:30 00:00 imm9:010010111 0:0 opc:00 10100010:10100010
	.inst 0xc2c0a056 // CLRPERM-C.CR-C Cd:22 Cn:2 000:000 1:1 10:10 Rm:0 11000010110:11000010110
	.inst 0x3801ab62 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:27 10:10 imm9:000011010 0:0 opc:00 111000:111000 size:00
	.inst 0x3801a59f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:12 01:01 imm9:000011010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b28 // ldr c8, [x25, #2]
	.inst 0xc2400f2c // ldr c12, [x25, #3]
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc240173b // ldr c27, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x20000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850032
	msr SCTLR_EL3, x25
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601179 // ldr c25, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x11, #0xf
	and x25, x25, x11
	cmp x25, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032b // ldr c11, [x25, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240072b // ldr c11, [x25, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400b2b // ldr c11, [x25, #2]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc2400f2b // ldr c11, [x25, #3]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240132b // ldr c11, [x25, #4]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc240172b // ldr c11, [x25, #5]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401b2b // ldr c11, [x25, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401f2b // ldr c11, [x25, #7]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240232b // ldr c11, [x25, #8]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240272b // ldr c11, [x25, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x0, =0x0000101a
	ldr x1, =check_data1
	ldr x2, =0x0000101b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001030
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
	ldr x0, =0x004b0640
	ldr x1, =check_data4
	ldr x2, =0x004b0650
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
