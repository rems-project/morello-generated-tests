.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x67, 0x12, 0x50, 0xfa, 0xa2, 0xdd, 0xc2, 0xc2, 0x21, 0x40, 0x4d, 0xa8, 0x20, 0xc4, 0x9f, 0x1a
	.byte 0x68, 0x2a, 0x1e, 0xab, 0xc9, 0xa1, 0x5d, 0x79, 0x3f, 0xb8, 0x03, 0xf8, 0x9e, 0x34, 0x05, 0xaa
	.byte 0x84, 0xf9, 0x4d, 0x38, 0x42, 0x2e, 0xce, 0x1a, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc5, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x20c
	/* C16 */
	.octa 0x807fffffffffffff
	/* C19 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xfc5
	/* C1 */
	.octa 0xfc5
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x20c
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000600ffffffffc00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfa501267 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:19 00:00 cond:0001 Rm:16 111010010:111010010 op:1 sf:1
	.inst 0xc2c2dda2 // CSEL-C.CI-C Cd:2 Cn:13 11:11 cond:1101 Cm:2 11000010110:11000010110
	.inst 0xa84d4021 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:1 Rt2:10000 imm7:0011010 L:1 1010000:1010000 opc:10
	.inst 0x1a9fc420 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:1 o2:1 0:0 cond:1100 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xab1e2a68 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:8 Rn:19 imm6:001010 Rm:30 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x795da1c9 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:14 imm12:011101101000 opc:01 111001:111001 size:01
	.inst 0xf803b83f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:1 10:10 imm9:000111011 0:0 opc:00 111000:111000 size:11
	.inst 0xaa05349e // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:4 imm6:001101 Rm:5 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0x384df984 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:12 10:10 imm9:011011111 0:0 opc:01 111000:111000 size:00
	.inst 0x1ace2e42 // rorv:aarch64/instrs/integer/shift/variable Rd:2 Rn:18 op2:11 0010:0010 Rm:14 0011010110:0011010110 sf:0
	.inst 0xc2c212e0
	.zero 164
	.inst 0x00000fc5
	.zero 1048364
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc240074c // ldr c12, [x26, #1]
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2400f50 // ldr c16, [x26, #3]
	.inst 0xc2401353 // ldr c19, [x26, #4]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032fa // ldr c26, [c23, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x826012fa // ldr c26, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x23, #0x3
	and x26, x26, x23
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400357 // ldr c23, [x26, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400757 // ldr c23, [x26, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400b57 // ldr c23, [x26, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400f57 // ldr c23, [x26, #3]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401357 // ldr c23, [x26, #4]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401757 // ldr c23, [x26, #5]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401b57 // ldr c23, [x26, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401f57 // ldr c23, [x26, #7]
	.inst 0xc2d7a661 // chkeq c19, c23
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
	ldr x0, =0x000010dc
	ldr x1, =check_data1
	ldr x2, =0x000010de
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010df
	ldr x1, =check_data2
	ldr x2, =0x000010e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000d0
	ldr x1, =check_data4
	ldr x2, =0x004000e0
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
