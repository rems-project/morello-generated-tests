.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x3d, 0x10, 0xef, 0x22, 0x00, 0xaa, 0x34, 0xcb, 0xa0, 0x32, 0xc1, 0xc2, 0xd7, 0x08, 0xd4, 0x9a
	.byte 0x37, 0x19, 0xb3, 0x22, 0xce, 0x7e, 0xdf, 0x08, 0x5f, 0x58, 0x31, 0x38, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x3d, 0x44, 0xce, 0x82, 0x4e, 0xe6, 0x04, 0x02, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x660
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x800
	/* C18 */
	.octa 0x7a0050000000000018000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x3e0
final_cap_values:
	/* C1 */
	.octa 0x440
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0xfffffffffffffe60
	/* C14 */
	.octa 0x7a0050000000000018139
	/* C17 */
	.octa 0x800
	/* C18 */
	.octa 0x7a0050000000000018000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x3e0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000027002000ffffffffffffe0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001660
	.dword 0x0000000000001670
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22ef103d // LDP-CC.RIAW-C Ct:29 Rn:1 Ct2:00100 imm7:1011110 L:1 001000101:001000101
	.inst 0xcb34aa00 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:16 imm3:010 option:101 Rm:20 01011001:01011001 S:0 op:1 sf:1
	.inst 0xc2c132a0 // GCFLGS-R.C-C Rd:0 Cn:21 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9ad408d7 // udiv:aarch64/instrs/integer/arithmetic/div Rd:23 Rn:6 o1:0 00001:00001 Rm:20 0011010110:0011010110 sf:1
	.inst 0x22b31937 // STP-CC.RIAW-C Ct:23 Rn:9 Ct2:00110 imm7:1100110 L:0 001000101:001000101
	.inst 0x08df7ece // ldlarb:aarch64/instrs/memory/ordered Rt:14 Rn:22 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x3831585f // strb_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:2 10:10 S:1 option:010 Rm:17 1:1 opc:00 111000:111000 size:00
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x82ce443d // ALDRSB-R.RRB-32 Rt:29 Rn:1 opc:01 S:0 option:010 Rm:14 0:0 L:1 100000101:100000101
	.inst 0x0204e64e // ADD-C.CIS-C Cd:14 Cn:18 imm12:000100111001 sh:0 A:0 00000010:00000010
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314f // ldr c15, [c10, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24021ea // ldr c10, [x15, #8]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc24025ea // ldr c10, [x15, #9]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24029ea // ldr c10, [x15, #10]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2402dea // ldr c10, [x15, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013e0
	ldr x1, =check_data1
	ldr x2, =0x000013e1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001440
	ldr x1, =check_data2
	ldr x2, =0x00001441
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001660
	ldr x1, =check_data3
	ldr x2, =0x00001680
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001801
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
