.section text0, #alloc, #execinstr
test_start:
	.inst 0xf82131fe // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:15 00:00 opc:011 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x78af229d // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:20 00:00 opc:010 0:0 Rs:15 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x9b5f7c1d // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:29 Rn:0 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0x902b9304 // ADRP-C.I-C Rd:4 immhi:010101110010011000 P:0 10000:10000 immlo:00 op:1
	.inst 0x98ae795d // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:29 imm19:1010111001111001010 011000:011000 opc:10
	.zero 1004
	.inst 0xc2d22abe // BICFLGS-C.CR-C Cd:30 Cn:21 1010:1010 opc:00 Rm:18 11000010110:11000010110
	.inst 0xc2dee0e0 // SCFLGS-C.CR-C Cd:0 Cn:7 111000:111000 Rm:30 11000010110:11000010110
	.inst 0x78085681 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:20 01:01 imm9:010000101 0:0 opc:00 111000:111000 size:01
	.inst 0xe2b313c0 // ASTUR-V.RI-S Rt:0 Rn:30 op2:00 imm9:100110001 V:1 op1:10 11100010:11100010
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400567 // ldr c7, [x11, #1]
	.inst 0xc240096f // ldr c15, [x11, #2]
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cb // ldr c11, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016e // ldr c14, [x11, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240056e // ldr c14, [x11, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240096e // ldr c14, [x11, #2]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240116e // ldr c14, [x11, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240156e // ldr c14, [x11, #5]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240196e // ldr c14, [x11, #6]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2401d6e // ldr c14, [x11, #7]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240216e // ldr c14, [x11, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240256e // ldr c14, [x11, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x14, v0.d[0]
	cmp x11, x14
	b.ne comparison_fail
	ldr x11, =0x0
	mov x14, v0.d[1]
	cmp x11, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x11, 0x83
	orr x14, x14, x11
	ldr x11, =0x920000ab
	cmp x11, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001042
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001240
	ldr x1, =check_data1
	ldr x2, =0x00001248
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f40
	ldr x1, =check_data2
	ldr x2, =0x00001f44
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 64
	.byte 0x40, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xfe, 0x31, 0x21, 0xf8, 0x9d, 0x22, 0xaf, 0x78, 0x1d, 0x7c, 0x5f, 0x9b, 0x04, 0x93, 0x2b, 0x90
	.byte 0x5d, 0x79, 0xae, 0x98
.data
check_data4:
	.byte 0xbe, 0x2a, 0xd2, 0xc2, 0xe0, 0xe0, 0xde, 0xc2, 0x81, 0x56, 0x08, 0x78, 0xc0, 0x13, 0xb3, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0xc0000000000300070000000000001240
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000500010000000000001040
	/* C21 */
	.octa 0x200f
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x76006008000001b260000
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0xc0000000000300070000000000001240
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc00000000005000100000000000010c5
	/* C21 */
	.octa 0x200f
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200f
initial_DDC_EL0_value:
	.octa 0x76006007fffffc4000000
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000e41e0000000040400001
final_PCC_value:
	.octa 0x200080005000e41e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x40400414
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
