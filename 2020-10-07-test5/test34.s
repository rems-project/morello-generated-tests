.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x5d, 0x78, 0xa4, 0x82, 0x01, 0x83, 0x40, 0x7a, 0xc2, 0x5a, 0xcc, 0x78, 0xe2, 0x02, 0x1f, 0xba
	.byte 0x0e, 0x54, 0x03, 0x79, 0xa2, 0x30, 0xc2, 0xc2
.data
check_data4:
	.byte 0x82, 0x51, 0x40, 0xe2, 0x00, 0xb1, 0xc0, 0xc2, 0x3f, 0x70, 0x23, 0xf1, 0x02, 0xf0, 0x52, 0x8b
	.byte 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000500030000000000001022
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x338
	/* C5 */
	.octa 0x20008000000000000000000000400075
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x1f87
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000007000700000000003fff41
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C4 */
	.octa 0x338
	/* C5 */
	.octa 0x20008000000000000000000000400075
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x1f87
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000007000700000000003fff41
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000000000000000000400019
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000180004000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82a4785d // ASTR-V.RRB-D Rt:29 Rn:2 opc:10 S:1 option:011 Rm:4 1:1 L:0 100000101:100000101
	.inst 0x7a408301 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:24 00:00 cond:1000 Rm:0 111010010:111010010 op:1 sf:0
	.inst 0x78cc5ac2 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:22 10:10 imm9:011000101 0:0 opc:11 111000:111000 size:01
	.inst 0xba1f02e2 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:23 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:1
	.inst 0x7903540e // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:0 imm12:000011010101 opc:00 111001:111001 size:01
	.inst 0xc2c230a2 // BLRS-C-C 00010:00010 Cn:5 100:100 opc:01 11000010110000100:11000010110000100
	.zero 92
	.inst 0xe2405182 // ASTURH-R.RI-32 Rt:2 Rn:12 op2:00 imm9:000000101 V:0 op1:01 11100010:11100010
	.inst 0xc2c0b100 // GCSEAL-R.C-C Rd:0 Cn:8 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xf123703f // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:1 imm12:100011011100 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x8b52f002 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:0 imm6:111100 Rm:18 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c21060
	.zero 1048440
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc240160c // ldr c12, [x16, #5]
	.inst 0xc2401a0e // ldr c14, [x16, #6]
	.inst 0xc2401e16 // ldr c22, [x16, #7]
	.inst 0xc2402217 // ldr c23, [x16, #8]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x16, #0x60000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603070 // ldr c16, [c3, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601070 // ldr c16, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401203 // ldr c3, [x16, #4]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401603 // ldr c3, [x16, #5]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401a03 // ldr c3, [x16, #6]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401e03 // ldr c3, [x16, #7]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402203 // ldr c3, [x16, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x3, v29.d[0]
	cmp x16, x3
	b.ne comparison_fail
	ldr x16, =0x0
	mov x3, v29.d[1]
	cmp x16, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011cc
	ldr x1, =check_data0
	ldr x2, =0x000011ce
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000019c0
	ldr x1, =check_data1
	ldr x2, =0x000019c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f8c
	ldr x1, =check_data2
	ldr x2, =0x00001f8e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400074
	ldr x1, =check_data4
	ldr x2, =0x00400088
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
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
