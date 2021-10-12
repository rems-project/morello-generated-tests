.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00
	.byte 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00
	.byte 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xf4, 0x31, 0x9e, 0x5a, 0xdc, 0x7b, 0x18, 0xb8, 0x5f, 0x32, 0x03, 0xd5, 0x02, 0xb8, 0xc9, 0xca
	.byte 0xe0, 0xd0, 0xc5, 0xc2, 0x5f, 0xab, 0x9b, 0xb8, 0xde, 0x57, 0x80, 0x82, 0x00, 0x11, 0xc4, 0xc2
.data
check_data5:
	.byte 0xf5, 0x07, 0xc0, 0xda, 0xde, 0x5b, 0xbe, 0xf8, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x90000000000700060000000000001010
	/* C26 */
	.octa 0x1086
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000600100010000000000001c75
final_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x90000000000700060000000000001010
	/* C20 */
	.octa 0xffffe38a
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1086
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000000100ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a9e31f4 // csinv:aarch64/instrs/integer/conditional/select Rd:20 Rn:15 o2:0 0:0 cond:0011 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0xb8187bdc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:28 Rn:30 10:10 imm9:110000111 0:0 opc:00 111000:111000 size:10
	.inst 0xd503325f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0010 11010101000000110011:11010101000000110011
	.inst 0xcac9b802 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:0 imm6:101110 Rm:9 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c5d0e0 // CVTDZ-C.R-C Cd:0 Rn:7 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb89bab5f // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:26 10:10 imm9:110111010 0:0 opc:10 111000:111000 size:10
	.inst 0x828057de // ALDRSB-R.RRB-64 Rt:30 Rn:30 opc:01 S:1 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xc2c41100 // LDPBR-C.C-C Ct:0 Cn:8 100:100 opc:00 11000010110001000:11000010110001000
	.zero 224
	.inst 0xdac007f5 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf8be5bde // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:30 10:10 S:1 option:010 Rm:30 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c21080
	.zero 1048308
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e7 // ldr c7, [x23, #0]
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2400afa // ldr c26, [x23, #2]
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x20000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603097 // ldr c23, [c4, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601097 // ldr c23, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x4, #0x2
	and x23, x23, x4
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24012e4 // ldr c4, [x23, #4]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc24016e4 // ldr c4, [x23, #5]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2401ae4 // ldr c4, [x23, #6]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2401ee4 // ldr c4, [x23, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bfc
	ldr x1, =check_data2
	ldr x2, =0x00001c00
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c75
	ldr x1, =check_data3
	ldr x2, =0x00001c76
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x0040010c
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
