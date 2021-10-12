.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x5e, 0x35, 0x99, 0x79, 0xa9, 0x86, 0x37, 0x79, 0x41, 0x70, 0xc0, 0xc2, 0xd7, 0x33, 0xc5, 0xc2
	.byte 0xc0, 0xc3, 0xc2, 0xc2, 0xbf, 0x39, 0x70, 0x39, 0x5e, 0x7c, 0xdf, 0x48, 0x3f, 0x7c, 0xde, 0x9b
	.byte 0x63, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x0f, 0x68, 0x5e, 0xb1, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000500070000000000001ffc
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000180060000000000000b70
	/* C11 */
	.octa 0x20000000800100050000000000407ffc
	/* C13 */
	.octa 0x800000005000c002000000000040c3f0
	/* C21 */
	.octa 0x40000000400000010000000000000010
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffc
	/* C2 */
	.octa 0x80000000000500070000000000001ffc
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000180060000000000000b70
	/* C11 */
	.octa 0x20000000800100050000000000407ffc
	/* C13 */
	.octa 0x800000005000c002000000000040c3f0
	/* C15 */
	.octa 0x79a000
	/* C21 */
	.octa 0x40000000400000010000000000000010
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7999355e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:10 imm12:011001001101 opc:10 111001:111001 size:01
	.inst 0x793786a9 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:21 imm12:110111100001 opc:00 111001:111001 size:01
	.inst 0xc2c07041 // GCOFF-R.C-C Rd:1 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c533d7 // CVTP-R.C-C Rd:23 Cn:30 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c2c3c0 // CVT-R.CC-C Rd:0 Cn:30 110000:110000 Cm:2 11000010110:11000010110
	.inst 0x397039bf // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:13 imm12:110000001110 opc:01 111001:111001 size:00
	.inst 0x48df7c5e // ldlarh:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x9bde7c3f // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:1 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0xc2c25163 // RETR-C-C 00011:00011 Cn:11 100:100 opc:10 11000010110000100:11000010110000100
	.zero 32728
	.inst 0xb15e680f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:0 imm12:011110011010 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c21240
	.zero 1015804
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400282 // ldr c2, [x20, #0]
	.inst 0xc2400689 // ldr c9, [x20, #1]
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc240128d // ldr c13, [x20, #4]
	.inst 0xc2401695 // ldr c21, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850032
	msr SCTLR_EL3, x20
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601254 // ldr c20, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x18, #0xf
	and x20, x20, x18
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400292 // ldr c18, [x20, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400692 // ldr c18, [x20, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a92 // ldr c18, [x20, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400e92 // ldr c18, [x20, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401292 // ldr c18, [x20, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401692 // ldr c18, [x20, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401a92 // ldr c18, [x20, #6]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2401e92 // ldr c18, [x20, #7]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402292 // ldr c18, [x20, #8]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402692 // ldr c18, [x20, #9]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402a92 // ldr c18, [x20, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000180a
	ldr x1, =check_data0
	ldr x2, =0x0000180c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bd2
	ldr x1, =check_data1
	ldr x2, =0x00001bd4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407ffc
	ldr x1, =check_data4
	ldr x2, =0x00408004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040cffe
	ldr x1, =check_data5
	ldr x2, =0x0040cfff
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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
