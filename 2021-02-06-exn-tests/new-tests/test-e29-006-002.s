.section text0, #alloc, #execinstr
test_start:
	.inst 0x926a8420 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:1 imms:100001 immr:101010 N:1 100100:100100 opc:00 sf:1
	.inst 0x694fe3e0 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:31 Rt2:11000 imm7:0011111 L:1 1010010:1010010 opc:01
	.inst 0x826ca00c // ALDR-C.RI-C Ct:12 Rn:0 op:00 imm9:011001010 L:1 1000001001:1000001001
	.inst 0x8299e21e // ASTRB-R.RRB-B Rt:30 Rn:16 opc:00 S:0 option:111 Rm:25 0:0 L:0 100000101:100000101
	.inst 0x88007fbf // stxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:29 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:10
	.zero 3052
	.inst 0x9b3dfbcf // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:15 Rn:30 Ra:30 o0:1 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x08dffc41 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x82c1709e // ALDRB-R.RRB-B Rt:30 Rn:4 opc:00 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x2c925a3d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:29 Rn:17 Rt2:10110 imm7:0100100 L:0 1011001:1011001 opc:00
	.inst 0xd4000001
	.zero 62444
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
	ldr x20, =initial_cap_values
	.inst 0xc2400282 // ldr c2, [x20, #0]
	.inst 0xc2400684 // ldr c4, [x20, #1]
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2400e91 // ldr c17, [x20, #3]
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc240169d // ldr c29, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q22, =0x2020002
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x20, =0x4000000
	msr SPSR_EL3, x20
	ldr x20, =initial_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884114 // msr CSP_EL0, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0x3c0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x4
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =initial_DDC_EL1_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc28c4134 // msr DDC_EL1, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f4 // ldr c20, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400297 // ldr c23, [x20, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400697 // ldr c23, [x20, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a97 // ldr c23, [x20, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e97 // ldr c23, [x20, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401697 // ldr c23, [x20, #5]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401a97 // ldr c23, [x20, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401e97 // ldr c23, [x20, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402297 // ldr c23, [x20, #8]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2402697 // ldr c23, [x20, #9]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402a97 // ldr c23, [x20, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402e97 // ldr c23, [x20, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x2020002
	mov x23, v22.d[0]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v22.d[1]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v29.d[0]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v29.d[1]
	cmp x20, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x23, 0x80
	orr x20, x20, x23
	ldr x23, =0x920000e9
	cmp x23, x20
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000140c
	ldr x1, =check_data3
	ldr x2, =0x00001414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400c00
	ldr x1, =check_data5
	ldr x2, =0x40400c14
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402000
	ldr x1, =check_data6
	ldr x2, =0x40402001
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
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.zero 1024
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4c, 0x04, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x02
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x4c, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x20, 0x84, 0x6a, 0x92, 0xe0, 0xe3, 0x4f, 0x69, 0x0c, 0xa0, 0x6c, 0x82, 0x1e, 0xe2, 0x99, 0x82
	.byte 0xbf, 0x7f, 0x00, 0x88
.data
check_data5:
	.byte 0xcf, 0xfb, 0x3d, 0x9b, 0x41, 0xfc, 0xdf, 0x08, 0x9e, 0x70, 0xc1, 0x82, 0x3d, 0x5a, 0x92, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000000027c02f0000000040402000
	/* C4 */
	.octa 0x40400000
	/* C16 */
	.octa 0x1008
	/* C17 */
	.octa 0x40000000400200030000000000001000
	/* C25 */
	.octa 0x4
	/* C29 */
	.octa 0x800000000080000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x44c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000027c02f0000000040402000
	/* C4 */
	.octa 0x40400000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1008
	/* C17 */
	.octa 0x40000000400200030000000000001090
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4
	/* C29 */
	.octa 0x800000000080000000000000
	/* C30 */
	.octa 0x20
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001390
initial_DDC_EL0_value:
	.octa 0xc00000006004000400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x800000004004000000000000403fe001
initial_VBAR_EL1_value:
	.octa 0x200080005000041d0000000040400801
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001390
final_PCC_value:
	.octa 0x200080005000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000680200000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000010f0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x82600ef4 // ldr x20, [c23, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400ef4 // str x20, [c23, #0]
	ldr x20, =0x40400c14
	mrs x23, ELR_EL1
	sub x20, x20, x23
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b297 // cvtp c23, x20
	.inst 0xc2d442f7 // scvalue c23, c23, x20
	.inst 0x826002f4 // ldr c20, [c23, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
