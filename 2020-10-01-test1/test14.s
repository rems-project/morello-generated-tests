.section data0, #alloc, #write
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
	.zero 3968
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x2e, 0x78, 0x7b, 0xf2, 0x41, 0xb8, 0xbb, 0x79, 0x54, 0xfc, 0x7f, 0x42, 0x3e, 0x2c, 0xc7, 0x38
	.byte 0x5f, 0x38, 0x03, 0xd5, 0x42, 0x90, 0xc0, 0xc2, 0x59, 0x96, 0x9c, 0xb8, 0x24, 0x02, 0xbe, 0xd0
	.byte 0x1f, 0x08, 0x59, 0x78, 0xe0, 0x0f, 0xbf, 0x8a, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x0c, 0x10
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400430
	/* C1 */
	.octa 0xfffffffe0
	/* C2 */
	.octa 0x80000000000010000000000000400024
	/* C18 */
	.octa 0x400018
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x107e
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0xffffffff7c446000
	/* C14 */
	.octa 0xfffffffe0
	/* C18 */
	.octa 0x3fffe1
	/* C20 */
	.octa 0x8abf0fe0
	/* C25 */
	.octa 0xffffffffb89c9659
	/* C30 */
	.octa 0xffffffc2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003ffd00010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf27b782e // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:14 Rn:1 imms:011110 immr:111011 N:1 100100:100100 opc:11 sf:1
	.inst 0x79bbb841 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:2 imm12:111011101110 opc:10 111001:111001 size:01
	.inst 0x427ffc54 // ALDAR-R.R-32 Rt:20 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x38c72c3e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:1 11:11 imm9:001110010 0:0 opc:11 111000:111000 size:00
	.inst 0xd503385f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1000 11010101000000110011:11010101000000110011
	.inst 0xc2c09042 // GCTAG-R.C-C Rd:2 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xb89c9659 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:18 01:01 imm9:111001001 0:0 opc:10 111000:111000 size:10
	.inst 0xd0be0224 // ADRP-C.IP-C Rd:4 immhi:011111000000010001 P:1 10000:10000 immlo:10 op:1
	.inst 0x7859081f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:110010000 0:0 opc:01 111000:111000 size:01
	.inst 0x8abf0fe0 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:31 imm6:000011 Rm:31 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2c210c0
	.zero 916
	.inst 0x0000c2c2
	.zero 6716
	.inst 0x0000100c
	.zero 1040892
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0xc
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c3 // ldr c3, [c6, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826010c3 // ldr c3, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x6, #0xf
	and x3, x3, x6
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400066 // ldr c6, [x3, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400466 // ldr c6, [x3, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401066 // ldr c6, [x3, #4]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401466 // ldr c6, [x3, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401866 // ldr c6, [x3, #6]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401c66 // ldr c6, [x3, #7]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402066 // ldr c6, [x3, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107e
	ldr x1, =check_data0
	ldr x2, =0x0000107f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004003c0
	ldr x1, =check_data2
	ldr x2, =0x004003c2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401e00
	ldr x1, =check_data3
	ldr x2, =0x00401e02
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
