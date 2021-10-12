.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5f, 0xe9, 0x65, 0xd8, 0x1e, 0x90, 0xc5, 0xc2, 0x3e, 0x8e, 0x4b, 0x37, 0xdf, 0xbb, 0xc9, 0xc2
	.byte 0xad, 0x7f, 0x9f, 0xc8, 0xbe, 0xff, 0x40, 0xbd, 0x19, 0x10, 0x15, 0x78, 0xde, 0x23, 0xd6, 0xc2
	.byte 0xdf, 0x1b, 0x54, 0x0a, 0xde, 0x0f, 0x22, 0x6b, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001141
	/* C13 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000300020000000000001000
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001141
	/* C13 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000300020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x10000001e0870091080000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd865e95f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0110010111101001010 011000:011000 opc:11
	.inst 0xc2c5901e // CVTD-C.R-C Cd:30 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x374b8e3e // tbnz:aarch64/instrs/branch/conditional/test Rt:30 imm14:01110001110001 b40:01001 op:1 011011:011011 b5:0
	.inst 0xc2c9bbdf // SCBNDS-C.CI-C Cd:31 Cn:30 1110:1110 S:0 imm6:010011 11000010110:11000010110
	.inst 0xc89f7fad // stllr:aarch64/instrs/memory/ordered Rt:13 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xbd40ffbe // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:29 imm12:000000111111 opc:01 111101:111101 size:10
	.inst 0x78151019 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:0 00:00 imm9:101010001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2d623de // SCBNDSE-C.CR-C Cd:30 Cn:30 000:000 opc:01 0:0 Rm:22 11000010110:11000010110
	.inst 0x0a541bdf // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:30 imm6:000110 Rm:20 N:0 shift:01 01010:01010 opc:00 sf:0
	.inst 0x6b220fde // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:30 imm3:011 option:000 Rm:2 01011001:01011001 S:1 op:1 sf:0
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc240066d // ldr c13, [x19, #1]
	.inst 0xc2400a79 // ldr c25, [x19, #2]
	.inst 0xc2400e7d // ldr c29, [x19, #3]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603233 // ldr c19, [c17, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601233 // ldr c19, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x17, #0x4
	and x19, x19, x17
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400271 // ldr c17, [x19, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400671 // ldr c17, [x19, #1]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x17, v30.d[0]
	cmp x19, x17
	b.ne comparison_fail
	ldr x19, =0x0
	mov x17, v30.d[1]
	cmp x19, x17
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
	ldr x0, =0x00001092
	ldr x1, =check_data1
	ldr x2, =0x00001094
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fc
	ldr x1, =check_data2
	ldr x2, =0x00001100
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
