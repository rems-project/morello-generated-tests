.section data0, #alloc, #write
	.byte 0x00, 0x00, 0xc0, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0xc0, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x0c, 0x08, 0x10, 0x02, 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x4e, 0x90, 0x05, 0xb8, 0xfd, 0x37, 0x6e, 0x82, 0x20, 0x26, 0xa2, 0xa9, 0xe1, 0xd4, 0x7b, 0x51
	.byte 0xc9, 0x20, 0xa1, 0x78, 0x22, 0x00, 0x40, 0x4b, 0xb8, 0xa7, 0x3e, 0x02, 0xc3, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x64, 0x70, 0xfe, 0xb8, 0x50, 0x98, 0x10, 0x79, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000080210080c
	/* C2 */
	.octa 0x40000000000702070000000000000fab
	/* C3 */
	.octa 0x1104
	/* C6 */
	.octa 0xc0000000500010020000000000001002
	/* C7 */
	.octa 0x2ff5fc0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0xc00000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x400000000081000700000000000012e0
	/* C30 */
	.octa 0x20000000000100070000000000400200
final_cap_values:
	/* C0 */
	.octa 0x400000080210080c
	/* C1 */
	.octa 0x2100fc0
	/* C2 */
	.octa 0x7b4
	/* C3 */
	.octa 0x1104
	/* C4 */
	.octa 0x40000008
	/* C6 */
	.octa 0xc0000000500010020000000000001002
	/* C7 */
	.octa 0x2ff5fc0
	/* C9 */
	.octa 0x5c0
	/* C14 */
	.octa 0xc00000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000008100070000000000001100
	/* C24 */
	.octa 0xfa9
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20000000000100070000000000400200
initial_SP_EL3_value:
	.octa 0xf40
initial_RDDC_EL0_value:
	.octa 0xc0000000200100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000667c00000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword final_cap_values + 208
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb805904e // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:2 00:00 imm9:001011001 0:0 opc:00 111000:111000 size:10
	.inst 0x826e37fd // ALDRB-R.RI-B Rt:29 Rn:31 op:01 imm9:011100011 L:1 1000001001:1000001001
	.inst 0xa9a22620 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:17 Rt2:01001 imm7:1000100 L:0 1010011:1010011 opc:10
	.inst 0x517bd4e1 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:7 imm12:111011110101 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x78a120c9 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:6 00:00 opc:010 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x4b400022 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:1 imm6:000000 Rm:0 0:0 shift:01 01011:01011 S:0 op:1 sf:0
	.inst 0x023ea7b8 // ADD-C.CIS-C Cd:24 Cn:29 imm12:111110101001 sh:0 A:0 00000010:00000010
	.inst 0xc2c213c3 // BRR-C-C 00011:00011 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 480
	.inst 0xb8fe7064 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:4 Rn:3 00:00 opc:111 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x79109850 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:16 Rn:2 imm12:010000100110 opc:00 111001:111001 size:01
	.inst 0xc2c21340
	.zero 1048052
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc24012a7 // ldr c7, [x21, #4]
	.inst 0xc24016a9 // ldr c9, [x21, #5]
	.inst 0xc2401aae // ldr c14, [x21, #6]
	.inst 0xc2401eb0 // ldr c16, [x21, #7]
	.inst 0xc24022b1 // ldr c17, [x21, #8]
	.inst 0xc24026be // ldr c30, [x21, #9]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103d
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	ldr x21, =initial_RDDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28b4335 // msr RDDC_EL0, c21
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603355 // ldr c21, [c26, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601355 // ldr c21, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ba // ldr c26, [x21, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24006ba // ldr c26, [x21, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400aba // ldr c26, [x21, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400eba // ldr c26, [x21, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc24026ba // ldr c26, [x21, #9]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2402aba // ldr c26, [x21, #10]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2402eba // ldr c26, [x21, #11]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24032ba // ldr c26, [x21, #12]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24036ba // ldr c26, [x21, #13]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x00001023
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400200
	ldr x1, =check_data4
	ldr x2, =0x0040020c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
