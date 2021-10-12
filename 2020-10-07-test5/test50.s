.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x80, 0x09, 0xc0, 0xda, 0x82, 0x05, 0xd0, 0xc2, 0x64, 0x4a, 0x20, 0xe2, 0x9c, 0x06, 0x3b, 0x29
	.byte 0x4d, 0x04, 0x71, 0x39, 0x13, 0xb7, 0x11, 0x7c, 0x20, 0x32, 0xc7, 0xc2, 0xe7, 0x93, 0xc6, 0xc2
	.byte 0x3f, 0xd0, 0x38, 0x8b, 0x9e, 0xdc, 0x00, 0xf8, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1003
	/* C12 */
	.octa 0x400
	/* C16 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000030007000000000000100c
	/* C20 */
	.octa 0x1050
	/* C24 */
	.octa 0x1018
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400
	/* C4 */
	.octa 0x1010
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x400
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000030007000000000000100c
	/* C20 */
	.octa 0x1050
	/* C24 */
	.octa 0xf33
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000001f00000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00980 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:12 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2d00582 // BUILD-C.C-C Cd:2 Cn:12 001:001 opc:00 0:0 Cm:16 11000010110:11000010110
	.inst 0xe2204a64 // ASTUR-V.RI-Q Rt:4 Rn:19 op2:10 imm9:000000100 V:1 op1:00 11100010:11100010
	.inst 0x293b069c // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:28 Rn:20 Rt2:00001 imm7:1110110 L:0 1010010:1010010 opc:00
	.inst 0x3971044d // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:2 imm12:110001000001 opc:01 111001:111001 size:00
	.inst 0x7c11b713 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:19 Rn:24 01:01 imm9:100011011 0:0 opc:00 111100:111100 size:01
	.inst 0xc2c73220 // RRMASK-R.R-C Rd:0 Rn:17 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c693e7 // CLRPERM-C.CI-C Cd:7 Cn:31 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x8b38d03f // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:1 imm3:100 option:110 Rm:24 01011001:01011001 S:0 op:0 sf:1
	.inst 0xf800dc9e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:4 11:11 imm9:000001101 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2400a4c // ldr c12, [x18, #2]
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc2401251 // ldr c17, [x18, #4]
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2401a54 // ldr c20, [x18, #6]
	.inst 0xc2401e58 // ldr c24, [x18, #7]
	.inst 0xc240225c // ldr c28, [x18, #8]
	.inst 0xc240265e // ldr c30, [x18, #9]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q4, =0x0
	ldr q19, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603152 // ldr c18, [c10, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601152 // ldr c18, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024a // ldr c10, [x18, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a4a // ldr c10, [x18, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240124a // ldr c10, [x18, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240164a // ldr c10, [x18, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc2401a4a // ldr c10, [x18, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401e4a // ldr c10, [x18, #7]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240224a // ldr c10, [x18, #8]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240264a // ldr c10, [x18, #9]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2402a4a // ldr c10, [x18, #10]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2402e4a // ldr c10, [x18, #11]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240324a // ldr c10, [x18, #12]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240364a // ldr c10, [x18, #13]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x10, v4.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v4.d[1]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v19.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v19.d[1]
	cmp x18, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001041
	ldr x1, =check_data2
	ldr x2, =0x00001042
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
