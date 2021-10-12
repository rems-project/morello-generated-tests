.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x22, 0x18, 0x4c, 0xba, 0x00, 0xa4, 0x10, 0xa9, 0xc0, 0xa4, 0xd5, 0xc2
.data
check_data4:
	.byte 0x18, 0x64, 0xed, 0xe2, 0x23, 0x52, 0x22, 0x9b, 0x3f, 0xf0, 0xc6, 0xc2, 0x21, 0x1e, 0xc1, 0xb6
	.byte 0xf0, 0xe0, 0xc1, 0xc2, 0x32, 0x0c, 0x76, 0x82, 0xbf, 0x0a, 0x72, 0xd0, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000200020000000000000001000
	/* C1 */
	.octa 0xfffffffffffffe86
	/* C6 */
	.octa 0x20408008500600000000000000420001
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x0
	/* C21 */
	.octa 0x400008000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x40000000200020000000000000001000
	/* C1 */
	.octa 0xfffffffffffffe86
	/* C6 */
	.octa 0x20408008500600000000000000420001
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x3fff80000000ff00000000000000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x400008000000000000000000000000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000800000008008000000000040000d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005f6007020000000000000028
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba4c1822 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0010 0:0 Rn:1 10:10 cond:0001 imm5:01100 111010010:111010010 op:0 sf:1
	.inst 0xa910a400 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:0 Rt2:01001 imm7:0100001 L:0 1010010:1010010 opc:10
	.inst 0xc2d5a4c0 // BLRS-C.C-C 00000:00000 Cn:6 001:001 opc:01 1:1 Cm:21 11000010110:11000010110
	.zero 131060
	.inst 0xe2ed6418 // ALDUR-V.RI-D Rt:24 Rn:0 op2:01 imm9:011010110 V:1 op1:11 11100010:11100010
	.inst 0x9b225223 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:17 Ra:20 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c6f03f // CLRPERM-C.CI-C Cd:31 Cn:1 100:100 perm:111 1100001011000110:1100001011000110
	.inst 0xb6c11e21 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:00100011110001 b40:11000 op:0 011011:011011 b5:1
	.inst 0xc2c1e0f0 // SCFLGS-C.CR-C Cd:16 Cn:7 111000:111000 Rm:1 11000010110:11000010110
	.inst 0x82760c32 // ALDR-R.RI-64 Rt:18 Rn:1 op:11 imm9:101100000 L:1 1000001001:1000001001
	.inst 0xd0720abf // ADRP-C.I-C Rd:31 immhi:111001000001010101 P:0 10000:10000 immlo:10 op:1
	.inst 0xc2c210a0
	.zero 917472
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x40000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030ae // ldr c14, [c5, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x826010ae // ldr c14, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x5, #0xf
	and x14, x14, x5
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c5 // ldr c5, [x14, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc24011c5 // ldr c5, [x14, #4]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc24015c5 // ldr c5, [x14, #5]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24019c5 // ldr c5, [x14, #6]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401dc5 // ldr c5, [x14, #7]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24021c5 // ldr c5, [x14, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24025c5 // ldr c5, [x14, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x5, v24.d[0]
	cmp x14, x5
	b.ne comparison_fail
	ldr x14, =0x0
	mov x5, v24.d[1]
	cmp x14, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001088
	ldr x1, =check_data0
	ldr x2, =0x00001090
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001108
	ldr x1, =check_data1
	ldr x2, =0x00001118
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017d8
	ldr x1, =check_data2
	ldr x2, =0x000017e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00420000
	ldr x1, =check_data4
	ldr x2, =0x00420020
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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
