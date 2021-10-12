.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xbf, 0x7d, 0xd9, 0xd0, 0xe0, 0x37, 0x6b, 0xa9, 0x7e, 0x9f, 0x95, 0x38, 0xe0, 0x9b, 0xe6, 0xc2
	.byte 0xfe, 0xc4, 0x32, 0xb9, 0xe2, 0x81, 0xa4, 0xaa, 0xdf, 0x3f, 0x50, 0xd0, 0xa0, 0x00, 0x3f, 0xd6
.data
check_data4:
	.byte 0xdf, 0xa4, 0xc4, 0x78, 0xc1, 0x98, 0xeb, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x100
	/* C6 */
	.octa 0x4ffffc
	/* C7 */
	.octa 0xffffffffffffe438
	/* C11 */
	.octa 0x0
	/* C27 */
	.octa 0x20a5
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x3
	/* C5 */
	.octa 0x100
	/* C6 */
	.octa 0x500046
	/* C7 */
	.octa 0xffffffffffffe438
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C27 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x20
initial_csp_value:
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000500070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd0d97dbf // ADRP-C.I-C Rd:31 immhi:101100101111101101 P:1 10000:10000 immlo:10 op:1
	.inst 0xa96b37e0 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:31 Rt2:01101 imm7:1010110 L:1 1010010:1010010 opc:10
	.inst 0x38959f7e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:27 11:11 imm9:101011001 0:0 opc:10 111000:111000 size:00
	.inst 0xc2e69be0 // SUBS-R.CC-C Rd:0 Cn:31 100110:100110 Cm:6 11000010111:11000010111
	.inst 0xb932c4fe // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:7 imm12:110010110001 opc:00 111001:111001 size:10
	.inst 0xaaa481e2 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:15 imm6:100000 Rm:4 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xd0503fdf // ADRDP-C.ID-C Rd:31 immhi:101000000111111110 P:0 10000:10000 immlo:10 op:1
	.inst 0xd63f00a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 224
	.inst 0x78c4a4df // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:6 01:01 imm9:001001010 0:0 opc:11 111000:111000 size:01
	.inst 0xc2eb98c1 // SUBS-R.CC-C Rd:1 Cn:6 100110:100110 Cm:11 11000010111:11000010111
	.inst 0xc2c212c0
	.zero 1048308
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400105 // ldr c5, [x8, #0]
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc240111b // ldr c27, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_csp_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x8
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c8 // ldr c8, [c22, #3]
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	.inst 0x826012c8 // ldr c8, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x22, #0xf
	and x8, x8, x22
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400116 // ldr c22, [x8, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400516 // ldr c22, [x8, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400916 // ldr c22, [x8, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401516 // ldr c22, [x8, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401916 // ldr c22, [x8, #6]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401d16 // ldr c22, [x8, #7]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402116 // ldr c22, [x8, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016b0
	ldr x1, =check_data0
	ldr x2, =0x000016c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016fc
	ldr x1, =check_data1
	ldr x2, =0x00001700
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x0040010c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
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
