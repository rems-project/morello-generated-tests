.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x10
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x7e, 0xf2, 0x29, 0xc2, 0x37, 0xf0, 0xc5, 0xc2, 0xc0, 0xbf, 0x4f, 0xd3, 0xee, 0x6b, 0x45, 0x7a
	.byte 0x41, 0x84, 0x9c, 0x5a, 0x1f, 0xf0, 0x38, 0x0b, 0x63, 0x65, 0x43, 0x39, 0x57, 0x10, 0x95, 0x78
	.byte 0xb0, 0x07, 0x46, 0xf8, 0x0f, 0x74, 0x9e, 0x1a, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x10c1
	/* C11 */
	.octa 0x1024
	/* C19 */
	.octa 0xffffffffffff6840
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x10004000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x10c1
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x1024
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0xffffffffffff6840
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1060
	/* C30 */
	.octa 0x10004000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000580408040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc229f27e // STR-C.RIB-C Ct:30 Rn:19 imm12:101001111100 L:0 110000100:110000100
	.inst 0xc2c5f037 // CVTPZ-C.R-C Cd:23 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xd34fbfc0 // ubfm:aarch64/instrs/integer/bitfield Rd:0 Rn:30 imms:101111 immr:001111 N:1 100110:100110 opc:10 sf:1
	.inst 0x7a456bee // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:31 10:10 cond:0110 imm5:00101 111010010:111010010 op:1 sf:0
	.inst 0x5a9c8441 // csneg:aarch64/instrs/integer/conditional/select Rd:1 Rn:2 o2:1 0:0 cond:1000 Rm:28 011010100:011010100 op:1 sf:0
	.inst 0x0b38f01f // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:0 imm3:100 option:111 Rm:24 01011001:01011001 S:0 op:0 sf:0
	.inst 0x39436563 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:11 imm12:000011011001 opc:01 111001:111001 size:00
	.inst 0x78951057 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:2 00:00 imm9:101010001 0:0 opc:10 111000:111000 size:01
	.inst 0xf84607b0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:29 01:01 imm9:001100000 0:0 opc:01 111000:111000 size:11
	.inst 0x1a9e740f // csinc:aarch64/instrs/integer/conditional/select Rd:15 Rn:0 o2:1 0:0 cond:0111 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0xc2c21320
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
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2400e93 // ldr c19, [x20, #3]
	.inst 0xc240129d // ldr c29, [x20, #4]
	.inst 0xc240169e // ldr c30, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x10000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603334 // ldr c20, [c25, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601334 // ldr c20, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x20, x20, x25
	cmp x20, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400299 // ldr c25, [x20, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400699 // ldr c25, [x20, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400a99 // ldr c25, [x20, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400e99 // ldr c25, [x20, #3]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401699 // ldr c25, [x20, #5]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401a99 // ldr c25, [x20, #6]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401e99 // ldr c25, [x20, #7]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402299 // ldr c25, [x20, #8]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402699 // ldr c25, [x20, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001012
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fd
	ldr x1, =check_data2
	ldr x2, =0x000010fe
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
