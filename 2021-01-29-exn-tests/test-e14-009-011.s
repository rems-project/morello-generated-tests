.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c06801 // ORRFLGS-C.CR-C Cd:1 Cn:0 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x131254e1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:7 imms:010101 immr:010010 N:0 100110:100110 opc:00 sf:0
	.inst 0x69e8e5dd // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:14 Rt2:11001 imm7:1010001 L:1 1010011:1010011 opc:01
	.inst 0x887f9bd2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:30 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x5a81c34c // 0x5a81c34c
	.inst 0x8254b3e5 // 0x8254b3e5
	.inst 0xc2e1199d // 0xc2e1199d
	.inst 0xc2df6bc3 // 0xc2df6bc3
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc240092e // ldr c14, [x9, #2]
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601269 // ldr c9, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x19, #0xf
	and x9, x9, x19
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400133 // ldr c19, [x9, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400533 // ldr c19, [x9, #1]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400933 // ldr c19, [x9, #2]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2400d33 // ldr c19, [x9, #3]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401533 // ldr c19, [x9, #5]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401933 // ldr c19, [x9, #6]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401d33 // ldr c19, [x9, #7]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402133 // ldr c19, [x9, #8]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984113 // mrs c19, CSP_EL0
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001600
	ldr x1, =check_data0
	ldr x2, =0x00001610
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400048
	ldr x1, =check_data2
	ldr x2, =0x40400050
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x32, 0xc2, 0xc2, 0x01, 0x68, 0xc0, 0xc2, 0xe1, 0x54, 0x12, 0x13, 0xdd, 0xe5, 0xe8, 0x69
	.byte 0xd2, 0x9b, 0x7f, 0x88, 0x4c, 0xc3, 0x81, 0x5a, 0xe5, 0xb3, 0x54, 0x82, 0x9d, 0x19, 0xe1, 0xc2
	.byte 0xc3, 0x6b, 0xdf, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data2:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000001000000000000
	/* C14 */
	.octa 0x80000000000080080000000040400104
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000610050000000040400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000610050000000040400000
	/* C5 */
	.octa 0x4000000000000001000000000000
	/* C6 */
	.octa 0xc2c06801
	/* C14 */
	.octa 0x80000000000080080000000040400048
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xc2c23201
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000610050000000040400000
initial_SP_EL0_value:
	.octa 0x150
initial_DDC_EL0_value:
	.octa 0x480000000003000700006ff840000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x150
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
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
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600e69 // ldr x9, [c19, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e69 // str x9, [c19, #0]
	ldr x9, =0x40400028
	mrs x19, ELR_EL1
	sub x9, x9, x19
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b133 // cvtp c19, x9
	.inst 0xc2c94273 // scvalue c19, c19, x9
	.inst 0x82600269 // ldr c9, [c19, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
