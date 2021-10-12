.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x5a, 0x78, 0x13, 0xc2, 0x5f, 0x33, 0x03, 0xd5, 0x41, 0x44, 0xdd, 0xc2, 0x44, 0x4e, 0x80, 0x82
	.byte 0x03, 0xc8, 0x39, 0x39, 0xcb, 0x20, 0x40, 0x3a, 0xe0, 0x03, 0xc0, 0x5a, 0x5f, 0x85, 0x45, 0x34
.data
check_data4:
	.byte 0x96, 0x10, 0xc7, 0xc2, 0x82, 0xa2, 0x0d, 0x02, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000600100050000000000001000
	/* C2 */
	.octa 0x4800000000070006ffffffffffffd120
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C18 */
	.octa 0x840
	/* C20 */
	.octa 0x7200300000000000e0000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x2000000010700874000000080000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4800000000070006ffffffffffffd120
	/* C2 */
	.octa 0x7200300000000000e0368
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C18 */
	.octa 0x840
	/* C20 */
	.octa 0x7200300000000000e0000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x2000000010700874000000080000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200980050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000000000000904920e00000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc213785a // STR-C.RIB-C Ct:26 Rn:2 imm12:010011011110 L:0 110000100:110000100
	.inst 0xd503335f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0011 11010101000000110011:11010101000000110011
	.inst 0xc2dd4441 // CSEAL-C.C-C Cd:1 Cn:2 001:001 opc:10 0:0 Cm:29 11000010110:11000010110
	.inst 0x82804e44 // ASTRH-R.RRB-32 Rt:4 Rn:18 opc:11 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x3939c803 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:0 imm12:111001110010 opc:00 111001:111001 size:00
	.inst 0x3a4020cb // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:6 00:00 cond:0010 Rm:0 111010010:111010010 op:0 sf:0
	.inst 0x5ac003e0 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:31 101101011000000000000:101101011000000000000 sf:0
	.inst 0x3445855f // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0100010110000101010 op:0 011010:011010 sf:0
	.zero 569508
	.inst 0xc2c71096 // RRLEN-R.R-C Rd:22 Rn:4 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x020da282 // ADD-C.CIS-C Cd:2 Cn:20 imm12:001101101000 sh:0 A:0 00000010:00000010
	.inst 0xc2c212e0
	.zero 479024
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b7a // ldr c26, [x27, #6]
	.inst 0xc2401f7d // ldr c29, [x27, #7]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032fb // ldr c27, [c23, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x826012fb // ldr c27, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x23, #0xf
	and x27, x27, x23
	cmp x27, #0xb
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
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401377 // ldr c23, [x27, #4]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401777 // ldr c23, [x27, #5]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401f77 // ldr c23, [x27, #7]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402377 // ldr c23, [x27, #8]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402777 // ldr c23, [x27, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001840
	ldr x1, =check_data0
	ldr x2, =0x00001842
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e72
	ldr x1, =check_data1
	ldr x2, =0x00001e73
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f00
	ldr x1, =check_data2
	ldr x2, =0x00001f10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0048b0c4
	ldr x1, =check_data4
	ldr x2, =0x0048b0d0
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
