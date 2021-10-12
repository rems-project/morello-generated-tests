.section data0, #alloc, #write
	.zero 2304
	.byte 0xf0, 0x08, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xe8, 0x00, 0x80, 0x00, 0x20
	.zero 1776
.data
check_data0:
	.byte 0x05, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xf0, 0x08, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xe8, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xff
.data
check_data5:
	.byte 0x02, 0xe4, 0x00, 0x78, 0x3b, 0x50, 0xc1, 0xc2, 0x00, 0x70, 0xd1, 0xc2
.data
check_data6:
	.byte 0x23, 0x30, 0xc0, 0xc2, 0x3f, 0x00, 0xc0, 0x5a, 0x8b, 0x17, 0x5c, 0x6b, 0x1b, 0xf2, 0x88, 0x29
	.byte 0xe3, 0xb7, 0x50, 0x82, 0x24, 0xa4, 0xde, 0x93, 0xc2, 0xdb, 0x13, 0x78, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0000000000300070000000000001842
	/* C1 */
	.octa 0x110050000000000000001
	/* C2 */
	.octa 0x0
	/* C16 */
	.octa 0xfbc
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x2051
final_cap_values:
	/* C0 */
	.octa 0xd0000000000300070000000000001850
	/* C1 */
	.octa 0x110050000000000000001
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xffffffffffffffff
	/* C4 */
	.octa 0x800000
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C27 */
	.octa 0x11005
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x2051
initial_SP_EL3_value:
	.octa 0x40000000008140050000000000001ef0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000006000300ffffffff000009
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001900
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7800e402 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:000001110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c1503b // CFHI-R.C-C Rd:27 Cn:1 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2d17000 // BR-CI-C 0:0 0000:0000 Cn:0 100:100 imm7:0001011 110000101101:110000101101
	.zero 2276
	.inst 0xc2c03023 // GCLEN-R.C-C Rd:3 Cn:1 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x5ac0003f // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:1 101101011000000000000:101101011000000000000 sf:0
	.inst 0x6b5c178b // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:11 Rn:28 imm6:000101 Rm:28 0:0 shift:01 01011:01011 S:1 op:1 sf:0
	.inst 0x2988f21b // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:27 Rn:16 Rt2:11100 imm7:0010001 L:0 1010011:1010011 opc:00
	.inst 0x8250b7e3 // ASTRB-R.RI-B Rt:3 Rn:31 op:01 imm9:100001011 L:0 1000001001:1000001001
	.inst 0x93dea424 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:4 Rn:1 imms:101001 Rm:30 0:0 N:1 00100111:00100111 sf:1
	.inst 0x7813dbc2 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:100111101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c212e0
	.zero 1046256
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc240129c // ldr c28, [x20, #4]
	.inst 0xc240169e // ldr c30, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x3085003a
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f4 // ldr c20, [c23, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826012f4 // ldr c20, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x23, #0xf
	and x20, x20, x23
	cmp x20, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400297 // ldr c23, [x20, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400697 // ldr c23, [x20, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a97 // ldr c23, [x20, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e97 // ldr c23, [x20, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401697 // ldr c23, [x20, #5]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401a97 // ldr c23, [x20, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401e97 // ldr c23, [x20, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402297 // ldr c23, [x20, #8]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402697 // ldr c23, [x20, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001842
	ldr x1, =check_data1
	ldr x2, =0x00001844
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001900
	ldr x1, =check_data2
	ldr x2, =0x00001910
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f8e
	ldr x1, =check_data3
	ldr x2, =0x00001f90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffb
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004008f0
	ldr x1, =check_data6
	ldr x2, =0x00400910
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
