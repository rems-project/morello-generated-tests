.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x53, 0x30, 0xc7, 0xc2, 0x20, 0x03, 0x1e, 0x3a, 0x02, 0x24, 0xd2, 0xc2, 0xbe, 0x7b, 0x1f, 0x37
	.byte 0x40, 0xf8, 0x96, 0x2c, 0xa1, 0x7a, 0xef, 0x42, 0xfe, 0x7f, 0xc6, 0x9b, 0x61, 0xbd, 0x19, 0xf8
	.byte 0xc1, 0xa7, 0xc1, 0xc2, 0xc0, 0x91, 0x02, 0x78, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x1105
	/* C14 */
	.octa 0x1013
	/* C18 */
	.octa 0xf04000000000000000000000000
	/* C21 */
	.octa 0x2020
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1ebc
	/* C11 */
	.octa 0x10a0
	/* C14 */
	.octa 0x1013
	/* C18 */
	.octa 0xf04000000000000000000000000
	/* C19 */
	.octa 0xffffffffffffffff
	/* C21 */
	.octa 0x2020
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005000c0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000339000500bf00000000f001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c73053 // RRMASK-R.R-C Rd:19 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x3a1e0320 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:25 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2d22402 // CPYTYPE-C.C-C Cd:2 Cn:0 001:001 opc:01 0:0 Cm:18 11000010110:11000010110
	.inst 0x371f7bbe // tbnz:aarch64/instrs/branch/conditional/test Rt:30 imm14:11101111011101 b40:00011 op:1 011011:011011 b5:0
	.inst 0x2c96f840 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:2 Rt2:11110 imm7:0101101 L:0 1011001:1011001 opc:00
	.inst 0x42ef7aa1 // LDP-C.RIB-C Ct:1 Rn:21 Ct2:11110 imm7:1011110 L:1 010000101:010000101
	.inst 0x9bc67ffe // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:6 10:10 U:1 10011011:10011011
	.inst 0xf819bd61 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:11 11:11 imm9:110011011 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c1a7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0x780291c0 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:14 00:00 imm9:000101001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc240090e // ldr c14, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q0, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a8 // ldr c8, [c13, #3]
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	.inst 0x826011a8 // ldr c8, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x13, #0xf
	and x8, x8, x13
	cmp x8, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010d // ldr c13, [x8, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240050d // ldr c13, [x8, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc240150d // ldr c13, [x8, #5]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240190d // ldr c13, [x8, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401d0d // ldr c13, [x8, #7]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240210d // ldr c13, [x8, #8]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240250d // ldr c13, [x8, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x13, v0.d[0]
	cmp x8, x13
	b.ne comparison_fail
	ldr x8, =0x0
	mov x13, v0.d[1]
	cmp x8, x13
	b.ne comparison_fail
	ldr x8, =0x0
	mov x13, v30.d[0]
	cmp x8, x13
	b.ne comparison_fail
	ldr x8, =0x0
	mov x13, v30.d[1]
	cmp x8, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103c
	ldr x1, =check_data0
	ldr x2, =0x0000103e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a0
	ldr x1, =check_data1
	ldr x2, =0x000010a8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e00
	ldr x1, =check_data2
	ldr x2, =0x00001e20
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
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
