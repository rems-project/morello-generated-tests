.section data0, #alloc, #write
	.byte 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa1, 0x88, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa1, 0x88, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa0, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x21, 0xc8, 0x62, 0xa2, 0xc0, 0x66, 0x2e, 0xe2, 0x62, 0xbc, 0x13, 0xf8, 0x25, 0x08, 0x23, 0x11
	.byte 0x82, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0xfe, 0x7b, 0x79, 0x82, 0xbe, 0x86, 0xa1, 0x9b, 0x20, 0x00, 0x38, 0xcb, 0x5e, 0x68, 0x06, 0xfd
	.byte 0x3f, 0x50, 0x22, 0x78, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000000c0100000000000000c60
	/* C2 */
	.octa 0x3a0
	/* C3 */
	.octa 0x40000000410201820000000000001505
	/* C12 */
	.octa 0x20008000500000010000000000400018
	/* C22 */
	.octa 0x1017
final_cap_values:
	/* C1 */
	.octa 0x88a10000000000001008
	/* C2 */
	.octa 0x3a0
	/* C3 */
	.octa 0x40000000410201820000000000001440
	/* C5 */
	.octa 0x18ca
	/* C12 */
	.octa 0x20008000500000010000000000400018
	/* C22 */
	.octa 0x1017
initial_SP_EL3_value:
	.octa 0x800000000001000500000000000011b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005804000500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa262c821 // LDR-C.RRB-C Ct:1 Rn:1 10:10 S:0 option:110 Rm:2 1:1 opc:01 10100010:10100010
	.inst 0xe22e66c0 // ALDUR-V.RI-B Rt:0 Rn:22 op2:01 imm9:011100110 V:1 op1:00 11100010:11100010
	.inst 0xf813bc62 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:3 11:11 imm9:100111011 0:0 opc:00 111000:111000 size:11
	.inst 0x11230825 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:5 Rn:1 imm12:100011000010 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c21182 // BRS-C-C 00010:00010 Cn:12 100:100 opc:00 11000010110000100:11000010110000100
	.zero 4
	.inst 0x82797bfe // ALDR-R.RI-32 Rt:30 Rn:31 op:10 imm9:110010111 L:1 1000001001:1000001001
	.inst 0x9ba186be // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:21 Ra:1 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xcb380020 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:1 imm3:000 option:000 Rm:24 01011001:01011001 S:0 op:1 sf:1
	.inst 0xfd06685e // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:2 imm12:000110011010 opc:00 111101:111101 size:11
	.inst 0x7822503f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:101 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21320
	.zero 1048528
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc2401216 // ldr c22, [x16, #4]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085103f
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603330 // ldr c16, [c25, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601330 // ldr c16, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400219 // ldr c25, [x16, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400619 // ldr c25, [x16, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400a19 // ldr c25, [x16, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400e19 // ldr c25, [x16, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x25, v0.d[0]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x0
	mov x25, v0.d[1]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x0
	mov x25, v30.d[0]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x0
	mov x25, v30.d[1]
	cmp x16, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fd
	ldr x1, =check_data2
	ldr x2, =0x000010fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001440
	ldr x1, =check_data3
	ldr x2, =0x00001448
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000180c
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400018
	ldr x1, =check_data6
	ldr x2, =0x00400030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
