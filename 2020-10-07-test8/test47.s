.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x0e, 0xe1, 0xe0, 0x82, 0xc0, 0x43, 0x32, 0x3d, 0xde, 0xa0, 0x5d, 0xf2, 0x22, 0xb0, 0x3a, 0xd1
	.byte 0x36, 0xe0, 0x1a, 0xb2, 0x4c, 0x1b, 0xe1, 0xc2, 0xec, 0x5b, 0x58, 0x7a, 0x6e, 0x73, 0x47, 0x78
	.byte 0xa1, 0x10, 0xc1, 0xc2, 0xe0, 0x84, 0x72, 0x62, 0xa0, 0x12, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x41ac60
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x7a0170000000000000001
	/* C6 */
	.octa 0x8000000000000002
	/* C7 */
	.octa 0x900000000000c00000000000004001c0
	/* C8 */
	.octa 0xe01a4
	/* C26 */
	.octa 0x1400420010000010000000001
	/* C27 */
	.octa 0x80000000400000010000000000000f95
	/* C30 */
	.octa 0x4000000040000002000000000000130e
final_cap_values:
	/* C0 */
	.octa 0x7847736e7a585becc2e11b4cb21ae036
	/* C1 */
	.octa 0xc2c212a0627284e0c2c110a1
	/* C2 */
	.octa 0xfffffffffffff154
	/* C5 */
	.octa 0x7a0170000000000000001
	/* C6 */
	.octa 0x8000000000000002
	/* C7 */
	.octa 0x900000000000c00000000000004001c0
	/* C8 */
	.octa 0xe01a4
	/* C12 */
	.octa 0x1400420010000000000000000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x4444444444444444
	/* C26 */
	.octa 0x1400420010000010000000001
	/* C27 */
	.octa 0x80000000400000010000000000000f95
	/* C30 */
	.octa 0x8000000000000002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001fe5000d0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000400480140000000000500001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 80
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82e0e10e // ALDR-R.RRB-32 Rt:14 Rn:8 opc:00 S:0 option:111 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x3d3243c0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:30 imm12:110010010000 opc:00 111101:111101 size:00
	.inst 0xf25da0de // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:6 imms:101000 immr:011101 N:1 100100:100100 opc:11 sf:1
	.inst 0xd13ab022 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:1 imm12:111010101100 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xb21ae036 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:22 Rn:1 imms:111000 immr:011010 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2e11b4c // CVT-C.CR-C Cd:12 Cn:26 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0x7a585bec // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:31 10:10 cond:0101 imm5:11000 111010010:111010010 op:1 sf:0
	.inst 0x7847736e // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:27 00:00 imm9:001110111 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c110a1 // GCLIM-R.C-C Rd:1 Cn:5 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x627284e0 // LDNP-C.RIB-C Ct:0 Rn:7 Ct2:00001 imm7:1100101 L:1 011000100:011000100
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc2401548 // ldr c8, [x10, #5]
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	.inst 0xc240215e // ldr c30, [x10, #8]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032aa // ldr c10, [c21, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012aa // ldr c10, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x21, #0xf
	and x10, x10, x21
	cmp x10, #0xc
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400155 // ldr c21, [x10, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400555 // ldr c21, [x10, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400955 // ldr c21, [x10, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400d55 // ldr c21, [x10, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401155 // ldr c21, [x10, #4]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2401555 // ldr c21, [x10, #5]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401d55 // ldr c21, [x10, #7]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2402155 // ldr c21, [x10, #8]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2402555 // ldr c21, [x10, #9]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402955 // ldr c21, [x10, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402d55 // ldr c21, [x10, #11]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2403155 // ldr c21, [x10, #12]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x21, v0.d[0]
	cmp x10, x21
	b.ne comparison_fail
	ldr x10, =0x0
	mov x21, v0.d[1]
	cmp x10, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f9e
	ldr x1, =check_data1
	ldr x2, =0x00001f9f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fae04
	ldr x1, =check_data3
	ldr x2, =0x004fae08
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
