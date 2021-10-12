.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x3e
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x6c, 0xe0, 0x2c, 0x32, 0x02, 0x87, 0x3f, 0xfd, 0x0d, 0x00, 0x04, 0x5a, 0xc2, 0x13, 0xc1, 0xc2
	.byte 0xc0, 0xfb, 0x62, 0x78, 0x5f, 0x3c, 0x03, 0xd5, 0x72, 0x10, 0x19, 0xb1, 0xde, 0x7e, 0x9f, 0x08
	.byte 0xc3, 0x4d, 0x1e, 0xe2, 0x5e, 0xc8, 0xf8, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x8000000000010005000000000050001a
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0xffffffffffffa098
	/* C30 */
	.octa 0x2007e005000000000000123e
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffffff
	/* C3 */
	.octa 0x0
	/* C14 */
	.octa 0x8000000000010005000000000050001a
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0xffffffffffffa098
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020000280000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600208020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x322ce06c // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:12 Rn:3 imms:111000 immr:101100 N:0 100100:100100 opc:01 sf:0
	.inst 0xfd3f8702 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:2 Rn:24 imm12:111111100001 opc:00 111101:111101 size:11
	.inst 0x5a04000d // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:13 Rn:0 000000:000000 Rm:4 11010000:11010000 S:0 op:1 sf:0
	.inst 0xc2c113c2 // GCLIM-R.C-C Rd:2 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x7862fbc0 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:30 10:10 S:1 option:111 Rm:2 1:1 opc:01 111000:111000 size:01
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0xb1191072 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:18 Rn:3 imm12:011001000100 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x089f7ede // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:22 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe21e4dc3 // ALDURSB-R.RI-32 Rt:3 Rn:14 op2:11 imm9:111100100 V:0 op1:00 11100010:11100010
	.inst 0xc2f8c85e // ORRFLGS-C.CI-C Cd:30 Cn:2 0:0 01:01 imm8:11000110 11000010111:11000010111
	.inst 0xc2c21120
	.zero 1048532
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
	.inst 0xc240020e // ldr c14, [x16, #0]
	.inst 0xc2400616 // ldr c22, [x16, #1]
	.inst 0xc2400a18 // ldr c24, [x16, #2]
	.inst 0xc2400e1e // ldr c30, [x16, #3]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q2, =0x0
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603130 // ldr c16, [c9, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601130 // ldr c16, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	.inst 0xc2400209 // ldr c9, [x16, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400609 // ldr c9, [x16, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400a09 // ldr c9, [x16, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401209 // ldr c9, [x16, #4]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401609 // ldr c9, [x16, #5]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401a09 // ldr c9, [x16, #6]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x9, v2.d[0]
	cmp x16, x9
	b.ne comparison_fail
	ldr x16, =0x0
	mov x9, v2.d[1]
	cmp x16, x9
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
	ldr x0, =0x0000123c
	ldr x1, =check_data1
	ldr x2, =0x0000123e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fa0
	ldr x1, =check_data2
	ldr x2, =0x00001fa8
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
