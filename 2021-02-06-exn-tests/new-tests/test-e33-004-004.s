.section text0, #alloc, #execinstr
test_start:
	.inst 0x697653a6 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:6 Rn:29 Rt2:10100 imm7:1101100 L:1 1010010:1010010 opc:01
	.inst 0x299a5cb7 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:23 Rn:5 Rt2:10111 imm7:0110100 L:0 1010011:1010011 opc:00
	.inst 0xb81de61a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:16 01:01 imm9:111011110 0:0 opc:00 111000:111000 size:10
	.inst 0x4b338819 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:25 Rn:0 imm3:010 option:100 Rm:19 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2dd8481 // CHKSS-_.CC-C 00001:00001 Cn:4 001:001 opc:00 1:1 Cm:29 11000010110:11000010110
	.inst 0x787f23bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xd85484df // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0101010010000100110 011000:011000 opc:11
	.inst 0xe2af659e // ALDUR-V.RI-S Rt:30 Rn:12 op2:01 imm9:011110110 V:1 op1:10 11100010:11100010
	.inst 0xe210d3a1 // ASTURB-R.RI-32 Rt:1 Rn:29 op2:00 imm9:100001101 V:0 op1:00 11100010:11100010
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc2401310 // ldr c16, [x24, #4]
	.inst 0xc2401717 // ldr c23, [x24, #5]
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2401f1d // ldr c29, [x24, #7]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d8 // ldr c24, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x14, #0xf
	and x24, x24, x14
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030e // ldr c14, [x24, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240070e // ldr c14, [x24, #1]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400b0e // ldr c14, [x24, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400f0e // ldr c14, [x24, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240170e // ldr c14, [x24, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401b0e // ldr c14, [x24, #6]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2401f0e // ldr c14, [x24, #7]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240230e // ldr c14, [x24, #8]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240270e // ldr c14, [x24, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x14, v30.d[0]
	cmp x24, x14
	b.ne comparison_fail
	ldr x24, =0x0
	mov x14, v30.d[1]
	cmp x24, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea701 // chkeq c24, c14
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
	ldr x0, =0x000010a8
	ldr x1, =check_data1
	ldr x2, =0x000010b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f8
	ldr x1, =check_data2
	ldr x2, =0x000010fa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011f8
	ldr x1, =check_data3
	ldr x2, =0x000011fc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001804
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xa6, 0x53, 0x76, 0x69, 0xb7, 0x5c, 0x9a, 0x29, 0x1a, 0xe6, 0x1d, 0xb8, 0x19, 0x88, 0x33, 0x4b
	.byte 0x81, 0x84, 0xdd, 0xc2, 0xbf, 0x23, 0x7f, 0x78, 0xdf, 0x84, 0x54, 0xd8, 0x9e, 0x65, 0xaf, 0xe2
	.byte 0xa1, 0xd3, 0x10, 0xe2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x50000000000000000
	/* C5 */
	.octa 0xf30
	/* C12 */
	.octa 0x80000000600200040000000000001102
	/* C16 */
	.octa 0x1800
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000001800600000000000010f8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x50000000000000000
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000600200040000000000001102
	/* C16 */
	.octa 0x17de
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000001800600000000000010f8
initial_DDC_EL0_value:
	.octa 0xc00000000007000700ffffffffffe003
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000200080800000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200080800000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010f0
	.dword 0x0000000000001800
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x82600dd8 // ldr x24, [c14, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400dd8 // str x24, [c14, #0]
	ldr x24, =0x40400028
	mrs x14, ELR_EL1
	sub x24, x24, x14
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30e // cvtp c14, x24
	.inst 0xc2d841ce // scvalue c14, c14, x24
	.inst 0x826001d8 // ldr c24, [c14, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
