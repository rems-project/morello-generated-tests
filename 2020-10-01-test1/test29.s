.section data0, #alloc, #write
	.zero 3968
	.byte 0x01, 0x21, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xf0, 0x00, 0x80, 0x00, 0x20
	.zero 112
.data
check_data0:
	.zero 16
	.byte 0x01, 0x21, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xf0, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x01, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x7f, 0x06, 0x4b, 0xf8, 0x21, 0x70, 0x1c, 0xf8, 0xe1, 0x4b, 0xdf, 0xc2, 0x02, 0x74, 0x57, 0x38
	.byte 0xdf, 0x33, 0xc4, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xfa, 0xb3, 0xcb, 0x78, 0x1c, 0xe5, 0x48, 0x38, 0x49, 0x9f, 0x9b, 0xaa, 0x5e, 0x38, 0xc2, 0xc2
	.byte 0xc1, 0x33, 0xc7, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C1 */
	.octa 0x400000000007001f0000000000002001
	/* C8 */
	.octa 0x800000000001000500000000004ffffe
	/* C19 */
	.octa 0x80000000400104010000000000400410
	/* C30 */
	.octa 0x90100000000100050000000000001f70
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fff75
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000000050008c
	/* C19 */
	.octa 0x800000004001040100000000004004c0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x400400000000000000000000
initial_csp_value:
	.octa 0x80000000000100050000000000001f41
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f70
	.dword 0x0000000000001f80
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf84b067f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:19 01:01 imm9:010110000 0:0 opc:01 111000:111000 size:11
	.inst 0xf81c7021 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:111000111 0:0 opc:00 111000:111000 size:11
	.inst 0xc2df4be1 // UNSEAL-C.CC-C Cd:1 Cn:31 0010:0010 opc:01 Cm:31 11000010110:11000010110
	.inst 0x38577402 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:101110111 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c433df // LDPBLR-C.C-C Ct:31 Cn:30 100:100 opc:01 11000010110001000:11000010110001000
	.zero 8428
	.inst 0x78cbb3fa // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:31 00:00 imm9:010111011 0:0 opc:11 111000:111000 size:01
	.inst 0x3848e51c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:28 Rn:8 01:01 imm9:010001110 0:0 opc:01 111000:111000 size:00
	.inst 0xaa9b9f49 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:26 imm6:100111 Rm:27 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c2385e // SCBNDS-C.CI-C Cd:30 Cn:2 1110:1110 S:0 imm6:000100 11000010110:11000010110
	.inst 0xc2c733c1 // RRMASK-R.R-C Rd:1 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c21220
	.zero 1040104
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc240131e // ldr c30, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_csp_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x80
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601238 // ldr c24, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400311 // ldr c17, [x24, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400711 // ldr c17, [x24, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b11 // ldr c17, [x24, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f11 // ldr c17, [x24, #3]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401311 // ldr c17, [x24, #4]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2401b11 // ldr c17, [x24, #6]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2401f11 // ldr c17, [x24, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f70
	ldr x1, =check_data0
	ldr x2, =0x00001f90
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fc8
	ldr x1, =check_data1
	ldr x2, =0x00001fd0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400410
	ldr x1, =check_data4
	ldr x2, =0x00400418
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402100
	ldr x1, =check_data5
	ldr x2, =0x00402118
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
