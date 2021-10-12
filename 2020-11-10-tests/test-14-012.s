.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
	.zero 1680
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x00, 0x00, 0x00
	.zero 2384
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xe2, 0xfe, 0xee, 0x22, 0x20, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x63, 0x1a, 0xdb, 0xc2, 0x2c, 0xec, 0xc1, 0xc2, 0x21, 0x79, 0xa5, 0x90, 0xee, 0xc3, 0x81, 0x82
	.byte 0x7f, 0x13, 0x21, 0x38, 0xc0, 0xc3, 0x81, 0xe2, 0x3f, 0x31, 0xc7, 0xc2, 0x04, 0xa5, 0x49, 0xc2
	.byte 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200080009b8100070000000000403dc0
	/* C8 */
	.octa 0xfffffffffffff010
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x50000000000000000
	/* C23 */
	.octa 0x1000
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000200700000000000000001028
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffff4b327000
	/* C2 */
	.octa 0x2800000000000000000000000
	/* C3 */
	.octa 0x50000000000000000
	/* C4 */
	.octa 0x40800000000000000000000000
	/* C8 */
	.octa 0xfffffffffffff010
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x200080009b8100070000000000403dc0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x50000000000000000
	/* C23 */
	.octa 0xdd0
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000200700000000000000001028
initial_SP_EL3_value:
	.octa 0x4000000001030007ffffffffb4cda010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000073400020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000006001700ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x00000000000016a0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22eefee2 // LDP-CC.RIAW-C Ct:2 Rn:23 Ct2:11111 imm7:1011101 L:1 001000101:001000101
	.inst 0xc2c21020 // BR-C-C 00000:00000 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 15800
	.inst 0xc2db1a63 // ALIGND-C.CI-C Cd:3 Cn:19 0110:0110 U:0 imm6:110110 11000010110:11000010110
	.inst 0xc2c1ec2c // CSEL-C.CI-C Cd:12 Cn:1 11:11 cond:1110 Cm:1 11000010110:11000010110
	.inst 0x90a57921 // ADRP-C.IP-C Rd:1 immhi:010010101111001001 P:1 10000:10000 immlo:00 op:1
	.inst 0x8281c3ee // ASTRB-R.RRB-B Rt:14 Rn:31 opc:00 S:0 option:110 Rm:1 0:0 L:0 100000101:100000101
	.inst 0x3821137f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:001 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xe281c3c0 // ASTUR-R.RI-32 Rt:0 Rn:30 op2:00 imm9:000011100 V:0 op1:10 11100010:11100010
	.inst 0xc2c7313f // RRMASK-R.R-C Rd:31 Rn:9 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc249a504 // LDR-C.RIB-C Ct:4 Rn:8 imm12:001001101001 L:1 110000100:110000100
	.inst 0xc2c21380
	.zero 1032732
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e8 // ldr c8, [x7, #2]
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2401cfb // ldr c27, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103f
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603387 // ldr c7, [c28, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601387 // ldr c7, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000fc // ldr c28, [x7, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24004fc // ldr c28, [x7, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24008fc // ldr c28, [x7, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400cfc // ldr c28, [x7, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc24010fc // ldr c28, [x7, #4]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc24014fc // ldr c28, [x7, #5]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24018fc // ldr c28, [x7, #6]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401cfc // ldr c28, [x7, #7]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24020fc // ldr c28, [x7, #8]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc24024fc // ldr c28, [x7, #9]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc24028fc // ldr c28, [x7, #10]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2402cfc // ldr c28, [x7, #11]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24030fc // ldr c28, [x7, #12]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001044
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016a0
	ldr x1, =check_data2
	ldr x2, =0x000016b0
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
	ldr x0, =0x00403dc0
	ldr x1, =check_data4
	ldr x2, =0x00403de4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
