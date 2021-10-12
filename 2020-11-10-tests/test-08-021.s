.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x04, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x9d, 0x94, 0x92, 0xda, 0xab, 0x2c, 0x6c, 0xaa, 0xad, 0xec, 0x68, 0x47, 0x63, 0x97, 0x9a
	.byte 0x35, 0x7c, 0x0c, 0xbc, 0xcd, 0x17, 0x00, 0x78, 0x3e, 0x78, 0xa1, 0x9b, 0x6d, 0xd3, 0x77, 0xe2
	.byte 0x40, 0x2c, 0xdc, 0x1a, 0x2e, 0x48, 0xc2, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xd09
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0xa0
	/* C27 */
	.octa 0x40000000080d00030000000000001203
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0x150
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xdd0
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x4
	/* C14 */
	.octa 0xdd0
	/* C27 */
	.octa 0x40000000080d00030000000000001203
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0xbeca51
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000207c0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400410000000000000000007
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x92949d00 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1010010011101000 hw:00 100101:100101 opc:00 sf:1
	.inst 0x6c2cabda // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:26 Rn:30 Rt2:01010 imm7:1011001 L:0 1011000:1011000 opc:01
	.inst 0x68ecadaa // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:10 Rn:13 Rt2:01011 imm7:1011001 L:1 1010001:1010001 opc:01
	.inst 0x9a976347 // csel:aarch64/instrs/integer/conditional/select Rd:7 Rn:26 o2:0 0:0 cond:0110 Rm:23 011010100:011010100 op:0 sf:1
	.inst 0xbc0c7c35 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:21 Rn:1 11:11 imm9:011000111 0:0 opc:00 111100:111100 size:10
	.inst 0x780017cd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:30 01:01 imm9:000000001 0:0 opc:00 111000:111000 size:01
	.inst 0x9ba1783e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:30 o0:0 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xe277d36d // ASTUR-V.RI-H Rt:13 Rn:27 op2:00 imm9:101111101 V:1 op1:01 11100010:11100010
	.inst 0x1adc2c40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:2 op2:11 0010:0010 Rm:28 0011010110:0011010110 sf:0
	.inst 0xc2c2482e // UNSEAL-C.CC-C Cd:14 Cn:1 0010:0010 opc:01 Cm:2 11000010110:11000010110
	.inst 0xc2c21280
	.zero 1048532
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aad // ldr c13, [x21, #2]
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc24012bc // ldr c28, [x21, #4]
	.inst 0xc24016be // ldr c30, [x21, #5]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q10, =0x0
	ldr q13, =0x0
	ldr q21, =0x0
	ldr q26, =0x0
	/* Set up flags and system registers */
	mov x21, #0x10000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603295 // ldr c21, [c20, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601295 // ldr c21, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x20, #0x1
	and x21, x21, x20
	cmp x21, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b4 // ldr c20, [x21, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24006b4 // ldr c20, [x21, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400ab4 // ldr c20, [x21, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400eb4 // ldr c20, [x21, #3]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24012b4 // ldr c20, [x21, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc24016b4 // ldr c20, [x21, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401ab4 // ldr c20, [x21, #6]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401eb4 // ldr c20, [x21, #7]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc24022b4 // ldr c20, [x21, #8]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc24026b4 // ldr c20, [x21, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x20, v10.d[0]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v10.d[1]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v13.d[0]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v13.d[1]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v21.d[0]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v21.d[1]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v26.d[0]
	cmp x21, x20
	b.ne comparison_fail
	ldr x21, =0x0
	mov x20, v26.d[1]
	cmp x21, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x00001028
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
	ldr x0, =0x00001150
	ldr x1, =check_data2
	ldr x2, =0x00001152
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001180
	ldr x1, =check_data3
	ldr x2, =0x00001182
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001dd0
	ldr x1, =check_data4
	ldr x2, =0x00001dd4
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
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
