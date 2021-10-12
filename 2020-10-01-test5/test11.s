.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x18
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x2e, 0xa4, 0xd9, 0xb5, 0xdf, 0xa3, 0x52, 0xf1, 0x18, 0xb8, 0x1f, 0xb9, 0x5f, 0x04, 0x72, 0x62
	.byte 0xa2, 0x7e, 0x9f, 0x48, 0x12, 0x01, 0x19, 0x5a, 0x61, 0x4e, 0x4c, 0x38, 0xc1, 0x7f, 0xce, 0x9b
	.byte 0x17, 0x60, 0xcc, 0xc2, 0xe0, 0x9b, 0x9f, 0xe2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000000000
	/* C2 */
	.octa 0x80100000000300070000000000001800
	/* C12 */
	.octa 0x10000040000000
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100050000000000403f3a
	/* C21 */
	.octa 0x40000000500200010000000000001000
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80100000000300070000000000001800
	/* C12 */
	.octa 0x10000040000000
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100050000000000403ffe
	/* C21 */
	.octa 0x40000000500200010000000000001000
	/* C23 */
	.octa 0x40000000000300070010000040000000
	/* C24 */
	.octa 0x0
initial_csp_value:
	.octa 0x80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000520043030000000000410001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001640
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb5d9a42e // cbnz:aarch64/instrs/branch/conditional/compare Rt:14 imm19:1101100110100100001 op:1 011010:011010 sf:1
	.inst 0xf152a3df // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010010101000 sh:1 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xb91fb818 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:24 Rn:0 imm12:011111101110 opc:00 111001:111001 size:10
	.inst 0x6272045f // LDNP-C.RIB-C Ct:31 Rn:2 Ct2:00001 imm7:1100100 L:1 011000100:011000100
	.inst 0x489f7ea2 // stllrh:aarch64/instrs/memory/ordered Rt:2 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x5a190112 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:18 Rn:8 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:0
	.inst 0x384c4e61 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:19 11:11 imm9:011000100 0:0 opc:01 111000:111000 size:00
	.inst 0x9bce7fc1 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:30 Ra:11111 0:0 Rm:14 10:10 U:1 10011011:10011011
	.inst 0xc2cc6017 // SCOFF-C.CR-C Cd:23 Cn:0 000:000 opc:11 0:0 Rm:12 11000010110:11000010110
	.inst 0xe29f9be0 // ALDURSW-R.RI-64 Rt:0 Rn:31 op2:10 imm9:111111001 V:0 op1:10 11100010:11100010
	.inst 0xc2c210e0
	.zero 1048532
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
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2401978 // ldr c24, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850038
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030eb // ldr c11, [c7, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826010eb // ldr c11, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	.inst 0xc2400167 // ldr c7, [x11, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400567 // ldr c7, [x11, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400d67 // ldr c7, [x11, #3]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401167 // ldr c7, [x11, #4]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401567 // ldr c7, [x11, #5]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401967 // ldr c7, [x11, #6]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2401d67 // ldr c7, [x11, #7]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402167 // ldr c7, [x11, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
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
	ldr x0, =0x00001640
	ldr x1, =check_data1
	ldr x2, =0x00001660
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fb8
	ldr x1, =check_data2
	ldr x2, =0x00001fbc
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
	ldr x0, =0x00403ffe
	ldr x1, =check_data4
	ldr x2, =0x00403fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040437c
	ldr x1, =check_data5
	ldr x2, =0x00404380
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
