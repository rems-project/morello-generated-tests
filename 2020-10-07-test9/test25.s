.section data0, #alloc, #write
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00
	.zero 128
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1904
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xd2, 0x87, 0xc2, 0xe2, 0x83, 0x52, 0xc2, 0xc2, 0xc1, 0x43, 0x5a, 0x38, 0x42, 0xb0, 0xa0, 0xaa
	.byte 0x62, 0x32, 0xc2, 0xc2
.data
check_data3:
	.byte 0x9f, 0x7e, 0xc1, 0x9b, 0x21, 0x7e, 0x41, 0x9b, 0x02, 0x30, 0xc2, 0xc2
.data
check_data4:
	.byte 0xff, 0x01, 0x1f, 0xda, 0xc5, 0xb8, 0x9e, 0x78, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000d00100190000000000400030
	/* C6 */
	.octa 0x400019
	/* C19 */
	.octa 0x20008000800100050000000000400019
	/* C20 */
	.octa 0x200080000007000f0000000000400008
	/* C30 */
	.octa 0x80000000000700060000000000001858
final_cap_values:
	/* C0 */
	.octa 0x20008000d00100190000000000400030
	/* C2 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x5283
	/* C6 */
	.octa 0x400019
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x20008000800100050000000000400019
	/* C20 */
	.octa 0x200080000007000f0000000000400008
	/* C30 */
	.octa 0x20008000000100050000000000400025
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2c287d2 // ALDUR-R.RI-64 Rt:18 Rn:30 op2:01 imm9:000101000 V:0 op1:11 11100010:11100010
	.inst 0xc2c25283 // RETR-C-C 00011:00011 Cn:20 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x385a43c1 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:30 00:00 imm9:110100100 0:0 opc:01 111000:111000 size:00
	.inst 0xaaa0b042 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:101100 Rm:0 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c23262 // BLRS-C-C 00010:00010 Cn:19 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0x9bc17e9f // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:20 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0x9b417e21 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:17 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0xc2c23002 // BLRS-C-C 00010:00010 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 12
	.inst 0xda1f01ff // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:15 000000:000000 Rm:31 11010000:11010000 S:0 op:1 sf:1
	.inst 0x789eb8c5 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:5 Rn:6 10:10 imm9:111101011 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c212a0
	.zero 1048516
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400606 // ldr c6, [x16, #1]
	.inst 0xc2400a13 // ldr c19, [x16, #2]
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b0 // ldr c16, [c21, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017fc
	ldr x1, =check_data0
	ldr x2, =0x000017fd
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001880
	ldr x1, =check_data1
	ldr x2, =0x00001888
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400018
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400030
	ldr x1, =check_data4
	ldr x2, =0x0040003c
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
