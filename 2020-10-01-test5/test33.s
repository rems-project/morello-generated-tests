.section data0, #alloc, #write
	.zero 480
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78, 0xdd, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3584
.data
check_data0:
	.byte 0x78, 0xdd, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x43, 0x53, 0xc2, 0xc2, 0xdb, 0x77, 0x9f, 0x82, 0x5f, 0x3f, 0x03, 0xd5, 0xbe, 0xeb, 0xc4, 0xa9
	.byte 0x0f, 0xe4, 0x49, 0xa2, 0xa6, 0xa3, 0xdf, 0xc2, 0x47, 0x7c, 0x4f, 0x9b, 0xc3, 0x1f, 0x6b, 0x79
	.byte 0xce, 0x0d, 0x86, 0xaa, 0x02, 0xeb, 0xc2, 0xc2, 0x20, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4fff10
	/* C26 */
	.octa 0x20000000800080080000000000400004
	/* C29 */
	.octa 0x11a0
	/* C30 */
	.octa 0x800000000001000500000000004ffffe
final_cap_values:
	/* C0 */
	.octa 0x5008f0
	/* C3 */
	.octa 0xc2c2
	/* C6 */
	.octa 0x11e8
	/* C15 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C26 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0xffffffffffffffc2
	/* C29 */
	.octa 0x11e8
	/* C30 */
	.octa 0x4fdd78
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25343 // RETR-C-C 00011:00011 Cn:26 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x829f77db // ALDRSB-R.RRB-64 Rt:27 Rn:30 opc:01 S:1 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xd5033f5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1111 11010101000000110011:11010101000000110011
	.inst 0xa9c4ebbe // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:29 Rt2:11010 imm7:0001001 L:1 1010011:1010011 opc:10
	.inst 0xa249e40f // LDR-C.RIAW-C Ct:15 Rn:0 01:01 imm9:010011110 0:0 opc:01 10100010:10100010
	.inst 0xc2dfa3a6 // CLRPERM-C.CR-C Cd:6 Cn:29 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0x9b4f7c47 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:7 Rn:2 Ra:11111 0:0 Rm:15 10:10 U:0 10011011:10011011
	.inst 0x796b1fc3 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:30 imm12:101011000111 opc:01 111001:111001 size:01
	.inst 0xaa860dce // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:14 imm6:000011 Rm:6 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c2eb02 // CTHI-C.CR-C Cd:2 Cn:24 1010:1010 opc:11 Rm:2 11000010110:11000010110
	.inst 0xc2c21020
	.zero 1045208
	.inst 0xc2c20000
	.zero 3080
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 220
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc240049a // ldr c26, [x4, #1]
	.inst 0xc240089d // ldr c29, [x4, #2]
	.inst 0xc2400c9e // ldr c30, [x4, #3]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82601024 // ldr c4, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2c1a461 // chkeq c3, c1
	b.ne comparison_fail
	.inst 0xc2400881 // ldr c1, [x4, #2]
	.inst 0xc2c1a4c1 // chkeq c6, c1
	b.ne comparison_fail
	.inst 0xc2400c81 // ldr c1, [x4, #3]
	.inst 0xc2c1a5e1 // chkeq c15, c1
	b.ne comparison_fail
	.inst 0xc2401081 // ldr c1, [x4, #4]
	.inst 0xc2c1a741 // chkeq c26, c1
	b.ne comparison_fail
	.inst 0xc2401481 // ldr c1, [x4, #5]
	.inst 0xc2c1a761 // chkeq c27, c1
	b.ne comparison_fail
	.inst 0xc2401881 // ldr c1, [x4, #6]
	.inst 0xc2c1a7a1 // chkeq c29, c1
	b.ne comparison_fail
	.inst 0xc2401c81 // ldr c1, [x4, #7]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011e8
	ldr x1, =check_data0
	ldr x2, =0x000011f8
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
	ldr x0, =0x004ff306
	ldr x1, =check_data2
	ldr x2, =0x004ff308
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fff10
	ldr x1, =check_data3
	ldr x2, =0x004fff20
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
