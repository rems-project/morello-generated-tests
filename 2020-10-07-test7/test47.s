.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x0e, 0x98, 0x10, 0x78, 0xd2, 0xc7, 0x57, 0x7c, 0xc2, 0x7e, 0xc8, 0xc2, 0x81, 0x82, 0x80, 0xda
	.byte 0x68, 0xdf, 0x55, 0x31, 0x9e, 0x21, 0x85, 0xf8, 0xc1, 0x03, 0x61, 0x82, 0x61, 0x01, 0x00, 0x1a
	.byte 0xe1, 0x2b, 0xeb, 0xc2, 0xc2, 0xbe, 0x59, 0x78, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000006000f0000000000002001
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100050000000000450001
	/* C30 */
	.octa 0x80000000000100060000000000001032
final_cap_values:
	/* C0 */
	.octa 0x400000000006000f0000000000002001
	/* C1 */
	.octa 0x5900000000000000
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x8000000000010005000000000044ff9c
	/* C30 */
	.octa 0x80000000000100060000000000000fae
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000047a0030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000004001000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010b0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7810980e // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:14 Rn:0 10:10 imm9:100001001 0:0 opc:00 111000:111000 size:01
	.inst 0x7c57c7d2 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:18 Rn:30 01:01 imm9:101111100 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c87ec2 // CSEL-C.CI-C Cd:2 Cn:22 11:11 cond:0111 Cm:8 11000010110:11000010110
	.inst 0xda808281 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:20 o2:0 0:0 cond:1000 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0x3155df68 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:8 Rn:27 imm12:010101110111 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xf885219e // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:12 00:00 imm9:001010010 0:0 opc:10 111000:111000 size:11
	.inst 0x826103c1 // ALDR-C.RI-C Ct:1 Rn:30 op:00 imm9:000010000 L:1 1000001001:1000001001
	.inst 0x1a000161 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:11 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2eb2be1 // ORRFLGS-C.CI-C Cd:1 Cn:31 0:0 01:01 imm8:01011001 11000010111:11000010111
	.inst 0x7859bec2 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:22 11:11 imm9:110011011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc240060e // ldr c14, [x16, #1]
	.inst 0xc2400a16 // ldr c22, [x16, #2]
	.inst 0xc2400e1e // ldr c30, [x16, #3]
	/* Set up flags and system registers */
	mov x16, #0x20000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f0 // ldr c16, [c23, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826012f0 // ldr c16, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400217 // ldr c23, [x16, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400617 // ldr c23, [x16, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a17 // ldr c23, [x16, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x23, v18.d[0]
	cmp x16, x23
	b.ne comparison_fail
	ldr x16, =0x0
	mov x23, v18.d[1]
	cmp x16, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001032
	ldr x1, =check_data0
	ldr x2, =0x00001034
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f0a
	ldr x1, =check_data2
	ldr x2, =0x00001f0c
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
	ldr x0, =0x0044ff9c
	ldr x1, =check_data4
	ldr x2, =0x0044ff9e
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
