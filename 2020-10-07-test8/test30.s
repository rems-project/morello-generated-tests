.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x39, 0x90, 0xc5, 0xc2, 0x02, 0x68, 0x43, 0xa2, 0x5f, 0x0a, 0xca, 0x9a, 0x82, 0x1d, 0x19, 0xad
	.byte 0xbe, 0x5d, 0x00, 0x53, 0xc1, 0x06, 0x22, 0x9b, 0x20, 0x02, 0x5f, 0xd6
.data
check_data3:
	.byte 0x59, 0x71, 0xc3, 0xc2, 0x80, 0x03, 0x5f, 0xd6
.data
check_data4:
	.byte 0x04, 0x60, 0xf9, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000300070000000000001020
	/* C1 */
	.octa 0x8000008001
	/* C10 */
	.octa 0x1000000000000000000000000
	/* C12 */
	.octa 0x40000000000600070000000000001000
	/* C17 */
	.octa 0x4001fc
	/* C28 */
	.octa 0x400804
final_cap_values:
	/* C0 */
	.octa 0x90100000000300070000000000001020
	/* C1 */
	.octa 0x8000008001
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x90100000000300070000000000001020
	/* C10 */
	.octa 0x1000000000000000000000000
	/* C12 */
	.octa 0x40000000000600070000000000001000
	/* C17 */
	.octa 0x4001fc
	/* C25 */
	.octa 0x1800000000000000000000000
	/* C28 */
	.octa 0x400804
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x1000780070000000000006000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001380
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c59039 // CVTD-C.R-C Cd:25 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xa2436802 // LDTR-C.RIB-C Ct:2 Rn:0 10:10 imm9:000110110 0:0 opc:01 10100010:10100010
	.inst 0x9aca0a5f // udiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:18 o1:0 00001:00001 Rm:10 0011010110:0011010110 sf:1
	.inst 0xad191d82 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:2 Rn:12 Rt2:00111 imm7:0110010 L:0 1011010:1011010 opc:10
	.inst 0x53005dbe // ubfm:aarch64/instrs/integer/bitfield Rd:30 Rn:13 imms:010111 immr:000000 N:0 100110:100110 opc:10 sf:0
	.inst 0x9b2206c1 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:22 Ra:1 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xd65f0220 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:17 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 480
	.inst 0xc2c37159 // SEAL-C.CI-C Cd:25 Cn:10 100:100 form:11 11000010110000110:11000010110000110
	.inst 0xd65f0380 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:28 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 1536
	.inst 0xc2f96004 // BICFLGS-C.CI-C Cd:4 Cn:0 0:0 00:00 imm8:11001011 11000010111:11000010111
	.inst 0xc2c21200
	.zero 1046516
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q2, =0x0
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320b // ldr c11, [c16, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260120b // ldr c11, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400170 // ldr c16, [x11, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x16, v2.d[0]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v2.d[1]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v7.d[0]
	cmp x11, x16
	b.ne comparison_fail
	ldr x11, =0x0
	mov x16, v7.d[1]
	cmp x11, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001320
	ldr x1, =check_data0
	ldr x2, =0x00001340
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001380
	ldr x1, =check_data1
	ldr x2, =0x00001390
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004001fc
	ldr x1, =check_data3
	ldr x2, =0x00400204
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400804
	ldr x1, =check_data4
	ldr x2, =0x0040080c
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
