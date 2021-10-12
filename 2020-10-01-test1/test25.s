.section data0, #alloc, #write
	.zero 1648
	.byte 0x58, 0x25, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0xa0
	.zero 2432
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x58, 0x25, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0xa0
.data
check_data2:
	.byte 0x1c, 0x2e, 0x4a, 0x02, 0x7f, 0x52, 0x63, 0xf2, 0x16, 0x5f, 0x72, 0x69, 0x21, 0xf0, 0xd4, 0xc2
.data
check_data3:
	.byte 0x41, 0x7c, 0x15, 0x51, 0x21, 0x18, 0xff, 0xc2, 0x1e, 0xd5, 0xe6, 0x98, 0x03, 0x10, 0xc7, 0xc2
	.byte 0xc2, 0x63, 0x4a, 0x3a, 0x3f, 0x00, 0x01, 0x9b, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x901000000607020f0000000000001400
	/* C16 */
	.octa 0x8006600703ffffffffd81000
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x8000000040000001000000000000108c
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C16 */
	.octa 0x8006600703ffffffffd81000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x8000000040000001000000000000108c
	/* C28 */
	.octa 0x80066007040000000000c000
	/* C30 */
	.octa 0x24a2e1c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001670
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x024a2e1c // ADD-C.CIS-C Cd:28 Cn:16 imm12:001010001011 sh:1 A:0 00000010:00000010
	.inst 0xf263527f // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:19 imms:010100 immr:100011 N:1 100100:100100 opc:11 sf:1
	.inst 0x69725f16 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:22 Rn:24 Rt2:10111 imm7:1100100 L:1 1010010:1010010 opc:01
	.inst 0xc2d4f021 // BLR-CI-C 1:1 0000:0000 Cn:1 100:100 imm7:0100111 110000101101:110000101101
	.zero 206152
	.inst 0x51157c41 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:2 imm12:010101011111 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2ff1821 // CVT-C.CR-C Cd:1 Cn:1 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0x98e6d51e // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:1110011011010101000 011000:011000 opc:10
	.inst 0xc2c71003 // RRLEN-R.R-C Rd:3 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3a4a63c2 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0010 0:0 Rn:30 00:00 cond:0110 Rm:10 111010010:111010010 op:0 sf:0
	.inst 0x9b01003f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:1 Ra:0 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2c211c0
	.zero 842380
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400bb0 // ldr c16, [x29, #2]
	.inst 0xc2400fb3 // ldr c19, [x29, #3]
	.inst 0xc24013b8 // ldr c24, [x29, #4]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011dd // ldr c29, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x14, #0xf
	and x29, x29, x14
	cmp x29, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ae // ldr c14, [x29, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24007ae // ldr c14, [x29, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400bae // ldr c14, [x29, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400fae // ldr c14, [x29, #3]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24013ae // ldr c14, [x29, #4]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24017ae // ldr c14, [x29, #5]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401bae // ldr c14, [x29, #6]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc2401fae // ldr c14, [x29, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc24023ae // ldr c14, [x29, #8]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc24027ae // ldr c14, [x29, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001670
	ldr x1, =check_data1
	ldr x2, =0x00001680
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00432558
	ldr x1, =check_data3
	ldr x2, =0x00432574
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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
