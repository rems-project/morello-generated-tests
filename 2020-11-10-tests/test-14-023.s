.section data0, #alloc, #write
	.zero 144
	.byte 0x31, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x81, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3936
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x31, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x81, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xe9, 0x7f, 0x0e, 0x22, 0x90, 0x11, 0xc5, 0xc2, 0xa0, 0x67, 0xd7, 0x78, 0x81, 0xd1, 0x9f, 0x8b
	.byte 0xf7, 0x73, 0xd4, 0x42, 0xc0, 0x93, 0xc5, 0xc2, 0x20, 0xdc, 0x7b, 0x02, 0x33, 0x7d, 0x0d, 0xc8
	.byte 0xc0, 0x33, 0xd1, 0xc2
.data
check_data5:
	.byte 0x5e, 0x08, 0x81, 0xb8, 0x60, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100050000000000001de8
	/* C9 */
	.octa 0x400040000001000500000000004ffff0
	/* C12 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005001800200000000004087f8
	/* C30 */
	.octa 0x90000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0xef7000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000100050000000000001de8
	/* C9 */
	.octa 0x400040000001000500000000004ffff0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1
	/* C14 */
	.octa 0x1
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000050018002000000000040876e
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc8100000000100050000000000001030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800020070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001090
	.dword 0x00000000000012b0
	.dword 0x00000000000012c0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x220e7fe9 // STXR-R.CR-C Ct:9 Rn:31 (1)(1)(1)(1)(1):11111 0:0 Rs:14 0:0 L:0 001000100:001000100
	.inst 0xc2c51190 // CVTD-R.C-C Rd:16 Cn:12 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x78d767a0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:29 01:01 imm9:101110110 0:0 opc:11 111000:111000 size:01
	.inst 0x8b9fd181 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:12 imm6:110100 Rm:31 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0x42d473f7 // LDP-C.RIB-C Ct:23 Rn:31 Ct2:11100 imm7:0101000 L:1 010000101:010000101
	.inst 0xc2c593c0 // CVTD-C.R-C Cd:0 Rn:30 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x027bdc20 // ADD-C.CIS-C Cd:0 Cn:1 imm12:111011110111 sh:1 A:0 00000010:00000010
	.inst 0xc80d7d33 // stxr:aarch64/instrs/memory/exclusive/single Rt:19 Rn:9 Rt2:11111 o0:0 Rs:13 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2d133c0 // BR-CI-C 0:0 0000:0000 Cn:30 100:100 imm7:0001001 110000101101:110000101101
	.zero 12
	.inst 0xb881085e // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:2 10:10 imm9:000010000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21060
	.zero 1048520
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
	ldr x25, =initial_cap_values
	.inst 0xc2400322 // ldr c2, [x25, #0]
	.inst 0xc2400729 // ldr c9, [x25, #1]
	.inst 0xc2400b2c // ldr c12, [x25, #2]
	.inst 0xc2400f3d // ldr c29, [x25, #3]
	.inst 0xc240133e // ldr c30, [x25, #4]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103d
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603079 // ldr c25, [c3, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601079 // ldr c25, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x3, #0xf
	and x25, x25, x3
	cmp x25, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f23 // ldr c3, [x25, #3]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401323 // ldr c3, [x25, #4]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401723 // ldr c3, [x25, #5]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401b23 // ldr c3, [x25, #6]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401f23 // ldr c3, [x25, #7]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402323 // ldr c3, [x25, #8]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402723 // ldr c3, [x25, #9]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402b23 // ldr c3, [x25, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402f23 // ldr c3, [x25, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012b0
	ldr x1, =check_data2
	ldr x2, =0x000012d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001df8
	ldr x1, =check_data3
	ldr x2, =0x00001dfc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400030
	ldr x1, =check_data5
	ldr x2, =0x00400038
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004087f8
	ldr x1, =check_data6
	ldr x2, =0x004087fa
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffff0
	ldr x1, =check_data7
	ldr x2, =0x004ffff8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
