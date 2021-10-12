.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc1, 0x92, 0xc5, 0xc2, 0x3c, 0xf3, 0xea, 0xb0, 0xe1, 0x49, 0x0f, 0x90, 0x02, 0x35, 0xb1, 0xea
	.byte 0xbc, 0x48, 0xab, 0xb8, 0xc0, 0x13, 0xc7, 0xc2, 0x0b, 0x30, 0x57, 0x3a, 0x31, 0x26, 0xa1, 0x50
	.byte 0xca, 0x7f, 0x9f, 0xc8, 0x82, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x8000000000098006fffffffffffe4a1e
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x43b5de
	/* C12 */
	.octa 0x20008000480000020000000000400040
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x80800040004001
	/* C30 */
	.octa 0x40000000580400060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x4000032007000080081e93c000
	/* C2 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x8000000000098006fffffffffffe4a1e
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x43b5de
	/* C12 */
	.octa 0x20008000480000020000000000400040
	/* C17 */
	.octa 0x200080000805000400000000003424e2
	/* C22 */
	.octa 0x80800040004001
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000580400060000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080500040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000320070000800800000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c592c1 // CVTD-C.R-C Cd:1 Rn:22 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xb0eaf33c // ADRP-C.IP-C Rd:28 immhi:110101011110011001 P:1 10000:10000 immlo:01 op:1
	.inst 0x900f49e1 // ADRP-C.I-C Rd:1 immhi:000111101001001111 P:0 10000:10000 immlo:00 op:1
	.inst 0xeab13502 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:8 imm6:001101 Rm:17 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xb8ab48bc // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:28 Rn:5 10:10 S:0 option:010 Rm:11 1:1 opc:10 111000:111000 size:10
	.inst 0xc2c713c0 // RRLEN-R.R-C Rd:0 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3a57300b // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:0 00:00 cond:0011 Rm:23 111010010:111010010 op:0 sf:0
	.inst 0x50a12631 // ADR-C.I-C Rd:17 immhi:010000100100110001 P:1 10000:10000 immlo:10 op:0
	.inst 0xc89f7fca // stllr:aarch64/instrs/memory/ordered Rt:10 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c21182 // BRS-C-C 00010:00010 Cn:12 100:100 opc:00 11000010110000100:11000010110000100
	.zero 24
	.inst 0xc2c21360
	.zero 1048508
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
	.inst 0xc24000e5 // ldr c5, [x7, #0]
	.inst 0xc24004e8 // ldr c8, [x7, #1]
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2400ceb // ldr c11, [x7, #3]
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc24014f1 // ldr c17, [x7, #5]
	.inst 0xc24018f6 // ldr c22, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603367 // ldr c7, [c27, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601367 // ldr c7, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000fb // ldr c27, [x7, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24004fb // ldr c27, [x7, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24008fb // ldr c27, [x7, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400cfb // ldr c27, [x7, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24010fb // ldr c27, [x7, #4]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc24014fb // ldr c27, [x7, #5]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc24018fb // ldr c27, [x7, #6]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401cfb // ldr c27, [x7, #7]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc24020fb // ldr c27, [x7, #8]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc24024fb // ldr c27, [x7, #9]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc24028fb // ldr c27, [x7, #10]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc2402cfb // ldr c27, [x7, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400040
	ldr x1, =check_data2
	ldr x2, =0x00400044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0041fffc
	ldr x1, =check_data3
	ldr x2, =0x00420000
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
