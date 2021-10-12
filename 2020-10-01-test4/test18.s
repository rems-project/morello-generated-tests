.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x63, 0x13, 0xc0, 0xda, 0x81, 0x05, 0x02, 0x9b, 0xc0, 0x10, 0x86, 0x5a, 0x3e, 0x44, 0xd6, 0x42
	.byte 0x5b, 0x2b, 0x95, 0x78, 0x41, 0xf0, 0xc0, 0xc2, 0xd7, 0x31, 0x0c, 0x4a, 0x81, 0x2b, 0x09, 0xb8
	.byte 0x9f, 0xfb, 0xac, 0x82, 0x27, 0xd0, 0xc0, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xe
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x301
	/* C26 */
	.octa 0x1000
	/* C28 */
	.octa 0x400000005c000002ffffffffffffff70
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x301
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x400000005c000002ffffffffffffff70
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005f80100200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac01363 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:3 Rn:27 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x9b020581 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:12 Ra:1 o0:0 Rm:2 0011011000:0011011000 sf:1
	.inst 0x5a8610c0 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:6 o2:0 0:0 cond:0001 Rm:6 011010100:011010100 op:1 sf:0
	.inst 0x42d6443e // LDP-C.RIB-C Ct:30 Rn:1 Ct2:10001 imm7:0101100 L:1 010000101:010000101
	.inst 0x78952b5b // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:26 10:10 imm9:101010010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c0f041 // GCTYPE-R.C-C Rd:1 Cn:2 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x4a0c31d7 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:23 Rn:14 imm6:001100 Rm:12 N:0 shift:00 01010:01010 opc:10 sf:0
	.inst 0xb8092b81 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:28 10:10 imm9:010010010 0:0 opc:00 111000:111000 size:10
	.inst 0x82acfb9f // ASTR-V.RRB-D Rt:31 Rn:28 opc:10 S:1 option:111 Rm:12 1:1 L:0 100000101:100000101
	.inst 0xc2c0d027 // GCPERM-R.C-C Rd:7 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c212c0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc240088c // ldr c12, [x4, #2]
	.inst 0xc2400c9a // ldr c26, [x4, #3]
	.inst 0xc240109c // ldr c28, [x4, #4]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x4, #0x40000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c4 // ldr c4, [c22, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x826012c4 // ldr c4, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x22, #0x4
	and x4, x4, x22
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400096 // ldr c22, [x4, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400496 // ldr c22, [x4, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400896 // ldr c22, [x4, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400c96 // ldr c22, [x4, #3]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2401896 // ldr c22, [x4, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401c96 // ldr c22, [x4, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402096 // ldr c22, [x4, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x22, v31.d[0]
	cmp x4, x22
	b.ne comparison_fail
	ldr x4, =0x0
	mov x22, v31.d[1]
	cmp x4, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001778
	ldr x1, =check_data2
	ldr x2, =0x00001780
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f54
	ldr x1, =check_data3
	ldr x2, =0x00001f56
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
