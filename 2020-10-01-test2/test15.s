.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x12, 0xec, 0x12, 0xf8, 0x8b, 0x1b, 0xda, 0xc2, 0x24, 0x28, 0xdf, 0xc2, 0x17, 0xd5, 0xda, 0x28
	.byte 0xc2, 0xae, 0x01, 0x9b, 0x02, 0xe8, 0xe4, 0xc2, 0xd4, 0xfb, 0xfe, 0x82, 0xe0, 0x93, 0x04, 0xfc
	.byte 0x4a, 0xc3, 0x5e, 0x3a, 0x61, 0x99, 0x00, 0x82, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100070000000000002052
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C8 */
	.octa 0x80000000580108310000000000001020
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x100400120010000000000010001
	/* C30 */
	.octa 0xe38e38e38e400000
final_cap_values:
	/* C0 */
	.octa 0x40000000000100070000000000001f80
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100072700000000001f80
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C8 */
	.octa 0x800000005801083100000000000010f4
	/* C11 */
	.octa 0x100400120010000000000000000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x100400120010000000000010001
	/* C30 */
	.octa 0xe38e38e38e400000
initial_csp_value:
	.octa 0x4000000010004800000000000000131f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000280faa060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002003000700000ea000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf812ec12 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:0 11:11 imm9:100101110 0:0 opc:00 111000:111000 size:11
	.inst 0xc2da1b8b // ALIGND-C.CI-C Cd:11 Cn:28 0110:0110 U:0 imm6:110100 11000010110:11000010110
	.inst 0xc2df2824 // BICFLGS-C.CR-C Cd:4 Cn:1 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x28dad517 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:23 Rn:8 Rt2:10101 imm7:0110101 L:1 1010001:1010001 opc:00
	.inst 0x9b01aec2 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:22 Ra:11 o0:1 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2e4e802 // ORRFLGS-C.CI-C Cd:2 Cn:0 0:0 01:01 imm8:00100111 11000010111:11000010111
	.inst 0x82fefbd4 // ALDR-V.RRB-D Rt:20 Rn:30 opc:10 S:1 option:111 Rm:30 1:1 L:1 100000101:100000101
	.inst 0xfc0493e0 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:001001001 0:0 opc:00 111100:111100 size:11
	.inst 0x3a5ec34a // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1010 0:0 Rn:26 00:00 cond:1100 Rm:30 111010010:111010010 op:0 sf:0
	.inst 0x82009961 // LDR-C.I-C Ct:1 imm17:00000010011001011 1000001000:1000001000
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc240121c // ldr c28, [x16, #4]
	.inst 0xc240161e // ldr c30, [x16, #5]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_csp_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f0 // ldr c16, [c15, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x826011f0 // ldr c16, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020f // ldr c15, [x16, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240060f // ldr c15, [x16, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a0f // ldr c15, [x16, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400e0f // ldr c15, [x16, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240120f // ldr c15, [x16, #4]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc2401a0f // ldr c15, [x16, #6]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc2401e0f // ldr c15, [x16, #7]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240220f // ldr c15, [x16, #8]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc240260f // ldr c15, [x16, #9]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc2402a0f // ldr c15, [x16, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x15, v0.d[0]
	cmp x16, x15
	b.ne comparison_fail
	ldr x16, =0x0
	mov x15, v0.d[1]
	cmp x16, x15
	b.ne comparison_fail
	ldr x16, =0xc2da1b8bf812ec12
	mov x15, v20.d[0]
	cmp x16, x15
	b.ne comparison_fail
	ldr x16, =0x0
	mov x15, v20.d[1]
	cmp x16, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001368
	ldr x1, =check_data1
	ldr x2, =0x00001370
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f88
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
	ldr x0, =0x00404cd0
	ldr x1, =check_data4
	ldr x2, =0x00404ce0
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
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
