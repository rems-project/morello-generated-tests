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
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc1, 0x00, 0x00, 0xba, 0xe0, 0x2b, 0x00, 0xaa, 0xc1, 0xa3, 0x52, 0xe2, 0xd2, 0x0d, 0xb4, 0x9b
	.byte 0x41, 0xe0, 0xde, 0xc2, 0x45, 0xf3, 0x05, 0xe2, 0xec, 0x6f, 0x48, 0x38, 0xff, 0xab, 0x1b, 0x78
	.byte 0x20, 0x7c, 0xde, 0x9b, 0x11, 0xd0, 0xc5, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000010000000000000
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000000500040000000000001d9d
	/* C30 */
	.octa 0x400000000003000700000000000010e0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x800000000010000000000000
	/* C2 */
	.octa 0x800000000010000000000000
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0xc0000000541200530000000000000001
	/* C26 */
	.octa 0x40000000000500040000000000001d9d
	/* C30 */
	.octa 0x400000000003000700000000000010e0
initial_csp_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000541200530000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba0000c1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:6 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0xaa002be0 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:31 imm6:001010 Rm:0 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0xe252a3c1 // ASTURH-R.RI-32 Rt:1 Rn:30 op2:00 imm9:100101010 V:0 op1:01 11100010:11100010
	.inst 0x9bb40dd2 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:14 Ra:3 o0:0 Rm:20 01:01 U:1 10011011:10011011
	.inst 0xc2dee041 // SCFLGS-C.CR-C Cd:1 Cn:2 111000:111000 Rm:30 11000010110:11000010110
	.inst 0xe205f345 // ASTURB-R.RI-32 Rt:5 Rn:26 op2:00 imm9:001011111 V:0 op1:00 11100010:11100010
	.inst 0x38486fec // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:31 11:11 imm9:010000110 0:0 opc:01 111000:111000 size:00
	.inst 0x781babff // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:110111010 0:0 opc:00 111000:111000 size:01
	.inst 0x9bde7c20 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:1 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0xc2c5d011 // CVTDZ-C.R-C Cd:17 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c21120
	.zero 1048532
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
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc240109a // ldr c26, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603124 // ldr c4, [c9, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601124 // ldr c4, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x9, #0xf
	and x4, x4, x9
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400089 // ldr c9, [x4, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401089 // ldr c9, [x4, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401489 // ldr c9, [x4, #5]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401889 // ldr c9, [x4, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401c89 // ldr c9, [x4, #7]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402089 // ldr c9, [x4, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100a
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001052
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001096
	ldr x1, =check_data2
	ldr x2, =0x00001097
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dfc
	ldr x1, =check_data3
	ldr x2, =0x00001dfd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
