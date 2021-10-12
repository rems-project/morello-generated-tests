.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 37868
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 27628
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c0 // ldr c0, [x30, #0]
	.inst 0xc24007c1 // ldr c1, [x30, #1]
	.inst 0xc2400bc7 // ldr c7, [x30, #2]
	.inst 0xc2400fd1 // ldr c17, [x30, #3]
	.inst 0xc24013d4 // ldr c20, [x30, #4]
	.inst 0xc24017d5 // ldr c21, [x30, #5]
	.inst 0xc2401bd8 // ldr c24, [x30, #6]
	.inst 0xc2401fdb // ldr c27, [x30, #7]
	.inst 0xc24023dd // ldr c29, [x30, #8]
	/* Set up flags and system registers */
	ldr x30, =0x0
	msr SPSR_EL3, x30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x30d5d99f
	msr SCTLR_EL1, x30
	ldr x30, =0xc0000
	msr CPACR_EL1, x30
	ldr x30, =0x0
	msr S3_0_C1_C2_2, x30 // CCTLR_EL1
	ldr x30, =0x4
	msr S3_3_C1_C2_2, x30 // CCTLR_EL0
	ldr x30, =initial_DDC_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc288413e // msr DDC_EL0, c30
	ldr x30, =initial_DDC_EL1_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc28c413e // msr DDC_EL1, c30
	ldr x30, =0x80000000
	msr HCR_EL2, x30
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012fe // ldr c30, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e403e // msr CELR_EL3, c30
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* Check processor flags */
	mrs x30, nzcv
	ubfx x30, x30, #28, #4
	mov x23, #0x4
	and x30, x30, x23
	cmp x30, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003d7 // ldr c23, [x30, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24007d7 // ldr c23, [x30, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400bd7 // ldr c23, [x30, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400fd7 // ldr c23, [x30, #3]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc24013d7 // ldr c23, [x30, #4]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc24017d7 // ldr c23, [x30, #5]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401bd7 // ldr c23, [x30, #6]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401fd7 // ldr c23, [x30, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc24023d7 // ldr c23, [x30, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x30, =final_PCC_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x30, 0x83
	orr x23, x23, x30
	ldr x30, =0x920000a3
	cmp x30, x23
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001025
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000150a
	ldr x1, =check_data3
	ldr x2, =0x0000150c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d00
	ldr x1, =check_data4
	ldr x2, =0x00001d02
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40409400
	ldr x1, =check_data6
	ldr x2, =0x40409414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
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
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x1f
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data6:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xcdc
	/* C1 */
	.octa 0x1ec
	/* C7 */
	.octa 0x800000004004400cff800000000057c5
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4e6
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xcdc
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004004400cff800000000057c5
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4e6
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd00000005d0910240000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000600100040000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000841d0000000040409000
final_PCC_value:
	.octa 0x200080006000841d0000000040409414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401900000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020003de // add c30, c30, #0
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020203de // add c30, c30, #128
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020403de // add c30, c30, #256
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020603de // add c30, c30, #384
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020803de // add c30, c30, #512
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020a03de // add c30, c30, #640
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020c03de // add c30, c30, #768
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x020e03de // add c30, c30, #896
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021003de // add c30, c30, #1024
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021203de // add c30, c30, #1152
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021403de // add c30, c30, #1280
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021603de // add c30, c30, #1408
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021803de // add c30, c30, #1536
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021a03de // add c30, c30, #1664
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021c03de // add c30, c30, #1792
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x82600efe // ldr x30, [c23, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400efe // str x30, [c23, #0]
	ldr x30, =0x40409414
	mrs x23, ELR_EL1
	sub x30, x30, x23
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d7 // cvtp c23, x30
	.inst 0xc2de42f7 // scvalue c23, c23, x30
	.inst 0x826002fe // ldr c30, [c23, #0]
	.inst 0x021e03de // add c30, c30, #1920
	.inst 0xc2c213c0 // br c30

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
