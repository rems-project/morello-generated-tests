.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x10, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xac, 0x7c, 0xa6, 0x9b, 0x40, 0x00, 0x1f, 0x7a, 0x37, 0xfc, 0x9f, 0x08, 0x80, 0xef, 0x07, 0xf8
	.byte 0x48, 0x70, 0x29, 0x9b, 0x25, 0x98, 0xff, 0xc2, 0x56, 0xc8, 0xa8, 0x42, 0x22, 0xd1, 0xcb, 0x28
	.byte 0xe7, 0x7e, 0xd9, 0x9b, 0x41, 0x00, 0xc0, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000500400020000000000001000
	/* C2 */
	.octa 0x4c000000000400070000000000001910
	/* C9 */
	.octa 0x80000000000e000f0000000000001000
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0x20000000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000088000000000000000001002
final_cap_values:
	/* C0 */
	.octa 0x1910
	/* C1 */
	.octa 0x591000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1911080
	/* C9 */
	.octa 0x80000000000e000f000000000000105c
	/* C18 */
	.octa 0x4000000000000000000000000000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x20000000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000088000000000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ba67cac // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:12 Rn:5 Ra:31 o0:0 Rm:6 01:01 U:1 10011011:10011011
	.inst 0x7a1f0040 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:2 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:0
	.inst 0x089ffc37 // stlrb:aarch64/instrs/memory/ordered Rt:23 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xf807ef80 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:28 11:11 imm9:001111110 0:0 opc:00 111000:111000 size:11
	.inst 0x9b297048 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:8 Rn:2 Ra:28 o0:0 Rm:9 01:01 U:0 10011011:10011011
	.inst 0xc2ff9825 // SUBS-R.CC-C Rd:5 Cn:1 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x42a8c856 // STP-C.RIB-C Ct:22 Rn:2 Ct2:10010 imm7:1010001 L:0 010000101:010000101
	.inst 0x28cbd122 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:9 Rt2:10100 imm7:0010111 L:1 1010001:1010001 opc:00
	.inst 0x9bd97ee7 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:7 Rn:23 Ra:11111 0:0 Rm:25 10:10 U:1 10011011:10011011
	.inst 0xc2c00041 // SCBNDS-C.CR-C Cd:1 Cn:2 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc24019bc // ldr c28, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x20000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260114d // ldr c13, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x10, #0xf
	and x13, x13, x10
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001aa // ldr c10, [x13, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005aa // ldr c10, [x13, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24011aa // ldr c10, [x13, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24015aa // ldr c10, [x13, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24019aa // ldr c10, [x13, #6]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401daa // ldr c10, [x13, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24021aa // ldr c10, [x13, #8]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc24025aa // ldr c10, [x13, #9]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24029aa // ldr c10, [x13, #10]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2402daa // ldr c10, [x13, #11]
	.inst 0xc2caa781 // chkeq c28, c10
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001620
	ldr x1, =check_data2
	ldr x2, =0x00001640
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
