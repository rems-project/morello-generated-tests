.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x4b, 0x83, 0x44, 0xfa, 0xc1, 0x23, 0xc0, 0x1a, 0xc0, 0x03, 0xa0, 0xea, 0x74, 0xf8, 0xd1, 0xc2
	.byte 0x81, 0xc1, 0x81, 0x5a, 0xe2, 0x5b, 0x66, 0x78, 0xf5, 0x4b, 0xe2, 0x3c, 0x15, 0xe1, 0x27, 0x3d
	.byte 0x93, 0x05, 0x41, 0xb8, 0xd4, 0x2f, 0xda, 0x3c, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc0, 0xff
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x400000000000000000000000
	/* C6 */
	.octa 0xffe
	/* C8 */
	.octa 0x40000000000100050000000000001606
	/* C12 */
	.octa 0x800000000001000500000000004ffff8
	/* C30 */
	.octa 0x8000000040010002000000000000203e
final_cap_values:
	/* C0 */
	.octa 0x203e
	/* C1 */
	.octa 0x4ffff8
	/* C2 */
	.octa 0xffc0
	/* C3 */
	.octa 0x400000000000000000000000
	/* C6 */
	.octa 0xffe
	/* C8 */
	.octa 0x40000000000100050000000000001606
	/* C12 */
	.octa 0x80000000000100050000000000500008
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x423000000000000000000000
	/* C30 */
	.octa 0x80000000400100020000000000001fe0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfa44834b // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:26 00:00 cond:1000 Rm:4 111010010:111010010 op:1 sf:1
	.inst 0x1ac023c1 // lslv:aarch64/instrs/integer/shift/variable Rd:1 Rn:30 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xeaa003c0 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:30 imm6:000000 Rm:0 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xc2d1f874 // SCBNDS-C.CI-S Cd:20 Cn:3 1110:1110 S:1 imm6:100011 11000010110:11000010110
	.inst 0x5a81c181 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:12 o2:0 0:0 cond:1100 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x78665be2 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:31 10:10 S:1 option:010 Rm:6 1:1 opc:01 111000:111000 size:01
	.inst 0x3ce24bf5 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:21 Rn:31 10:10 S:0 option:010 Rm:2 1:1 opc:11 111100:111100 size:00
	.inst 0x3d27e115 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:21 Rn:8 imm12:100111111000 opc:00 111101:111101 size:00
	.inst 0xb8410593 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:19 Rn:12 01:01 imm9:000010000 0:0 opc:01 111000:111000 size:10
	.inst 0x3cda2fd4 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:20 Rn:30 11:11 imm9:110100010 0:0 opc:11 111100:111100 size:00
	.inst 0xc2c212e0
	.zero 8144
	.inst 0x0000ffc0
	.zero 1040384
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008e6 // ldr c6, [x7, #2]
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x20000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850038
	msr SCTLR_EL3, x7
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e7 // ldr c7, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x23, #0xf
	and x7, x7, x23
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f7 // ldr c23, [x7, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004f7 // ldr c23, [x7, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24008f7 // ldr c23, [x7, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400cf7 // ldr c23, [x7, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc24010f7 // ldr c23, [x7, #4]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc24014f7 // ldr c23, [x7, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401cf7 // ldr c23, [x7, #7]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24020f7 // ldr c23, [x7, #8]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc24024f7 // ldr c23, [x7, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x23, v20.d[0]
	cmp x7, x23
	b.ne comparison_fail
	ldr x7, =0x0
	mov x23, v20.d[1]
	cmp x7, x23
	b.ne comparison_fail
	ldr x7, =0x0
	mov x23, v21.d[0]
	cmp x7, x23
	b.ne comparison_fail
	ldr x7, =0x0
	mov x23, v21.d[1]
	cmp x7, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x0, =0x00401ffc
	ldr x1, =check_data3
	ldr x2, =0x00401ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040ffc0
	ldr x1, =check_data4
	ldr x2, =0x0040ffd0
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
