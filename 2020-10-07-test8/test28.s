.section data0, #alloc, #write
	.zero 4016
	.byte 0xf5, 0x03, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00, 0x40, 0x44, 0x00, 0x80, 0x00, 0x20
	.zero 64
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xcf, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xf5, 0x03, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00, 0x40, 0x44, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x00, 0x40
.data
check_data6:
	.byte 0xd2, 0x32, 0x00, 0xb8, 0xc8, 0x0b, 0x1d, 0x78, 0x3b, 0x00, 0x12, 0x7a, 0x21, 0x70, 0xdf, 0xc2
.data
check_data7:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xdf, 0xdb, 0x77, 0x78, 0x41, 0x60, 0xeb, 0x62, 0x0a, 0x78, 0x4d, 0xfa
	.byte 0xff, 0x8f, 0x18, 0xf8, 0xfc, 0x04, 0xda, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90100000000500030000000000002000
	/* C2 */
	.octa 0x198b
	/* C7 */
	.octa 0x40008000004000000000c001
	/* C8 */
	.octa 0x4000
	/* C18 */
	.octa 0xcf
	/* C22 */
	.octa 0x400000005504000c00000000000013fd
	/* C23 */
	.octa 0xffe00801
	/* C26 */
	.octa 0x100010000000000000000
	/* C30 */
	.octa 0x40000000180140050000000000002020
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x16eb
	/* C7 */
	.octa 0x40008000004000000000c001
	/* C8 */
	.octa 0x4000
	/* C18 */
	.octa 0xcf
	/* C22 */
	.octa 0x400000005504000c00000000000013fd
	/* C23 */
	.octa 0xffe00801
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x100010000000000000000
	/* C27 */
	.octa 0x1f30
	/* C28 */
	.octa 0x40008000004000000000c001
	/* C30 */
	.octa 0x200080004021c02d0000000000400011
initial_SP_EL3_value:
	.octa 0x1423
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004021c02d0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000004009002500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001710
	.dword 0x0000000000001720
	.dword 0x0000000000001fb0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb80032d2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:22 00:00 imm9:000000011 0:0 opc:00 111000:111000 size:10
	.inst 0x781d0bc8 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:8 Rn:30 10:10 imm9:111010000 0:0 opc:00 111000:111000 size:01
	.inst 0x7a12003b // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:27 Rn:1 000000:000000 Rm:18 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2df7021 // BLR-CI-C 1:1 0000:0000 Cn:1 100:100 imm7:1111011 110000101101:110000101101
	.zero 394212
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x7877dbdf // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:30 10:10 S:1 option:110 Rm:23 1:1 opc:01 111000:111000 size:01
	.inst 0x62eb6041 // LDP-C.RIBW-C Ct:1 Rn:2 Ct2:11000 imm7:1010110 L:1 011000101:011000101
	.inst 0xfa4d780a // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:0 10:10 cond:0111 imm5:01101 111010010:111010010 op:1 sf:1
	.inst 0xf8188fff // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:110001000 0:0 opc:00 111000:111000 size:11
	.inst 0xc2da04fc // BUILD-C.C-C Cd:28 Cn:7 001:001 opc:00 0:0 Cm:26 11000010110:11000010110
	.inst 0xc2c211e0
	.zero 654320
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
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2401092 // ldr c18, [x4, #4]
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2401897 // ldr c23, [x4, #6]
	.inst 0xc2401c9a // ldr c26, [x4, #7]
	.inst 0xc240209e // ldr c30, [x4, #8]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e4 // ldr c4, [c15, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011e4 // ldr c4, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008f // ldr c15, [x4, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240048f // ldr c15, [x4, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc240088f // ldr c15, [x4, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240108f // ldr c15, [x4, #4]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240148f // ldr c15, [x4, #5]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc240188f // ldr c15, [x4, #6]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc2401c8f // ldr c15, [x4, #7]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc240208f // ldr c15, [x4, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240248f // ldr c15, [x4, #9]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240288f // ldr c15, [x4, #10]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc2402c8f // ldr c15, [x4, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x0000103a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013d0
	ldr x1, =check_data1
	ldr x2, =0x000013d8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001710
	ldr x1, =check_data3
	ldr x2, =0x00001730
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb0
	ldr x1, =check_data4
	ldr x2, =0x00001fc0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff0
	ldr x1, =check_data5
	ldr x2, =0x00001ff2
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004603f4
	ldr x1, =check_data7
	ldr x2, =0x00460410
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
