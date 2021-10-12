.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c193e5 // CLRTAG-C.C-C Cd:5 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xb86b301f // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x8b2990d8 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:24 Rn:6 imm3:100 option:100 Rm:9 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2c6d15c // CLRPERM-C.CI-C Cd:28 Cn:10 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0xd4048b03 // smc:aarch64/instrs/system/exceptions/runtime/smc 00011:00011 imm16:0010010001011000 11010100000:11010100000
	.zero 11244
	.inst 0xb886041e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:001100000 0:0 opc:10 111000:111000 size:10
	.inst 0xe21b7ee4 // ALDURSB-R.RI-32 Rt:4 Rn:23 op2:11 imm9:110110111 V:0 op1:00 11100010:11100010
	.inst 0xc2d5a681 // CHKEQ-_.CC-C 00001:00001 Cn:20 001:001 opc:01 1:1 Cm:21 11000010110:11000010110
	.inst 0xac62e2fd // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:29 Rn:23 Rt2:11000 imm7:1000101 L:1 1011000:1011000 opc:10
	.inst 0xd4000001
	.zero 54252
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc24015f7 // ldr c23, [x15, #5]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x4
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x8260102f // ldr c15, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x1, #0xf
	and x15, x15, x1
	cmp x15, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc2c1a481 // chkeq c4, c1
	b.ne comparison_fail
	.inst 0xc24009e1 // ldr c1, [x15, #2]
	.inst 0xc2c1a541 // chkeq c10, c1
	b.ne comparison_fail
	.inst 0xc2400de1 // ldr c1, [x15, #3]
	.inst 0xc2c1a561 // chkeq c11, c1
	b.ne comparison_fail
	.inst 0xc24011e1 // ldr c1, [x15, #4]
	.inst 0xc2c1a681 // chkeq c20, c1
	b.ne comparison_fail
	.inst 0xc24015e1 // ldr c1, [x15, #5]
	.inst 0xc2c1a6a1 // chkeq c21, c1
	b.ne comparison_fail
	.inst 0xc24019e1 // ldr c1, [x15, #6]
	.inst 0xc2c1a6e1 // chkeq c23, c1
	b.ne comparison_fail
	.inst 0xc2401de1 // ldr c1, [x15, #7]
	.inst 0xc2c1a781 // chkeq c28, c1
	b.ne comparison_fail
	.inst 0xc24021e1 // ldr c1, [x15, #8]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x1, v24.d[0]
	cmp x15, x1
	b.ne comparison_fail
	ldr x15, =0x0
	mov x1, v24.d[1]
	cmp x15, x1
	b.ne comparison_fail
	ldr x15, =0x0
	mov x1, v29.d[0]
	cmp x15, x1
	b.ne comparison_fail
	ldr x15, =0x0
	mov x1, v29.d[1]
	cmp x15, x1
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984021 // mrs c1, CELR_EL1
	.inst 0xc2c1a5e1 // chkeq c15, c1
	b.ne comparison_fail
	ldr x1, =esr_el1_dump_address
	ldr x1, [x1]
	mov x15, 0x0
	orr x1, x1, x15
	ldr x15, =0x2000000
	cmp x15, x1
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001280
	ldr x1, =check_data0
	ldr x2, =0x00001284
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb7
	ldr x1, =check_data1
	ldr x2, =0x00001fb8
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
	ldr x0, =0x40401280
	ldr x1, =check_data3
	ldr x2, =0x40401284
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401c50
	ldr x1, =check_data4
	ldr x2, =0x40401c70
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40402c00
	ldr x1, =check_data5
	ldr x2, =0x40402c14
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe5, 0x93, 0xc1, 0xc2, 0x1f, 0x30, 0x6b, 0xb8, 0xd8, 0x90, 0x29, 0x8b, 0x5c, 0xd1, 0xc6, 0xc2
	.byte 0x03, 0x8b, 0x04, 0xd4
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0x1e, 0x04, 0x86, 0xb8, 0xe4, 0x7e, 0x1b, 0xe2, 0x81, 0xa6, 0xd5, 0xc2, 0xfd, 0xe2, 0x62, 0xac
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1280
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000000300070000000000002000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x12e0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000000300070000000000002000
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x800000000905080c00fffffffff7be70
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x82600c2f // ldr x15, [c1, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c2f // str x15, [c1, #0]
	ldr x15, =0x40402c14
	mrs x1, ELR_EL1
	sub x15, x15, x1
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e1 // cvtp c1, x15
	.inst 0xc2cf4021 // scvalue c1, c1, x15
	.inst 0x8260002f // ldr c15, [c1, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
