.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xc3, 0x13, 0xc2, 0xc2, 0x01, 0x84, 0xd5, 0xc2, 0xc0, 0x50, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xe2, 0x10, 0xc0, 0xc2, 0x41, 0x10, 0xc2, 0xc2, 0x82, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0xb4, 0xce, 0xa0, 0x18, 0x0e, 0xf7, 0xdd, 0x78, 0x40, 0x24, 0xd8, 0x0a, 0x46, 0x81, 0xf9, 0xb0
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400240020000000000008000
	/* C6 */
	.octa 0x20008000c000dffe000000000041fff4
	/* C7 */
	.octa 0x20000000000000000
	/* C12 */
	.octa 0xa00080008003000700000000004be80d
	/* C21 */
	.octa 0x207008700ffffffffffe000
	/* C24 */
	.octa 0x800000000e3f4e3f0000000000408e32
	/* C30 */
	.octa 0x20000000800100070000000000400004
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0xa000800000030007fffffffff34e7000
	/* C7 */
	.octa 0x20000000000000000
	/* C12 */
	.octa 0xa00080008003000700000000004be80d
	/* C14 */
	.octa 0xffffc2c2
	/* C20 */
	.octa 0xc2c2c2c2
	/* C21 */
	.octa 0x207008700ffffffffffe000
	/* C24 */
	.octa 0x800000000e3f4e3f0000000000408e11
	/* C30 */
	.octa 0x20000000800100070000000000400004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c213c3 // BRR-C-C 00011:00011 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2d58401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:21 11000010110:11000010110
	.inst 0xc2c250c0 // RET-C-C 00000:00000 Cn:6 100:100 opc:10 11000010110000100:11000010110000100
	.zero 468
	.inst 0xc2c2c2c2
	.zero 35916
	.inst 0xc2c20000
	.zero 94656
	.inst 0xc2c010e2 // GCBASE-R.C-C Rd:2 Cn:7 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c21041 // CHKSLD-C-C 00001:00001 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c25182 // RETS-C-C 00010:00010 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 649228
	.inst 0x18a0ceb4 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:20 imm19:1010000011001110101 011000:011000 opc:00
	.inst 0x78ddf70e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:14 Rn:24 01:01 imm9:111011111 0:0 opc:11 111000:111000 size:01
	.inst 0x0ad82440 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:2 imm6:001001 Rm:24 N:0 shift:11 01010:01010 opc:00 sf:0
	.inst 0xb0f98146 // ADRP-C.I-C Rd:6 immhi:111100110000001010 P:1 10000:10000 immlo:01 op:1
	.inst 0xc2c21260
	.zero 268256
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2401175 // ldr c21, [x11, #4]
	.inst 0xc2401578 // ldr c24, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260126b // ldr c11, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x19, #0xf
	and x11, x11, x19
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400173 // ldr c19, [x11, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400573 // ldr c19, [x11, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402173 // ldr c19, [x11, #8]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402573 // ldr c19, [x11, #9]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040000c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004001e0
	ldr x1, =check_data1
	ldr x2, =0x004001e4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00408e32
	ldr x1, =check_data2
	ldr x2, =0x00408e34
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0041fff4
	ldr x1, =check_data3
	ldr x2, =0x00420000
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004be80c
	ldr x1, =check_data4
	ldr x2, =0x004be820
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
