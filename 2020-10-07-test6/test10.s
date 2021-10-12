.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 1968
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xcc, 0x3b, 0x55, 0x7a, 0x92, 0xd2, 0xf5, 0x2d, 0x49, 0xa0, 0x45, 0xb9, 0xbf, 0xca, 0x55, 0xe2
	.byte 0xaa, 0x84, 0xfe, 0xea, 0x48, 0x66, 0x86, 0xeb, 0xd7, 0xeb, 0xb3, 0xb9, 0x61, 0x6b, 0x43, 0xb1
	.byte 0x90, 0xd2, 0x8b, 0xf8, 0xe9, 0x93, 0xc1, 0xc2, 0x00, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xa98
	/* C5 */
	.octa 0xfffffffbffffffff
	/* C20 */
	.octa 0x408010
	/* C21 */
	.octa 0x800000000001000500000000000018a0
	/* C30 */
	.octa 0x400c10
final_cap_values:
	/* C2 */
	.octa 0xa98
	/* C5 */
	.octa 0xfffffffbffffffff
	/* C10 */
	.octa 0xffdff9f3ffffffff
	/* C20 */
	.octa 0x407fbc
	/* C21 */
	.octa 0x800000000001000500000000000018a0
	/* C23 */
	.octa 0xffffffffc2c2c2c2
	/* C30 */
	.octa 0x400c10
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000016000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7a553bcc // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:30 10:10 cond:0011 imm5:10101 111010010:111010010 op:1 sf:0
	.inst 0x2df5d292 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:18 Rn:20 Rt2:10100 imm7:1101011 L:1 1011011:1011011 opc:00
	.inst 0xb945a049 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:2 imm12:000101101000 opc:01 111001:111001 size:10
	.inst 0xe255cabf // ALDURSH-R.RI-64 Rt:31 Rn:21 op2:10 imm9:101011100 V:0 op1:01 11100010:11100010
	.inst 0xeafe84aa // bics:aarch64/instrs/integer/logical/shiftedreg Rd:10 Rn:5 imm6:100001 Rm:30 N:1 shift:11 01010:01010 opc:11 sf:1
	.inst 0xeb866648 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:8 Rn:18 imm6:011001 Rm:6 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xb9b3ebd7 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:30 imm12:110011111010 opc:10 111001:111001 size:10
	.inst 0xb1436b61 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:27 imm12:000011011010 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xf88bd290 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:20 00:00 imm9:010111101 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c193e9 // CLRTAG-C.C-C Cd:9 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c21000
	.zero 16332
	.inst 0xc2c2c2c2
	.zero 16320
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1015868
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400382 // ldr c2, [x28, #0]
	.inst 0xc2400785 // ldr c5, [x28, #1]
	.inst 0xc2400b94 // ldr c20, [x28, #2]
	.inst 0xc2400f95 // ldr c21, [x28, #3]
	.inst 0xc240139e // ldr c30, [x28, #4]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x8260301c // ldr c28, [c0, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260101c // ldr c28, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2c0a441 // chkeq c2, c0
	b.ne comparison_fail
	.inst 0xc2400780 // ldr c0, [x28, #1]
	.inst 0xc2c0a4a1 // chkeq c5, c0
	b.ne comparison_fail
	.inst 0xc2400b80 // ldr c0, [x28, #2]
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	.inst 0xc2400f80 // ldr c0, [x28, #3]
	.inst 0xc2c0a681 // chkeq c20, c0
	b.ne comparison_fail
	.inst 0xc2401380 // ldr c0, [x28, #4]
	.inst 0xc2c0a6a1 // chkeq c21, c0
	b.ne comparison_fail
	.inst 0xc2401780 // ldr c0, [x28, #5]
	.inst 0xc2c0a6e1 // chkeq c23, c0
	b.ne comparison_fail
	.inst 0xc2401b80 // ldr c0, [x28, #6]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0xc2c2c2c2
	mov x0, v18.d[0]
	cmp x28, x0
	b.ne comparison_fail
	ldr x28, =0x0
	mov x0, v18.d[1]
	cmp x28, x0
	b.ne comparison_fail
	ldr x28, =0xc2c2c2c2
	mov x0, v20.d[0]
	cmp x28, x0
	b.ne comparison_fail
	ldr x28, =0x0
	mov x0, v20.d[1]
	cmp x28, x0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x0000103c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x000017fe
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
	ldr x0, =0x00403ff8
	ldr x1, =check_data3
	ldr x2, =0x00403ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407fbc
	ldr x1, =check_data4
	ldr x2, =0x00407fc4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
