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
	.zero 16
.data
check_data3:
	.byte 0xd3, 0xd3, 0xe1, 0x82, 0x33, 0x89, 0x01, 0x1b, 0x03, 0xa4, 0x9e, 0xda, 0x1c, 0xfd, 0xf7, 0xb0
	.byte 0xc0, 0x02, 0x5f, 0xd6
.data
check_data4:
	.byte 0x02, 0xb0, 0xc0, 0xc2, 0x06, 0x00, 0x6c, 0x78, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x48, 0x42, 0x6b, 0x82, 0x50, 0x8e, 0x50, 0x78, 0x20, 0xa7, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000001000
	/* C1 */
	.octa 0x1700
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000000100070000000000001100
	/* C22 */
	.octa 0x404800
	/* C25 */
	.octa 0x2040800250043ffe0000000000404000
	/* C30 */
	.octa 0x4023d8
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000001000
	/* C1 */
	.octa 0x1700
	/* C2 */
	.octa 0x1
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000000100070000000000001008
	/* C22 */
	.octa 0x404800
	/* C25 */
	.octa 0x2040800250043ffe0000000000404000
	/* C28 */
	.octa 0x2000800000010007fffffffff03a1000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000800000010007000000000040480d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001c40
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82e1d3d3 // ALDR-R.RRB-32 Rt:19 Rn:30 opc:00 S:1 option:110 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x1b018933 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:19 Rn:9 Ra:2 o0:1 Rm:1 0011011000:0011011000 sf:0
	.inst 0xda9ea403 // csneg:aarch64/instrs/integer/conditional/select Rd:3 Rn:0 o2:1 0:0 cond:1010 Rm:30 011010100:011010100 op:1 sf:1
	.inst 0xb0f7fd1c // ADRP-C.IP-C Rd:28 immhi:111011111111101000 P:1 10000:10000 immlo:01 op:1
	.inst 0xd65f02c0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:22 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 16364
	.inst 0xc2c0b002 // GCSEAL-R.C-C Rd:2 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x786c0006 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:0 00:00 opc:000 0:0 Rs:12 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c210a0
	.zero 2036
	.inst 0x826b4248 // ALDR-C.RI-C Ct:8 Rn:18 op:00 imm9:010110100 L:1 1000001001:1000001001
	.inst 0x78508e50 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:18 11:11 imm9:100001000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c2a720 // BLRS-C.C-C 00000:00000 Cn:25 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.zero 1030132
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2401152 // ldr c18, [x10, #4]
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2401959 // ldr c25, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x8
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030aa // ldr c10, [c5, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010aa // ldr c10, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x5, #0x9
	and x10, x10, x5
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400145 // ldr c5, [x10, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d45 // ldr c5, [x10, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401145 // ldr c5, [x10, #4]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401545 // ldr c5, [x10, #5]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401945 // ldr c5, [x10, #6]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401d45 // ldr c5, [x10, #7]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2402145 // ldr c5, [x10, #8]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2402545 // ldr c5, [x10, #9]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402945 // ldr c5, [x10, #10]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2402d45 // ldr c5, [x10, #11]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2403145 // ldr c5, [x10, #12]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403545 // ldr c5, [x10, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c40
	ldr x1, =check_data2
	ldr x2, =0x00001c50
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404000
	ldr x1, =check_data4
	ldr x2, =0x0040400c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00404800
	ldr x1, =check_data5
	ldr x2, =0x0040480c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407fd8
	ldr x1, =check_data6
	ldr x2, =0x00407fdc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
