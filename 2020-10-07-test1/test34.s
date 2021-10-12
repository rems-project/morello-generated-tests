.section data0, #alloc, #write
	.byte 0x38, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
	.byte 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00
.data
check_data0:
	.byte 0x38, 0x20, 0x00, 0x00
.data
check_data1:
	.byte 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38
.data
check_data2:
	.byte 0x38
.data
check_data3:
	.byte 0xe7, 0xb3, 0x52, 0xba, 0x3f, 0x14, 0x5e, 0x38, 0x1e, 0xe8, 0x60, 0xb8, 0xd8, 0x67, 0x3c, 0xe2
	.byte 0x02, 0x30, 0x5d, 0x71, 0x48, 0x01, 0x5c, 0xa2, 0xce, 0x08, 0x5d, 0x3a, 0xe1, 0xe7, 0x1c, 0xd0
	.byte 0x90, 0xa4, 0x42, 0x38, 0x5d, 0xa0, 0x22, 0x9b, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0x38
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000005801069a0000000000000800
	/* C1 */
	.octa 0x80000000000700020000000000400006
	/* C4 */
	.octa 0x800000000001000500000000004ffffe
	/* C10 */
	.octa 0x80000000400000010000000000002020
final_cap_values:
	/* C0 */
	.octa 0x800000005801069a0000000000000800
	/* C1 */
	.octa 0x80000000400000040100000039cfc000
	/* C2 */
	.octa 0xff8b4800
	/* C4 */
	.octa 0x80000000000100050000000000500028
	/* C8 */
	.octa 0x38383838383838383838383838383838
	/* C10 */
	.octa 0x80000000400000010000000000002020
	/* C16 */
	.octa 0x38
	/* C29 */
	.octa 0x38380300f3f83838
	/* C30 */
	.octa 0x2038
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004000000400ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba52b3e7 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:31 00:00 cond:1011 Rm:18 111010010:111010010 op:0 sf:1
	.inst 0x385e143f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:1 01:01 imm9:111100001 0:0 opc:01 111000:111000 size:00
	.inst 0xb860e81e // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:0 10:10 S:0 option:111 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0xe23c67d8 // ALDUR-V.RI-B Rt:24 Rn:30 op2:01 imm9:111000110 V:1 op1:00 11100010:11100010
	.inst 0x715d3002 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:0 imm12:011101001100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xa25c0148 // LDUR-C.RI-C Ct:8 Rn:10 00:00 imm9:111000000 0:0 opc:01 10100010:10100010
	.inst 0x3a5d08ce // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:6 10:10 cond:0000 imm5:11101 111010010:111010010 op:0 sf:0
	.inst 0xd01ce7e1 // ADRP-C.I-C Rd:1 immhi:001110011100111111 P:0 10000:10000 immlo:10 op:1
	.inst 0x3842a490 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:4 01:01 imm9:000101010 0:0 opc:01 111000:111000 size:00
	.inst 0x9b22a05d // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:2 Ra:8 o0:1 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c211c0
	.zero 1048528
	.inst 0x00380000
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f4a // ldr c10, [x26, #3]
	/* Set up flags and system registers */
	mov x26, #0x80000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031da // ldr c26, [c14, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826011da // ldr c26, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x14, #0xf
	and x26, x26, x14
	cmp x26, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034e // ldr c14, [x26, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240074e // ldr c14, [x26, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401f4e // ldr c14, [x26, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240234e // ldr c14, [x26, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x38
	mov x14, v24.d[0]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v24.d[1]
	cmp x26, x14
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
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
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
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
	.inst 0xc28b413a // msr DDC_EL3, c26
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
