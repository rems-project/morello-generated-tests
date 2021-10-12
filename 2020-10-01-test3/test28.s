.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xd6, 0xff, 0x9f, 0x08, 0xff, 0x10, 0xc7, 0xc2, 0x20, 0x16, 0xd2, 0x28, 0xff, 0x13, 0x5d, 0xa2
	.byte 0x7e, 0x22, 0xea, 0xb6
.data
check_data6:
	.byte 0x2e, 0x39, 0x52, 0xba, 0x80, 0x37, 0x4b, 0xad, 0x59, 0xf5, 0x06, 0x38, 0xff, 0x08, 0xd8, 0x9a
	.byte 0x21, 0x9f, 0x02, 0xa2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1ffe
	/* C17 */
	.octa 0x1d94
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x1000
	/* C28 */
	.octa 0x1e10
	/* C30 */
	.octa 0x1ffe
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x206d
	/* C17 */
	.octa 0x1e24
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x1290
	/* C28 */
	.octa 0x1e10
	/* C30 */
	.octa 0x1ffe
initial_csp_value:
	.octa 0x200f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000601470000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089fffd6 // stlrb:aarch64/instrs/memory/ordered Rt:22 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c710ff // RRLEN-R.R-C Rd:31 Rn:7 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28d21620 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:17 Rt2:00101 imm7:0100100 L:1 1010001:1010001 opc:00
	.inst 0xa25d13ff // LDUR-C.RI-C Ct:31 Rn:31 00:00 imm9:111010001 0:0 opc:01 10100010:10100010
	.inst 0xb6ea227e // tbz:aarch64/instrs/branch/conditional/test Rt:30 imm14:01000100010011 b40:11101 op:0 011011:011011 b5:1
	.zero 17480
	.inst 0xba52392e // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:9 10:10 cond:0011 imm5:10010 111010010:111010010 op:0 sf:1
	.inst 0xad4b3780 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:28 Rt2:01101 imm7:0010110 L:1 1011010:1011010 opc:10
	.inst 0x3806f559 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:10 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:00
	.inst 0x9ad808ff // udiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:7 o1:0 00001:00001 Rm:24 0011010110:0011010110 sf:1
	.inst 0xa2029f21 // STR-C.RIBW-C Ct:1 Rn:25 11:11 imm9:000101001 0:0 opc:00 10100010:10100010
	.inst 0xc2c21280
	.zero 1031052
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2401a19 // ldr c25, [x16, #6]
	.inst 0xc2401e1c // ldr c28, [x16, #7]
	.inst 0xc240221e // ldr c30, [x16, #8]
	/* Set up flags and system registers */
	mov x16, #0x20000000
	msr nzcv, x16
	ldr x16, =initial_csp_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603290 // ldr c16, [c20, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x82601290 // ldr c16, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x20, #0xf
	and x16, x16, x20
	cmp x16, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400214 // ldr c20, [x16, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400614 // ldr c20, [x16, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401a14 // ldr c20, [x16, #6]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2401e14 // ldr c20, [x16, #7]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402214 // ldr c20, [x16, #8]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402614 // ldr c20, [x16, #9]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402a14 // ldr c20, [x16, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x20, v0.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v0.d[1]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v13.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v13.d[1]
	cmp x16, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001290
	ldr x1, =check_data0
	ldr x2, =0x000012a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d94
	ldr x1, =check_data1
	ldr x2, =0x00001d9c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f70
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040445c
	ldr x1, =check_data6
	ldr x2, =0x00404474
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
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
