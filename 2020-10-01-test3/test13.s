.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x67, 0x05, 0x44, 0xa2, 0x59, 0x04, 0x82, 0xda, 0x2e, 0x70, 0x05, 0x38, 0x9e, 0x07, 0x66, 0x79
	.byte 0x15, 0x28, 0xde, 0xc2, 0xc3, 0xb5, 0x20, 0xaa, 0x30, 0x7c, 0x9f, 0x48, 0x40, 0x44, 0x5d, 0x4b
	.byte 0x9e, 0x90, 0x61, 0xe2, 0x48, 0xf4, 0x4e, 0x78, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400000000001000500000000000013fc
	/* C2 */
	.octa 0x800000000001000500000000004ffffc
	/* C4 */
	.octa 0x1001
	/* C11 */
	.octa 0x80000000000100070000000000440000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000400000010000000000000000
final_cap_values:
	/* C1 */
	.octa 0x400000000001000500000000000013fc
	/* C2 */
	.octa 0x800000000001000500000000005000eb
	/* C3 */
	.octa 0xffffffffffffffff
	/* C4 */
	.octa 0x1001
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000000100070000000000440400
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffffffb00004
	/* C28 */
	.octa 0x80000000400000010000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000401c0050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2440567 // LDR-C.RIAW-C Ct:7 Rn:11 01:01 imm9:001000000 0:0 opc:01 10100010:10100010
	.inst 0xda820459 // csneg:aarch64/instrs/integer/conditional/select Rd:25 Rn:2 o2:1 0:0 cond:0000 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0x3805702e // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:1 00:00 imm9:001010111 0:0 opc:00 111000:111000 size:00
	.inst 0x7966079e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:28 imm12:100110000001 opc:01 111001:111001 size:01
	.inst 0xc2de2815 // BICFLGS-C.CR-C Cd:21 Cn:0 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0xaa20b5c3 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:14 imm6:101101 Rm:0 N:1 shift:00 01010:01010 opc:01 sf:1
	.inst 0x489f7c30 // stllrh:aarch64/instrs/memory/ordered Rt:16 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4b5d4440 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:2 imm6:010001 Rm:29 0:0 shift:01 01011:01011 S:0 op:1 sf:0
	.inst 0xe261909e // ASTUR-V.RI-H Rt:30 Rn:4 op2:00 imm9:000011001 V:1 op1:01 11100010:11100010
	.inst 0x784ef448 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:2 01:01 imm9:011101111 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc240126b // ldr c11, [x19, #4]
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2401a70 // ldr c16, [x19, #6]
	.inst 0xc2401e7c // ldr c28, [x19, #7]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f3 // ldr c19, [c23, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x23, #0x4
	and x19, x19, x23
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2402277 // ldr c23, [x19, #8]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2402677 // ldr c23, [x19, #9]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2402a77 // ldr c23, [x19, #10]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402e77 // ldr c23, [x19, #11]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2403277 // ldr c23, [x19, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x23, v30.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v30.d[1]
	cmp x19, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101a
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001302
	ldr x1, =check_data1
	ldr x2, =0x00001304
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013fc
	ldr x1, =check_data2
	ldr x2, =0x000013fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001453
	ldr x1, =check_data3
	ldr x2, =0x00001454
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440000
	ldr x1, =check_data5
	ldr x2, =0x00440010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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
