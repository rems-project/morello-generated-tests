.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x0a
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x02, 0x7a, 0xbc, 0xd0, 0xc2, 0xb3, 0xf3, 0xc2, 0x35, 0x28, 0x12, 0xa2, 0xeb, 0x5b, 0x00, 0x4a
	.byte 0x40, 0xa0, 0x81, 0x5a, 0xc1, 0x1f, 0xa2, 0x4a, 0xe2, 0xd3, 0xc0, 0xc2, 0x1e, 0x48, 0xc1, 0xc2
	.byte 0x41, 0x3c, 0x52, 0x79, 0x40, 0x4a, 0xed, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1a00
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0xa004000000000000000000000000000
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x6a00000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x804
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0xa004000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x2010000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000014740000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000007040700ffffffffffe7c3
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd0bc7a02 // ADRP-C.IP-C Rd:2 immhi:011110001111010000 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2f3b3c2 // EORFLGS-C.CI-C Cd:2 Cn:30 0:0 10:10 imm8:10011101 11000010111:11000010111
	.inst 0xa2122835 // STTR-C.RIB-C Ct:21 Rn:1 10:10 imm9:100100010 0:0 opc:00 10100010:10100010
	.inst 0x4a005beb // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:11 Rn:31 imm6:010110 Rm:0 N:0 shift:00 01010:01010 opc:10 sf:0
	.inst 0x5a81a040 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:2 o2:0 0:0 cond:1010 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x4aa21fc1 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:30 imm6:000111 Rm:2 N:1 shift:10 01010:01010 opc:10 sf:0
	.inst 0xc2c0d3e2 // GCPERM-R.C-C Rd:2 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c1481e // UNSEAL-C.CC-C Cd:30 Cn:0 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0x79523c41 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:2 imm12:010010001111 opc:01 111001:111001 size:01
	.inst 0xc2ed4a40 // ORRFLGS-C.CI-C Cd:0 Cn:18 0:0 01:01 imm8:01101010 11000010111:11000010111
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004b2 // ldr c18, [x5, #1]
	.inst 0xc24008b5 // ldr c21, [x5, #2]
	.inst 0xc2400cbe // ldr c30, [x5, #3]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603365 // ldr c5, [c27, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601365 // ldr c5, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x27, #0x9
	and x5, x5, x27
	cmp x5, #0x0
	b.ne comparison_fail
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
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24010bb // ldr c27, [x5, #4]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc24014bb // ldr c27, [x5, #5]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001522
	ldr x1, =check_data1
	ldr x2, =0x00001524
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
