.section data0, #alloc, #write
	.byte 0xf8, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x0e, 0x20, 0x20, 0xca, 0x3d, 0xd0, 0xc5, 0xc2, 0x19, 0x6d, 0x9e, 0xb8, 0x27, 0x08, 0x58, 0xfa
	.byte 0xfd, 0x40, 0xd3, 0x02, 0x37, 0xd9, 0x30, 0xa8, 0xff, 0x03, 0x63, 0x78, 0xad, 0x27, 0xd6, 0x9a
	.byte 0x0c, 0xce, 0x08, 0x71, 0xff, 0x71, 0x30, 0xf8, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x202000
	/* C3 */
	.octa 0xbf10
	/* C7 */
	.octa 0x200028000000000000000
	/* C8 */
	.octa 0x80000000000100070000000000001202
	/* C9 */
	.octa 0x40000000000100050000000000001c00
	/* C15 */
	.octa 0xc0000000580000040000000000001000
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x202000
	/* C3 */
	.octa 0xbf10
	/* C7 */
	.octa 0x200028000000000000000
	/* C8 */
	.octa 0x800000000001000700000000000011e8
	/* C9 */
	.octa 0x40000000000100050000000000001c00
	/* C12 */
	.octa 0xfffffdcd
	/* C13 */
	.octa 0x7fffffffffb30000
	/* C15 */
	.octa 0xc0000000580000040000000000001000
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x200027fffffffffb30000
initial_SP_EL3_value:
	.octa 0xc0000000000080200000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004040c0410000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x620270000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xca20200e // eon:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:0 imm6:001000 Rm:0 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0xc2c5d03d // CVTDZ-C.R-C Cd:29 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb89e6d19 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:25 Rn:8 11:11 imm9:111100110 0:0 opc:10 111000:111000 size:10
	.inst 0xfa580827 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0111 0:0 Rn:1 10:10 cond:0000 imm5:11000 111010010:111010010 op:1 sf:1
	.inst 0x02d340fd // SUB-C.CIS-C Cd:29 Cn:7 imm12:010011010000 sh:1 A:1 00000010:00000010
	.inst 0xa830d937 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:23 Rn:9 Rt2:10110 imm7:1100001 L:0 1010000:1010000 opc:10
	.inst 0x786303ff // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x9ad627ad // lsrv:aarch64/instrs/integer/shift/variable Rd:13 Rn:29 op2:01 0010:0010 Rm:22 0011010110:0011010110 sf:1
	.inst 0x7108ce0c // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:12 Rn:16 imm12:001000110011 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xf83071ff // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:111 o3:0 Rs:16 1:1 R:0 A:0 00:00 V:0 111:111 size:11
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc2401149 // ldr c9, [x10, #4]
	.inst 0xc240154f // ldr c15, [x10, #5]
	.inst 0xc2401950 // ldr c16, [x10, #6]
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2402157 // ldr c23, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x40000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103d
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328a // ldr c10, [c20, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260128a // ldr c10, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x20, #0xf
	and x10, x10, x20
	cmp x10, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400154 // ldr c20, [x10, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400554 // ldr c20, [x10, #1]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400d54 // ldr c20, [x10, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401954 // ldr c20, [x10, #6]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401d54 // ldr c20, [x10, #7]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2402154 // ldr c20, [x10, #8]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2402554 // ldr c20, [x10, #9]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402954 // ldr c20, [x10, #10]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402d54 // ldr c20, [x10, #11]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2403154 // ldr c20, [x10, #12]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e8
	ldr x1, =check_data1
	ldr x2, =0x000011ec
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b08
	ldr x1, =check_data2
	ldr x2, =0x00001b18
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
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
