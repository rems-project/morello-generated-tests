.section data0, #alloc, #write
	.zero 512
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x40
.data
check_data2:
	.zero 16
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xe5, 0xbb, 0x5d, 0x3a, 0x89, 0x13, 0xc1, 0xc2, 0x42, 0x4a, 0x6a, 0xb8, 0x1e, 0x43, 0x90, 0xe2
	.byte 0xa1, 0xe0, 0xd5, 0x22, 0x56, 0x0c, 0xc4, 0x38, 0x10, 0x17, 0x2d, 0xd1, 0x02, 0xe4, 0x0b, 0x39
	.byte 0x02, 0x00, 0x64, 0x82, 0x5f, 0xa3, 0x89, 0x39, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x900000000006000e0000000000000c00
	/* C5 */
	.octa 0xff0
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C24 */
	.octa 0x400000005f60136a000000000000203c
	/* C26 */
	.octa 0x1402
	/* C28 */
	.octa 0x2007c01300040000800a0000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x900000000006000e0000000000000c00
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x12a0
	/* C9 */
	.octa 0x4000080120000
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x4bb
	/* C18 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C26 */
	.octa 0x1402
	/* C28 */
	.octa 0x2007c01300040000800a0000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008f88170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000007020700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a5dbbe5 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:31 10:10 cond:1011 imm5:11101 111010010:111010010 op:0 sf:0
	.inst 0xc2c11389 // GCLIM-R.C-C Rd:9 Cn:28 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xb86a4a42 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:2 Rn:18 10:10 S:0 option:010 Rm:10 1:1 opc:01 111000:111000 size:10
	.inst 0xe290431e // ASTUR-R.RI-32 Rt:30 Rn:24 op2:00 imm9:100000100 V:0 op1:10 11100010:11100010
	.inst 0x22d5e0a1 // LDP-CC.RIAW-C Ct:1 Rn:5 Ct2:11000 imm7:0101011 L:1 001000101:001000101
	.inst 0x38c40c56 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:2 11:11 imm9:001000000 0:0 opc:11 111000:111000 size:00
	.inst 0xd12d1710 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:24 imm12:101101000101 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x390be402 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:0 imm12:001011111001 opc:00 111001:111001 size:00
	.inst 0x82640002 // ALDR-C.RI-C Ct:2 Rn:0 op:00 imm9:001000000 L:1 1000001001:1000001001
	.inst 0x3989a35f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:26 imm12:001001101000 opc:10 111001:111001 size:00
	.inst 0xc2c211e0
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
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc24019dc // ldr c28, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ee // ldr c14, [c15, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x826011ee // ldr c14, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x14, x14, x15
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cf // ldr c15, [x14, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24005cf // ldr c15, [x14, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24009cf // ldr c15, [x14, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400dcf // ldr c15, [x14, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24019cf // ldr c15, [x14, #6]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc2401dcf // ldr c15, [x14, #7]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc24021cf // ldr c15, [x14, #8]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc24025cf // ldr c15, [x14, #9]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc24029cf // ldr c15, [x14, #10]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2402dcf // ldr c15, [x14, #11]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc24031cf // ldr c15, [x14, #12]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x000010f9
	ldr x1, =check_data1
	ldr x2, =0x000010fa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001240
	ldr x1, =check_data3
	ldr x2, =0x00001241
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000186a
	ldr x1, =check_data4
	ldr x2, =0x0000186b
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f40
	ldr x1, =check_data5
	ldr x2, =0x00001f44
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
