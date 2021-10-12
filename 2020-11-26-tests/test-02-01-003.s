.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x98
.data
check_data3:
	.byte 0xff, 0x12, 0xc1, 0xc2, 0x21, 0x00, 0xf5, 0x38, 0xfc, 0x6b, 0x4a, 0x29, 0xb2, 0x90, 0xc1, 0xc2
	.byte 0xe8, 0x03, 0xc0, 0xc2, 0x5f, 0x22, 0x2b, 0x38, 0x7b, 0x6b, 0x16, 0x38, 0x37, 0xec, 0x12, 0x02
	.byte 0xeb, 0x33, 0x16, 0x0b, 0xa0, 0x0b, 0x99, 0xb8, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4004e06100ffffffffffc001
	/* C27 */
	.octa 0x2098
	/* C29 */
	.octa 0x400078
final_cap_values:
	/* C0 */
	.octa 0x294a6bfc
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4bb
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x2098
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x400078
initial_SP_EL3_value:
	.octa 0x400000000000000000001f20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c112ff // GCLIM-R.C-C Rd:31 Cn:23 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x38f50021 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:000 0:0 Rs:21 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x294a6bfc // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:28 Rn:31 Rt2:11010 imm7:0010100 L:1 1010010:1010010 opc:00
	.inst 0xc2c190b2 // CLRTAG-C.C-C Cd:18 Cn:5 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c003e8 // SCBNDS-C.CR-C Cd:8 Cn:31 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0x382b225f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:010 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x38166b7b // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:27 10:10 imm9:101100110 0:0 opc:00 111000:111000 size:00
	.inst 0x0212ec37 // ADD-C.CIS-C Cd:23 Cn:1 imm12:010010111011 sh:0 A:0 00000010:00000010
	.inst 0x0b1633eb // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:11 Rn:31 imm6:001100 Rm:22 0:0 shift:00 01011:01011 S:0 op:0 sf:0
	.inst 0xb8990ba0 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:110010000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21040
	.zero 1048532
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
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
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
	.inst 0xc24003c1 // ldr c1, [x30, #0]
	.inst 0xc24007c5 // ldr c5, [x30, #1]
	.inst 0xc2400bcb // ldr c11, [x30, #2]
	.inst 0xc2400fd5 // ldr c21, [x30, #3]
	.inst 0xc24013d7 // ldr c23, [x30, #4]
	.inst 0xc24017db // ldr c27, [x30, #5]
	.inst 0xc2401bdd // ldr c29, [x30, #6]
	/* Set up flags and system registers */
	mov x30, #0x00000000
	msr nzcv, x30
	ldr x30, =initial_SP_EL3_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc2c1d3df // cpy c31, c30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x3085103f
	msr SCTLR_EL3, x30
	ldr x30, =0x0
	msr S3_6_C1_C2_2, x30 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260305e // ldr c30, [c2, #3]
	.inst 0xc28b413e // msr DDC_EL3, c30
	isb
	.inst 0x8260105e // ldr c30, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c213c0 // br c30
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003c2 // ldr c2, [x30, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24007c2 // ldr c2, [x30, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400bc2 // ldr c2, [x30, #2]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2400fc2 // ldr c2, [x30, #3]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc24013c2 // ldr c2, [x30, #4]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc24017c2 // ldr c2, [x30, #5]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2401bc2 // ldr c2, [x30, #6]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2401fc2 // ldr c2, [x30, #7]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc24023c2 // ldr c2, [x30, #8]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc24027c2 // ldr c2, [x30, #9]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f70
	ldr x1, =check_data1
	ldr x2, =0x00001f78
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
