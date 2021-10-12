.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x1d, 0x0f, 0xdb, 0x9a, 0x83, 0xc8, 0xbd, 0x82, 0xd7, 0x73, 0xc0, 0xc2, 0xd4, 0x07, 0x90, 0x9a
	.byte 0x4a, 0xe4, 0x42, 0xea, 0xfe, 0x2e, 0xde, 0xc2, 0x0c, 0xe4, 0x86, 0x78, 0x41, 0xd3, 0xc0, 0xc2
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x1f, 0xf8, 0xcc, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x401c7e
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000400200110000000000001800
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x401cec
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000400200110000000000001800
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410200000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000200000080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9adb0f1d // sdiv:aarch64/instrs/integer/arithmetic/div Rd:29 Rn:24 o1:1 00001:00001 Rm:27 0011010110:0011010110 sf:1
	.inst 0x82bdc883 // ASTR-V.RRB-D Rt:3 Rn:4 opc:10 S:0 option:110 Rm:29 1:1 L:0 100000101:100000101
	.inst 0xc2c073d7 // GCOFF-R.C-C Rd:23 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9a9007d4 // csinc:aarch64/instrs/integer/conditional/select Rd:20 Rn:30 o2:1 0:0 cond:0000 Rm:16 011010100:011010100 op:0 sf:1
	.inst 0xea42e44a // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:10 Rn:2 imm6:111001 Rm:2 N:0 shift:01 01010:01010 opc:11 sf:1
	.inst 0xc2de2efe // CSEL-C.CI-C Cd:30 Cn:23 11:11 cond:0010 Cm:30 11000010110:11000010110
	.inst 0x7886e40c // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:0 01:01 imm9:001101110 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c0d341 // GCPERM-R.C-C Rd:1 Cn:26 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2ccf81f // SCBNDS-C.CI-S Cd:31 Cn:0 1110:1110 S:1 imm6:011001 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x18, #0x40000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f2 // ldr c18, [c7, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010f2 // ldr c18, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x7, #0xf
	and x18, x18, x7
	cmp x18, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400247 // ldr c7, [x18, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400e47 // ldr c7, [x18, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401247 // ldr c7, [x18, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401647 // ldr c7, [x18, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401a47 // ldr c7, [x18, #6]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401e47 // ldr c7, [x18, #7]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402247 // ldr c7, [x18, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402647 // ldr c7, [x18, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x7, v3.d[0]
	cmp x18, x7
	b.ne comparison_fail
	ldr x18, =0x0
	mov x7, v3.d[1]
	cmp x18, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001808
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00401c7e
	ldr x1, =check_data2
	ldr x2, =0x00401c80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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

	.balign 128
vector_table:
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
