.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x41
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x0a, 0x68, 0x1d, 0x79, 0x84, 0x83, 0xe4, 0xf8, 0x72, 0x30, 0xe6, 0x62, 0xda, 0x53, 0xff, 0xe2
	.byte 0x21, 0x60, 0x5d, 0xba, 0xff, 0xd7, 0x09, 0x82, 0x5e, 0xb2, 0xc0, 0xc2, 0xd2, 0xf6, 0xb1, 0xa9
	.byte 0x12, 0x02, 0xc0, 0xda, 0x40, 0xe7, 0xe4, 0xd2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x850
	/* C3 */
	.octa 0x1900
	/* C4 */
	.octa 0x8000000
	/* C10 */
	.octa 0x0
	/* C22 */
	.octa 0x1800
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x4100001200000000
	/* C30 */
	.octa 0x40000000000100050000000000001803
final_cap_values:
	/* C0 */
	.octa 0x273a000000000000
	/* C3 */
	.octa 0x15c0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x1718
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x4100001200000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa01080003d0640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000000000000010000000100d
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000015c0
	.dword initial_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x791d680a // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:0 imm12:011101011010 opc:00 111001:111001 size:01
	.inst 0xf8e48384 // swp:aarch64/instrs/memory/atomicops/swp Rt:4 Rn:28 100000:100000 Rs:4 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x62e63072 // LDP-C.RIBW-C Ct:18 Rn:3 Ct2:01100 imm7:1001100 L:1 011000101:011000101
	.inst 0xe2ff53da // ASTUR-V.RI-D Rt:26 Rn:30 op2:00 imm9:111110101 V:1 op1:11 11100010:11100010
	.inst 0xba5d6021 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:1 00:00 cond:0110 Rm:29 111010010:111010010 op:0 sf:1
	.inst 0x8209d7ff // LDR-C.I-C Ct:31 imm17:00100111010111111 1000001000:1000001000
	.inst 0xc2c0b25e // GCSEAL-R.C-C Rd:30 Cn:18 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xa9b1f6d2 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:18 Rn:22 Rt2:11101 imm7:1100011 L:0 1010011:1010011 opc:10
	.inst 0xdac00212 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:18 Rn:16 101101011000000000000:101101011000000000000 sf:1
	.inst 0xd2e4e740 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0010011100111010 hw:11 100101:100101 opc:10 sf:1
	.inst 0xc2c212a0
	.zero 1048532
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2400a84 // ldr c4, [x20, #2]
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2401296 // ldr c22, [x20, #4]
	.inst 0xc240169c // ldr c28, [x20, #5]
	.inst 0xc2401a9d // ldr c29, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q26, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b4 // ldr c20, [c21, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826012b4 // ldr c20, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x21, #0xf
	and x20, x20, x21
	cmp x20, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400295 // ldr c21, [x20, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400695 // ldr c21, [x20, #1]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400a95 // ldr c21, [x20, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400e95 // ldr c21, [x20, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401295 // ldr c21, [x20, #4]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2401e95 // ldr c21, [x20, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402295 // ldr c21, [x20, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x21, v26.d[0]
	cmp x20, x21
	b.ne comparison_fail
	ldr x20, =0x0
	mov x21, v26.d[1]
	cmp x20, x21
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
	ldr x0, =0x000015c0
	ldr x1, =check_data1
	ldr x2, =0x000015e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001704
	ldr x1, =check_data2
	ldr x2, =0x00001706
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001718
	ldr x1, =check_data3
	ldr x2, =0x00001728
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017f8
	ldr x1, =check_data4
	ldr x2, =0x00001800
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
	ldr x0, =0x0044ec00
	ldr x1, =check_data6
	ldr x2, =0x0044ec10
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
