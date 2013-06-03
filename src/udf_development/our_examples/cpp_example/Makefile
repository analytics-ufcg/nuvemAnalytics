all:	RangeCheckingCPP.so
	g++ -D HAVE_LONG_INT_64 -I /opt/vertica/sdk/include -Wall -shared -Wno-unused-value -fPIC -o RangeCheckingCPP.so InRange.cpp /opt/vertica/sdk/include/Vertica.cpp
