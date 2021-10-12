.section data0, #alloc, #write
	.zero 4016
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 64
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x62, 0x28, 0xca, 0x9a, 0xa2, 0xff, 0x14, 0x51, 0x27, 0xfd, 0xff, 0x62, 0x01, 0x70, 0xc0, 0xc2
	.byte 0xa2, 0x2b, 0xed, 0x02, 0xde, 0xb1, 0xc0, 0xc2, 0xe2, 0xc1, 0xc7, 0x82, 0xe0, 0xeb, 0xdf, 0xc2
	.byte 0x5e, 0x08, 0xc0, 0xda, 0x1e, 0x37, 0x09, 0xf9, 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C9 */
	.octa 0x80100000000100070000000000001fc0
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x4f7ffa
	/* C24 */
	.octa 0x40000000000100050000000000000000
	/* C29 */
	.octa 0x800020000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x8001
	/* C9 */
	.octa 0x80100000000100070000000000001fb0
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x4f7ffa
	/* C24 */
	.octa 0x40000000000100050000000000000000
	/* C29 */
	.octa 0x800020000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fb0
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9aca2862 // asrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:3 op2:10 0010:0010 Rm:10 0011010110:0011010110 sf:1
	.inst 0x5114ffa2 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:29 imm12:010100111111 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x62fffd27 // LDP-C.RIBW-C Ct:7 Rn:9 Ct2:11111 imm7:1111111 L:1 011000101:011000101
	.inst 0xc2c07001 // GCOFF-R.C-C Rd:1 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x02ed2ba2 // SUB-C.CIS-C Cd:2 Cn:29 imm12:101101001010 sh:1 A:1 00000010:00000010
	.inst 0xc2c0b1de // GCSEAL-R.C-C Rd:30 Cn:14 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x82c7c1e2 // ALDRB-R.RRB-B Rt:2 Rn:15 opc:00 S:0 option:110 Rm:7 0:0 L:1 100000101:100000101
	.inst 0xc2dfebe0 // CTHI-C.CR-C Cd:0 Cn:31 1010:1010 opc:11 Rm:31 11000010110:11000010110
	.inst 0xdac0085e // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:2 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf909371e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:24 imm12:001001001101 opc:00 111001:111001 size:11
	.inst 0xc2c21360
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a9 // ldr c9, [x5, #1]
	.inst 0xc24008ae // ldr c14, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010b8 // ldr c24, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603365 // ldr c5, [c27, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601365 // ldr c5, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000bb // ldr c27, [x5, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24004bb // ldr c27, [x5, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24008bb // ldr c27, [x5, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400cbb // ldr c27, [x5, #3]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc24010bb // ldr c27, [x5, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc24014bb // ldr c27, [x5, #5]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401cbb // ldr c27, [x5, #7]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc24020bb // ldr c27, [x5, #8]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24024bb // ldr c27, [x5, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001268
	ldr x1, =check_data0
	ldr x2, =0x00001270
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb0
	ldr x1, =check_data1
	ldr x2, =0x00001fd0
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
	ldr x0, =0x004ffffb
	ldr x1, =check_data3
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
