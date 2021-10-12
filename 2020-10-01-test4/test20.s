.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xca, 0x03, 0xc2, 0xc2, 0xff, 0x51, 0xdf, 0x78, 0xcc, 0x83, 0x43, 0x7a, 0x2a, 0x64, 0x80, 0xe2
	.byte 0xf7, 0x8b, 0xc2, 0xc2, 0xe1, 0x03, 0x02, 0xba, 0x01, 0x86, 0xc2, 0xc2, 0x2c, 0xc3, 0xb8, 0x82
	.byte 0x1a, 0x70, 0xc0, 0xc2, 0xbe, 0xcb, 0xcd, 0x68, 0x60, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x4401fe
	/* C2 */
	.octa 0x420200040000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000300070000000000400041
	/* C16 */
	.octa 0x203a0060001000000000000
	/* C24 */
	.octa 0x2f0
	/* C25 */
	.octa 0xd10
	/* C29 */
	.octa 0x800000000007800f000000000040e004
	/* C30 */
	.octa 0x700060000000000000000
final_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x420200040000000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000300070000000000400041
	/* C16 */
	.octa 0x203a0060001000000000000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x4804000400ffffffffffe000
	/* C24 */
	.octa 0x2f0
	/* C25 */
	.octa 0xd10
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000007800f000000000040e070
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x4804000400ffffffffffe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000088700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 80
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c203ca // SCBNDS-C.CR-C Cd:10 Cn:30 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0x78df51ff // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:15 00:00 imm9:111110101 0:0 opc:11 111000:111000 size:01
	.inst 0x7a4383cc // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1100 0:0 Rn:30 00:00 cond:1000 Rm:3 111010010:111010010 op:1 sf:0
	.inst 0xe280642a // ALDUR-R.RI-32 Rt:10 Rn:1 op2:01 imm9:000000110 V:0 op1:10 11100010:11100010
	.inst 0xc2c28bf7 // CHKSSU-C.CC-C Cd:23 Cn:31 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0xba0203e1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:31 000000:000000 Rm:2 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c28601 // CHKSS-_.CC-C 00001:00001 Cn:16 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0x82b8c32c // ASTR-R.RRB-32 Rt:12 Rn:25 opc:00 S:0 option:110 Rm:24 1:1 L:0 100000101:100000101
	.inst 0xc2c0701a // GCOFF-R.C-C Rd:26 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x68cdcbbe // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:29 Rt2:10010 imm7:0011011 L:1 1010001:1010001 opc:01
	.inst 0xc2c21360
	.zero 1048532
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
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e8c // ldr c12, [x20, #3]
	.inst 0xc240128f // ldr c15, [x20, #4]
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2401a98 // ldr c24, [x20, #6]
	.inst 0xc2401e99 // ldr c25, [x20, #7]
	.inst 0xc240229d // ldr c29, [x20, #8]
	.inst 0xc240269e // ldr c30, [x20, #9]
	/* Set up flags and system registers */
	mov x20, #0x60000000
	msr nzcv, x20
	ldr x20, =initial_csp_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850032
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603374 // ldr c20, [c27, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601374 // ldr c20, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	mov x27, #0xf
	and x20, x20, x27
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029b // ldr c27, [x20, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240069b // ldr c27, [x20, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a9b // ldr c27, [x20, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e9b // ldr c27, [x20, #3]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240129b // ldr c27, [x20, #4]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401a9b // ldr c27, [x20, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240229b // ldr c27, [x20, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240269b // ldr c27, [x20, #9]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2402a9b // ldr c27, [x20, #10]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402e9b // ldr c27, [x20, #11]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc240329b // ldr c27, [x20, #12]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240369b // ldr c27, [x20, #13]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00400036
	ldr x1, =check_data2
	ldr x2, =0x00400038
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040e004
	ldr x1, =check_data3
	ldr x2, =0x0040e00c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00440204
	ldr x1, =check_data4
	ldr x2, =0x00440208
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
