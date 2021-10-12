.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xff, 0xb3, 0xc5, 0xc2, 0x20, 0x78, 0xba, 0xf2, 0x70, 0xfa, 0xd8, 0xc2, 0xa1, 0x8d, 0x94, 0xe2
	.byte 0x81, 0xe1, 0x0b, 0xb0, 0x62, 0x27, 0x8b, 0xe2, 0x1e, 0x95, 0x45, 0x2c, 0x7e, 0x31, 0x3d, 0x30
	.byte 0x81, 0xca, 0x56, 0xf8, 0x42, 0xd0, 0x5e, 0xd8, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x800000000001000500000000004003b8
	/* C13 */
	.octa 0x10b8
	/* C19 */
	.octa 0xc00000000000000000000000
	/* C20 */
	.octa 0x80000000000100050000000000002084
	/* C27 */
	.octa 0x1002
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x800000000001000500000000004003b8
	/* C13 */
	.octa 0x10b8
	/* C16 */
	.octa 0xc31000000000000000000000
	/* C19 */
	.octa 0xc00000000000000000000000
	/* C20 */
	.octa 0x80000000000100050000000000002084
	/* C27 */
	.octa 0x1002
	/* C30 */
	.octa 0x2000800000004008000000000047a649
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000600020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b3ff // CVTP-C.R-C Cd:31 Rn:31 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xf2ba7820 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1101001111000001 hw:01 100101:100101 opc:11 sf:1
	.inst 0xc2d8fa70 // SCBNDS-C.CI-S Cd:16 Cn:19 1110:1110 S:1 imm6:110001 11000010110:11000010110
	.inst 0xe2948da1 // ASTUR-C.RI-C Ct:1 Rn:13 op2:11 imm9:101001000 V:0 op1:10 11100010:11100010
	.inst 0xb00be181 // ADRP-C.I-C Rd:1 immhi:000101111100001100 P:0 10000:10000 immlo:01 op:1
	.inst 0xe28b2762 // ALDUR-R.RI-32 Rt:2 Rn:27 op2:01 imm9:010110010 V:0 op1:10 11100010:11100010
	.inst 0x2c45951e // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:30 Rn:8 Rt2:00101 imm7:0001011 L:1 1011000:1011000 opc:00
	.inst 0x303d317e // ADR-C.I-C Rd:30 immhi:011110100110001011 P:0 10000:10000 immlo:01 op:0
	.inst 0xf856ca81 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:20 10:10 imm9:101101100 0:0 opc:01 111000:111000 size:11
	.inst 0xd85ed042 // prfm_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:0101111011010000010 011000:011000 opc:11
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2400b0d // ldr c13, [x24, #2]
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc240171b // ldr c27, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x8
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b8 // ldr c24, [c21, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x826012b8 // ldr c24, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400315 // ldr c21, [x24, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400715 // ldr c21, [x24, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400b15 // ldr c21, [x24, #2]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2400f15 // ldr c21, [x24, #3]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401315 // ldr c21, [x24, #4]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401f15 // ldr c21, [x24, #7]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402315 // ldr c21, [x24, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x21, v5.d[0]
	cmp x24, x21
	b.ne comparison_fail
	ldr x24, =0x0
	mov x21, v5.d[1]
	cmp x24, x21
	b.ne comparison_fail
	ldr x24, =0x0
	mov x21, v30.d[0]
	cmp x24, x21
	b.ne comparison_fail
	ldr x24, =0x0
	mov x21, v30.d[1]
	cmp x24, x21
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
	ldr x0, =0x000010b4
	ldr x1, =check_data1
	ldr x2, =0x000010b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	ldr x0, =0x004003e4
	ldr x1, =check_data4
	ldr x2, =0x004003ec
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
