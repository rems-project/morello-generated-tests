.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf0, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x2c, 0x00
.data
check_data2:
	.byte 0x2c, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x3a, 0x70, 0xd4, 0x29, 0xea, 0x1b, 0x51, 0x3a, 0x60, 0x72, 0x3f, 0x4a, 0xde, 0xbf, 0xc1, 0xc2
	.byte 0x5f, 0xb1, 0x3e, 0x02, 0xa1, 0x19, 0x14, 0x78, 0x7f, 0x58, 0xd0, 0xc2, 0xc0, 0xb3, 0x05, 0xfc
	.byte 0x42, 0xd8, 0x32, 0xf8, 0x81, 0xc5, 0x14, 0x78, 0x20, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x47ff8c
	/* C2 */
	.octa 0x12f0
	/* C3 */
	.octa 0xc001200100ffffff00000001
	/* C10 */
	.octa 0x800720030000000000000000
	/* C12 */
	.octa 0x1f00
	/* C13 */
	.octa 0x204f
	/* C18 */
	.octa 0x0
	/* C30 */
	.octa 0x1f55
final_cap_values:
	/* C1 */
	.octa 0x48002c
	/* C2 */
	.octa 0x12f0
	/* C3 */
	.octa 0xc001200100ffffff00000001
	/* C10 */
	.octa 0x800720030000000000000000
	/* C12 */
	.octa 0x1e4c
	/* C13 */
	.octa 0x204f
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1f55
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x29d4703a // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:26 Rn:1 Rt2:11100 imm7:0101000 L:1 1010011:1010011 opc:00
	.inst 0x3a511bea // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:31 10:10 cond:0001 imm5:10001 111010010:111010010 op:0 sf:0
	.inst 0x4a3f7260 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:19 imm6:011100 Rm:31 N:1 shift:00 01010:01010 opc:10 sf:0
	.inst 0xc2c1bfde // CSEL-C.CI-C Cd:30 Cn:30 11:11 cond:1011 Cm:1 11000010110:11000010110
	.inst 0x023eb15f // ADD-C.CIS-C Cd:31 Cn:10 imm12:111110101100 sh:0 A:0 00000010:00000010
	.inst 0x781419a1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:13 10:10 imm9:101000001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2d0587f // ALIGNU-C.CI-C Cd:31 Cn:3 0110:0110 U:1 imm6:100000 11000010110:11000010110
	.inst 0xfc05b3c0 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:001011011 0:0 opc:00 111100:111100 size:11
	.inst 0xf832d842 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:2 Rn:2 10:10 S:1 option:110 Rm:18 1:1 opc:00 111000:111000 size:11
	.inst 0x7814c581 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:12 01:01 imm9:101001100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc24014ad // ldr c13, [x5, #5]
	.inst 0xc24018b2 // ldr c18, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x5, #0x40000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603325 // ldr c5, [c25, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601325 // ldr c5, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x25, #0xf
	and x5, x5, x25
	cmp x5, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b9 // ldr c25, [x5, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24004b9 // ldr c25, [x5, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc24008b9 // ldr c25, [x5, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400cb9 // ldr c25, [x5, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc24014b9 // ldr c25, [x5, #5]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401cb9 // ldr c25, [x5, #7]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24020b9 // ldr c25, [x5, #8]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc24024b9 // ldr c25, [x5, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x25, v0.d[0]
	cmp x5, x25
	b.ne comparison_fail
	ldr x5, =0x0
	mov x25, v0.d[1]
	cmp x5, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000012f0
	ldr x1, =check_data0
	ldr x2, =0x000012f8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f00
	ldr x1, =check_data1
	ldr x2, =0x00001f02
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f90
	ldr x1, =check_data2
	ldr x2, =0x00001f92
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb0
	ldr x1, =check_data3
	ldr x2, =0x00001fb8
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
	ldr x0, =0x0048002c
	ldr x1, =check_data5
	ldr x2, =0x00480034
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
