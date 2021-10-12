.section data0, #alloc, #write
	.zero 4000
	.byte 0x01, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 80
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x01, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data6:
	.byte 0xb7, 0xe0, 0xca, 0xc2, 0x21, 0xd4, 0xd3, 0x82, 0xcb, 0x03, 0x43, 0x3a, 0xdf, 0x3e, 0x5d, 0x28
	.byte 0x7e, 0x4e, 0x48, 0xb8, 0x56, 0x74, 0x82, 0xda, 0x9f, 0x0d, 0x59, 0x38, 0xc1, 0x51, 0xdf, 0xc2
.data
check_data7:
	.byte 0x21, 0xd9, 0x92, 0xb8, 0xf2, 0xcb, 0x62, 0x82, 0x80, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000010007ffffffffffffffe2
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x80000000000000000000000000002003
	/* C12 */
	.octa 0x50000e
	/* C14 */
	.octa 0x90100000600400080000000000002000
	/* C19 */
	.octa 0x103c
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x80000000000000000000000000002003
	/* C12 */
	.octa 0x4fff9e
	/* C14 */
	.octa 0x90100000600400080000000000002000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x10c0
	/* C30 */
	.octa 0x20008000000000000000000000400020
initial_csp_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001bf180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fa0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cae0b7 // SCFLGS-C.CR-C Cd:23 Cn:5 111000:111000 Rm:10 11000010110:11000010110
	.inst 0x82d3d421 // ALDRSB-R.RRB-32 Rt:1 Rn:1 opc:01 S:1 option:110 Rm:19 0:0 L:1 100000101:100000101
	.inst 0x3a4303cb // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:30 00:00 cond:0000 Rm:3 111010010:111010010 op:0 sf:0
	.inst 0x285d3edf // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:22 Rt2:01111 imm7:0111010 L:1 1010000:1010000 opc:00
	.inst 0xb8484e7e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:19 11:11 imm9:010000100 0:0 opc:01 111000:111000 size:10
	.inst 0xda827456 // csneg:aarch64/instrs/integer/conditional/select Rd:22 Rn:2 o2:1 0:0 cond:0111 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0x38590d9f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:12 11:11 imm9:110010000 0:0 opc:01 111000:111000 size:00
	.inst 0xc2df51c1 // BLR-CI-C 1:1 0000:0000 Cn:14 100:100 imm7:1111010 110000101101:110000101101
	.zero 4064
	.inst 0xb892d921 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:9 10:10 imm9:100101101 0:0 opc:10 111000:111000 size:10
	.inst 0x8262cbf2 // ALDR-R.RI-32 Rt:18 Rn:31 op:10 imm9:000101100 L:1 1000001001:1000001001
	.inst 0xc2c21280
	.zero 1044468
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
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400623 // ldr c3, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc240122c // ldr c12, [x17, #4]
	.inst 0xc240162e // ldr c14, [x17, #5]
	.inst 0xc2401a33 // ldr c19, [x17, #6]
	.inst 0xc2401e36 // ldr c22, [x17, #7]
	.inst 0xc240223e // ldr c30, [x17, #8]
	/* Set up flags and system registers */
	mov x17, #0x40000000
	msr nzcv, x17
	ldr x17, =initial_csp_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085003a
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603291 // ldr c17, [c20, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x82601291 // ldr c17, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	mov x20, #0xf
	and x17, x17, x20
	cmp x17, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400234 // ldr c20, [x17, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400634 // ldr c20, [x17, #1]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400a34 // ldr c20, [x17, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400e34 // ldr c20, [x17, #3]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401e34 // ldr c20, [x17, #7]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2402234 // ldr c20, [x17, #8]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402634 // ldr c20, [x17, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101e
	ldr x1, =check_data0
	ldr x2, =0x0000101f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010b4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e8
	ldr x1, =check_data3
	ldr x2, =0x000010f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f30
	ldr x1, =check_data4
	ldr x2, =0x00001f34
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fa0
	ldr x1, =check_data5
	ldr x2, =0x00001fb0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00401000
	ldr x1, =check_data7
	ldr x2, =0x0040100c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004fff9e
	ldr x1, =check_data8
	ldr x2, =0x004fff9f
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
