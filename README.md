# ub-benchmark-infra
Collection of scripts used for benchmarking various systems against UB
optimizations.

# Useful information
To create a new benchmark for phoronix-test-suite (PTS) you need to use
the template found in template/. The template is a modified
compress-pbzip2. Modify it as per your use case, put the modified
template/ in /var/lib/phoronix-test-suite/test-profiles/local/ (at least
that is for Debian 11) and run:
```
phoronix-test-suite force-install yourtestsuite
```

Read the content of the files in template/ if you want to understand
what they are doing.

If you want to install it with your compiler configuration run:
```
CC=/path/to/c/compiler CXX=/path/to/cpp/compiler CFLAGS='-f1 -f2'
CXXFLAGS='-f3 -f4' phoronix-test-suite force-install yourtestsuite
```

Then to run the benchmark run:
```
phoronix-test-suite benchmark yourtestsuite
```

To delete a benchmark run:
```
rm -rf /var/lib/phoronix-test-suite/installed-tests/local/yourtestsuite
rm -rf /var/lib/phoronix-test-suite/test-profiles/local/yourtestsuite
```

# UB benchmarking algorithm
```
for ts in test-suites
	res = {}
	for ub in undef_behaviors:
		compile_testsuite(ts, {compiler, ub})
		run_testsuite(ts)
		res += fetch_testsuite_results()
	compare_results(res)
```

The only problem that I see here is that at one moment I will want to
combine multiple UBs to test their impact. I don't want to try all
combinations of UBs, instead it would be helpful to do an analysis to
see what UBs are required to be tested.

# Filtered test suites
We don't need to benchmark all the tests provided by phoronix. We need
to filter them so that we get only the ones that are compiled with a C
compiler. Now the question is: if a test is written in multiple
programming languages, do we want to benchmark it too? I would say yes
because if we see an impact the only place where it can have effect is
in the part compiled with our modified compiler.

I did a simple filtering in the tests provided by phoronix with the
following command:
```
git clone https://github.com/phoronix-test-suite/test-profiles.git && cd test-profiles && grep -orP --include=*.xml '(?<=<ExternalDependencies>).*?(?=</ExternalDependencies>)' | grep "build-utilities"
```

The build-utilities dependency is translated in PTS into the following
two dependencies: build-essential, autoconf. There are a lot of results
for the above command.

However there is one more step before benchmarking the test profiles
against UB modifications. Some of the test profiles contain projects
that are stupid. For example take pts/compress-pbzip2, please take a
look at the makefile in http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
and notice that it overwrites the CC set in the environment. In this
case I need to manually modify the makefile and create a new test
profile. I expect this problem with other test profiles too.
