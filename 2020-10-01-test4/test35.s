.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x18, 0x7c, 0xdf, 0x48, 0x40, 0x02, 0x1f, 0xd6
.data
check_data4:
	.byte 0xed, 0x8f, 0x44, 0xe2, 0x95, 0x32, 0xec, 0xc2, 0xc7, 0x2b, 0x48, 0xba, 0x7e, 0x17, 0xc0, 0xda
	.byte 0xcf, 0x33, 0xc0, 0xc2, 0xfe, 0x7f, 0x9f, 0x48, 0x31, 0xe4, 0xde, 0xd2, 0x47, 0xac, 0xda, 0x38
	.byte 0x20, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x101c
	/* C2 */
	.octa 0x401060
	/* C18 */
	.octa 0x40000c
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x8800a3d21201aa35
final_cap_values:
	/* C0 */
	.octa 0x101c
	/* C2 */
	.octa 0x40100a
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0xf72100000000
	/* C18 */
	.octa 0x40000c
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x6100000000000000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x8800a3d21201aa35
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x80000000520410020000000000001030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040784270000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000430007000000000081c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48df7c18 // ldlarh:aarch64/instrs/memory/ordered Rt:24 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd61f0240 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:18 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0xe2448fed // ALDURSH-R.RI-32 Rt:13 Rn:31 op2:11 imm9:001001000 V:0 op1:01 11100010:11100010
	.inst 0xc2ec3295 // EORFLGS-C.CI-C Cd:21 Cn:20 0:0 10:10 imm8:01100001 11000010111:11000010111
	.inst 0xba482bc7 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0111 0:0 Rn:30 10:10 cond:0010 imm5:01000 111010010:111010010 op:0 sf:1
	.inst 0xdac0177e // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:27 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c033cf // GCLEN-R.C-C Rd:15 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x489f7ffe // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xd2dee431 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:1111011100100001 hw:10 100101:100101 opc:10 sf:1
	.inst 0x38daac47 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:7 Rn:2 11:11 imm9:110101010 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c21020
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400af2 // ldr c18, [x23, #2]
	.inst 0xc2400ef4 // ldr c20, [x23, #3]
	.inst 0xc24012fb // ldr c27, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x20000000
	msr nzcv, x23
	ldr x23, =initial_csp_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x3085003a
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82603037 // ldr c23, [c1, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601037 // ldr c23, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2c1a441 // chkeq c2, c1
	b.ne comparison_fail
	.inst 0xc2400ae1 // ldr c1, [x23, #2]
	.inst 0xc2c1a4e1 // chkeq c7, c1
	b.ne comparison_fail
	.inst 0xc2400ee1 // ldr c1, [x23, #3]
	.inst 0xc2c1a5a1 // chkeq c13, c1
	b.ne comparison_fail
	.inst 0xc24012e1 // ldr c1, [x23, #4]
	.inst 0xc2c1a5e1 // chkeq c15, c1
	b.ne comparison_fail
	.inst 0xc24016e1 // ldr c1, [x23, #5]
	.inst 0xc2c1a621 // chkeq c17, c1
	b.ne comparison_fail
	.inst 0xc2401ae1 // ldr c1, [x23, #6]
	.inst 0xc2c1a641 // chkeq c18, c1
	b.ne comparison_fail
	.inst 0xc2401ee1 // ldr c1, [x23, #7]
	.inst 0xc2c1a681 // chkeq c20, c1
	b.ne comparison_fail
	.inst 0xc24022e1 // ldr c1, [x23, #8]
	.inst 0xc2c1a6a1 // chkeq c21, c1
	b.ne comparison_fail
	.inst 0xc24026e1 // ldr c1, [x23, #9]
	.inst 0xc2c1a701 // chkeq c24, c1
	b.ne comparison_fail
	.inst 0xc2402ae1 // ldr c1, [x23, #10]
	.inst 0xc2c1a761 // chkeq c27, c1
	b.ne comparison_fail
	.inst 0xc2402ee1 // ldr c1, [x23, #11]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x0000101e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001078
	ldr x1, =check_data2
	ldr x2, =0x0000107a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040000c
	ldr x1, =check_data4
	ldr x2, =0x00400030
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040100a
	ldr x1, =check_data5
	ldr x2, =0x0040100b
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
