.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbd
	.zero 1088
	.byte 0x20, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2928
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbd
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x20, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x54, 0x7c, 0x5f, 0x22, 0x00, 0x80, 0xc2, 0xc2, 0xc2, 0x62, 0x36, 0x38, 0x1e, 0xfc, 0x5f, 0xc8
	.byte 0x88, 0xfc, 0x1f, 0x42, 0xfb, 0x64, 0x4a, 0xe2, 0x44, 0xdc, 0x3e, 0xaa, 0xc1, 0xc7, 0x47, 0x91
	.byte 0xa1, 0x15, 0xeb, 0x54, 0xc0, 0xa3, 0x58, 0x6c, 0x60, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1480
	/* C2 */
	.octa 0x1030
	/* C4 */
	.octa 0x1440
	/* C7 */
	.octa 0x80000000000780170000000000409f10
	/* C8 */
	.octa 0x0
	/* C22 */
	.octa 0x103f
final_cap_values:
	/* C0 */
	.octa 0x1480
	/* C1 */
	.octa 0x1f1f20
	/* C2 */
	.octa 0xbd
	/* C4 */
	.octa 0x6fffffffffffffff
	/* C7 */
	.octa 0x80000000000780170000000000409f10
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0xbd000000000000000000000000000000
	/* C22 */
	.octa 0x103f
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xf20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402cc02e0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000007000f00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x225f7c54 // LDXR-C.R-C Ct:20 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2c28000 // SCTAG-C.CR-C Cd:0 Cn:0 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0x383662c2 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:22 00:00 opc:110 0:0 Rs:22 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc85ffc1e // ldaxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0x421ffc88 // STLR-C.R-C Ct:8 Rn:4 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe24a64fb // ALDURH-R.RI-32 Rt:27 Rn:7 op2:01 imm9:010100110 V:0 op1:01 11100010:11100010
	.inst 0xaa3edc44 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:2 imm6:110111 Rm:30 N:1 shift:00 01010:01010 opc:01 sf:1
	.inst 0x9147c7c1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:30 imm12:000111110001 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x54eb15a1 // b_cond:aarch64/instrs/branch/conditional/cond cond:0001 0:0 imm19:1110101100010101101 01010100:01010100
	.inst 0x6c58a3c0 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:30 Rt2:01000 imm7:0110001 L:1 1011000:1011000 opc:01
	.inst 0xc2c21260
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc2401616 // ldr c22, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x40000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851037
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603270 // ldr c16, [c19, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601270 // ldr c16, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x19, #0x4
	and x16, x16, x19
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400213 // ldr c19, [x16, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400613 // ldr c19, [x16, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400a13 // ldr c19, [x16, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400e13 // ldr c19, [x16, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401213 // ldr c19, [x16, #4]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401613 // ldr c19, [x16, #5]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2401e13 // ldr c19, [x16, #7]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402213 // ldr c19, [x16, #8]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402613 // ldr c19, [x16, #9]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x19, v0.d[0]
	cmp x16, x19
	b.ne comparison_fail
	ldr x16, =0x0
	mov x19, v0.d[1]
	cmp x16, x19
	b.ne comparison_fail
	ldr x16, =0x0
	mov x19, v8.d[0]
	cmp x16, x19
	b.ne comparison_fail
	ldr x16, =0x0
	mov x19, v8.d[1]
	cmp x16, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a8
	ldr x1, =check_data1
	ldr x2, =0x000010b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001440
	ldr x1, =check_data2
	ldr x2, =0x00001450
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001480
	ldr x1, =check_data3
	ldr x2, =0x00001488
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
	ldr x0, =0x00409fb6
	ldr x1, =check_data5
	ldr x2, =0x00409fb8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
