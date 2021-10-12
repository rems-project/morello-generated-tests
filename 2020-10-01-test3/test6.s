.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x80, 0x23, 0xeb, 0xa8, 0x2f, 0x6a, 0x82, 0xd3, 0x3b, 0x29, 0x9b, 0x64, 0x49, 0x80, 0x82
	.byte 0x20, 0xa3, 0x72, 0xbd, 0x4e, 0x7d, 0xdf, 0x08, 0xcd, 0xaa, 0xc2, 0xc2, 0xa0, 0xe0, 0xed, 0x50
	.byte 0x24, 0x4a, 0xc0, 0xc2, 0xfe, 0x9a, 0x97, 0xe2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x800000000001000500000000004ffffe
	/* C11 */
	.octa 0x415054
	/* C17 */
	.octa 0x800000000000000000000000
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x419007
	/* C25 */
	.octa 0x800000000001000500000000004fcd58
	/* C29 */
	.octa 0x414000
final_cap_values:
	/* C0 */
	.octa 0x2000c0000000400800000000003dbc32
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C10 */
	.octa 0x800000000001000500000000004ffffe
	/* C11 */
	.octa 0x415054
	/* C14 */
	.octa 0xc2
	/* C17 */
	.octa 0x800000000000000000000000
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x419007
	/* C25 */
	.octa 0x800000000001000500000000004fcd58
	/* C29 */
	.octa 0x414000
	/* C30 */
	.octa 0xffffffffc2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000c000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000107411f0000000000420001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb238000 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:0 imm3:000 option:100 Rm:3 01011001:01011001 S:1 op:1 sf:1
	.inst 0x826a2fa8 // ALDR-R.RI-64 Rt:8 Rn:29 op:11 imm9:010100010 L:1 1000001001:1000001001
	.inst 0x9b293bd3 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:19 Rn:30 Ra:14 o0:0 Rm:9 01:01 U:0 10011011:10011011
	.inst 0x82804964 // ALDRSH-R.RRB-64 Rt:4 Rn:11 opc:10 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xbd72a320 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:25 imm12:110010101000 opc:01 111101:111101 size:10
	.inst 0x08df7d4e // ldlarb:aarch64/instrs/memory/ordered Rt:14 Rn:10 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c2aacd // EORFLGS-C.CR-C Cd:13 Cn:22 1010:1010 opc:10 Rm:2 11000010110:11000010110
	.inst 0x50ede0a0 // ADR-C.I-C Rd:0 immhi:110110111100000101 P:1 10000:10000 immlo:10 op:0
	.inst 0xc2c04a24 // UNSEAL-C.CC-C Cd:4 Cn:17 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xe2979afe // ALDURSW-R.RI-64 Rt:30 Rn:23 op2:10 imm9:101111001 V:0 op1:10 11100010:11100010
	.inst 0xc2c210e0
	.zero 83172
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 2876
	.inst 0x0000c2c2
	.zero 16168
	.inst 0xc2c2c2c2
	.zero 946292
	.inst 0xc2c2c2c2
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a3 // ldr c3, [x21, #1]
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2400eab // ldr c11, [x21, #3]
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2401eb9 // ldr c25, [x21, #7]
	.inst 0xc24022bd // ldr c29, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f5 // ldr c21, [c7, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x826010f5 // ldr c21, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x7, #0xf
	and x21, x21, x7
	cmp x21, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a7 // ldr c7, [x21, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24006a7 // ldr c7, [x21, #1]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400ea7 // ldr c7, [x21, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24012a7 // ldr c7, [x21, #4]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc24016a7 // ldr c7, [x21, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401aa7 // ldr c7, [x21, #6]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401ea7 // ldr c7, [x21, #7]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc24022a7 // ldr c7, [x21, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24026a7 // ldr c7, [x21, #9]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402aa7 // ldr c7, [x21, #10]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402ea7 // ldr c7, [x21, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24032a7 // ldr c7, [x21, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0xc2c2c2c2
	mov x7, v0.d[0]
	cmp x21, x7
	b.ne comparison_fail
	ldr x21, =0x0
	mov x7, v0.d[1]
	cmp x21, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00414510
	ldr x1, =check_data1
	ldr x2, =0x00414518
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00415054
	ldr x1, =check_data2
	ldr x2, =0x00415056
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00418f80
	ldr x1, =check_data3
	ldr x2, =0x00418f84
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
