/*-
 * Copyright (c) 2012-2016 Robert N. M. Watson
 * Copyright (c) 2014 SRI International
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>

#if !__has_feature(capabilities)
#error "This code requires a CHERI-aware compiler"
#endif

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/time.h>

#include <machine/cherireg.h>
#include <machine/cpuregs.h>

#include <cheri/cheri.h>
#include <cheri/cheric.h>
#include <cheri/cheri_fd.h>
#include <cheri/sandbox.h>

#include <cheritest-helper.h>
#include <err.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>

#include "cheritest.h"

void
test_copyregs(const struct cheri_test *ctp __unused)
{

	CHERI_CGETDEFAULT(2);
	CHERI_CGETDEFAULT(3);
	CHERI_CGETDEFAULT(4);
	CHERI_CGETDEFAULT(5);
	CHERI_CGETDEFAULT(6);
	CHERI_CGETDEFAULT(7);
	cheritest_success();
}

void
test_listregs(const struct cheri_test *ctp __unused)
{

	/*
	 * Because of the assembly generated by CP2_CR_GET(), can't use a loop
	 * -- register numbers must be available at compile-time.
	 */
	printf("CP2 registers:\n");
	CHERI_CAPREG_PRINT(0);
	CHERI_CAPREG_PRINT(1);
	CHERI_CAPREG_PRINT(2);
	CHERI_CAPREG_PRINT(3);
	CHERI_CAPREG_PRINT(4);
	CHERI_CAPREG_PRINT(5);
	CHERI_CAPREG_PRINT(6);
	CHERI_CAPREG_PRINT(7);
	CHERI_CAPREG_PRINT(8);
	CHERI_CAPREG_PRINT(9);
	CHERI_CAPREG_PRINT(10);
	CHERI_CAPREG_PRINT(11);
	CHERI_CAPREG_PRINT(12);
	CHERI_CAPREG_PRINT(13);
	CHERI_CAPREG_PRINT(14);
	CHERI_CAPREG_PRINT(15);
	CHERI_CAPREG_PRINT(16);
	CHERI_CAPREG_PRINT(17);
	CHERI_CAPREG_PRINT(18);
	CHERI_CAPREG_PRINT(19);
	CHERI_CAPREG_PRINT(20);
	CHERI_CAPREG_PRINT(21);
	CHERI_CAPREG_PRINT(22);
	CHERI_CAPREG_PRINT(23);
	CHERI_CAPREG_PRINT(24);
	CHERI_CAPREG_PRINT(25);
	CHERI_CAPREG_PRINT(26);
	CHERI_PCC_PRINT();
	cheritest_success();
}

/*
 * These tests assume that the compiler and run-time libraries won't muck with
 * the global registers in question -- which is true at the time of writing.
 *
 * However, in the future, it could be that they are modified -- e.g., to
 * differentiate memory capabilities from class-type capabilities.  In that
 * case, these tests would need to check the original capability values saved
 * during process startup -- and also the new expected values.
 */
