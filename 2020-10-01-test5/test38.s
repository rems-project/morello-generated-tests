.section data0, #alloc, #write
	.zero 4032
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 32
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xf2, 0x90, 0xc1, 0xc2, 0x9e, 0xaf, 0xd7, 0xc2, 0x2c, 0x02, 0x01, 0x3a, 0xc0, 0xd7, 0x9f, 0x9a
	.byte 0xc3, 0x68, 0x43, 0x54
.data
check_data2:
	.byte 0xee, 0xff, 0x77, 0xb9, 0x2c, 0x94, 0x59, 0x78, 0x1e, 0xed, 0x13, 0xca, 0x7e, 0x5f, 0xe3, 0x62
	.byte 0x5c, 0x08, 0x3f, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4ffffc
	/* C17 */
	.octa 0x0
	/* C27 */
	.octa 0x2360
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x4fff95
	/* C12 */
	.octa 0xc2c2
	/* C14 */
	.octa 0xc2c2c2c2
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0x1fc0
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
initial_csp_value:
	.octa 0x4f46b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000608770000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c190f2 // CLRTAG-C.C-C Cd:18 Cn:7 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2d7af9e // CSEL-C.CI-C Cd:30 Cn:28 11:11 cond:1010 Cm:23 11000010110:11000010110
	.inst 0x3a01022c // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:12 Rn:17 000000:000000 Rm:1 11010000:11010000 S:1 op:0 sf:0
	.inst 0x9a9fd7c0 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:30 o2:1 0:0 cond:1101 Rm:31 011010100:011010100 op:0 sf:1
	.inst 0x544368c3 // b_cond:aarch64/instrs/branch/conditional/cond cond:0011 0:0 imm19:0100001101101000110 01010100:01010100
	.zero 552212
	.inst 0xb977ffee // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:31 imm12:110111111111 opc:01 111001:111001 size:10
	.inst 0x7859942c // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:1 01:01 imm9:110011001 0:0 opc:01 111000:111000 size:01
	.inst 0xca13ed1e // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:8 imm6:111011 Rm:19 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0x62e35f7e // LDP-C.RIBW-C Ct:30 Rn:27 Ct2:10111 imm7:1000110 L:1 011000101:011000101
	.inst 0x9b3f085c // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:28 Rn:2 Ra:2 o0:0 Rm:31 01:01 U:0 10011011:10011011
	.inst 0xc2c210c0
	.zero 463212
	.inst 0xc2c2c2c2
	.zero 33100
	.inst 0x0000c2c2
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400531 // ldr c17, [x9, #1]
	.inst 0xc240093b // ldr c27, [x9, #2]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_csp_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085003a
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c9 // ldr c9, [c6, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x826010c9 // ldr c9, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x6, #0xf
	and x9, x9, x6
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400126 // ldr c6, [x9, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401526 // ldr c6, [x9, #5]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401926 // ldr c6, [x9, #6]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2401d26 // ldr c6, [x9, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fc0
	ldr x1, =check_data0
	ldr x2, =0x00001fe0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00486d28
	ldr x1, =check_data2
	ldr x2, =0x00486d40
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004f7eac
	ldr x1, =check_data3
	ldr x2, =0x004f7eb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004ffffe
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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
