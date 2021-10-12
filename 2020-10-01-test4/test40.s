.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x01, 0xef, 0x9c, 0xe2, 0xd7, 0x3b, 0x4a, 0x51, 0x72, 0xeb, 0xa9, 0xb8, 0x5f, 0xdc, 0xfe, 0x02
	.byte 0xdf, 0x7f, 0x9f, 0x48, 0x16, 0x1c, 0x30, 0x92, 0xfd, 0x47, 0x5d, 0x82, 0xc0, 0x40, 0x70, 0x82
	.byte 0x22, 0xa1, 0x50, 0x30, 0x5e, 0x30, 0x0d, 0xb1, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2400000010000000000fb8010
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0xe700000000003000
	/* C24 */
	.octa 0x1442
	/* C27 */
	.octa 0x800000000007000f18ffffffffffe000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000700070000000000001118
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200080000000800800000000004a1445
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0xe700000000003000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0xffd73118
	/* C24 */
	.octa 0x1442
	/* C27 */
	.octa 0x800000000007000f18ffffffffffe000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4a1791
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000100702f70000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29cef01 // ASTUR-C.RI-C Ct:1 Rn:24 op2:11 imm9:111001110 V:0 op1:10 11100010:11100010
	.inst 0x514a3bd7 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:23 Rn:30 imm12:001010001110 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xb8a9eb72 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:18 Rn:27 10:10 S:0 option:111 Rm:9 1:1 opc:10 111000:111000 size:10
	.inst 0x02fedc5f // SUB-C.CIS-C Cd:31 Cn:2 imm12:111110110111 sh:1 A:1 00000010:00000010
	.inst 0x489f7fdf // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x92301c16 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:22 Rn:0 imms:000111 immr:110000 N:0 100100:100100 opc:00 sf:1
	.inst 0x825d47fd // ASTRB-R.RI-B Rt:29 Rn:31 op:01 imm9:111010100 L:0 1000001001:1000001001
	.inst 0x827040c0 // ALDR-C.RI-C Ct:0 Rn:6 op:00 imm9:100000100 L:1 1000001001:1000001001
	.inst 0x3050a122 // ADR-C.I-C Rd:2 immhi:101000010100001001 P:0 10000:10000 immlo:01 op:0
	.inst 0xb10d305e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:2 imm12:001101001100 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c21260
	.zero 1048532
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc24015db // ldr c27, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326e // ldr c14, [c19, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260126e // ldr c14, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x19, #0xf
	and x14, x14, x19
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d3 // ldr c19, [x14, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005d3 // ldr c19, [x14, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24009d3 // ldr c19, [x14, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc24019d3 // ldr c19, [x14, #6]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2401dd3 // ldr c19, [x14, #7]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc24021d3 // ldr c19, [x14, #8]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc24025d3 // ldr c19, [x14, #9]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc24029d3 // ldr c19, [x14, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001118
	ldr x1, =check_data2
	ldr x2, =0x0000111a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011e4
	ldr x1, =check_data3
	ldr x2, =0x000011e5
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001410
	ldr x1, =check_data4
	ldr x2, =0x00001420
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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
