.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xff, 0xff
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x21, 0x50, 0xbe, 0x6d, 0x5e, 0x30, 0xc7, 0xc2, 0xf1, 0xe3, 0xc2, 0xc2, 0x82, 0x60, 0xe2, 0xc2
	.byte 0x22, 0xa0, 0x24, 0x39, 0x5e, 0x7d, 0x9f, 0x48, 0x60, 0xd9, 0xb5, 0x39, 0x5f, 0x10, 0xc0, 0xc2
	.byte 0x41, 0xc0, 0x24, 0xe2, 0x82, 0x26, 0xde, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000100500030000000000001058
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x100070000000000001000
	/* C10 */
	.octa 0x40000000500900020000000000001000
	/* C11 */
	.octa 0x80000000000100050000000000001288
	/* C20 */
	.octa 0xc00300020000000000004001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000100500030000000000001038
	/* C2 */
	.octa 0xc0030002ffffffffffffffff
	/* C4 */
	.octa 0x100070000000000001000
	/* C10 */
	.octa 0x40000000500900020000000000001000
	/* C11 */
	.octa 0x80000000000100050000000000001288
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0xc00300020000000000004001
	/* C30 */
	.octa 0xffffffffffffffff
initial_csp_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005800000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6dbe5021 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:1 Rn:1 Rt2:10100 imm7:1111100 L:0 1011011:1011011 opc:01
	.inst 0xc2c7305e // RRMASK-R.R-C Rd:30 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c2e3f1 // SCFLGS-C.CR-C Cd:17 Cn:31 111000:111000 Rm:2 11000010110:11000010110
	.inst 0xc2e26082 // BICFLGS-C.CI-C Cd:2 Cn:4 0:0 00:00 imm8:00010011 11000010111:11000010111
	.inst 0x3924a022 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:1 imm12:100100101000 opc:00 111001:111001 size:00
	.inst 0x489f7d5e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:10 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x39b5d960 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:11 imm12:110101110110 opc:10 111001:111001 size:00
	.inst 0xc2c0105f // GCBASE-R.C-C Rd:31 Cn:2 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xe224c041 // ASTUR-V.RI-B Rt:1 Rn:2 op2:00 imm9:001001100 V:1 op1:00 11100010:11100010
	.inst 0xc2de2682 // CPYTYPE-C.C-C Cd:2 Cn:20 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c21180
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
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2401514 // ldr c20, [x8, #5]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q1, =0x0
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_csp_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603188 // ldr c8, [c12, #3]
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	.inst 0x82601188 // ldr c8, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010c // ldr c12, [x8, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240050c // ldr c12, [x8, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc240150c // ldr c12, [x8, #5]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240190c // ldr c12, [x8, #6]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc2401d0c // ldr c12, [x8, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240210c // ldr c12, [x8, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x12, v1.d[0]
	cmp x8, x12
	b.ne comparison_fail
	ldr x8, =0x0
	mov x12, v1.d[1]
	cmp x8, x12
	b.ne comparison_fail
	ldr x8, =0x0
	mov x12, v20.d[0]
	cmp x8, x12
	b.ne comparison_fail
	ldr x8, =0x0
	mov x12, v20.d[1]
	cmp x8, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000104d
	ldr x1, =check_data2
	ldr x2, =0x0000104e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001960
	ldr x1, =check_data3
	ldr x2, =0x00001961
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
