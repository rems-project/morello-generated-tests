.section data0, #alloc, #write
	.byte 0x10, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x10, 0x11
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 18
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x0d, 0x7c, 0xdf, 0xc8, 0xc7, 0xfd, 0xdf, 0x48, 0xf5, 0xc0, 0x1a, 0xac, 0xac, 0x08, 0xdf, 0xc2
	.byte 0x50, 0x64, 0x5d, 0xa2, 0x0c, 0xe8, 0xd8, 0x82, 0x1d, 0xcc, 0x15, 0x78, 0xde, 0x07, 0x35, 0xe2
	.byte 0xc1, 0x30, 0xc0, 0xc2, 0x0b, 0xac, 0x0d, 0x78, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000590100040000000000001808
	/* C2 */
	.octa 0x1840
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x300070000000000000001
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C24 */
	.octa 0x80
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000100700070000000000001800
final_cap_values:
	/* C0 */
	.octa 0x183e
	/* C1 */
	.octa 0x400000000000
	/* C2 */
	.octa 0x15a0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x300070000000000000001
	/* C7 */
	.octa 0x1110
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x80
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000100700070000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004045c04f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000200100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8df7c0d // ldlar:aarch64/instrs/memory/ordered Rt:13 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x48dffdc7 // ldarh:aarch64/instrs/memory/ordered Rt:7 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xac1ac0f5 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:21 Rn:7 Rt2:10000 imm7:0110101 L:0 1011000:1011000 opc:10
	.inst 0xc2df08ac // SEAL-C.CC-C Cd:12 Cn:5 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0xa25d6450 // LDR-C.RIAW-C Ct:16 Rn:2 01:01 imm9:111010110 0:0 opc:01 10100010:10100010
	.inst 0x82d8e80c // ALDRSH-R.RRB-32 Rt:12 Rn:0 opc:10 S:0 option:111 Rm:24 0:0 L:1 100000101:100000101
	.inst 0x7815cc1d // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:0 11:11 imm9:101011100 0:0 opc:00 111000:111000 size:01
	.inst 0xe23507de // ALDUR-V.RI-B Rt:30 Rn:30 op2:01 imm9:101010000 V:1 op1:00 11100010:11100010
	.inst 0xc2c030c1 // GCLEN-R.C-C Rd:1 Cn:6 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x780dac0b // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:11 Rn:0 11:11 imm9:011011010 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21360
	.zero 1048532
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
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc240164e // ldr c14, [x18, #5]
	.inst 0xc2401a58 // ldr c24, [x18, #6]
	.inst 0xc2401e5d // ldr c29, [x18, #7]
	.inst 0xc240225e // ldr c30, [x18, #8]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q16, =0x0
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603372 // ldr c18, [c27, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601372 // ldr c18, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025b // ldr c27, [x18, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240065b // ldr c27, [x18, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a5b // ldr c27, [x18, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240165b // ldr c27, [x18, #5]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401e5b // ldr c27, [x18, #7]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240225b // ldr c27, [x18, #8]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240265b // ldr c27, [x18, #9]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2402a5b // ldr c27, [x18, #10]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2402e5b // ldr c27, [x18, #11]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240325b // ldr c27, [x18, #12]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240365b // ldr c27, [x18, #13]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x27, v16.d[0]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v16.d[1]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v21.d[0]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v21.d[1]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v30.d[0]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v30.d[1]
	cmp x18, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001460
	ldr x1, =check_data1
	ldr x2, =0x00001480
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001750
	ldr x1, =check_data2
	ldr x2, =0x00001751
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001764
	ldr x1, =check_data3
	ldr x2, =0x00001766
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001808
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0000183e
	ldr x1, =check_data5
	ldr x2, =0x00001850
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001888
	ldr x1, =check_data6
	ldr x2, =0x0000188a
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
