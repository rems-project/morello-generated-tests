.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x4d, 0x7c, 0x1f, 0x42, 0x7f, 0x3a, 0x40, 0x69, 0xbe, 0x09, 0xc1, 0xc2, 0x3d, 0x90, 0xc5, 0xc2
	.byte 0x16, 0xa1, 0x81, 0x9a, 0x90, 0xbb, 0x43, 0xd2, 0x5e, 0x6d, 0x20, 0xe2, 0x20, 0x76, 0x16, 0xf1
	.byte 0x01, 0x31, 0xc2, 0xc2, 0x7f, 0xd3, 0xc0, 0x82, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20000004007100200ff0001ffffe000
	/* C2 */
	.octa 0x48000000600400020000000000001000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000860117000000000040007a
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x159c
	/* C19 */
	.octa 0x1000
	/* C27 */
	.octa 0x80000000008600070000000000000001
final_cap_values:
	/* C0 */
	.octa 0xfff
	/* C1 */
	.octa 0x20000004007100200ff0001ffffe000
	/* C2 */
	.octa 0x48000000600400020000000000001000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000860117000000000040007a
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x159c
	/* C19 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000008600070000000000000001
	/* C29 */
	.octa 0x800000000003000700ff0001ffffe000
	/* C30 */
	.octa 0x7000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000300070000000000000100
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421f7c4d // ASTLR-C.R-C Ct:13 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x69403a7f // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:19 Rt2:01110 imm7:0000000 L:1 1010010:1010010 opc:01
	.inst 0xc2c109be // SEAL-C.CC-C Cd:30 Cn:13 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0xc2c5903d // CVTD-C.R-C Cd:29 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x9a81a116 // csel:aarch64/instrs/integer/conditional/select Rd:22 Rn:8 o2:0 0:0 cond:1010 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0xd243bb90 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:16 Rn:28 imms:101110 immr:000011 N:1 100100:100100 opc:10 sf:1
	.inst 0xe2206d5e // ALDUR-V.RI-Q Rt:30 Rn:10 op2:11 imm9:000000110 V:1 op1:00 11100010:11100010
	.inst 0xf1167620 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:17 imm12:010110011101 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c23101 // CHKTGD-C-C 00001:00001 Cn:8 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x82c0d37f // ALDRB-R.RRB-B Rt:31 Rn:27 opc:00 S:1 option:110 Rm:0 0:0 L:1 100000101:100000101
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc240130d // ldr c13, [x24, #4]
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2401b13 // ldr c19, [x24, #6]
	.inst 0xc2401f1b // ldr c27, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603338 // ldr c24, [c25, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x82601338 // ldr c24, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x25, #0xf
	and x24, x24, x25
	cmp x24, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400319 // ldr c25, [x24, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b19 // ldr c25, [x24, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401f19 // ldr c25, [x24, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2402319 // ldr c25, [x24, #8]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2402719 // ldr c25, [x24, #9]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2402b19 // ldr c25, [x24, #10]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402f19 // ldr c25, [x24, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2403319 // ldr c25, [x24, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x25, v30.d[0]
	cmp x24, x25
	b.ne comparison_fail
	ldr x24, =0x0
	mov x25, v30.d[1]
	cmp x24, x25
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400080
	ldr x1, =check_data2
	ldr x2, =0x00400090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
