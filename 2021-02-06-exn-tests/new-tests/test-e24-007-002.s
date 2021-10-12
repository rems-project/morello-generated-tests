.section text0, #alloc, #execinstr
test_start:
	.inst 0x78fe3361 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:27 00:00 opc:011 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xb818e8de // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:6 10:10 imm9:110001110 0:0 opc:00 111000:111000 size:10
	.inst 0xb8b04bdd // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:30 10:10 S:0 option:010 Rm:16 1:1 opc:10 111000:111000 size:10
	.inst 0x48a57c36 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:22 Rn:1 11111:11111 o0:0 Rs:5 1:1 L:0 0010001:0010001 size:01
	.inst 0xc2cb8be0 // CHKSSU-C.CC-C Cd:0 Cn:31 0010:0010 opc:10 Cm:11 11000010110:11000010110
	.inst 0xe24aabe7 // ALDURSH-R.RI-64 Rt:7 Rn:31 op2:10 imm9:010101010 V:0 op1:01 11100010:11100010
	.inst 0x8241ea81 // ASTR-R.RI-32 Rt:1 Rn:20 op:10 imm9:000011110 L:0 1000001001:1000001001
	.inst 0xc2c4b03f // LDCT-R.R-_ Rt:31 Rn:1 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xe29462dd // ASTUR-R.RI-32 Rt:29 Rn:22 op2:00 imm9:101000110 V:0 op1:10 11100010:11100010
	.inst 0xd4000001
	.zero 65496
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
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e5 // ldr c5, [x23, #0]
	.inst 0xc24006e6 // ldr c6, [x23, #1]
	.inst 0xc2400aeb // ldr c11, [x23, #2]
	.inst 0xc2400ef0 // ldr c16, [x23, #3]
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2401afb // ldr c27, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b7 // ldr c23, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x21, #0xf
	and x23, x23, x21
	cmp x23, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f5 // ldr c21, [x23, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006f5 // ldr c21, [x23, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400af5 // ldr c21, [x23, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401af5 // ldr c21, [x23, #6]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401ef5 // ldr c21, [x23, #7]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc24022f5 // ldr c21, [x23, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc24026f5 // ldr c21, [x23, #9]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402af5 // ldr c21, [x23, #10]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402ef5 // ldr c21, [x23, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ba
	ldr x1, =check_data1
	ldr x2, =0x000010bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001148
	ldr x1, =check_data2
	ldr x2, =0x0000114c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012e0
	ldr x1, =check_data3
	ldr x2, =0x000012e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001740
	ldr x1, =check_data4
	ldr x2, =0x00001780
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001888
	ldr x1, =check_data5
	ldr x2, =0x0000188c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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

.section data0, #alloc, #write
	.byte 0x40, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xb0, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 64
.data
check_data5:
	.byte 0x40, 0x17, 0x00, 0x00
.data
check_data6:
	.byte 0x61, 0x33, 0xfe, 0x78, 0xde, 0xe8, 0x18, 0xb8, 0xdd, 0x4b, 0xb0, 0xb8, 0x36, 0x7c, 0xa5, 0x48
	.byte 0xe0, 0x8b, 0xcb, 0xc2, 0xe7, 0xab, 0x4a, 0xe2, 0x81, 0xea, 0x41, 0x82, 0x3f, 0xb0, 0xc4, 0xc2
	.byte 0xdd, 0x62, 0x94, 0xe2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0xffff
	/* C6 */
	.octa 0x1072
	/* C11 */
	.octa 0x8000000000070007000000000000a003
	/* C16 */
	.octa 0x1230
	/* C20 */
	.octa 0x40000000000700040000000000001810
	/* C22 */
	.octa 0x40000000000700050000000000001202
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0xb0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000520400110000000000001010
	/* C1 */
	.octa 0x1740
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1072
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x8000000000070007000000000000a003
	/* C16 */
	.octa 0x1230
	/* C20 */
	.octa 0x40000000000700040000000000001810
	/* C22 */
	.octa 0x40000000000700050000000000001202
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xb0
initial_SP_EL0_value:
	.octa 0x80000000520400110000000000001010
initial_DDC_EL0_value:
	.octa 0xc00000005804080c0000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000520400110000000000001010
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001140
	.dword 0x0000000000001740
	.dword 0x0000000000001750
	.dword 0x0000000000001760
	.dword 0x0000000000001770
	.dword 0x0000000000001880
	.dword 0
esr_el1_dump_address:
	.dword 0

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
	b finish
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

.section vector_table_el1, #alloc, #execinstr
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x40400028
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
