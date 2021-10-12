.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x40, 0x00, 0xc0
	.zero 16
.data
check_data3:
	.byte 0x00, 0x16, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xcb, 0x4f, 0xfa, 0x02, 0x40, 0x13, 0xc5, 0xc2, 0x3e, 0x36, 0x55, 0x82, 0xc4, 0x7f, 0xdf, 0x9b
	.byte 0x01, 0x41, 0x01, 0xb9, 0xd5, 0xe7, 0x7b, 0x39, 0x0c, 0x45, 0x73, 0x82, 0x56, 0x12, 0x80, 0x78
	.byte 0x3e, 0x6c, 0x97, 0x22, 0xdf, 0x17, 0x13, 0x78, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4c000000180700070000000000001600
	/* C8 */
	.octa 0x4000000058041a940000000000001a00
	/* C17 */
	.octa 0xc00
	/* C18 */
	.octa 0x80000000400100040000000000000fff
	/* C26 */
	.octa 0x400
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xc0004000000300070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c0000001807000700000000000018e0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000058041a940000000000001a00
	/* C11 */
	.octa 0xc000400000030007ffffffffff16e000
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0xc00
	/* C18 */
	.octa 0x80000000400100040000000000000fff
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x400
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xc0004000000300070000000000000f31
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001f470407000000000000c000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x02fa4fcb // SUB-C.CIS-C Cd:11 Cn:30 imm12:111010010011 sh:1 A:1 00000010:00000010
	.inst 0xc2c51340 // CVTD-R.C-C Rd:0 Cn:26 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x8255363e // ASTRB-R.RI-B Rt:30 Rn:17 op:01 imm9:101010011 L:0 1000001001:1000001001
	.inst 0x9bdf7fc4 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:4 Rn:30 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xb9014101 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:8 imm12:000001010000 opc:00 111001:111001 size:10
	.inst 0x397be7d5 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:21 Rn:30 imm12:111011111001 opc:01 111001:111001 size:00
	.inst 0x8273450c // ALDRB-R.RI-B Rt:12 Rn:8 op:01 imm9:100110100 L:1 1000001001:1000001001
	.inst 0x78801256 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:22 Rn:18 00:00 imm9:000000001 0:0 opc:10 111000:111000 size:01
	.inst 0x22976c3e // STP-CC.RIAW-C Ct:30 Rn:1 Ct2:11011 imm7:0101110 L:0 001000101:001000101
	.inst 0x781317df // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:100110001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400688 // ldr c8, [x20, #1]
	.inst 0xc2400a91 // ldr c17, [x20, #2]
	.inst 0xc2400e92 // ldr c18, [x20, #3]
	.inst 0xc240129a // ldr c26, [x20, #4]
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603154 // ldr c20, [c10, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601154 // ldr c20, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x10, #0xf
	and x20, x20, x10
	cmp x20, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028a // ldr c10, [x20, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240168a // ldr c10, [x20, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc2401a8a // ldr c10, [x20, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401e8a // ldr c10, [x20, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240228a // ldr c10, [x20, #8]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240268a // ldr c10, [x20, #9]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2402a8a // ldr c10, [x20, #10]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402e8a // ldr c10, [x20, #11]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc240328a // ldr c10, [x20, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001153
	ldr x1, =check_data1
	ldr x2, =0x00001154
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001600
	ldr x1, =check_data2
	ldr x2, =0x00001620
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b40
	ldr x1, =check_data3
	ldr x2, =0x00001b44
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ef9
	ldr x1, =check_data4
	ldr x2, =0x00001efa
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f34
	ldr x1, =check_data5
	ldr x2, =0x00001f35
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
