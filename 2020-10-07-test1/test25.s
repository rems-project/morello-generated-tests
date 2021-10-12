.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 3
.data
check_data2:
	.byte 0x29, 0x51, 0xc0, 0xc2, 0x5f, 0x1c, 0x5e, 0xe2, 0x74, 0x61, 0xdf, 0xc2, 0xb6, 0xe3, 0x25, 0xe2
	.byte 0x5f, 0x3c, 0x03, 0xd5, 0xc8, 0x16, 0xed, 0xe2, 0xe1, 0xd3, 0xc0, 0xc2, 0x31, 0xfc, 0xdf, 0xc8
	.byte 0x22, 0x44, 0x1b, 0xf1, 0xe0, 0x01, 0x0f, 0x78, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x8000000043e423e50000000000404401
	/* C11 */
	.octa 0x720070000000000000000
	/* C15 */
	.octa 0x1f0c
	/* C22 */
	.octa 0x80000000000100050000000000001f1f
	/* C29 */
	.octa 0x40000000000100050000000000001fa0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ff0
	/* C2 */
	.octa 0x191f
	/* C11 */
	.octa 0x720070000000000000000
	/* C15 */
	.octa 0x1f0c
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x720070000000000002000
	/* C22 */
	.octa 0x80000000000100050000000000001f1f
	/* C29 */
	.octa 0x40000000000100050000000000001fa0
initial_SP_EL3_value:
	.octa 0x7fc0000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c05129 // GCVALUE-R.C-C Rd:9 Cn:9 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xe25e1c5f // ALDURSH-R.RI-32 Rt:31 Rn:2 op2:11 imm9:111100001 V:0 op1:01 11100010:11100010
	.inst 0xc2df6174 // SCOFF-C.CR-C Cd:20 Cn:11 000:000 opc:11 0:0 Rm:31 11000010110:11000010110
	.inst 0xe225e3b6 // ASTUR-V.RI-B Rt:22 Rn:29 op2:00 imm9:001011110 V:1 op1:00 11100010:11100010
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0xe2ed16c8 // ALDUR-V.RI-D Rt:8 Rn:22 op2:01 imm9:011010001 V:1 op1:11 11100010:11100010
	.inst 0xc2c0d3e1 // GCPERM-R.C-C Rd:1 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc8dffc31 // ldar:aarch64/instrs/memory/ordered Rt:17 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xf11b4422 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:1 imm12:011011010001 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x780f01e0 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:15 00:00 imm9:011110000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c211c0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc240149d // ldr c29, [x4, #5]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
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
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c4 // ldr c4, [c14, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011c4 // ldr c4, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x14, #0xf
	and x4, x4, x14
	cmp x4, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008e // ldr c14, [x4, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240048e // ldr c14, [x4, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240088e // ldr c14, [x4, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400c8e // ldr c14, [x4, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240148e // ldr c14, [x4, #5]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc240188e // ldr c14, [x4, #6]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2401c8e // ldr c14, [x4, #7]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc240208e // ldr c14, [x4, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x14, v8.d[0]
	cmp x4, x14
	b.ne comparison_fail
	ldr x4, =0x0
	mov x14, v8.d[1]
	cmp x4, x14
	b.ne comparison_fail
	ldr x4, =0x0
	mov x14, v22.d[0]
	cmp x4, x14
	b.ne comparison_fail
	ldr x4, =0x0
	mov x14, v22.d[1]
	cmp x4, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004043e2
	ldr x1, =check_data3
	ldr x2, =0x004043e4
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
