.section data0, #alloc, #write
	.zero 3120
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x10, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 944
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84, 0x00
.data
check_data0:
	.byte 0x40, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0x84
.data
check_data2:
	.byte 0xd9, 0x11, 0x7f, 0xb8, 0x26, 0x45, 0x08, 0x02, 0x81, 0x10, 0xc1, 0xc2, 0x1f, 0x50, 0x7e, 0x38
	.byte 0xdf, 0x41, 0x3d, 0xb8, 0xf0, 0xab, 0xc1, 0xc2, 0x82, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0xb2, 0x9f, 0x20, 0x22, 0xb1, 0xeb, 0x3f, 0x22, 0xc1, 0x73, 0xc0, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffe
	/* C4 */
	.octa 0x7c00d0000003fffff0001
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x72006000000000001fe00
	/* C14 */
	.octa 0xc0000000602010020000000000001c38
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x20008000800100050000000000400081
	/* C29 */
	.octa 0x4c000000000100050000000000001040
	/* C30 */
	.octa 0x400000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x7c00d0000003fffff0001
	/* C6 */
	.octa 0x720060000000000020011
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x72006000000000001fe00
	/* C14 */
	.octa 0xc0000000602010020000000000001c38
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x80001041
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x20008000800100050000000000400081
	/* C29 */
	.octa 0x4c000000000100050000000000001040
	/* C30 */
	.octa 0x400000000000000000000000
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800001079b3f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb87f11d9 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:14 00:00 opc:001 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x02084526 // ADD-C.CIS-C Cd:6 Cn:9 imm12:001000010001 sh:0 A:0 00000010:00000010
	.inst 0xc2c11081 // GCLIM-R.C-C Rd:1 Cn:4 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x387e501f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xb83d41df // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:100 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c1abf0 // 0xc2c1abf0
	.inst 0xc2c21382 // BRS-C-C 00010:00010 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.zero 100
	.inst 0x22209fb2 // STLXP-R.CR-C Ct:18 Rn:29 Ct2:00111 1:1 Rs:0 1:1 L:0 001000100:001000100
	.inst 0x223febb1 // STLXP-R.CR-C Ct:17 Rn:29 Ct2:11010 1:1 Rs:31 1:1 L:0 001000100:001000100
	.inst 0xc2c073c1 // GCOFF-R.C-C Rd:1 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c212c0
	.zero 1048432
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
	.inst 0xc24006a4 // ldr c4, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc24012ae // ldr c14, [x21, #4]
	.inst 0xc24016b1 // ldr c17, [x21, #5]
	.inst 0xc2401ab2 // ldr c18, [x21, #6]
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc24022bc // ldr c28, [x21, #8]
	.inst 0xc24026bd // ldr c29, [x21, #9]
	.inst 0xc2402abe // ldr c30, [x21, #10]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d5 // ldr c21, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc24002b6 // ldr c22, [x21, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006b6 // ldr c22, [x21, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401eb6 // ldr c22, [x21, #7]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc24022b6 // ldr c22, [x21, #8]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc24026b6 // ldr c22, [x21, #9]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402ab6 // ldr c22, [x21, #10]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402eb6 // ldr c22, [x21, #11]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc24032b6 // ldr c22, [x21, #12]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24036b6 // ldr c22, [x21, #13]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2403ab6 // ldr c22, [x21, #14]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001c38
	ldr x1, =check_data0
	ldr x2, =0x00001c3c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400080
	ldr x1, =check_data3
	ldr x2, =0x00400090
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
