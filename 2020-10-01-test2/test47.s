.section data0, #alloc, #write
	.zero 272
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3648
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 128
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01, 0xa4, 0x01, 0x8a, 0xe1, 0xd3, 0xc0, 0xc2, 0x5e, 0xf9, 0x60, 0x38, 0x0f, 0xc8, 0x53, 0xb8
	.byte 0x21, 0xa0, 0xde, 0xc2, 0xdf, 0x92, 0xc0, 0xc2, 0x1f, 0xc7, 0x3f, 0x9b, 0x2a, 0xfc, 0x48, 0x62
	.byte 0x3b, 0xc8, 0x54, 0x02, 0xd9, 0x73, 0xc0, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2034
	/* C10 */
	.octa 0x4fdfca
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2034
	/* C1 */
	.octa 0x1000
	/* C10 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C15 */
	.octa 0xc2c2c2c2
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0xc2
	/* C27 */
	.octa 0x533000
	/* C30 */
	.octa 0xc2
initial_csp_value:
	.octa 0x4000000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8a01a401 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:0 imm6:101001 Rm:1 N:0 shift:00 01010:01010 opc:00 sf:1
	.inst 0xc2c0d3e1 // GCPERM-R.C-C Rd:1 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x3860f95e // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:10 10:10 S:1 option:111 Rm:0 1:1 opc:01 111000:111000 size:00
	.inst 0xb853c80f // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:15 Rn:0 10:10 imm9:100111100 0:0 opc:01 111000:111000 size:10
	.inst 0xc2dea021 // CLRPERM-C.CR-C Cd:1 Cn:1 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0xc2c092df // GCTAG-R.C-C Rd:31 Cn:22 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x9b3fc71f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:24 Ra:17 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0x6248fc2a // LDNP-C.RIB-C Ct:10 Rn:1 Ct2:11111 imm7:0010001 L:1 011000100:011000100
	.inst 0x0254c83b // ADD-C.CIS-C Cd:27 Cn:1 imm12:010100110010 sh:1 A:0 00000010:00000010
	.inst 0xc2c073d9 // GCOFF-R.C-C Rd:25 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c21120
	.zero 1048528
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006aa // ldr c10, [x21, #1]
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_csp_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603135 // ldr c21, [c9, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601135 // ldr c21, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a9 // ldr c9, [x21, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006a9 // ldr c9, [x21, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc24012a9 // ldr c9, [x21, #4]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24016a9 // ldr c9, [x21, #5]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2401aa9 // ldr c9, [x21, #6]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2401ea9 // ldr c9, [x21, #7]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001110
	ldr x1, =check_data0
	ldr x2, =0x00001130
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f70
	ldr x1, =check_data1
	ldr x2, =0x00001f74
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
