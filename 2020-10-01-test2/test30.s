.section data0, #alloc, #write
	.zero 1872
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x04, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
	.zero 2176
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x04, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xe1, 0x33, 0xc2, 0xc2, 0xcd, 0x08, 0xc0, 0xda, 0xfe, 0xf7, 0x70, 0xe2, 0x3a, 0x74, 0xed, 0x22
	.byte 0xfd, 0x4b, 0xdb, 0xc2, 0x40, 0x64, 0xc3, 0xc2, 0xc0, 0x1b, 0xe2, 0xc2, 0x5f, 0x3e, 0x03, 0xd5
	.byte 0xc1, 0x84, 0xc9, 0xc2, 0x4f, 0x95, 0x82, 0x79, 0x80, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90000000000d00070000000000001750
	/* C2 */
	.octa 0x40f9807e0000000000004000
	/* C3 */
	.octa 0xffffffffff8000
	/* C6 */
	.octa 0x11a005007fffffffffe000
	/* C9 */
	.octa 0x300720470040000000000001
	/* C10 */
	.octa 0x80000000000100050000000000001eb2
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x8007c38700ffffffffffc400
final_cap_values:
	/* C0 */
	.octa 0x8007c3870000000000000380
	/* C1 */
	.octa 0x90000000000d000700000000000014f0
	/* C2 */
	.octa 0x40f9807e0000000000004000
	/* C3 */
	.octa 0xffffffffff8000
	/* C6 */
	.octa 0x11a005007fffffffffe000
	/* C9 */
	.octa 0x300720470040000000000001
	/* C10 */
	.octa 0x80000000000100050000000000001eb2
	/* C13 */
	.octa 0xffff7f0000e0ffff
	/* C15 */
	.octa 0xffffffffffffc2c2
	/* C26 */
	.octa 0xc2c2040180c2c2c2c2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8007c38700ffffffffffc400
initial_csp_value:
	.octa 0x410031
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003f0600020000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001750
	.dword 0x0000000000001760
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c233e1 // CHKTGD-C-C 00001:00001 Cn:31 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xdac008cd // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:13 Rn:6 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe270f7fe // ALDUR-V.RI-H Rt:30 Rn:31 op2:01 imm9:100001111 V:1 op1:01 11100010:11100010
	.inst 0x22ed743a // LDP-CC.RIAW-C Ct:26 Rn:1 Ct2:11101 imm7:1011010 L:1 001000101:001000101
	.inst 0xc2db4bfd // UNSEAL-C.CC-C Cd:29 Cn:31 0010:0010 opc:01 Cm:27 11000010110:11000010110
	.inst 0xc2c36440 // CPYVALUE-C.C-C Cd:0 Cn:2 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0xc2e21bc0 // CVT-C.CR-C Cd:0 Cn:30 0110:0110 0:0 0:0 Rm:2 11000010111:11000010111
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0xc2c984c1 // CHKSS-_.CC-C 00001:00001 Cn:6 001:001 opc:00 1:1 Cm:9 11000010110:11000010110
	.inst 0x7982954f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:10 imm12:000010100101 opc:10 111001:111001 size:01
	.inst 0xc2c21380
	.zero 65300
	.inst 0x0000c2c2
	.zero 983228
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2401afb // ldr c27, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_csp_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603397 // ldr c23, [c28, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601397 // ldr c23, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x28, #0xf
	and x23, x23, x28
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fc // ldr c28, [x23, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006fc // ldr c28, [x23, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400afc // ldr c28, [x23, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc24016fc // ldr c28, [x23, #5]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401afc // ldr c28, [x23, #6]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2401efc // ldr c28, [x23, #7]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc24022fc // ldr c28, [x23, #8]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc24026fc // ldr c28, [x23, #9]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc2402afc // ldr c28, [x23, #10]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc2402efc // ldr c28, [x23, #11]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc24032fc // ldr c28, [x23, #12]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0xc2c2
	mov x28, v30.d[0]
	cmp x23, x28
	b.ne comparison_fail
	ldr x23, =0x0
	mov x28, v30.d[1]
	cmp x23, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001750
	ldr x1, =check_data0
	ldr x2, =0x00001770
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
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
	ldr x0, =0x0040ff40
	ldr x1, =check_data3
	ldr x2, =0x0040ff42
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
