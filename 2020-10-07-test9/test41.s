.section data0, #alloc, #write
	.zero 400
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x02, 0x00, 0x00
	.zero 2672
	.byte 0xbe, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 992
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x02, 0x00, 0x00
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xbe, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data6:
	.byte 0xc0, 0xb0, 0xc6, 0xc2, 0x40, 0x48, 0xf3, 0x22, 0xe1, 0x13, 0x66, 0x71, 0xbe, 0xfc, 0xdf, 0x08
	.byte 0xc1, 0x5e, 0x74, 0xc2, 0x01, 0x44, 0x94, 0x38, 0xff, 0x6b, 0x19, 0x62, 0x1e, 0xfc, 0xdf, 0x08
	.byte 0x5e, 0xd4, 0x5f, 0x02, 0x5f, 0x8c, 0x1e, 0xca, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1c10
	/* C5 */
	.octa 0x15d4
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0xffffffffffff4020
	/* C26 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1002
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1a70
	/* C5 */
	.octa 0x15d4
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffff4020
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x7f6a70
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000110000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8000000000700020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001190
	.dword 0x0000000000001c10
	.dword 0x0000000000001c20
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c6b0c0 // CLRPERM-C.CI-C Cd:0 Cn:6 100:100 perm:101 1100001011000110:1100001011000110
	.inst 0x22f34840 // LDP-CC.RIAW-C Ct:0 Rn:2 Ct2:10010 imm7:1100110 L:1 001000101:001000101
	.inst 0x716613e1 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:31 imm12:100110000100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x08dffcbe // ldarb:aarch64/instrs/memory/ordered Rt:30 Rn:5 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2745ec1 // LDR-C.RIB-C Ct:1 Rn:22 imm12:110100010111 L:1 110000100:110000100
	.inst 0x38944401 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:101000100 0:0 opc:10 111000:111000 size:00
	.inst 0x62196bff // STNP-C.RIB-C Ct:31 Rn:31 Ct2:11010 imm7:0110010 L:0 011000100:011000100
	.inst 0x08dffc1e // ldarb:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x025fd45e // ADD-C.CIS-C Cd:30 Cn:2 imm12:011111110101 sh:1 A:0 00000010:00000010
	.inst 0xca1e8c5f // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:100011 Rm:30 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2400f16 // ldr c22, [x24, #3]
	.inst 0xc240131a // ldr c26, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085003a
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603298 // ldr c24, [c20, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601298 // ldr c24, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x20, #0xf
	and x24, x24, x20
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400314 // ldr c20, [x24, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400714 // ldr c20, [x24, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401b14 // ldr c20, [x24, #6]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2401f14 // ldr c20, [x24, #7]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402314 // ldr c20, [x24, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010be
	ldr x1, =check_data1
	ldr x2, =0x000010bf
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x000011a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001320
	ldr x1, =check_data3
	ldr x2, =0x00001340
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000015d4
	ldr x1, =check_data4
	ldr x2, =0x000015d5
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c10
	ldr x1, =check_data5
	ldr x2, =0x00001c30
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
