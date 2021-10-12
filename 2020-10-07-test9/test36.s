.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x20
.data
check_data1:
	.byte 0x04
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x5c, 0x7b, 0x31, 0xa2, 0xc6, 0x6b, 0x13, 0x78, 0x00, 0x68, 0x8e, 0x78, 0x5e, 0x10, 0x01, 0x38
	.byte 0x7e, 0x42, 0xcc, 0xc2, 0x22, 0x03, 0x01, 0xda, 0xc2, 0x73, 0x5b, 0x82, 0xe0, 0x73, 0xc0, 0xc2
	.byte 0x9e, 0x30, 0xf0, 0xc2, 0x4b, 0xfe, 0x3f, 0x42, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000003ff900070000000000001002
	/* C1 */
	.octa 0x3dffffffffffffff
	/* C2 */
	.octa 0x40000000030700010000000000001000
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x20
	/* C17 */
	.octa 0x800000000000100
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x200007c0070000000008000001
	/* C25 */
	.octa 0x4000000000000000
	/* C26 */
	.octa 0x48000000000000008000000000000000
	/* C28 */
	.octa 0x20004000000000000000000000000000
	/* C30 */
	.octa 0x40000000580710070000000000001804
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3dffffffffffffff
	/* C2 */
	.octa 0x200000000000000
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x20
	/* C17 */
	.octa 0x800000000000100
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x200007c0070000000008000001
	/* C25 */
	.octa 0x4000000000000000
	/* C26 */
	.octa 0x48000000000000008000000000000000
	/* C28 */
	.octa 0x20004000000000000000000000000000
	/* C30 */
	.octa 0x3fff800000008100000000000000
initial_SP_EL3_value:
	.octa 0x400000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080004000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700fff03db8000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword initial_cap_values + 208
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2317b5c // STR-C.RRB-C Ct:28 Rn:26 10:10 S:1 option:011 Rm:17 1:1 opc:00 10100010:10100010
	.inst 0x78136bc6 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:6 Rn:30 10:10 imm9:100110110 0:0 opc:00 111000:111000 size:01
	.inst 0x788e6800 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:0 10:10 imm9:011100110 0:0 opc:10 111000:111000 size:01
	.inst 0x3801105e // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:000010001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2cc427e // SCVALUE-C.CR-C Cd:30 Cn:19 000:000 opc:10 0:0 Rm:12 11000010110:11000010110
	.inst 0xda010322 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:25 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:1
	.inst 0x825b73c2 // ASTR-C.RI-C Ct:2 Rn:30 op:00 imm9:110110111 L:0 1000001001:1000001001
	.inst 0xc2c073e0 // GCOFF-R.C-C Rd:0 Cn:31 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2f0309e // EORFLGS-C.CI-C Cd:30 Cn:4 0:0 10:10 imm8:10000001 11000010111:11000010111
	.inst 0x423ffe4b // ASTLR-R.R-32 Rt:11 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c21300
	.zero 1048532
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc24016ab // ldr c11, [x21, #5]
	.inst 0xc2401aac // ldr c12, [x21, #6]
	.inst 0xc2401eb1 // ldr c17, [x21, #7]
	.inst 0xc24022b2 // ldr c18, [x21, #8]
	.inst 0xc24026b3 // ldr c19, [x21, #9]
	.inst 0xc2402ab9 // ldr c25, [x21, #10]
	.inst 0xc2402eba // ldr c26, [x21, #11]
	.inst 0xc24032bc // ldr c28, [x21, #12]
	.inst 0xc24036be // ldr c30, [x21, #13]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603315 // ldr c21, [c24, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601315 // ldr c21, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x24, #0x2
	and x21, x21, x24
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b8 // ldr c24, [x21, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006b8 // ldr c24, [x21, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400ab8 // ldr c24, [x21, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400eb8 // ldr c24, [x21, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc24012b8 // ldr c24, [x21, #4]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401ab8 // ldr c24, [x21, #6]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24022b8 // ldr c24, [x21, #8]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24026b8 // ldr c24, [x21, #9]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402ab8 // ldr c24, [x21, #10]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402eb8 // ldr c24, [x21, #11]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24032b8 // ldr c24, [x21, #12]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc24036b8 // ldr c24, [x21, #13]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001011
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e8
	ldr x1, =check_data2
	ldr x2, =0x000010ea
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000173a
	ldr x1, =check_data3
	ldr x2, =0x0000173c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001b90
	ldr x1, =check_data4
	ldr x2, =0x00001ba0
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
