.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8fd0021 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x48fe7cfe // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:7 11111:11111 o0:0 Rs:30 1:1 L:1 0010001:0010001 size:01
	.inst 0x081fffe3 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:3 Rn:31 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xb861033f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe231dbe1 // ASTUR-V.RI-Q Rt:1 Rn:31 op2:10 imm9:100011101 V:1 op1:00 11100010:11100010
	.zero 492
	.inst 0x901af1df // ADRDP-C.ID-C Rd:31 immhi:001101011110001110 P:0 10000:10000 immlo:00 op:1
	.inst 0xd4000001
	.zero 504
	.inst 0xc2c531fc // CVTP-R.C-C Rd:28 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2de2240 // SCBNDSE-C.CR-C Cd:0 Cn:18 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 64500
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
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2400a0f // ldr c15, [x16, #2]
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x8
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d0 // ldr c16, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x22, #0xf
	and x16, x16, x22
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400216 // ldr c22, [x16, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400616 // ldr c22, [x16, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a16 // ldr c22, [x16, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400e16 // ldr c22, [x16, #3]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401616 // ldr c22, [x16, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401a16 // ldr c22, [x16, #6]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2401e16 // ldr c22, [x16, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402216 // ldr c22, [x16, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x22, 0x80
	orr x16, x16, x22
	ldr x22, =0x920000e8
	cmp x22, x16
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
	ldr x0, =0x40400200
	ldr x1, =check_data3
	ldr x2, =0x40400208
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x4040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x21, 0x00, 0xfd, 0xf8, 0xfe, 0x7c, 0xfe, 0x48, 0xe3, 0xff, 0x1f, 0x08, 0x3f, 0x03, 0x61, 0xb8
	.byte 0xe1, 0xdb, 0x31, 0xe2
.data
check_data3:
	.byte 0xdf, 0xf1, 0x1a, 0x90, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0xfc, 0x31, 0xc5, 0xc2, 0x40, 0x22, 0xde, 0xc2, 0x00, 0x00, 0x5f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000540300020000000000001000
	/* C7 */
	.octa 0xc0000000000300030000000000001000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x400000000000000000000
	/* C25 */
	.octa 0xc0000000000100050000000000001000
	/* C29 */
	.octa 0xdfffe00000000000
	/* C30 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x2000200000000000
	/* C7 */
	.octa 0xc0000000000300030000000000001000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x400000000000000000000
	/* C25 */
	.octa 0xc0000000000100050000000000001000
	/* C28 */
	.octa 0xffffffffbfbffe00
	/* C29 */
	.octa 0xdfffe00000000000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000000401c0050000000000001010
initial_DDC_EL0_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0x400020000000000000200000
initial_VBAR_EL1_value:
	.octa 0x20008000400002000000000040400001
final_SP_EL0_value:
	.octa 0x400000000401c0050000000000001010
final_PCC_value:
	.octa 0x20008000400002000000000040400208
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x82600ed0 // ldr x16, [c22, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ed0 // str x16, [c22, #0]
	ldr x16, =0x40400208
	mrs x22, ELR_EL1
	sub x16, x16, x22
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b216 // cvtp c22, x16
	.inst 0xc2d042d6 // scvalue c22, c22, x16
	.inst 0x826002d0 // ldr c16, [c22, #0]
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
