.section data0, #alloc, #write
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3952
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0x85, 0x47, 0xd7, 0xe2, 0x69, 0xd2, 0xc1, 0xc2, 0x52, 0x70, 0x40, 0x6c, 0xd0, 0x6b, 0x58, 0x38
	.byte 0xb4, 0x7e, 0x02, 0x1b, 0x01, 0x13, 0xc2, 0xc2, 0x1f, 0xf8, 0x21, 0x9b, 0x53, 0x80, 0xc0, 0xc2
	.byte 0xa0, 0x05, 0x09, 0x1b, 0xe1, 0x88, 0xde, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C2 */
	.octa 0x800000000001000500000000004f8708
	/* C7 */
	.octa 0x100040000000000000000
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x1104
	/* C30 */
	.octa 0x80000000000100050000000000002078
final_cap_values:
	/* C1 */
	.octa 0x100040000000000000000
	/* C2 */
	.octa 0x800000000001000500000000004f8708
	/* C5 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C7 */
	.octa 0x100040000000000000000
	/* C16 */
	.octa 0xc2
	/* C19 */
	.octa 0x800000000001000500000000004f8708
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x1104
	/* C30 */
	.octa 0x80000000000100050000000000002078
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000100fffffffd000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d74785 // ALDUR-R.RI-64 Rt:5 Rn:28 op2:01 imm9:101110100 V:0 op1:11 11100010:11100010
	.inst 0xc2c1d269 // CPY-C.C-C Cd:9 Cn:19 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x6c407052 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:18 Rn:2 Rt2:11100 imm7:0000000 L:1 1011000:1011000 opc:01
	.inst 0x38586bd0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:30 10:10 imm9:110000110 0:0 opc:01 111000:111000 size:00
	.inst 0x1b027eb4 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:20 Rn:21 Ra:31 o0:0 Rm:2 0011011000:0011011000 sf:0
	.inst 0xc2c21301 // CHKSLD-C-C 00001:00001 Cn:24 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x9b21f81f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:30 o0:1 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2c08053 // SCTAG-C.CR-C Cd:19 Cn:2 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0x1b0905a0 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:13 Ra:1 o0:0 Rm:9 0011011000:0011011000 sf:0
	.inst 0xc2de88e1 // CHKSSU-C.CC-C Cd:1 Cn:7 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1017564
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 30952
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
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc24016fe // ldr c30, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603097 // ldr c23, [c4, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601097 // ldr c23, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	mov x4, #0xf
	and x23, x23, x4
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc24012e4 // ldr c4, [x23, #4]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc24016e4 // ldr c4, [x23, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401ae4 // ldr c4, [x23, #6]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2401ee4 // ldr c4, [x23, #7]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24022e4 // ldr c4, [x23, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0xc2c2c2c2c2c2c2c2
	mov x4, v18.d[0]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0x0
	mov x4, v18.d[1]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0xc2c2c2c2c2c2c2c2
	mov x4, v28.d[0]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0x0
	mov x4, v28.d[1]
	cmp x23, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001078
	ldr x1, =check_data0
	ldr x2, =0x00001080
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
	ldr x0, =0x004f8708
	ldr x1, =check_data3
	ldr x2, =0x004f8718
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
