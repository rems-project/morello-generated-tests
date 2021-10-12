.section data0, #alloc, #write
	.zero 2704
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1376
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xe0, 0x8b, 0x57, 0x78, 0xc2, 0x3c, 0xc1, 0xc2, 0xd8, 0xdb, 0xd8, 0xc2, 0x3f, 0x30, 0xc7, 0xc2
	.byte 0xdf, 0x26, 0xe4, 0x92, 0xc0, 0xb3, 0xe2, 0xc2, 0xc1, 0x2e, 0x99, 0x78, 0x00, 0xd1, 0xc5, 0xc2
	.byte 0x3e, 0x30, 0xc1, 0xc2, 0x21, 0x90, 0xc5, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01, 0x80
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C22 */
	.octa 0x8000000000010005000000000040106e
	/* C30 */
	.octa 0x720070002000000008000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3800cffffffffffff8001
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100050000000000401000
	/* C24 */
	.octa 0x720070004000000000000
	/* C30 */
	.octa 0xff00000000000000
initial_csp_value:
	.octa 0x80000000000600000000000000001b20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x3800c0000000000200000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78578be0 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:101111000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c13cc2 // CSEL-C.CI-C Cd:2 Cn:6 11:11 cond:0011 Cm:1 11000010110:11000010110
	.inst 0xc2d8dbd8 // ALIGNU-C.CI-C Cd:24 Cn:30 0110:0110 U:1 imm6:110001 11000010110:11000010110
	.inst 0xc2c7303f // RRMASK-R.R-C Rd:31 Rn:1 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x92e426df // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:0010000100110110 hw:11 100101:100101 opc:00 sf:1
	.inst 0xc2e2b3c0 // EORFLGS-C.CI-C Cd:0 Cn:30 0:0 10:10 imm8:00010101 11000010111:11000010111
	.inst 0x78992ec1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:22 11:11 imm9:110010010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c5d100 // CVTDZ-C.R-C Cd:0 Rn:8 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c1303e // GCFLGS-R.C-C Rd:30 Cn:1 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c59021 // CVTD-C.R-C Cd:1 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c21060
	.zero 4052
	.inst 0x00008001
	.zero 1044476
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400648 // ldr c8, [x18, #1]
	.inst 0xc2400a56 // ldr c22, [x18, #2]
	.inst 0xc2400e5e // ldr c30, [x18, #3]
	/* Set up flags and system registers */
	mov x18, #0x20000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x3085003a
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603072 // ldr c18, [c3, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601072 // ldr c18, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x3, #0x2
	and x18, x18, x3
	cmp x18, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400243 // ldr c3, [x18, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a43 // ldr c3, [x18, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401243 // ldr c3, [x18, #4]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401643 // ldr c3, [x18, #5]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2401a43 // ldr c3, [x18, #6]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001a98
	ldr x1, =check_data0
	ldr x2, =0x00001a9a
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
	ldr x0, =0x00401000
	ldr x1, =check_data2
	ldr x2, =0x00401002
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
	.inst 0xc28b4132 // msr ddc_el3, c18
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
