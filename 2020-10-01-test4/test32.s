.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xe0, 0x67, 0x2d, 0xa8, 0x42, 0xf8, 0x3a, 0xf1, 0x41, 0xf8, 0xcf, 0xc2, 0x22, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x10, 0x74, 0xc8, 0x82, 0xc6, 0x7f, 0x1f, 0x42, 0xaf, 0x01, 0xde, 0xc2, 0x48, 0x19, 0x62, 0x6a
	.byte 0xec, 0x27, 0xcd, 0xc2, 0xde, 0x43, 0xe1, 0x82, 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xb
	/* C2 */
	.octa 0x1312
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x4ffff2
	/* C9 */
	.octa 0x20008000800100070000000000404001
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x800500070000000000000000
	/* C25 */
	.octa 0x100000000
	/* C30 */
	.octa 0x1b20
final_cap_values:
	/* C0 */
	.octa 0xb
	/* C1 */
	.octa 0x464404540000000000000454
	/* C2 */
	.octa 0x454
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x20008000800100070000000000404001
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x1
	/* C13 */
	.octa 0x800500070000000000000000
	/* C15 */
	.octa 0xdb2000000000000000000000
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x100000000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1410
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000000010007008c849800000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa82d67e0 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:31 Rt2:11001 imm7:1011010 L:0 1010000:1010000 opc:10
	.inst 0xf13af842 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:2 imm12:111010111110 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2cff841 // SCBNDS-C.CI-S Cd:1 Cn:2 1110:1110 S:1 imm6:011111 11000010110:11000010110
	.inst 0xc2c25122 // RETS-C-C 00010:00010 Cn:9 100:100 opc:10 11000010110000100:11000010110000100
	.zero 16368
	.inst 0x82c87410 // ALDRSB-R.RRB-32 Rt:16 Rn:0 opc:01 S:1 option:011 Rm:8 0:0 L:1 100000101:100000101
	.inst 0x421f7fc6 // ASTLR-C.R-C Ct:6 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2de01af // SCBNDS-C.CR-C Cd:15 Cn:13 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0x6a621948 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:8 Rn:10 imm6:000110 Rm:2 N:1 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2cd27ec // CPYTYPE-C.C-C Cd:12 Cn:31 001:001 opc:01 0:0 Cm:13 11000010110:11000010110
	.inst 0x82e143de // ALDR-R.RRB-32 Rt:30 Rn:30 opc:00 S:0 option:010 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xc2c21380
	.zero 1032164
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
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2401aed // ldr c13, [x23, #6]
	.inst 0xc2401ef9 // ldr c25, [x23, #7]
	.inst 0xc24022fe // ldr c30, [x23, #8]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_csp_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603397 // ldr c23, [c28, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601397 // ldr c23, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x23, x23, x28
	cmp x23, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fc // ldr c28, [x23, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006fc // ldr c28, [x23, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400afc // ldr c28, [x23, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24016fc // ldr c28, [x23, #5]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401afc // ldr c28, [x23, #6]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2401efc // ldr c28, [x23, #7]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24022fc // ldr c28, [x23, #8]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc24026fc // ldr c28, [x23, #9]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2402afc // ldr c28, [x23, #10]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2402efc // ldr c28, [x23, #11]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24032fc // ldr c28, [x23, #12]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000012e0
	ldr x1, =check_data0
	ldr x2, =0x000012f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001b20
	ldr x1, =check_data1
	ldr x2, =0x00001b30
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f74
	ldr x1, =check_data2
	ldr x2, =0x00001f78
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404000
	ldr x1, =check_data4
	ldr x2, =0x0040401c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffd
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
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
