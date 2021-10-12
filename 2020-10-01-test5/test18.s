.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x1f, 0x10, 0xc1, 0xc2, 0x4d, 0xdc, 0x4f, 0x2d, 0x1d, 0x78, 0xa3, 0x9b, 0x1e, 0x70, 0x1b, 0x18
	.byte 0x01, 0xd3, 0xc5, 0xc2, 0x20, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0x21, 0x11, 0xc2, 0xc2, 0xd9, 0xa3, 0x46, 0x82, 0xd6, 0xd3, 0xc5, 0xc2, 0x43, 0x33, 0x8b, 0x38
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x120460000000010000001
	/* C2 */
	.octa 0x410000
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x400081
	/* C25 */
	.octa 0x4010000000000000000000000000
	/* C26 */
	.octa 0x80000000000500070000000000001f4b
final_cap_values:
	/* C0 */
	.octa 0x120460000000010000001
	/* C1 */
	.octa 0xe80080001006000f0000000000400081
	/* C2 */
	.octa 0x410000
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0xe80080001006000f0000000000001000
	/* C24 */
	.octa 0x400081
	/* C25 */
	.octa 0x4010000000000000000000000000
	/* C26 */
	.octa 0x80000000000500070000000000001f4b
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080003e0640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xe80080001006000f0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1101f // GCLIM-R.C-C Rd:31 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x2d4fdc4d // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:13 Rn:2 Rt2:10111 imm7:0011111 L:1 1011010:1011010 opc:00
	.inst 0x9ba3781d // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:0 Ra:30 o0:0 Rm:3 01:01 U:1 10011011:10011011
	.inst 0x181b701e // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:30 imm19:0001101101110000000 011000:011000 opc:00
	.inst 0xc2c5d301 // CVTDZ-C.R-C Cd:1 Rn:24 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 104
	.inst 0xc2c21121 // CHKSLD-C-C 00001:00001 Cn:9 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x8246a3d9 // ASTR-C.RI-C Ct:25 Rn:30 op:00 imm9:001101010 L:0 1000001001:1000001001
	.inst 0xc2c5d3d6 // CVTDZ-C.R-C Cd:22 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x388b3343 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:26 00:00 imm9:010110011 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c211e0
	.zero 224632
	.inst 0x00001000
	.zero 823792
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc24012f9 // ldr c25, [x23, #4]
	.inst 0xc24016fa // ldr c26, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f7 // ldr c23, [c15, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x826011f7 // ldr c23, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x15, #0xf
	and x23, x23, x15
	cmp x23, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ef // ldr c15, [x23, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006ef // ldr c15, [x23, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc24016ef // ldr c15, [x23, #5]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401aef // ldr c15, [x23, #6]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc2401eef // ldr c15, [x23, #7]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc24022ef // ldr c15, [x23, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc24026ef // ldr c15, [x23, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x15, v13.d[0]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x0
	mov x15, v13.d[1]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x0
	mov x15, v23.d[0]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x0
	mov x15, v23.d[1]
	cmp x23, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016a0
	ldr x1, =check_data0
	ldr x2, =0x000016b0
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
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400080
	ldr x1, =check_data3
	ldr x2, =0x00400094
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0041007c
	ldr x1, =check_data4
	ldr x2, =0x00410084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00436e0c
	ldr x1, =check_data5
	ldr x2, =0x00436e10
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
