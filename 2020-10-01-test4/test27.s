.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x40
	.byte 0x20, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xc1, 0x2f, 0xd6, 0x1a, 0x9d, 0xd0, 0x09, 0xf8, 0x8d, 0x99, 0x4b, 0xfa, 0x07, 0xfc, 0xdf, 0x08
	.byte 0x1e, 0xd0, 0x87, 0x82, 0x21, 0xbf, 0x9e, 0x78, 0xa1, 0x84, 0xc2, 0xc2, 0x40, 0x88, 0x28, 0x62
	.byte 0xe1, 0x11, 0xc2, 0xc2, 0x61, 0xca, 0x59, 0xa2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000004000000c0000000000001000
	/* C2 */
	.octa 0x100040000000000001520
	/* C4 */
	.octa 0x1023
	/* C5 */
	.octa 0x601020040000008000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C19 */
	.octa 0x1800
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x1021
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000004000000c0000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100040000000000001520
	/* C4 */
	.octa 0x1023
	/* C5 */
	.octa 0x601020040000008000000000
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C19 */
	.octa 0x1800
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x100c
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc1000005e440c7a0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011c0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ad62fc1 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:30 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xf809d09d // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:4 00:00 imm9:010011101 0:0 opc:00 111000:111000 size:11
	.inst 0xfa4b998d // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:12 10:10 cond:1001 imm5:01011 111010010:111010010 op:1 sf:1
	.inst 0x08dffc07 // ldarb:aarch64/instrs/memory/ordered Rt:7 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8287d01e // ASTRB-R.RRB-B Rt:30 Rn:0 opc:00 S:1 option:110 Rm:7 0:0 L:0 100000101:100000101
	.inst 0x789ebf21 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:25 11:11 imm9:111101011 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c284a1 // CHKSS-_.CC-C 00001:00001 Cn:5 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0x62288840 // STNP-C.RIB-C Ct:0 Rn:2 Ct2:00010 imm7:1010001 L:0 011000100:011000100
	.inst 0xc2c211e1 // CHKSLD-C-C 00001:00001 Cn:15 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa259ca61 // LDTR-C.RIB-C Ct:1 Rn:19 10:10 imm9:110011100 0:0 opc:01 10100010:10100010
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2400e25 // ldr c5, [x17, #3]
	.inst 0xc240122f // ldr c15, [x17, #4]
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2401e39 // ldr c25, [x17, #7]
	.inst 0xc240223d // ldr c29, [x17, #8]
	.inst 0xc240263e // ldr c30, [x17, #9]
	/* Set up flags and system registers */
	mov x17, #0x20000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603071 // ldr c17, [c3, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x82601071 // ldr c17, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x3, #0xf
	and x17, x17, x3
	cmp x17, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400223 // ldr c3, [x17, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400623 // ldr c3, [x17, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a23 // ldr c3, [x17, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e23 // ldr c3, [x17, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401223 // ldr c3, [x17, #4]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401623 // ldr c3, [x17, #5]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401a23 // ldr c3, [x17, #6]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401e23 // ldr c3, [x17, #7]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402223 // ldr c3, [x17, #8]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2402623 // ldr c3, [x17, #9]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402a23 // ldr c3, [x17, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402e23 // ldr c3, [x17, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011c0
	ldr x1, =check_data3
	ldr x2, =0x000011d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001230
	ldr x1, =check_data4
	ldr x2, =0x00001250
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
