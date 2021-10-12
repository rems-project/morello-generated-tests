.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x0e, 0x90, 0x64, 0x82, 0x20, 0x30, 0xc7, 0xc2, 0xe0, 0x36, 0xf2, 0x02, 0xeb, 0x52, 0xc3, 0xc2
	.byte 0x41, 0xfc, 0xa9, 0xa2, 0x11, 0x40, 0xc1, 0xc2, 0x5f, 0x30, 0x7b, 0xb8, 0x00, 0x55, 0x50, 0x38
	.byte 0x77, 0x0b, 0xda, 0xc2, 0x7e, 0x82, 0xbf, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1070
	/* C1 */
	.octa 0x1000000000000000000000000
	/* C2 */
	.octa 0xdc000000400000010000000000001000
	/* C8 */
	.octa 0x800000000049000700000000004ffffe
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000502100000000000000001000
	/* C23 */
	.octa 0x800100040008000000000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000000000000000000000000
	/* C2 */
	.octa 0xdc000000400000010000000000001000
	/* C8 */
	.octa 0x800000000049000700000000004fff03
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x1000100040008000000000000
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x800100040000000000000000
	/* C19 */
	.octa 0xc0000000502100000000000000001000
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000103000300fe00000000f121
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8264900e // ALDR-C.RI-C Ct:14 Rn:0 op:00 imm9:001001001 L:1 1000001001:1000001001
	.inst 0xc2c73020 // RRMASK-R.R-C Rd:0 Rn:1 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x02f236e0 // SUB-C.CIS-C Cd:0 Cn:23 imm12:110010001101 sh:1 A:1 00000010:00000010
	.inst 0xc2c352eb // SEAL-C.CI-C Cd:11 Cn:23 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xa2a9fc41 // CASL-C.R-C Ct:1 Rn:2 11111:11111 R:1 Cs:9 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c14011 // SCVALUE-C.CR-C Cd:17 Cn:0 000:000 opc:10 0:0 Rm:1 11000010110:11000010110
	.inst 0xb87b305f // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:011 o3:0 Rs:27 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x38505500 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:8 01:01 imm9:100000101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2da0b77 // SEAL-C.CC-C Cd:23 Cn:27 0010:0010 opc:00 Cm:26 11000010110:11000010110
	.inst 0xb8bf827e // swp:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:19 100000:100000 Rs:31 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xc2c21300
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012c9 // ldr c9, [x22, #4]
	.inst 0xc24016d3 // ldr c19, [x22, #5]
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2401eda // ldr c26, [x22, #7]
	.inst 0xc24022db // ldr c27, [x22, #8]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603316 // ldr c22, [c24, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601316 // ldr c22, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d8 // ldr c24, [x22, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006d8 // ldr c24, [x22, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400ad8 // ldr c24, [x22, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400ed8 // ldr c24, [x22, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc24012d8 // ldr c24, [x22, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc24016d8 // ldr c24, [x22, #5]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401ad8 // ldr c24, [x22, #6]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2401ed8 // ldr c24, [x22, #7]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24022d8 // ldr c24, [x22, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc24026d8 // ldr c24, [x22, #9]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402ad8 // ldr c24, [x22, #10]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2402ed8 // ldr c24, [x22, #11]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc24032d8 // ldr c24, [x22, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001500
	ldr x1, =check_data1
	ldr x2, =0x00001510
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
