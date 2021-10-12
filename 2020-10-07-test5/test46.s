.section data0, #alloc, #write
	.zero 2320
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 272
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1392
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0x52, 0x78, 0x48, 0xfd, 0x3f, 0x36, 0xd4, 0x90, 0xdf, 0x03, 0xdf, 0xc2, 0x7e, 0x8a, 0x48, 0x38
	.byte 0x62, 0x3e, 0x46, 0x28, 0x08, 0x3c, 0x6f, 0xb9, 0xa1, 0x61, 0x59, 0xa8, 0x5f, 0x1a, 0x68, 0xb9
	.byte 0xc0, 0xaf, 0x9a, 0xf9, 0x02, 0xc0, 0xdf, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fd0bc
	/* C2 */
	.octa 0x80000000580008020000000000400010
	/* C13 */
	.octa 0x80000000000100050000000000001780
	/* C18 */
	.octa 0x800000000001000500000000004fd7e0
	/* C19 */
	.octa 0x80000000000300070000000000001a00
	/* C30 */
	.octa 0x800300070000000000000000
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fd0bc
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C2 */
	.octa 0x4fd0bc
	/* C8 */
	.octa 0xc2c2c2c2
	/* C13 */
	.octa 0x80000000000100050000000000001780
	/* C15 */
	.octa 0xc2c2c2c2
	/* C18 */
	.octa 0x800000000001000500000000004fd7e0
	/* C19 */
	.octa 0x80000000000300070000000000001a00
	/* C24 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C30 */
	.octa 0xc2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfd487852 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:18 Rn:2 imm12:001000011110 opc:01 111101:111101 size:11
	.inst 0x90d4363f // ADRP-C.IP-C Rd:31 immhi:101010000110110001 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2df03df // SCBNDS-C.CR-C Cd:31 Cn:30 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0x38488a7e // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:19 10:10 imm9:010001000 0:0 opc:01 111000:111000 size:00
	.inst 0x28463e62 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:19 Rt2:01111 imm7:0001100 L:1 1010000:1010000 opc:00
	.inst 0xb96f3c08 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:0 imm12:101111001111 opc:01 111001:111001 size:10
	.inst 0xa85961a1 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:13 Rt2:11000 imm7:0110010 L:1 1010000:1010000 opc:10
	.inst 0xb9681a5f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:18 imm12:101000000110 opc:01 111001:111001 size:10
	.inst 0xf99aafc0 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:30 imm12:011010101011 opc:10 111001:111001 size:11
	.inst 0xc2dfc002 // CVT-R.CC-C Rd:2 Cn:0 110000:110000 Cm:31 11000010110:11000010110
	.inst 0xc2c212e0
	.zero 4308
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1044208
	.inst 0xc2c2c2c2
	.zero 4
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2400f72 // ldr c18, [x27, #3]
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012fb // ldr c27, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x23, #0xf
	and x27, x27, x23
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400377 // ldr c23, [x27, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400777 // ldr c23, [x27, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400b77 // ldr c23, [x27, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400f77 // ldr c23, [x27, #3]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401377 // ldr c23, [x27, #4]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401777 // ldr c23, [x27, #5]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401f77 // ldr c23, [x27, #7]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402377 // ldr c23, [x27, #8]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2402777 // ldr c23, [x27, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0xc2c2c2c2c2c2c2c2
	mov x23, v18.d[0]
	cmp x27, x23
	b.ne comparison_fail
	ldr x27, =0x0
	mov x23, v18.d[1]
	cmp x27, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001910
	ldr x1, =check_data0
	ldr x2, =0x00001920
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a30
	ldr x1, =check_data1
	ldr x2, =0x00001a38
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a88
	ldr x1, =check_data2
	ldr x2, =0x00001a89
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
	ldr x0, =0x00401100
	ldr x1, =check_data4
	ldr x2, =0x00401108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
