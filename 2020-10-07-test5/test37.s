.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x3d, 0x00
.data
check_data3:
	.byte 0x3e, 0x38, 0x92, 0xb8, 0xe1, 0xda, 0x07, 0x78, 0xc9, 0x4a, 0x3f, 0x38, 0x69, 0x18, 0x42, 0x78
	.byte 0x5f, 0xc4, 0x08, 0x51, 0x01, 0x88, 0xc2, 0xc2, 0xbe, 0xaf, 0x4f, 0x78, 0xeb, 0x43, 0x7a, 0xc2
	.byte 0x00, 0x15, 0xc0, 0xda, 0x57, 0xb3, 0x89, 0xda, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000f4040002000000000801
	/* C1 */
	.octa 0x48003d
	/* C2 */
	.octa 0x803040700ffe04000400001
	/* C3 */
	.octa 0x1001
	/* C9 */
	.octa 0x0
	/* C22 */
	.octa 0x1000
	/* C23 */
	.octa 0x1103
	/* C29 */
	.octa 0x424000
final_cap_values:
	/* C1 */
	.octa 0x4000f4040002000000000801
	/* C2 */
	.octa 0x803040700ffe04000400001
	/* C3 */
	.octa 0x1001
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C22 */
	.octa 0x1000
	/* C23 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x4240fa
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000024780000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb892383e // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:1 10:10 imm9:100100011 0:0 opc:10 111000:111000 size:10
	.inst 0x7807dae1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:23 10:10 imm9:001111101 0:0 opc:00 111000:111000 size:01
	.inst 0x383f4ac9 // strb_reg:aarch64/instrs/memory/single/general/register Rt:9 Rn:22 10:10 S:0 option:010 Rm:31 1:1 opc:00 111000:111000 size:00
	.inst 0x78421869 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:3 10:10 imm9:000100001 0:0 opc:01 111000:111000 size:01
	.inst 0x5108c45f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:2 imm12:001000110001 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2c28801 // CHKSSU-C.CC-C Cd:1 Cn:0 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0x784fafbe // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:29 11:11 imm9:011111010 0:0 opc:01 111000:111000 size:01
	.inst 0xc27a43eb // LDR-C.RIB-C Ct:11 Rn:31 imm12:111010010000 L:1 110000100:110000100
	.inst 0xdac01500 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:8 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xda89b357 // csinv:aarch64/instrs/integer/conditional/select Rd:23 Rn:26 o2:0 0:0 cond:1011 Rm:9 011010100:011010100 op:1 sf:1
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2401209 // ldr c9, [x16, #4]
	.inst 0xc2401616 // ldr c22, [x16, #5]
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085003a
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603230 // ldr c16, [c17, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601230 // ldr c16, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x17, #0xf
	and x16, x16, x17
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400211 // ldr c17, [x16, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400611 // ldr c17, [x16, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401a11 // ldr c17, [x16, #6]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2401e11 // ldr c17, [x16, #7]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402211 // ldr c17, [x16, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001022
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001180
	ldr x1, =check_data2
	ldr x2, =0x00001182
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
	ldr x0, =0x0040e6d0
	ldr x1, =check_data4
	ldr x2, =0x0040e6e0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004240fa
	ldr x1, =check_data5
	ldr x2, =0x004240fc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047ff60
	ldr x1, =check_data6
	ldr x2, =0x0047ff64
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
