.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x1e, 0xdc, 0x24, 0xe2, 0xd8, 0x13, 0x04, 0xd2, 0xc1, 0x93, 0xdc, 0x38, 0x3e, 0x12, 0x53, 0xb0
	.byte 0x23, 0x7f, 0x9f, 0x48, 0x37, 0x50, 0xdc, 0x6c, 0x1f, 0x08, 0xcd, 0xc2, 0x1e, 0x50, 0x09, 0x52
	.byte 0x1e, 0x9a, 0x8c, 0x39, 0xb3, 0x03, 0x57, 0x31, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000200030000000000001603
	/* C3 */
	.octa 0x0
	/* C13 */
	.octa 0x200000064082400004a080000012401
	/* C16 */
	.octa 0xc00
	/* C25 */
	.octa 0x7e0
	/* C30 */
	.octa 0x800
final_cap_values:
	/* C0 */
	.octa 0x80000000000200030000000000001603
	/* C1 */
	.octa 0x1c0
	/* C3 */
	.octa 0x0
	/* C13 */
	.octa 0x200000064082400004a080000012401
	/* C16 */
	.octa 0xc00
	/* C24 */
	.octa 0xf0000001f0000801
	/* C25 */
	.octa 0x7e0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000047004100fffffffff80001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe224dc1e // ALDUR-V.RI-Q Rt:30 Rn:0 op2:11 imm9:001001101 V:1 op1:00 11100010:11100010
	.inst 0xd20413d8 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:24 Rn:30 imms:000100 immr:000100 N:0 100100:100100 opc:10 sf:1
	.inst 0x38dc93c1 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:30 00:00 imm9:111001001 0:0 opc:11 111000:111000 size:00
	.inst 0xb053123e // ADRDP-C.ID-C Rd:30 immhi:101001100010010001 P:0 10000:10000 immlo:01 op:1
	.inst 0x489f7f23 // stllrh:aarch64/instrs/memory/ordered Rt:3 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x6cdc5037 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:23 Rn:1 Rt2:10100 imm7:0111000 L:1 1011001:1011001 opc:01
	.inst 0xc2cd081f // SEAL-C.CC-C Cd:31 Cn:0 0010:0010 opc:00 Cm:13 11000010110:11000010110
	.inst 0x5209501e // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:0 imms:010100 immr:001001 N:0 100100:100100 opc:10 sf:0
	.inst 0x398c9a1e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:16 imm12:001100100110 opc:10 111001:111001 size:00
	.inst 0x315703b3 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:29 imm12:010111000000 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157e // ldr c30, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ab // ldr c11, [c21, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826012ab // ldr c11, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400175 // ldr c21, [x11, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400575 // ldr c21, [x11, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400975 // ldr c21, [x11, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401175 // ldr c21, [x11, #4]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401975 // ldr c21, [x11, #6]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2401d75 // ldr c21, [x11, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x21, v20.d[0]
	cmp x11, x21
	b.ne comparison_fail
	ldr x11, =0x0
	mov x21, v20.d[1]
	cmp x11, x21
	b.ne comparison_fail
	ldr x11, =0x0
	mov x21, v23.d[0]
	cmp x11, x21
	b.ne comparison_fail
	ldr x11, =0x0
	mov x21, v23.d[1]
	cmp x11, x21
	b.ne comparison_fail
	ldr x11, =0x0
	mov x21, v30.d[0]
	cmp x11, x21
	b.ne comparison_fail
	ldr x11, =0x0
	mov x21, v30.d[1]
	cmp x11, x21
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
	ldr x0, =0x00001650
	ldr x1, =check_data1
	ldr x2, =0x00001660
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017c9
	ldr x1, =check_data2
	ldr x2, =0x000017ca
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e0
	ldr x1, =check_data3
	ldr x2, =0x000017e2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f26
	ldr x1, =check_data4
	ldr x2, =0x00001f27
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
