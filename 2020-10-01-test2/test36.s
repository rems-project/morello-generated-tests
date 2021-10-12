.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x07, 0x80, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xe9, 0x87, 0x4c, 0x38, 0x40, 0x84, 0xc1, 0xc2
.data
check_data4:
	.byte 0xb2, 0x7e, 0x9f, 0x08, 0xa1, 0x11, 0xc7, 0xc2, 0x64, 0xbe, 0x84, 0x70, 0x9e, 0xf3, 0x0d, 0xc2
	.byte 0x4a, 0x28, 0x5b, 0x3a, 0xc1, 0x55, 0x0d, 0x38, 0xc5, 0x8b, 0xd2, 0xc2, 0x61, 0x0a, 0x38, 0xd2
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400008000000000000000000000000
	/* C2 */
	.octa 0x204080080001000500000000004007e8
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C18 */
	.octa 0x22001700e0000000000001
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0xffffffffffffdba0
	/* C30 */
	.octa 0x780070040000000000001
final_cap_values:
	/* C2 */
	.octa 0x204080080001000500000000004007e8
	/* C4 */
	.octa 0x309fbf
	/* C5 */
	.octa 0x780070040000000000001
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x10d5
	/* C18 */
	.octa 0x22001700e0000000000001
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0xffffffffffffdba0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x780070040000000000001
initial_csp_value:
	.octa 0x80000000000100070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005704016400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x384c87e9 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:9 Rn:31 01:01 imm9:011001000 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c18440 // BRS-C.C-C 00000:00000 Cn:2 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.zero 2016
	.inst 0x089f7eb2 // stllrb:aarch64/instrs/memory/ordered Rt:18 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c711a1 // RRLEN-R.R-C Rd:1 Rn:13 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x7084be64 // ADR-C.I-C Rd:4 immhi:000010010111110011 P:1 10000:10000 immlo:11 op:0
	.inst 0xc20df39e // STR-C.RIB-C Ct:30 Rn:28 imm12:001101111100 L:0 110000100:110000100
	.inst 0x3a5b284a // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:2 10:10 cond:0010 imm5:11011 111010010:111010010 op:0 sf:0
	.inst 0x380d55c1 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:14 01:01 imm9:011010101 0:0 opc:00 111000:111000 size:00
	.inst 0xc2d28bc5 // CHKSSU-C.CC-C Cd:5 Cn:30 0010:0010 opc:10 Cm:18 11000010110:11000010110
	.inst 0xd2380a61 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:19 imms:000010 immr:111000 N:0 100100:100100 opc:10 sf:1
	.inst 0xc2c212c0
	.zero 1046516
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2400e2e // ldr c14, [x17, #3]
	.inst 0xc2401232 // ldr c18, [x17, #4]
	.inst 0xc2401635 // ldr c21, [x17, #5]
	.inst 0xc2401a3c // ldr c28, [x17, #6]
	.inst 0xc2401e3e // ldr c30, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x20000000
	msr nzcv, x17
	ldr x17, =initial_csp_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850038
	msr SCTLR_EL3, x17
	ldr x17, =0x8
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d1 // ldr c17, [c22, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x826012d1 // ldr c17, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x22, #0xf
	and x17, x17, x22
	cmp x17, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400236 // ldr c22, [x17, #0]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400636 // ldr c22, [x17, #1]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400a36 // ldr c22, [x17, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401236 // ldr c22, [x17, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401636 // ldr c22, [x17, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401e36 // ldr c22, [x17, #7]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402236 // ldr c22, [x17, #8]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402636 // ldr c22, [x17, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402a36 // ldr c22, [x17, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001360
	ldr x1, =check_data2
	ldr x2, =0x00001370
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004007e8
	ldr x1, =check_data4
	ldr x2, =0x0040080c
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
