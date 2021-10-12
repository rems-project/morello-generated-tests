.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c06801 // ORRFLGS-C.CR-C Cd:1 Cn:0 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x131254e1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:7 imms:010101 immr:010010 N:0 100110:100110 opc:00 sf:0
	.inst 0x69e8e5dd // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:14 Rt2:11001 imm7:1010001 L:1 1010011:1010011 opc:01
	.inst 0x887f9bd2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:30 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.zero 35820
	.inst 0x5a81c34c // 0x5a81c34c
	.inst 0x8254b3e5 // 0x8254b3e5
	.inst 0xc2e1199d // 0xc2e1199d
	.inst 0xc2df6bc3 // 0xc2df6bc3
	.inst 0xd4000001
	.zero 29676
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400645 // ldr c5, [x18, #1]
	.inst 0xc2400a4e // ldr c14, [x18, #2]
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601372 // ldr c18, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x27, #0xf
	and x18, x18, x27
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025b // ldr c27, [x18, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240065b // ldr c27, [x18, #1]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc2400a5b // ldr c27, [x18, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240165b // ldr c27, [x18, #5]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x18, 0x83
	orr x27, x27, x18
	ldr x18, =0x920000a3
	cmp x18, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000014b0
	ldr x1, =check_data0
	ldr x2, =0x000014c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001744
	ldr x1, =check_data1
	ldr x2, =0x0000174c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40408c00
	ldr x1, =check_data3
	ldr x2, =0x40408c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x01, 0x32, 0xc2, 0xc2, 0x01, 0x68, 0xc0, 0xc2, 0xe1, 0x54, 0x12, 0x13, 0xdd, 0xe5, 0xe8, 0x69
	.byte 0xd2, 0x9b, 0x7f, 0x88
.data
check_data3:
	.byte 0x4c, 0xc3, 0x81, 0x5a, 0xe5, 0xb3, 0x54, 0x82, 0x9d, 0x19, 0xe1, 0xc2, 0xc3, 0x6b, 0xdf, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000001800
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x800000004000400400005efc00004402
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x800000004000400400005efc00004402
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000001744
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x800000004000400400005efc00004402
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0x4c0000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000841d0000000040408801
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000841d0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100e901d0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600f72 // ldr x18, [c27, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f72 // str x18, [c27, #0]
	ldr x18, =0x40408c14
	mrs x27, ELR_EL1
	sub x18, x18, x27
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25b // cvtp c27, x18
	.inst 0xc2d2437b // scvalue c27, c27, x18
	.inst 0x82600372 // ldr c18, [c27, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
