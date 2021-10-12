.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data4:
	.byte 0xd8, 0x4b, 0xf8, 0xc2, 0x41, 0xb0, 0x3a, 0xe2, 0xbf, 0x01, 0xcc, 0xc2, 0x3e, 0x00, 0x96, 0x13
	.byte 0xbb, 0x93, 0xbe, 0x62, 0xc1, 0xb1, 0x17, 0x2d, 0x9f, 0xec, 0xd4, 0xf0, 0x42, 0xda, 0xab, 0x9b
	.byte 0xc0, 0xc7, 0x0e, 0xe2, 0xa1, 0x51, 0xc1, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x2016
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x400000000000000000000000
	/* C14 */
	.octa 0x40000000000100070000000000001740
	/* C22 */
	.octa 0x1000
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x4c000000000100070000000000002000
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x400000000000000000000000
	/* C14 */
	.octa 0x40000000000100070000000000001740
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0x3fff80000000c200000000000000
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x4c000000000100070000000000001fd0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f84bd8 // ORRFLGS-C.CI-C Cd:24 Cn:30 0:0 01:01 imm8:11000010 11000010111:11000010111
	.inst 0xe23ab041 // ASTUR-V.RI-B Rt:1 Rn:2 op2:00 imm9:110101011 V:1 op1:00 11100010:11100010
	.inst 0xc2cc01bf // SCBNDS-C.CR-C Cd:31 Cn:13 000:000 opc:00 0:0 Rm:12 11000010110:11000010110
	.inst 0x1396003e // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:30 Rn:1 imms:000000 Rm:22 0:0 N:0 00100111:00100111 sf:0
	.inst 0x62be93bb // STP-C.RIBW-C Ct:27 Rn:29 Ct2:00100 imm7:1111101 L:0 011000101:011000101
	.inst 0x2d17b1c1 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:14 Rt2:01100 imm7:0101111 L:0 1011010:1011010 opc:00
	.inst 0xf0d4ec9f // ADRP-C.I-C Rd:31 immhi:101010011101100100 P:1 10000:10000 immlo:11 op:1
	.inst 0x9babda42 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:18 Ra:22 o0:1 Rm:11 01:01 U:1 10011011:10011011
	.inst 0xe20ec7c0 // ALDURB-R.RI-32 Rt:0 Rn:30 op2:01 imm9:011101100 V:0 op1:00 11100010:11100010
	.inst 0xc2c151a1 // CFHI-R.C-C Rd:1 Cn:13 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400062 // ldr c2, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2401076 // ldr c22, [x3, #4]
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc240187d // ldr c29, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q1, =0x0
	ldr q12, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603383 // ldr c3, [c28, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601383 // ldr c3, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007c // ldr c28, [x3, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240047c // ldr c28, [x3, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240087c // ldr c28, [x3, #2]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc2400c7c // ldr c28, [x3, #3]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc240107c // ldr c28, [x3, #4]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240187c // ldr c28, [x3, #6]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc240207c // ldr c28, [x3, #8]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240247c // ldr c28, [x3, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x28, v1.d[0]
	cmp x3, x28
	b.ne comparison_fail
	ldr x3, =0x0
	mov x28, v1.d[1]
	cmp x3, x28
	b.ne comparison_fail
	ldr x3, =0x0
	mov x28, v12.d[0]
	cmp x3, x28
	b.ne comparison_fail
	ldr x3, =0x0
	mov x28, v12.d[1]
	cmp x3, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010ec
	ldr x1, =check_data0
	ldr x2, =0x000010ed
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc1
	ldr x1, =check_data2
	ldr x2, =0x00001fc2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
