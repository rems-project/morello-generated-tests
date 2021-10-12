.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x41, 0xe0, 0x5d, 0x91, 0xc5, 0xb1, 0x0c, 0x8b, 0x42, 0x15, 0x03, 0xa2, 0x9d, 0x2c, 0x32, 0xe2
	.byte 0x60, 0xa0, 0x82, 0x1a, 0xa2, 0x56, 0x9f, 0xaa, 0xe2, 0x33, 0xc7, 0xc2, 0xa2, 0xc2, 0x5e, 0xb8
	.byte 0x62, 0xfe, 0xdf, 0x08, 0x81, 0x3c, 0xbf, 0xd0, 0x40, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x10de
	/* C10 */
	.octa 0x48000000508400010000000000001040
	/* C19 */
	.octa 0x80000000000798070000000000409d02
	/* C21 */
	.octa 0x800000007ff800040000000000404008
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000800007830007000000007eb92000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x10de
	/* C10 */
	.octa 0x48000000508400010000000000001350
	/* C19 */
	.octa 0x80000000000798070000000000409d02
	/* C21 */
	.octa 0x800000007ff800040000000000404008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000078300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005800000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x915de041 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:2 imm12:011101111000 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x8b0cb1c5 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:5 Rn:14 imm6:101100 Rm:12 0:0 shift:00 01011:01011 S:0 op:0 sf:1
	.inst 0xa2031542 // STR-C.RIAW-C Ct:2 Rn:10 01:01 imm9:000110001 0:0 opc:00 10100010:10100010
	.inst 0xe2322c9d // ALDUR-V.RI-Q Rt:29 Rn:4 op2:11 imm9:100100010 V:1 op1:00 11100010:11100010
	.inst 0x1a82a060 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:3 o2:0 0:0 cond:1010 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0xaa9f56a2 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:21 imm6:010101 Rm:31 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c733e2 // RRMASK-R.R-C Rd:2 Rn:31 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xb85ec2a2 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:21 00:00 imm9:111101100 0:0 opc:01 111000:111000 size:10
	.inst 0x08dffe62 // ldarb:aarch64/instrs/memory/ordered Rt:2 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd0bf3c81 // ADRP-C.IP-C Rd:1 immhi:011111100111100100 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c21240
	.zero 1048532
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
	ldr x11, =initial_cap_values
	.inst 0xc2400162 // ldr c2, [x11, #0]
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2401175 // ldr c21, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x80000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324b // ldr c11, [c18, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260124b // ldr c11, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x18, #0x9
	and x11, x11, x18
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400172 // ldr c18, [x11, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401972 // ldr c18, [x11, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x18, v29.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v29.d[1]
	cmp x11, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
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
	ldr x0, =0x00403ff4
	ldr x1, =check_data3
	ldr x2, =0x00403ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00409d02
	ldr x1, =check_data4
	ldr x2, =0x00409d03
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
	.inst 0xc28b412b // msr ddc_el3, c11
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
