.section data0, #alloc, #write
	.zero 512
	.byte 0xc2, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xc2, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xe1, 0x68, 0xc8, 0xc2, 0xff, 0x27, 0xce, 0xe2, 0xa1, 0xa5, 0xc8, 0xc2, 0x74, 0x43, 0xbf, 0xe2
	.byte 0xa2, 0x46, 0x4a, 0xa2, 0x5f, 0x70, 0xa2, 0x79, 0xc2, 0x11, 0xc2, 0xc2
.data
check_data7:
	.byte 0x3b, 0x09, 0x96, 0x78, 0x0b, 0xd8, 0x04, 0xe2, 0x50, 0xf0, 0x30, 0x9b, 0xc0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000000c0000000000000002044
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x20008000400080010000000000408081
	/* C21 */
	.octa 0x11fe
	/* C27 */
	.octa 0x40000000000100050000000000002000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xec2
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000000c0000000000000002044
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x20008000400080010000000000408081
	/* C21 */
	.octa 0x1c3e
	/* C27 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001006
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000004001000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c868e1 // ORRFLGS-C.CR-C Cd:1 Cn:7 1010:1010 opc:01 Rm:8 11000010110:11000010110
	.inst 0xe2ce27ff // ALDUR-R.RI-64 Rt:31 Rn:31 op2:01 imm9:011100010 V:0 op1:11 11100010:11100010
	.inst 0xc2c8a5a1 // CHKEQ-_.CC-C 00001:00001 Cn:13 001:001 opc:01 1:1 Cm:8 11000010110:11000010110
	.inst 0xe2bf4374 // ASTUR-V.RI-S Rt:20 Rn:27 op2:00 imm9:111110100 V:1 op1:10 11100010:11100010
	.inst 0xa24a46a2 // LDR-C.RIAW-C Ct:2 Rn:21 01:01 imm9:010100100 0:0 opc:01 10100010:10100010
	.inst 0x79a2705f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:100010011100 opc:10 111001:111001 size:01
	.inst 0xc2c211c2 // BRS-C-C 00010:00010 Cn:14 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32868
	.inst 0x7896093b // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:9 10:10 imm9:101100000 0:0 opc:10 111000:111000 size:01
	.inst 0xe204d80b // ALDURSB-R.RI-64 Rt:11 Rn:0 op2:10 imm9:001001101 V:0 op1:00 11100010:11100010
	.inst 0x9b30f050 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:16 Rn:2 Ra:28 o0:1 Rm:16 01:01 U:0 10011011:10011011
	.inst 0xc2c213c0
	.zero 1015664
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400687 // ldr c7, [x20, #1]
	.inst 0xc2400a88 // ldr c8, [x20, #2]
	.inst 0xc2400e89 // ldr c9, [x20, #3]
	.inst 0xc240128d // ldr c13, [x20, #4]
	.inst 0xc240168e // ldr c14, [x20, #5]
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850032
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x30, =pcc_return_ddc_capabilities
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0x826033d4 // ldr c20, [c30, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826013d4 // ldr c20, [c30, #1]
	.inst 0x826023de // ldr c30, [c30, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x30, #0xf
	and x20, x20, x30
	cmp x20, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029e // ldr c30, [x20, #0]
	.inst 0xc2dea401 // chkeq c0, c30
	b.ne comparison_fail
	.inst 0xc240069e // ldr c30, [x20, #1]
	.inst 0xc2dea421 // chkeq c1, c30
	b.ne comparison_fail
	.inst 0xc2400a9e // ldr c30, [x20, #2]
	.inst 0xc2dea441 // chkeq c2, c30
	b.ne comparison_fail
	.inst 0xc2400e9e // ldr c30, [x20, #3]
	.inst 0xc2dea4e1 // chkeq c7, c30
	b.ne comparison_fail
	.inst 0xc240129e // ldr c30, [x20, #4]
	.inst 0xc2dea501 // chkeq c8, c30
	b.ne comparison_fail
	.inst 0xc240169e // ldr c30, [x20, #5]
	.inst 0xc2dea521 // chkeq c9, c30
	b.ne comparison_fail
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	.inst 0xc2dea561 // chkeq c11, c30
	b.ne comparison_fail
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	.inst 0xc2dea5a1 // chkeq c13, c30
	b.ne comparison_fail
	.inst 0xc240229e // ldr c30, [x20, #8]
	.inst 0xc2dea5c1 // chkeq c14, c30
	b.ne comparison_fail
	.inst 0xc240269e // ldr c30, [x20, #9]
	.inst 0xc2dea6a1 // chkeq c21, c30
	b.ne comparison_fail
	.inst 0xc2402a9e // ldr c30, [x20, #10]
	.inst 0xc2dea761 // chkeq c27, c30
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x30, v20.d[0]
	cmp x20, x30
	b.ne comparison_fail
	ldr x20, =0x0
	mov x30, v20.d[1]
	cmp x20, x30
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000104f
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e8
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa4
	ldr x1, =check_data3
	ldr x2, =0x00001fa6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff4
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040001c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00408080
	ldr x1, =check_data7
	ldr x2, =0x00408090
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
