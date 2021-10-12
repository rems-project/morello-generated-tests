.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 20
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x04, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x1f, 0xbc, 0x5b, 0xb8, 0x36, 0x02, 0xe5, 0x92, 0x40, 0xc5, 0x19, 0xe2, 0xb7, 0x23, 0x04, 0xa9
	.byte 0x3e, 0xa1, 0x02, 0xb8, 0x40, 0x8c, 0x56, 0xf8, 0x21, 0xdb, 0x8d, 0xb8, 0x41, 0x90, 0xc0, 0xc2
	.byte 0x22, 0x48, 0xd2, 0xc2, 0xa4, 0xe3, 0xdd, 0x82, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x108d
	/* C2 */
	.octa 0x1800
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1026
	/* C10 */
	.octa 0x80000000000300070000000000002000
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xf3b
	/* C29 */
	.octa 0x8000000040000c140000000000000fc8
	/* C30 */
	.octa 0x400
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1026
	/* C10 */
	.octa 0x80000000000300070000000000002000
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0xd7eeffffffffffff
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xf3b
	/* C29 */
	.octa 0x8000000040000c140000000000000fc8
	/* C30 */
	.octa 0x400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600408040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb85bbc1f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:0 11:11 imm9:110111011 0:0 opc:01 111000:111000 size:10
	.inst 0x92e50236 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:22 imm16:0010100000010001 hw:11 100101:100101 opc:00 sf:1
	.inst 0xe219c540 // ALDURB-R.RI-32 Rt:0 Rn:10 op2:01 imm9:110011100 V:0 op1:00 11100010:11100010
	.inst 0xa90423b7 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:23 Rn:29 Rt2:01000 imm7:0001000 L:0 1010010:1010010 opc:10
	.inst 0xb802a13e // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:9 00:00 imm9:000101010 0:0 opc:00 111000:111000 size:10
	.inst 0xf8568c40 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:101101000 0:0 opc:01 111000:111000 size:11
	.inst 0xb88ddb21 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:25 10:10 imm9:011011101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c09041 // GCTAG-R.C-C Rd:1 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2d24822 // UNSEAL-C.CC-C Cd:2 Cn:1 0010:0010 opc:01 Cm:18 11000010110:11000010110
	.inst 0x82dde3a4 // ALDRB-R.RRB-B Rt:4 Rn:29 opc:00 S:0 option:111 Rm:29 0:0 L:1 100000101:100000101
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b68 // ldr c8, [x27, #2]
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc2401772 // ldr c18, [x27, #5]
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc240237d // ldr c29, [x27, #8]
	.inst 0xc240277e // ldr c30, [x27, #9]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321b // ldr c27, [c16, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260121b // ldr c27, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400370 // ldr c16, [x27, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400770 // ldr c16, [x27, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400b70 // ldr c16, [x27, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401370 // ldr c16, [x27, #4]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401770 // ldr c16, [x27, #5]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401b70 // ldr c16, [x27, #6]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401f70 // ldr c16, [x27, #7]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2402370 // ldr c16, [x27, #8]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402770 // ldr c16, [x27, #9]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402b70 // ldr c16, [x27, #10]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402f70 // ldr c16, [x27, #11]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403370 // ldr c16, [x27, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001048
	ldr x1, =check_data1
	ldr x2, =0x0000104c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001050
	ldr x1, =check_data2
	ldr x2, =0x00001054
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001768
	ldr x1, =check_data3
	ldr x2, =0x00001770
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f91
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f9c
	ldr x1, =check_data5
	ldr x2, =0x00001f9d
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
