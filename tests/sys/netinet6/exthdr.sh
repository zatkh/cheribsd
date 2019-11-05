# $FreeBSD$
#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2019 Netflix, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

. $(atf_get_srcdir)/../common/vnet.subr

atf_test_case "exthdr" "cleanup"
exthdr_head() {

	atf_set descr 'Test IPv6 fragmentation code'
	atf_set require.user root
	atf_set require.progs scapy
}

exthdr_body() {

	if [ "$(atf_config_get ci false)" = "true" ] && \
		[ "$(uname -p)" = "i386" ]; then
		atf_skip "https://bugs.freebsd.org/241493"
	fi

	ids=65533
	id=`printf "%x" ${ids}`
	if [ $$ -gt 65535 ]; then
		xl=`printf "%x" $(($$ - 65535))`
		yl="1"
	else
		xl=`printf "%x" $$`
		yl=""
	fi

	vnet_init

	ip6a="2001:db8:6666:0000:${yl}:${id}:1:${xl}"
	ip6b="2001:db8:6666:0000:${yl}:${id}:2:${xl}"

	epair=$(vnet_mkepair)
	ifconfig ${epair}a mtu 131071 up
	ifconfig ${epair}a inet6 ${ip6a}/64

	jname="v6t-${id}-${yl}-${xl}"
	vnet_mkjail ${jname} ${epair}b
	jexec ${jname} ifconfig ${epair}b mtu 131071 up
	jexec ${jname} ifconfig ${epair}b inet6 ${ip6b}/64

	# Let IPv6 ND do its thing.
	#ping6 -q -c 1 ff02::1%${epair}a
	#ping6 -q -c 1 ${ip6b}
	sleep 3

	# Clear statistics.
	jexec ${jname} netstat -z -s > /dev/null

	# Run fragment tests.
	pyname=$(atf_get ident)
	pyname=${pyname%*_[0-9]}

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b}

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--hbh

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--rh

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--frag6

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--dest

	atf_check -s exit:0 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--hbh --dest

	atf_check -s exit:1 $(atf_get_srcdir)/${pyname}.py \
		--sendif ${epair}a --recvif ${epair}a \
		--src ${ip6a} --to  ${ip6b} \
		--dest --hbhbad

}

exthdr_cleanup() {

	vnet_cleanup
}

atf_init_test_cases()
{

	atf_add_test_case "exthdr"
}

# end
