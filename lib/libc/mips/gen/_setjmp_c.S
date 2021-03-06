/*-
 * Copyright (c) 1991, 1993
 *	The Regents of the University of California.
 * Copyright (c) 2015 SRI International
 * Copyright (c) 2017 Robert N. M. Watson
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * This code is derived from software contributed to Berkeley by
 * Ralph Campbell.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <machine/asm.h>
__FBSDID("$FreeBSD$");
#include <machine/regnum.h>

#include "SYS.h"

#ifdef __ABICALLS__
	.abicalls
#endif

/*
 * C library -- _setjmp, _longjmp
 *
 *	_longjmp(a,v)
 * will generate a "return(v)" from
 * the last call to
 *	_setjmp(a)
 * by restoring registers from the stack,
 * and a struct sigcontext, see <signal.h>
 */

/* Stack space required to save original $c3. */
#define SETJMP_FRAME_SIZE	(CALLFRAME_SIZ + _MIPS_SZCAP/8)

NESTED(_setjmp, SETJMP_FRAME_SIZE, _FRAME_RETURN_REG)
	.protected _C_LABEL(_setjmp)
	PIC_PROLOGUE(_setjmp)
	.set	noreorder
	/* XXXRW: CFI annotations for debugger. */

	REG_LI		v0, _JB_MAGIC__SETJMP
	csd		v0, zero, (_JB_MAGIC * SZREG)($c3)

	/*
	 * From "MIPSpro N32 ABI Handbook", Table 2-1:
	 * Registers s0..s7 are callee-saved.
	 * The sp register is callee-saved.
	 * The fp (or s8) register is callee-saved.
	 * The gp register is callee-saved (for n32/n64).
	 *
	 * NB: The pure-capability ABI roughly retains the n32/n64 MIPS ABI in
	 * terms of caller/callee-save registers, despite some registers
	 * seeing different use.
	 *
	 * NB: In the pure-capability ABI, we need to neither save nore restore
	 * $ra and $sp, which are caller-save and not used for control flow.
	 */
	csd		s0, zero, (_JB_REG_S0 * SZREG)($c3)
	csd		s1, zero, (_JB_REG_S1 * SZREG)($c3)
	csd		s2, zero, (_JB_REG_S2 * SZREG)($c3)
	csd		s3, zero, (_JB_REG_S3 * SZREG)($c3)
	csd		s4, zero, (_JB_REG_S4 * SZREG)($c3)
	csd		s5, zero, (_JB_REG_S5 * SZREG)($c3)
	csd		s6, zero, (_JB_REG_S6 * SZREG)($c3)
	csd		s7, zero, (_JB_REG_S7 * SZREG)($c3)
	csd		s8, zero, (_JB_REG_S8 * SZREG)($c3)
	csd		gp, zero, (_JB_REG_GP * SZREG)($c3)
#ifndef __mips_soft_float
	/*
	 * From "MIPSpro N32 ABI Handbook", Table 2-1:
	 * In N64, FP registers F24 .. F31 are callee-saved.
	 */
	cfc1	v0, $31
	csw	v0, zero, (_JB_FPREG_FCSR * SZREG)($c3)
	csdc1	$f24, zero, (_JB_FPREG_F24 * SZREG)($c3)
	csdc1	$f25, zero, (_JB_FPREG_F25 * SZREG)($c3)
	csdc1	$f26, zero, (_JB_FPREG_F26 * SZREG)($c3)
	csdc1	$f27, zero, (_JB_FPREG_F27 * SZREG)($c3)
	csdc1	$f28, zero, (_JB_FPREG_F28 * SZREG)($c3)
	csdc1	$f29, zero, (_JB_FPREG_F29 * SZREG)($c3)
	csdc1	$f30, zero, (_JB_FPREG_F30 * SZREG)($c3)
	csdc1	$f31, zero, (_JB_FPREG_F31 * SZREG)($c3)
#endif	/* ! __mips_soft_float */
	csc		$c11, zero, _JB_CHERI_OFFSET(C11)($c3)
	csc		$c12, zero, _JB_CHERI_OFFSET(C12)($c3)
	csc		$c13, zero, _JB_CHERI_OFFSET(C13)($c3)
	csc		$c14, zero, _JB_CHERI_OFFSET(C14)($c3)
	csc		$c15, zero, _JB_CHERI_OFFSET(C15)($c3)
	csc		$c16, zero, _JB_CHERI_OFFSET(C16)($c3)
	csc		$c17, zero, _JB_CHERI_OFFSET(C17)($c3)
	csc		$c18, zero, _JB_CHERI_OFFSET(C18)($c3)
	csc		$c19, zero, _JB_CHERI_OFFSET(C19)($c3)
	csc		$c20, zero, _JB_CHERI_OFFSET(C20)($c3)
	csc		$c21, zero, _JB_CHERI_OFFSET(C21)($c3)
	csc		$c22, zero, _JB_CHERI_OFFSET(C22)($c3)
	csc		$c23, zero, _JB_CHERI_OFFSET(C23)($c3)
	csc		$c24, zero, _JB_CHERI_OFFSET(C24)($c3)
	csc		$c25, zero, _JB_CHERI_OFFSET(C25)($c3)
	cgetdefault	$c4
	csc		$c4, zero, _JB_CHERI_OFFSET(DDC)($c3)

	move		v0, zero
	PIC_RETURN()
END(_setjmp)

