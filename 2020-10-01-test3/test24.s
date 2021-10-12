.section data0, #alloc, #write
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0x0d
	.zero 3968
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfc, 0x0d
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xfc, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x82, 0x05, 0xc0, 0xda, 0xc0, 0x01, 0x16, 0x7a, 0x0a, 0xdf, 0x09, 0x38, 0x31, 0x12, 0xc0, 0x5a
	.byte 0x82, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0x22, 0x14, 0xc8, 0x78, 0x02, 0x10, 0x18, 0xf8, 0x4a, 0xe9, 0xec, 0x42, 0x5f, 0x18, 0x08, 0x39
	.byte 0xfe, 0x9d, 0x27, 0xb1, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x107e
	/* C10 */
	.octa 0x2100
	/* C14 */
	.octa 0x149c
	/* C22 */
	.octa 0xfffff495
	/* C24 */
	.octa 0x40000000000300070000000000000fc4
	/* C28 */
	.octa 0x20008000002140050000000000400020
final_cap_values:
	/* C0 */
	.octa 0x2007
	/* C1 */
	.octa 0x10ff
	/* C2 */
	.octa 0xdfc
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x149c
	/* C22 */
	.octa 0xfffff495
	/* C24 */
	.octa 0x40000000000300070000000000001061
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000002140050000000000400020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000004002078300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e90
	.dword 0x0000000000001ea0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00582 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:12 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x7a1601c0 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:14 000000:000000 Rm:22 11010000:11010000 S:1 op:1 sf:0
	.inst 0x3809df0a // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:10 Rn:24 11:11 imm9:010011101 0:0 opc:00 111000:111000 size:00
	.inst 0x5ac01231 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:17 Rn:17 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c21382 // BRS-C-C 00010:00010 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.zero 12
	.inst 0x78c81422 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:1 01:01 imm9:010000001 0:0 opc:11 111000:111000 size:01
	.inst 0xf8181002 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:0 00:00 imm9:110000001 0:0 opc:00 111000:111000 size:11
	.inst 0x42ece94a // LDP-C.RIB-C Ct:10 Rn:10 Ct2:11010 imm7:1011001 L:1 010000101:010000101
	.inst 0x3908185f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:001000000110 opc:00 111001:111001 size:00
	.inst 0xb1279dfe // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:15 imm12:100111100111 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c21260
	.zero 1048520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc240056a // ldr c10, [x11, #1]
	.inst 0xc240096e // ldr c14, [x11, #2]
	.inst 0xc2400d76 // ldr c22, [x11, #3]
	.inst 0xc2401178 // ldr c24, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x20000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326b // ldr c11, [c19, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260126b // ldr c11, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400173 // ldr c19, [x11, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400573 // ldr c19, [x11, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402173 // ldr c19, [x11, #8]
	.inst 0xc2d3a781 // chkeq c28, c19
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
	ldr x0, =0x00001061
	ldr x1, =check_data1
	ldr x2, =0x00001062
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000107e
	ldr x1, =check_data2
	ldr x2, =0x00001080
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e90
	ldr x1, =check_data3
	ldr x2, =0x00001eb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f88
	ldr x1, =check_data4
	ldr x2, =0x00001f90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400020
	ldr x1, =check_data6
	ldr x2, =0x00400038
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
