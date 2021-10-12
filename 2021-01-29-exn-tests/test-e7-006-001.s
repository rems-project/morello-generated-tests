.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc03d // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x79e6403e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:100110010000 opc:11 111001:111001 size:01
	.inst 0x425ffe5e // LDAR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x1a0e03a1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:29 000000:000000 Rm:14 11010000:11010000 S:0 op:0 sf:0
	.inst 0x781e7fb3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:29 11:11 imm9:111100111 0:0 opc:00 111000:111000 size:01
	.zero 3052
	.inst 0xc2c8443e // CSEAL-C.C-C Cd:30 Cn:1 001:001 opc:10 0:0 Cm:8 11000010110:11000010110
	.inst 0x3ddf2aa0 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:21 imm12:011111001010 opc:11 111101:111101 size:00
	.inst 0x82608947 // ALDR-R.RI-32 Rt:7 Rn:10 op:10 imm9:000001000 L:1 1000001001:1000001001
	.inst 0xc221d6bf // STR-C.RIB-C Ct:31 Rn:21 imm12:100001110101 L:0 110000100:110000100
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e8 // ldr c8, [x15, #1]
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400df2 // ldr c18, [x15, #3]
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x1c0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
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
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260104f // ldr c15, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x15, x15, x2
	cmp x15, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e2 // ldr c2, [x15, #0]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2400de2 // ldr c2, [x15, #3]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc24011e2 // ldr c2, [x15, #4]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc24015e2 // ldr c2, [x15, #5]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x2, v0.d[0]
	cmp x15, x2
	b.ne comparison_fail
	ldr x15, =0x0
	mov x2, v0.d[1]
	cmp x15, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x15, 0x83
	orr x2, x2, x15
	ldr x15, =0x920000eb
	cmp x15, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001530
	ldr x1, =check_data1
	ldr x2, =0x00001540
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x2, =0x40400401
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400c00
	ldr x1, =check_data6
	ldr x2, =0x40400c14
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40401720
	ldr x1, =check_data7
	ldr x2, =0x40401722
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x3d, 0xc0, 0xbf, 0x38, 0x3e, 0x40, 0xe6, 0x79, 0x5e, 0xfe, 0x5f, 0x42, 0xa1, 0x03, 0x0e, 0x1a
	.byte 0xb3, 0x7f, 0x1e, 0x78
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x3e, 0x44, 0xc8, 0xc2, 0xa0, 0x2a, 0xdf, 0x3d, 0x47, 0x89, 0x60, 0x82, 0xbf, 0xd6, 0x21, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40400400
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x80000000000100050000000000001fd8
	/* C18 */
	.octa 0x1010
	/* C21 */
	.octa 0xffffffffffff9890
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x80000000000100050000000000001fd8
	/* C18 */
	.octa 0x1010
	/* C21 */
	.octa 0xffffffffffff9890
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x801000003ffb000300fe000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040400800
final_PCC_value:
	.octa 0x200080004000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000060080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x82600c4f // ldr x15, [c2, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c4f // str x15, [c2, #0]
	ldr x15, =0x40400c14
	mrs x2, ELR_EL1
	sub x15, x15, x2
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e2 // cvtp c2, x15
	.inst 0xc2cf4042 // scvalue c2, c2, x15
	.inst 0x8260004f // ldr c15, [c2, #0]
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
