.section data0, #alloc, #write
	.zero 2016
	.byte 0x40, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x2e, 0x00, 0x80, 0x00, 0x20
	.zero 2064
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x40, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x2e, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xdf, 0x7f, 0x1e, 0x1b, 0x99, 0xdb, 0x82, 0xb8, 0xf7, 0xaa, 0x4a, 0xe2, 0xe0, 0x93, 0xdf, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x1e, 0x12, 0x81, 0xd8, 0xe2, 0x87, 0xbc, 0x22, 0x02, 0x04, 0xbf, 0x9b, 0x52, 0x48, 0x24, 0xb8
	.byte 0x42, 0xb0, 0xc0, 0xc2, 0x0c, 0x7a, 0x70, 0xd1, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000401180040000000000407f60
	/* C28 */
	.octa 0xfd3
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0xfd3
initial_SP_EL3_value:
	.octa 0x9010000041020ff90000000000001820
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000010005003fffffffffa000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword initial_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b1e7fdf // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:30 Ra:31 o0:0 Rm:30 0011011000:0011011000 sf:0
	.inst 0xb882db99 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:28 10:10 imm9:000101101 0:0 opc:10 111000:111000 size:10
	.inst 0xe24aaaf7 // ALDURSH-R.RI-64 Rt:23 Rn:23 op2:10 imm9:010101010 V:0 op1:01 11100010:11100010
	.inst 0xc2df93e0 // BR-CI-C 0:0 0000:0000 Cn:31 100:100 imm7:1111100 110000101101:110000101101
	.zero 262192
	.inst 0xd881121e // prfm_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:1000000100010010000 011000:011000 opc:11
	.inst 0x22bc87e2 // STP-CC.RIAW-C Ct:2 Rn:31 Ct2:00001 imm7:1111001 L:0 001000101:001000101
	.inst 0x9bbf0402 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:0 Ra:1 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xb8244852 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:18 Rn:2 10:10 S:0 option:010 Rm:4 1:1 opc:00 111000:111000 size:10
	.inst 0xc2c0b042 // GCSEAL-R.C-C Rd:2 Cn:2 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xd1707a0c // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:12 Rn:16 imm12:110000011110 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c21260
	.zero 786340
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f12 // ldr c18, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc240171c // ldr c28, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850038
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603278 // ldr c24, [c19, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601278 // ldr c24, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400313 // ldr c19, [x24, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400713 // ldr c19, [x24, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400b13 // ldr c19, [x24, #2]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2401b13 // ldr c19, [x24, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001820
	ldr x1, =check_data2
	ldr x2, =0x00001840
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040800a
	ldr x1, =check_data4
	ldr x2, =0x0040800c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440040
	ldr x1, =check_data5
	ldr x2, =0x0044005c
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
