.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x5e, 0x30, 0xc7, 0xc2, 0xc1, 0x0a, 0x10, 0xb8, 0xc4, 0xca, 0xbf, 0xf8, 0xbe, 0xfa, 0x9e, 0xeb
	.byte 0xe0, 0x99, 0xa7, 0x02, 0x1f, 0x18, 0xdf, 0xd0, 0x3e, 0x31, 0xc7, 0xc2, 0x22, 0x53, 0xc0, 0xc2
	.byte 0x01, 0x30, 0xc2, 0xc2, 0xe7, 0x33, 0xc1, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x420050000000000000c00
	/* C22 */
	.octa 0x40000000000100050000000000002058
final_cap_values:
	/* C0 */
	.octa 0x42005000000000000021a
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x420050000000000000c00
	/* C22 */
	.octa 0x40000000000100050000000000002058
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005000d0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c7305e // RRMASK-R.R-C Rd:30 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xb8100ac1 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:22 10:10 imm9:100000000 0:0 opc:00 111000:111000 size:10
	.inst 0xf8bfcac4 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:4 Rn:22 10:10 S:0 option:110 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0xeb9efabe // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:21 imm6:111110 Rm:30 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0x02a799e0 // SUB-C.CIS-C Cd:0 Cn:15 imm12:100111100110 sh:0 A:1 00000010:00000010
	.inst 0xd0df181f // ADRP-C.IP-C Rd:31 immhi:101111100011000000 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c7313e // RRMASK-R.R-C Rd:30 Rn:9 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c05322 // GCVALUE-R.C-C Rd:2 Cn:25 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c133e7 // GCFLGS-R.C-C Rd:7 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c21300
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
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601304 // ldr c4, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0xf
	and x4, x4, x24
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400098 // ldr c24, [x4, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400498 // ldr c24, [x4, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400898 // ldr c24, [x4, #2]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2400c98 // ldr c24, [x4, #3]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401098 // ldr c24, [x4, #4]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401498 // ldr c24, [x4, #5]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f58
	ldr x1, =check_data0
	ldr x2, =0x00001f5c
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
