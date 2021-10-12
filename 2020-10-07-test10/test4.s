.section data0, #alloc, #write
	.zero 3264
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 816
.data
check_data0:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x3e, 0x31, 0xc0, 0xc2, 0xc8, 0x33, 0xc0, 0xc2, 0xde, 0x13, 0xc5, 0xc2, 0x41, 0x90, 0xd9, 0xc2
	.byte 0x02, 0xd0, 0x10, 0x3c, 0x02, 0xb0, 0xc0, 0xc2, 0xfe, 0xe5, 0x0f, 0x90, 0x1e, 0xa3, 0xa3, 0xb9
	.byte 0x82, 0x7a, 0xcf, 0xc2, 0xe1, 0xce, 0xf3, 0x02, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000000000000000020f1
	/* C2 */
	.octa 0x90100000600100020000000000002000
	/* C9 */
	.octa 0x10041087000000e000000000
	/* C20 */
	.octa 0x400000000000000000000000
	/* C23 */
	.octa 0x800640070000000060000000
	/* C24 */
	.octa 0x4fdc58
final_cap_values:
	/* C0 */
	.octa 0x20000000000000000000020f1
	/* C1 */
	.octa 0x80064007000000005f30d000
	/* C2 */
	.octa 0x41e000000000000000000000
	/* C8 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x10041087000000e000000000
	/* C20 */
	.octa 0x400000000000000000000000
	/* C23 */
	.octa 0x800640070000000060000000
	/* C24 */
	.octa 0x4fdc58
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001cc0
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0313e // GCLEN-R.C-C Rd:30 Cn:9 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c033c8 // GCLEN-R.C-C Rd:8 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c513de // CVTD-R.C-C Rd:30 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2d99041 // BLR-CI-C 1:1 0000:0000 Cn:2 100:100 imm7:1001100 110000101101:110000101101
	.inst 0x3c10d002 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:2 Rn:0 00:00 imm9:100001101 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c0b002 // GCSEAL-R.C-C Rd:2 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x900fe5fe // ADRDP-C.ID-C Rd:30 immhi:000111111100101111 P:0 10000:10000 immlo:00 op:1
	.inst 0xb9a3a31e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:24 imm12:100011101000 opc:10 111001:111001 size:10
	.inst 0xc2cf7a82 // SCBNDS-C.CI-S Cd:2 Cn:20 1110:1110 S:1 imm6:011110 11000010110:11000010110
	.inst 0x02f3cee1 // SUB-C.CIS-C Cd:1 Cn:23 imm12:110011110011 sh:1 A:1 00000010:00000010
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400db4 // ldr c20, [x13, #3]
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc24015b8 // ldr c24, [x13, #5]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x8
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x3, #0xf
	and x13, x13, x3
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24019a3 // ldr c3, [x13, #6]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2401da3 // ldr c3, [x13, #7]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24021a3 // ldr c3, [x13, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x3, v2.d[0]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v2.d[1]
	cmp x13, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001cc0
	ldr x1, =check_data0
	ldr x2, =0x00001cd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff8
	ldr x1, =check_data3
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