static void
check_initreg_code(__capability void *c)
{
	register_t v;

	/* Base. */
	v = cheri_getbase(c);
	if (v != CHERI_CAP_USER_CODE_BASE)
		cheritest_failure_errx("base %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_CODE_BASE);

	/* Length. */
	v = cheri_getlen(c);
	if (v != CHERI_CAP_USER_CODE_LENGTH)
		cheritest_failure_errx("length 0x%jx (expected 0x%jx)", v,
		    CHERI_CAP_USER_CODE_LENGTH);

	/* Offset. */
	v = cheri_getoffset(c);
	if (v != CHERI_CAP_USER_CODE_OFFSET)
		cheritest_failure_errx("offset %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_CODE_OFFSET);

	/* Type -- should be zero for an unsealed capability. */
	v = cheri_gettype(c);
	if (v != 0)
		cheritest_failure_errx("otype %jx (expected %jx)", v, 0);

	/* Permissions. */
	v = cheri_getperm(c);
	if (v != CHERI_CAP_USER_CODE_PERMS)
		cheritest_failure_errx("perms %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_CODE_PERMS);

	/* Sealed bit. */
	v = cheri_getsealed(c);
	if (v != 0)
		cheritest_failure_errx("sealed %jx (expected 0)", v);

	/* Tag bit. */
	v = cheri_gettag(c);
	if (v != 1)
		cheritest_failure_errx("tag %jx (expected 1)", v);
	cheritest_success();
}

static void
check_initreg_data(__capability void *c)
{
	register_t v;

	/* Base. */
	v = cheri_getbase(c);
	if (v != CHERI_CAP_USER_DATA_BASE)
		cheritest_failure_errx("base %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_BASE);

	/* Length. */
	v = cheri_getlen(c);
	if (v != CHERI_CAP_USER_DATA_LENGTH)
		cheritest_failure_errx("length 0x%jx (expected 0x%jx)", v,
		    CHERI_CAP_USER_DATA_LENGTH);

	/* Offset. */
	v = cheri_getoffset(c);
	if (v != CHERI_CAP_USER_DATA_OFFSET)
		cheritest_failure_errx("offset %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_OFFSET);

	/* Type -- should be zero for an unsealed capability. */
	v = cheri_gettype(c);
	if (v != 0)
		cheritest_failure_errx("otype %jx (expected %jx)", v, 0);

	/* Permissions. */
	v = cheri_getperm(c);
	if (v != CHERI_CAP_USER_DATA_PERMS)
		cheritest_failure_errx("perms %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_PERMS);

	/* Sealed bit. */
	v = cheri_getsealed(c);
	if (v != 0)
		cheritest_failure_errx("sealed %jx (expected 0)", v);

	/* Tag bit. */
	v = cheri_gettag(c);
	if (v != 1)
		cheritest_failure_errx("tag %jx (expected 1)", v);
	cheritest_success();
}

void
test_initregs_default(const struct cheri_test *ctp __unused)
{

	check_initreg_data(cheri_getdefault());
}

/*
 * Outside of CheriABI, we expect the stack capability to be the same as the
 * default data capability, since we need the stack pointer ($sp) to be usable
 * relative to either capability.
 *
 * Inside CheriABI, the stack capability should contain only the specific
 * address range used for the stack.  We could try to capture the same logic
 * here as used in the kernel to select the stack -- but it seems more
 * sensible to simply assert that the capability is not the same as the
 * default capability for the MIPS ABI.
 */
void
test_initregs_stack(const struct cheri_test *ctp __unused)
#ifndef __CHERI_PURE_CAPABILITY__
{

	check_initreg_data(cheri_getstack());
}
#else
{
	__capability void *c = cheri_getstack();
	register_t v;

	/* Base. */
	v = cheri_getbase(c);
	if (v == CHERI_CAP_USER_DATA_BASE)
		cheritest_failure_errx("base %jx (did not expect %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_BASE);

	/* Length. */
	v = cheri_getlen(c);
	if (v == CHERI_CAP_USER_DATA_LENGTH)
		cheritest_failure_errx("length 0x%jx (did not expect 0x%jx)",
		    v, CHERI_CAP_USER_DATA_LENGTH);

	/* Offset. */
	v = cheri_getoffset(c);
	if (v != CHERI_CAP_USER_DATA_OFFSET)
		cheritest_failure_errx("offset %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_OFFSET);

	/* Type -- should be zero for an unsealed capability. */
	v = cheri_gettype(c);
	if (v != 0)
		cheritest_failure_errx("otype %jx (expected %jx)", v, 0);

	/* Permissions. */
	v = cheri_getperm(c);
	if (v != CHERI_CAP_USER_DATA_PERMS)
		cheritest_failure_errx("perms %jx (expected %jx)", v,
		    (uintmax_t)CHERI_CAP_USER_DATA_PERMS);

	/* Sealed bit. */
	v = cheri_getsealed(c);
	if (v != 0)
		cheritest_failure_errx("sealed %jx (expected 0)", v);

	/* Tag bit. */
	v = cheri_gettag(c);
	if (v != 1)
		cheritest_failure_errx("tag %jx (expected 1)", v);
	cheritest_success();
}
#endif

void
test_initregs_idc(const struct cheri_test *ctp __unused)
{

	check_initreg_data(cheri_getidc());
}

void
test_initregs_pcc(const struct cheri_test *ctp __unused)
{
	__capability void *c;

	/* $pcc includes $pc, so clear that for the purposes of the check. */
	c = cheri_getpcc();
	c = cheri_setoffset(c, 0);
	check_initreg_code(c);
}
