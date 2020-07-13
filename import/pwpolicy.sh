ipa pwpolicy-add all-services \
 --priority=1 \
 --maxlife=10000 \
 --minlife=0 \
 --history=0 \
 --minclasses=3 \
 --minlength=30 \
 --maxfail=10 \
 --failinterval=300 \
 --lockouttime=600

ipa pwpolicy-add all-employees \
 --priority=0 \
 --maxlife=180 \
 --minlife=0 \
 --history=3 \
 --minclasses=3 \
 --minlength=12 \
 --maxfail=10 \
 --failinterval=300 \
 --lockouttime=600
