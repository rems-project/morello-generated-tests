.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x38, 0x1e, 0x38, 0x55, 0xb3, 0xc5, 0xc2, 0x7e, 0x40, 0xb7, 0x6c, 0xbe, 0x24, 0x63, 0x71
	.byte 0x10, 0x3c, 0x72, 0x02, 0xe2, 0xfb, 0x07, 0xe2, 0x4a, 0x2e, 0x7c, 0xb4
.data
check_data5:
	.byte 0xc3, 0x11, 0x0f, 0x72, 0xe2, 0x1c, 0x14, 0x38, 0x41, 0x86, 0x49, 0x82, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000010007000000000000101e
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000700020000000000001000
	/* C7 */
	.octa 0x4000000010070f4f0000000000002000
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x3e0000
	/* C18 */
	.octa 0x1000
	/* C26 */
	.octa 0x80200000400002
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4000000000010007000000000000101e
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x3e0000
	/* C7 */
	.octa 0x4000000010070f4f0000000000001f41
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x3e0000
	/* C16 */
	.octa 0x40000000000100070000000000c9001e
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0x20008000000100060080200000400002
	/* C26 */
	.octa 0x80200000400002
initial_SP_EL3_value:
	.octa 0x1100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006004000c00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x381e381e // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:0 10:10 imm9:111100011 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c5b355 // CVTP-C.R-C Cd:21 Rn:26 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x6cb7407e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:3 Rt2:10000 imm7:1101110 L:0 1011001:1011001 opc:01
	.inst 0x716324be // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:5 imm12:100011001001 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x02723c10 // ADD-C.CIS-C Cd:16 Cn:0 imm12:110010001111 sh:1 A:0 00000010:00000010
	.inst 0xe207fbe2 // ALDURSB-R.RI-64 Rt:2 Rn:31 op2:10 imm9:001111111 V:0 op1:00 11100010:11100010
	.inst 0xb47c2e4a // cbz:aarch64/instrs/branch/conditional/compare Rt:10 imm19:0111110000101110010 op:0 011010:011010 sf:1
	.zero 1017284
	.inst 0x720f11c3 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:14 imms:000100 immr:001111 N:0 100100:100100 opc:11 sf:0
	.inst 0x38141ce2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:7 11:11 imm9:101000001 0:0 opc:00 111000:111000 size:00
	.inst 0x82498641 // ASTRB-R.RI-B Rt:1 Rn:18 op:01 imm9:010011000 L:0 1000001001:1000001001
	.inst 0xc2c21320
	.zero 31248
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q16, =0x0
	ldr q30, =0x4000
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850038
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332f // ldr c15, [c25, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260132f // ldr c15, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x25, #0xf
	and x15, x15, x25
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f9 // ldr c25, [x15, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005f9 // ldr c25, [x15, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009f9 // ldr c25, [x15, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400df9 // ldr c25, [x15, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24015f9 // ldr c25, [x15, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24019f9 // ldr c25, [x15, #6]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401df9 // ldr c25, [x15, #7]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc24021f9 // ldr c25, [x15, #8]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc24025f9 // ldr c25, [x15, #9]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24029f9 // ldr c25, [x15, #10]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x25, v16.d[0]
	cmp x15, x25
	b.ne comparison_fail
	ldr x15, =0x0
	mov x25, v16.d[1]
	cmp x15, x25
	b.ne comparison_fail
	ldr x15, =0x4000
	mov x25, v30.d[0]
	cmp x15, x25
	b.ne comparison_fail
	ldr x15, =0x0
	mov x25, v30.d[1]
	cmp x15, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001098
	ldr x1, =check_data1
	ldr x2, =0x00001099
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000117f
	ldr x1, =check_data2
	ldr x2, =0x00001180
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f41
	ldr x1, =check_data3
	ldr x2, =0x00001f42
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004f85e0
	ldr x1, =check_data5
	ldr x2, =0x004f85f0
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
