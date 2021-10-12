.section data0, #alloc, #write
	.zero 3920
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0x40, 0xb4, 0x90, 0x9a, 0x41, 0x00, 0x09, 0x5a, 0x01, 0x07, 0xc0, 0xda, 0x20, 0x5c, 0xcf, 0x78
	.byte 0x42, 0xc8, 0x71, 0x62, 0x25, 0xa7, 0x00, 0xe2, 0x67, 0xa6, 0x66, 0x6d, 0xdf, 0xd0, 0xc0, 0xc2
	.byte 0x74, 0x54, 0x1b, 0xb0, 0x00, 0x44, 0xde, 0xc2, 0x00, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x2120
	/* C19 */
	.octa 0x400200
	/* C24 */
	.octa 0x40000180
	/* C25 */
	.octa 0x80000000000100050000000000001ff4
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffc2c2
	/* C1 */
	.octa 0x4080f6
	/* C2 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0xc2
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x400200
	/* C20 */
	.octa 0x36e8d000
	/* C24 */
	.octa 0x40000180
	/* C25 */
	.octa 0x80000000000100050000000000001ff4
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000628070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f60
	.dword initial_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a90b440 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:2 o2:1 0:0 cond:1011 Rm:16 011010100:011010100 op:0 sf:1
	.inst 0x5a090041 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:2 000000:000000 Rm:9 11010000:11010000 S:0 op:1 sf:0
	.inst 0xdac00701 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:24 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x78cf5c20 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:011110101 0:0 opc:11 111000:111000 size:01
	.inst 0x6271c842 // LDNP-C.RIB-C Ct:2 Rn:2 Ct2:10010 imm7:1100011 L:1 011000100:011000100
	.inst 0xe200a725 // ALDURB-R.RI-32 Rt:5 Rn:25 op2:01 imm9:000001010 V:0 op1:00 11100010:11100010
	.inst 0x6d66a667 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:7 Rn:19 Rt2:01001 imm7:1001101 L:1 1011010:1011010 opc:01
	.inst 0xc2c0d0df // GCPERM-R.C-C Rd:31 Cn:6 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xb01b5474 // ADRDP-C.ID-C Rd:20 immhi:001101101010100011 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2de4400 // CSEAL-C.C-C Cd:0 Cn:0 001:001 opc:10 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c21100
	.zero 60
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 32892
	.inst 0xc2c20000
	.zero 1015560
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c2 // ldr c2, [x14, #0]
	.inst 0xc24005d3 // ldr c19, [x14, #1]
	.inst 0xc24009d8 // ldr c24, [x14, #2]
	.inst 0xc2400dd9 // ldr c25, [x14, #3]
	.inst 0xc24011de // ldr c30, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310e // ldr c14, [c8, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260110e // ldr c14, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x8, #0xf
	and x14, x14, x8
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c8 // ldr c8, [x14, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc24011c8 // ldr c8, [x14, #4]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc24015c8 // ldr c8, [x14, #5]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc24019c8 // ldr c8, [x14, #6]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401dc8 // ldr c8, [x14, #7]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc24021c8 // ldr c8, [x14, #8]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc24025c8 // ldr c8, [x14, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0xc2c2c2c2c2c2c2c2
	mov x8, v7.d[0]
	cmp x14, x8
	b.ne comparison_fail
	ldr x14, =0x0
	mov x8, v7.d[1]
	cmp x14, x8
	b.ne comparison_fail
	ldr x14, =0xc2c2c2c2c2c2c2c2
	mov x8, v9.d[0]
	cmp x14, x8
	b.ne comparison_fail
	ldr x14, =0x0
	mov x8, v9.d[1]
	cmp x14, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f50
	ldr x1, =check_data0
	ldr x2, =0x00001f70
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
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
	ldr x0, =0x00400068
	ldr x1, =check_data3
	ldr x2, =0x00400078
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004080f6
	ldr x1, =check_data4
	ldr x2, =0x004080f8
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
