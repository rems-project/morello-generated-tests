.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc0, 0x66, 0xad, 0xd8, 0x4d, 0xfc, 0x9f, 0x08, 0x84, 0x58, 0xff, 0x82, 0x22, 0x6e, 0x50, 0x38
	.byte 0x01, 0x33, 0xc2, 0xc2, 0x80, 0x12, 0xd3, 0x29, 0xa0, 0x59, 0x43, 0x38, 0x43, 0x22, 0x6a, 0x90
	.byte 0x35, 0x40, 0x92, 0xe2, 0x5e, 0x90, 0xc1, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10e4
	/* C2 */
	.octa 0x4000000040000002000000000000100a
	/* C4 */
	.octa 0x4001f0
	/* C13 */
	.octa 0x80000000000100050000000000001fc9
	/* C17 */
	.octa 0x800000000001000500000000000020f8
	/* C20 */
	.octa 0x800000005c01dc020000000000401838
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x10e4
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xc0000000000040100024000154448000
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000100050000000000001fc9
	/* C17 */
	.octa 0x80000000000100050000000000001ffe
	/* C20 */
	.octa 0x800000005c01dc0200000000004018d0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000040100024000080000080
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd8ad66c0 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:1010110101100110110 011000:011000 opc:11
	.inst 0x089ffc4d // stlrb:aarch64/instrs/memory/ordered Rt:13 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x82ff5884 // ALDR-V.RRB-D Rt:4 Rn:4 opc:10 S:1 option:010 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x38506e22 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:17 11:11 imm9:100000110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c23301 // CHKTGD-C-C 00001:00001 Cn:24 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x29d31280 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:20 Rt2:00100 imm7:0100110 L:1 1010011:1010011 opc:00
	.inst 0x384359a0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:13 10:10 imm9:000110101 0:0 opc:01 111000:111000 size:00
	.inst 0x906a2243 // ADRDP-C.ID-C Rd:3 immhi:110101000100010010 P:0 10000:10000 immlo:00 op:1
	.inst 0xe2924035 // ASTUR-R.RI-32 Rt:21 Rn:1 op2:00 imm9:100100100 V:0 op1:10 11100010:11100010
	.inst 0xc2c1905e // CLRTAG-C.C-C Cd:30 Cn:2 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c210c0
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
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2401975 // ldr c21, [x11, #6]
	.inst 0xc2401d78 // ldr c24, [x11, #7]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cb // ldr c11, [c6, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826010cb // ldr c11, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x6, #0xf
	and x11, x11, x6
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400166 // ldr c6, [x11, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400966 // ldr c6, [x11, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401166 // ldr c6, [x11, #4]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401566 // ldr c6, [x11, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401966 // ldr c6, [x11, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401d66 // ldr c6, [x11, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402166 // ldr c6, [x11, #8]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2402566 // ldr c6, [x11, #9]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402966 // ldr c6, [x11, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x6, v4.d[0]
	cmp x11, x6
	b.ne comparison_fail
	ldr x11, =0x0
	mov x6, v4.d[1]
	cmp x11, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
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
	ldr x0, =0x004001f0
	ldr x1, =check_data3
	ldr x2, =0x004001f8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004018d0
	ldr x1, =check_data4
	ldr x2, =0x004018d8
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
