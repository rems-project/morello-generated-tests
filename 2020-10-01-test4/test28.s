.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x20, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x20, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x02
.data
check_data6:
	.byte 0x21, 0x48, 0x2e, 0xa2, 0x40, 0x69, 0xde, 0xc2, 0xf6, 0x7f, 0xdf, 0x48, 0x3f, 0x40, 0x22, 0x39
	.byte 0x0a, 0x04, 0xc0, 0x5a, 0x20, 0x18, 0x50, 0x6d, 0xcf, 0x03, 0x17, 0xe2, 0xc1, 0x54, 0xf6, 0x22
	.byte 0x9e, 0x69, 0xde, 0xc2, 0x18, 0x50, 0xc0, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20400000000000000000000006
	/* C6 */
	.octa 0xe
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x38
	/* C15 */
	.octa 0x2
	/* C30 */
	.octa 0x40000000000100050000000000001c08
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x20100000000000000000000000
	/* C6 */
	.octa 0xfffffffffffffece
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x38
	/* C15 */
	.octa 0x2
	/* C21 */
	.octa 0x20000000000000000000000000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x660
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001001c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc0000006001100200ffffffffffff01
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa22e4821 // STR-C.RRB-C Ct:1 Rn:1 10:10 S:0 option:010 Rm:14 1:1 opc:00 10100010:10100010
	.inst 0xc2de6940 // ORRFLGS-C.CR-C Cd:0 Cn:10 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0x48df7ff6 // ldlarh:aarch64/instrs/memory/ordered Rt:22 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x3922403f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:1 imm12:100010010000 opc:00 111001:111001 size:00
	.inst 0x5ac0040a // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:10 Rn:0 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x6d501820 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:1 Rt2:00110 imm7:0100000 L:1 1011010:1011010 opc:01
	.inst 0xe21703cf // ASTURB-R.RI-32 Rt:15 Rn:30 op2:00 imm9:101110000 V:0 op1:00 11100010:11100010
	.inst 0x22f654c1 // LDP-CC.RIAW-C Ct:1 Rn:6 Ct2:10101 imm7:1101100 L:1 001000101:001000101
	.inst 0xc2de699e // ORRFLGS-C.CR-C Cd:30 Cn:12 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xc2c05018 // GCVALUE-R.C-C Rd:24 Cn:0 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21040
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2400b4a // ldr c10, [x26, #2]
	.inst 0xc2400f4c // ldr c12, [x26, #3]
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260305a // ldr c26, [c2, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260105a // ldr c26, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400342 // ldr c2, [x26, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2400f42 // ldr c2, [x26, #3]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2401342 // ldr c2, [x26, #4]
	.inst 0xc2c2a581 // chkeq c12, c2
	b.ne comparison_fail
	.inst 0xc2401742 // ldr c2, [x26, #5]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401b42 // ldr c2, [x26, #6]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401f42 // ldr c2, [x26, #7]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2402342 // ldr c2, [x26, #8]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402742 // ldr c2, [x26, #9]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2402b42 // ldr c2, [x26, #10]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x2, v0.d[0]
	cmp x26, x2
	b.ne comparison_fail
	ldr x26, =0x0
	mov x2, v0.d[1]
	cmp x26, x2
	b.ne comparison_fail
	ldr x26, =0x0
	mov x2, v6.d[0]
	cmp x26, x2
	b.ne comparison_fail
	ldr x26, =0x0
	mov x2, v6.d[1]
	cmp x26, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
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
	ldr x0, =0x00001108
	ldr x1, =check_data2
	ldr x2, =0x00001118
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001662
	ldr x1, =check_data3
	ldr x2, =0x00001664
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001898
	ldr x1, =check_data4
	ldr x2, =0x00001899
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001b78
	ldr x1, =check_data5
	ldr x2, =0x00001b79
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
