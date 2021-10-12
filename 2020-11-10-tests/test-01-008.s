.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xde, 0xb3, 0x05, 0x1b, 0xdf, 0x32, 0x22, 0x38, 0xbc, 0x63, 0x2f, 0x51, 0x47, 0xf2, 0x7c, 0x82
	.byte 0x0c, 0xd0, 0x42, 0xba, 0x00, 0xfc, 0x5f, 0x48, 0x41, 0x7c, 0x5f, 0x42, 0x5e, 0xcc, 0x9e, 0x82
	.byte 0x1a, 0xbd, 0xff, 0x02, 0xbd, 0x77, 0xf2, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000007c9af000000000041dfa4
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0x3d8c0000
	/* C8 */
	.octa 0x8001a0040080000000000000
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0xc00000000006000f0000000000001000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x10000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0x3d8c0000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x8001a0040080000000000000
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0xc00000000006000f0000000000001000
	/* C26 */
	.octa 0x8001a004007fffffff011000
	/* C28 */
	.octa 0x428
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000001e1e000000fffffff02f8000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b05b3de // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:30 Ra:12 o0:1 Rm:5 0011011000:0011011000 sf:0
	.inst 0x382232df // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:011 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x512f63bc // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:28 Rn:29 imm12:101111011000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x827cf247 // ALDR-C.RI-C Ct:7 Rn:18 op:00 imm9:111001111 L:1 1000001001:1000001001
	.inst 0xba42d00c // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1100 0:0 Rn:0 00:00 cond:1101 Rm:2 111010010:111010010 op:0 sf:1
	.inst 0x485ffc00 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x425f7c41 // ALDAR-C.R-C Ct:1 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x829ecc5e // ASTRH-R.RRB-32 Rt:30 Rn:2 opc:11 S:0 option:110 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x02ffbd1a // SUB-C.CIS-C Cd:26 Cn:8 imm12:111111101111 sh:1 A:1 00000010:00000010
	.inst 0xc2f277bd // ASTR-C.RRB-C Ct:29 Rn:29 1:1 L:0 S:1 option:011 Rm:18 11000010111:11000010111
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc24015d2 // ldr c18, [x14, #5]
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x40000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312e // ldr c14, [c9, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260112e // ldr c14, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x9, #0xf
	and x14, x14, x9
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c9 // ldr c9, [x14, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24005c9 // ldr c9, [x14, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24009c9 // ldr c9, [x14, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24015c9 // ldr c9, [x14, #5]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc24019c9 // ldr c9, [x14, #6]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401dc9 // ldr c9, [x14, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24021c9 // ldr c9, [x14, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24025c9 // ldr c9, [x14, #9]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24029c9 // ldr c9, [x14, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402dc9 // ldr c9, [x14, #11]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc24031c9 // ldr c9, [x14, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001cf0
	ldr x1, =check_data1
	ldr x2, =0x00001d00
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
	ldr x0, =0x0041dfa4
	ldr x1, =check_data3
	ldr x2, =0x0041dfa6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
