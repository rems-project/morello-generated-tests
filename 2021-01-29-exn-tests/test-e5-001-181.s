.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 1004
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
	.inst 0xd4000001
	.zero 64492
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2401204 // ldr c4, [x16, #4]
	.inst 0xc2401608 // ldr c8, [x16, #5]
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2401e0c // ldr c12, [x16, #7]
	.inst 0xc240220d // ldr c13, [x16, #8]
	.inst 0xc240260e // ldr c14, [x16, #9]
	.inst 0xc2402a11 // ldr c17, [x16, #10]
	.inst 0xc2402e14 // ldr c20, [x16, #11]
	.inst 0xc240321d // ldr c29, [x16, #12]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f0 // ldr c16, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
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
	.inst 0xc240020f // ldr c15, [x16, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240060f // ldr c15, [x16, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a0f // ldr c15, [x16, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400e0f // ldr c15, [x16, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc240120f // ldr c15, [x16, #4]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2401a0f // ldr c15, [x16, #6]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc2401e0f // ldr c15, [x16, #7]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240220f // ldr c15, [x16, #8]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240260f // ldr c15, [x16, #9]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2402a0f // ldr c15, [x16, #10]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2402e0f // ldr c15, [x16, #11]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240320f // ldr c15, [x16, #12]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc240360f // ldr c15, [x16, #13]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2403a0f // ldr c15, [x16, #14]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2403e0f // ldr c15, [x16, #15]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x16, 0x83
	orr x15, x15, x16
	ldr x16, =0x920000eb
	cmp x16, x15
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
	ldr x0, =0x000016d0
	ldr x1, =check_data1
	ldr x2, =0x000016e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001818
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040197b
	ldr x1, =check_data6
	ldr x2, =0x4040197c
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

.section data0, #alloc, #write
	.byte 0x00, 0xa8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
	.byte 0x90, 0x20, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.byte 0x00, 0xa8
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xc0, 0xf4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data5:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2090
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0xfffff4c0
	/* C3 */
	.octa 0xffffffff
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x814
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0xc0000000000080080000000000001000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000100050000000000001810
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffffff
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0xfffff4c0
	/* C3 */
	.octa 0xffffffff
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x814
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0xc0000000000080080000000000001000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xa800
initial_DDC_EL0_value:
	.octa 0x80000000000680800000000040000001
initial_DDC_EL1_value:
	.octa 0xc00000005911100000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000441404000000000040400000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x20008000441404000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000204300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 160
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 160
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x82600df0 // ldr x16, [c15, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400df0 // str x16, [c15, #0]
	ldr x16, =0x40400414
	mrs x15, ELR_EL1
	sub x16, x16, x15
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20f // cvtp c15, x16
	.inst 0xc2d041ef // scvalue c15, c15, x16
	.inst 0x826001f0 // ldr c16, [c15, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
