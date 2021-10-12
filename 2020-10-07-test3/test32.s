.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x07, 0x00, 0x07, 0x00, 0x00, 0x40, 0x00, 0x40
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x9e, 0xf8, 0x33, 0xb9, 0x18, 0x10, 0xc1, 0xc2, 0x1e, 0xad, 0x72, 0x70, 0xff, 0xa7, 0x81, 0x9a
	.byte 0x00, 0xca, 0x17, 0xb8, 0xa4, 0x2b, 0x01, 0xa2, 0xa1, 0x16, 0xc0, 0x5a, 0x19, 0x04, 0xba, 0x79
	.byte 0x84, 0x38, 0xd7, 0xc2, 0xa2, 0xaa, 0x40, 0x38, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000200180050000000000000000
	/* C4 */
	.octa 0x4000400000070007ffffffffffffe000
	/* C16 */
	.octa 0x4000000060010b140000000000001400
	/* C21 */
	.octa 0x800000000003000700000000003ffff8
	/* C29 */
	.octa 0x48000000000700070000000000000ee0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000200180050000000000000000
	/* C1 */
	.octa 0x9
	/* C2 */
	.octa 0x33
	/* C4 */
	.octa 0x40004000602ee000ffffffffffffe000
	/* C16 */
	.octa 0x4000000060010b140000000000001400
	/* C21 */
	.octa 0x800000000003000700000000003ffff8
	/* C24 */
	.octa 0xffffffffffffffff
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x48000000000700070000000000000ee0
	/* C30 */
	.octa 0x200080000000001000000000004e55ab
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
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
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb933f89e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:4 imm12:110011111110 opc:00 111001:111001 size:10
	.inst 0xc2c11018 // GCLIM-R.C-C Rd:24 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x7072ad1e // ADR-C.I-C Rd:30 immhi:111001010101101000 P:0 10000:10000 immlo:11 op:0
	.inst 0x9a81a7ff // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:31 o2:1 0:0 cond:1010 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0xb817ca00 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:16 10:10 imm9:101111100 0:0 opc:00 111000:111000 size:10
	.inst 0xa2012ba4 // STTR-C.RIB-C Ct:4 Rn:29 10:10 imm9:000010010 0:0 opc:00 10100010:10100010
	.inst 0x5ac016a1 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:1 Rn:21 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0x79ba0419 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:25 Rn:0 imm12:111010000001 opc:10 111001:111001 size:01
	.inst 0xc2d73884 // SCBNDS-C.CI-C Cd:4 Cn:4 1110:1110 S:0 imm6:101110 11000010110:11000010110
	.inst 0x3840aaa2 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:21 10:10 imm9:000001010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc24009d0 // ldr c16, [x14, #2]
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc24011dd // ldr c29, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128e // ldr c14, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x20, #0x9
	and x14, x14, x20
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d4 // ldr c20, [x14, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005d4 // ldr c20, [x14, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009d4 // ldr c20, [x14, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400dd4 // ldr c20, [x14, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc24019d4 // ldr c20, [x14, #6]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2401dd4 // ldr c20, [x14, #7]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24021d4 // ldr c20, [x14, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24025d4 // ldr c20, [x14, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x0000137c
	ldr x1, =check_data1
	ldr x2, =0x00001380
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f8
	ldr x1, =check_data2
	ldr x2, =0x000013fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d02
	ldr x1, =check_data3
	ldr x2, =0x00001d04
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