#define LONGJMP_FRAME_SIZE	(CALLFRAME_SIZ + 2 * _MIPS_SZCAP/8)
NESTED(_longjmp, LONGJMP_FRAME_SIZE, _FRAME_RETURN_REG)
	.protected _C_LABEL(_longjmp)
	PIC_PROLOGUE(_longjmp)
	/* XXXRW: CFI annotations for debugger. */

	cincoffset	$csp, $csp, -LONGJMP_FRAME_SIZE	# allocate stack frame

	/*
	 * Prepare a proper stack frame so that we can call
	 * __cheriabi_longjmperror() before a tail call into
	 * __cheriabi_abort().
	 *
	 * Note that $a0 is saved as the return value, and $c3 as the jmp_buf
	 * pointer, in the pure-capability ABI, unlike in the MIPS ABI where
	 * they are in $a1 and $a0 respectively.
	 */
	csc		$c17, zero, CALLFRAME_CRA($csp)
	csd		a0, zero, CALLFRAME_S0($csp)	# save return value
	csc		$c3, zero, CALLFRAME_SIZ($csp)

	cld		v0, zero, (_JB_MAGIC  * SZREG)($c3)
	REG_LI		t0, _JB_MAGIC__SETJMP
	bne		v0, t0, botch			# jump if error
	nop

	/*
	 * XXXRW: Should signal mask be restored here, as in MIPS?  That is
	 * presumably the reason for saving/restoring $c3/$a0 around this gap.
	 */
	clc		$c3, zero, CALLFRAME_SIZ($csp)
	cld		a0, zero, CALLFRAME_S0($csp)	# restore return value

	/*
	 * From "MIPSpro N32 ABI Handbook", Table 2-1:
	 * Registers s0..s7 are callee-saved.
	 * The sp register is callee-saved.
	 * The fp (or s8) register is callee-saved.
	 * The gp register is callee-saved (for n32/n64).
	 *
	 * NB: In the pure-capability ABI, we need to neither save nore restore
	 * $ra and $sp, which are caller-save and not used for control flow.
	 */
	cld		s0, zero, (_JB_REG_S0 * SZREG)($c3)
	cld		s1, zero, (_JB_REG_S1 * SZREG)($c3)
	cld		s2, zero, (_JB_REG_S2 * SZREG)($c3)
	cld		s3, zero, (_JB_REG_S3 * SZREG)($c3)
	cld		s4, zero, (_JB_REG_S4 * SZREG)($c3)
	cld		s5, zero, (_JB_REG_S5 * SZREG)($c3)
	cld		s6, zero, (_JB_REG_S6 * SZREG)($c3)
	cld		s7, zero, (_JB_REG_S7 * SZREG)($c3)
	cld		s8, zero, (_JB_REG_S8 * SZREG)($c3)
	cld		gp, zero, (_JB_REG_GP * SZREG)($c3)
#ifndef __mips_soft_float
	/*
	 * From "MIPSpro N32 ABI Handbook", Table 2-1:
	 * In N32, FP registers F20, F22, F24, F26, F28, F30 are callee-saved.
	 * In N64, FP registers F23 .. F31 are callee-saved.
	 * In O32, FP registers F20 .. F23 are callee-saved.
	 */
        clw		v0, zero, (_JB_FPREG_FCSR * SZREG)($c3)
        ctc1		v0, $31
	cldc1		$f24, zero, (_JB_FPREG_F24 * SZREG)($c3)
	cldc1		$f25, zero, (_JB_FPREG_F25 * SZREG)($c3)
	cldc1		$f26, zero, (_JB_FPREG_F26 * SZREG)($c3)
	cldc1		$f27, zero, (_JB_FPREG_F27 * SZREG)($c3)
	cldc1		$f28, zero, (_JB_FPREG_F28 * SZREG)($c3)
	cldc1		$f29, zero, (_JB_FPREG_F29 * SZREG)($c3)
	cldc1		$f30, zero, (_JB_FPREG_F30 * SZREG)($c3)
	cldc1		$f31, zero, (_JB_FPREG_F31 * SZREG)($c3)
#endif	/* ! __mips_soft_float */
	clc		$c11, zero, _JB_CHERI_OFFSET(C11)($c3)
	clc		$c12, zero, _JB_CHERI_OFFSET(C12)($c3)
	clc		$c13, zero, _JB_CHERI_OFFSET(C13)($c3)
	clc		$c14, zero, _JB_CHERI_OFFSET(C14)($c3)
	clc		$c15, zero, _JB_CHERI_OFFSET(C15)($c3)
	clc		$c16, zero, _JB_CHERI_OFFSET(C16)($c3)
	clc		$c17, zero, _JB_CHERI_OFFSET(C17)($c3)
	clc		$c18, zero, _JB_CHERI_OFFSET(C18)($c3)
	clc		$c19, zero, _JB_CHERI_OFFSET(C19)($c3)
	clc		$c20, zero, _JB_CHERI_OFFSET(C20)($c3)
	clc		$c21, zero, _JB_CHERI_OFFSET(C21)($c3)
	clc		$c22, zero, _JB_CHERI_OFFSET(C22)($c3)
	clc		$c23, zero, _JB_CHERI_OFFSET(C23)($c3)
	clc		$c24, zero, _JB_CHERI_OFFSET(C24)($c3)
	clc		$c25, zero, _JB_CHERI_OFFSET(C25)($c3)
	clc		$c4, zero, _JB_CHERI_OFFSET(DDC)($c3)
	csetdefault	$c4

	/* Install $a0 as the return value from setjmp(). */
	move		v0, a0
	PIC_RETURN()

botch:
	/*
	 * We know we aren't returning so we don't care about restoring
	 * our caller's GP.
	 */
	// ld		v1, 0(zero)
	PIC_SAVE_GLOBALS_POINTER(CALLFRAME_CGP)
	PIC_CALL(longjmperror)
	PIC_RESTORE_GLOBALS_POINTER(CALLFRAME_CGP)
	PIC_TAILCALL(abort)
END(_longjmp)
