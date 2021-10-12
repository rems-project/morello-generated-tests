.section data0, #alloc, #write
	.zero 3056
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1024
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xa0, 0x33, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x42, 0x10, 0xc5, 0xc2, 0x86, 0xe4, 0x56, 0x78, 0xc2, 0x69, 0x9f, 0x82, 0x3e, 0xf4, 0x8d, 0x02
	.byte 0x3e, 0x5a, 0xf9, 0xc2, 0x0e, 0x11, 0x40, 0x7a, 0x20, 0x7c, 0xc1, 0x9b, 0x07, 0x5c, 0x35, 0x31
	.byte 0x51, 0x07, 0xb3, 0x92, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8001e0040000000000000000
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0x80000000000200000000000000001bf8
	/* C14 */
	.octa 0x401854
	/* C17 */
	.octa 0x800720030008000808900000
	/* C25 */
	.octa 0x218000
	/* C29 */
	.octa 0x20008000c000e001000000000047e005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8001e0040000000000000000
	/* C2 */
	.octa 0xffffffffffffc2c2
	/* C4 */
	.octa 0x80000000000200000000000000001b66
	/* C6 */
	.octa 0xc2c2
	/* C7 */
	.octa 0xd57
	/* C14 */
	.octa 0x401854
	/* C17 */
	.octa 0xffffffff67c5ffff
	/* C25 */
	.octa 0x218000
	/* C29 */
	.octa 0x20008000c000e001000000000047e005
	/* C30 */
	.octa 0x800720030008000808b38000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000200140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c233a0 // BLR-C-C 00000:00000 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.zero 6224
	.inst 0x0000c2c2
	.zero 509868
	.inst 0xc2c51042 // CVTD-R.C-C Rd:2 Cn:2 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x7856e486 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:4 01:01 imm9:101101110 0:0 opc:01 111000:111000 size:01
	.inst 0x829f69c2 // ALDRSH-R.RRB-64 Rt:2 Rn:14 opc:10 S:0 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x028df43e // SUB-C.CIS-C Cd:30 Cn:1 imm12:001101111101 sh:0 A:1 00000010:00000010
	.inst 0xc2f95a3e // CVTZ-C.CR-C Cd:30 Cn:17 0110:0110 1:1 0:0 Rm:25 11000010111:11000010111
	.inst 0x7a40110e // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:8 00:00 cond:0001 Rm:0 111010010:111010010 op:1 sf:0
	.inst 0x9bc17c20 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:1 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0x31355c07 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:0 imm12:110101010111 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x92b30751 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:1001100000111010 hw:01 100101:100101 opc:00 sf:1
	.inst 0xc2c211e0
	.zero 532436
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2400f6e // ldr c14, [x27, #3]
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fb // ldr c27, [c15, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826011fb // ldr c27, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x15, #0xf
	and x27, x27, x15
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036f // ldr c15, [x27, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240076f // ldr c15, [x27, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400b6f // ldr c15, [x27, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400f6f // ldr c15, [x27, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240136f // ldr c15, [x27, #4]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240176f // ldr c15, [x27, #5]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2401b6f // ldr c15, [x27, #6]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401f6f // ldr c15, [x27, #7]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240236f // ldr c15, [x27, #8]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240276f // ldr c15, [x27, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402b6f // ldr c15, [x27, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001bf8
	ldr x1, =check_data0
	ldr x2, =0x00001bfa
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00401854
	ldr x1, =check_data2
	ldr x2, =0x00401856
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0047e004
	ldr x1, =check_data3
	ldr x2, =0x0047e02c
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
