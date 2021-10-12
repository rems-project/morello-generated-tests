.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xdf, 0x13, 0xc5, 0xc2, 0x75, 0x71, 0xd3, 0xb0, 0x9a, 0xf3, 0xc6, 0x82, 0x64, 0x92, 0x87, 0xf2
	.byte 0xa0, 0x91, 0x33, 0xab, 0xde, 0x29, 0x0a, 0x78, 0x13, 0x7f, 0x01, 0x88, 0x1f, 0xe8, 0xcd, 0xc2
	.byte 0x88, 0x9e, 0xfa, 0x69, 0x21, 0xa4, 0xc1, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x4ffffd
	/* C14 */
	.octa 0x1f5a
	/* C20 */
	.octa 0x460000
	/* C24 */
	.octa 0x4ffff8
	/* C28 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C6 */
	.octa 0x4ffffd
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x1f5a
	/* C20 */
	.octa 0x45ffd4
	/* C21 */
	.octa 0xffffffffa722d000
	/* C24 */
	.octa 0x4ffff8
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c513df // CVTD-R.C-C Rd:31 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xb0d37175 // ADRP-C.IP-C Rd:21 immhi:101001101110001011 P:1 10000:10000 immlo:01 op:1
	.inst 0x82c6f39a // ALDRB-R.RRB-B Rt:26 Rn:28 opc:00 S:1 option:111 Rm:6 0:0 L:1 100000101:100000101
	.inst 0xf2879264 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:4 imm16:0011110010010011 hw:00 100101:100101 opc:11 sf:1
	.inst 0xab3391a0 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:13 imm3:100 option:100 Rm:19 01011001:01011001 S:1 op:0 sf:1
	.inst 0x780a29de // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:14 10:10 imm9:010100010 0:0 opc:00 111000:111000 size:01
	.inst 0x88017f13 // stxr:aarch64/instrs/memory/exclusive/single Rt:19 Rn:24 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:10
	.inst 0xc2cde81f // CTHI-C.CR-C Cd:31 Cn:0 1010:1010 opc:11 Rm:13 11000010110:11000010110
	.inst 0x69fa9e88 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:20 Rt2:00111 imm7:1110101 L:1 1010011:1010011 opc:01
	.inst 0xc2c1a421 // CHKEQ-_.CC-C 00001:00001 Cn:1 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x2, =initial_cap_values
	.inst 0xc2400046 // ldr c6, [x2, #0]
	.inst 0xc240044e // ldr c14, [x2, #1]
	.inst 0xc2400854 // ldr c20, [x2, #2]
	.inst 0xc2400c58 // ldr c24, [x2, #3]
	.inst 0xc240105c // ldr c28, [x2, #4]
	.inst 0xc240145e // ldr c30, [x2, #5]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851037
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603222 // ldr c2, [c17, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601222 // ldr c2, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x17, #0xf
	and x2, x2, x17
	cmp x2, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400051 // ldr c17, [x2, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400451 // ldr c17, [x2, #1]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2400851 // ldr c17, [x2, #2]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2400c51 // ldr c17, [x2, #3]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401051 // ldr c17, [x2, #4]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401451 // ldr c17, [x2, #5]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401851 // ldr c17, [x2, #6]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401c51 // ldr c17, [x2, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402051 // ldr c17, [x2, #8]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402451 // ldr c17, [x2, #9]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402851 // ldr c17, [x2, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffc
	ldr x1, =check_data0
	ldr x2, =0x00001ffe
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
	ldr x0, =0x0045ffd4
	ldr x1, =check_data2
	ldr x2, =0x0045ffdc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff8
	ldr x1, =check_data3
	ldr x2, =0x004ffffc
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
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
