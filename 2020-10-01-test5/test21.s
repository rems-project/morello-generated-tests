.section data0, #alloc, #write
	.zero 4016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 64
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xb2, 0xfd, 0x37, 0xe2, 0x1d, 0x4a, 0xc1, 0xc2, 0x52, 0x74, 0x8b, 0xe2, 0x60, 0xd1, 0xcb, 0x78
	.byte 0x2d, 0xe8, 0x65, 0x78, 0x22, 0x58, 0x56, 0x38, 0x62, 0xfc, 0x7f, 0x42, 0xe1, 0xd3, 0x51, 0xba
	.byte 0xff, 0x00, 0x80, 0xda, 0x81, 0x45, 0xfb, 0xd0, 0x60, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000009000000000000040009b
	/* C2 */
	.octa 0x491001
	/* C3 */
	.octa 0x488000
	/* C5 */
	.octa 0xefb65
	/* C11 */
	.octa 0x80000000000300070000000000001f01
	/* C13 */
	.octa 0x48b141
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffc2c2
	/* C1 */
	.octa 0x2000800000030007fffffffff6cb2000
	/* C2 */
	.octa 0xc2c2c2c2
	/* C3 */
	.octa 0x488000
	/* C5 */
	.octa 0xefb65
	/* C11 */
	.octa 0x80000000000300070000000000001f01
	/* C13 */
	.octa 0xc2c2
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xc2c2c2c2
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000100740060000000000484001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe237fdb2 // ALDUR-V.RI-Q Rt:18 Rn:13 op2:11 imm9:101111111 V:1 op1:00 11100010:11100010
	.inst 0xc2c14a1d // UNSEAL-C.CC-C Cd:29 Cn:16 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0xe28b7452 // ALDUR-R.RI-32 Rt:18 Rn:2 op2:01 imm9:010110111 V:0 op1:10 11100010:11100010
	.inst 0x78cbd160 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:11 00:00 imm9:010111101 0:0 opc:11 111000:111000 size:01
	.inst 0x7865e82d // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:13 Rn:1 10:10 S:0 option:111 Rm:5 1:1 opc:01 111000:111000 size:01
	.inst 0x38565822 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:1 10:10 imm9:101100101 0:0 opc:01 111000:111000 size:00
	.inst 0x427ffc62 // ALDAR-R.R-32 Rt:2 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xba51d3e1 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:31 00:00 cond:1101 Rm:17 111010010:111010010 op:0 sf:1
	.inst 0xda8000ff // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:7 o2:0 0:0 cond:0000 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xd0fb4581 // ADRP-C.I-C Rd:1 immhi:111101101000101100 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c21360
	.zero 557012
	.inst 0xc2c2c2c2
	.zero 12476
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 24552
	.inst 0xc2c2c2c2
	.zero 387908
	.inst 0x0000c2c2
	.zero 66556
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x30, cptr_el3
	orr x30, x30, #0x200
	msr cptr_el3, x30
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c1 // ldr c1, [x30, #0]
	.inst 0xc24007c2 // ldr c2, [x30, #1]
	.inst 0xc2400bc3 // ldr c3, [x30, #2]
	.inst 0xc2400fc5 // ldr c5, [x30, #3]
	.inst 0xc24013cb // ldr c11, [x30, #4]
	.inst 0xc24017cd // ldr c13, [x30, #5]
	.inst 0xc2401bd0 // ldr c16, [x30, #6]
	/* Set up flags and system registers */
	mov x30, #0x00000000
	msr nzcv, x30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x30850032
	msr SCTLR_EL3, x30
	ldr x30, =0x0
	msr S3_6_C1_C2_2, x30 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337e // ldr c30, [c27, #3]
	.inst 0xc28b413e // msr ddc_el3, c30
	isb
	.inst 0x8260137e // ldr c30, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c213c0 // br c30
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr ddc_el3, c30
	isb
	/* Check processor flags */
	mrs x30, nzcv
	ubfx x30, x30, #28, #4
	mov x27, #0xf
	and x30, x30, x27
	cmp x30, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003db // ldr c27, [x30, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24007db // ldr c27, [x30, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400bdb // ldr c27, [x30, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400fdb // ldr c27, [x30, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc24013db // ldr c27, [x30, #4]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24017db // ldr c27, [x30, #5]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401bdb // ldr c27, [x30, #6]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401fdb // ldr c27, [x30, #7]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24023db // ldr c27, [x30, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24027db // ldr c27, [x30, #9]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x30, =0xc2c2c2c2c2c2c2c2
	mov x27, v18.d[0]
	cmp x30, x27
	b.ne comparison_fail
	ldr x30, =0xc2c2c2c2c2c2c2c2
	mov x27, v18.d[1]
	cmp x30, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fbe
	ldr x1, =check_data0
	ldr x2, =0x00001fc0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00488000
	ldr x1, =check_data2
	ldr x2, =0x00488004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0048b0c0
	ldr x1, =check_data3
	ldr x2, =0x0048b0d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004910b8
	ldr x1, =check_data4
	ldr x2, =0x004910bc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004efc00
	ldr x1, =check_data5
	ldr x2, =0x004efc02
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
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr ddc_el3, c30
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
