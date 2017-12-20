#!/bin/bash
#
# https://www.usps.com/business/web-tools-apis/general-api-developer-guide.htm#_Toc423593926

quiet(){ $@ >/dev/null 2>&1; }
error(){ echo >&2 $*; }
die(){ echo "got $# arguments"; error "$@"; exit 1; }
have(){ quiet command -v "$1" || die "I require ${1} but it's not here"; }

have wget
have xmllint

if [ -z "${USPS_USERID+x}" ]
then
  die $(cat <<-EOF
	The USPS user ID must be provided in the USPS_USERID environment variable.
	How about trying this:
	
	    export USPS_USERID=xxxxxxxx
	
	but replace xxxxxxxx with your USPS user ID
	EOF
	)
fi

test_endpoint='production.shippingapis.com/ShippingAPITest.dll'
endpoint='production.shippingapis.com/ShippingAPI.dll'
api='Verify'
userid="$USPS_USERID"

street=${STREET:-'10911 Alto'}
city=${CITY:-'Oak View'}
state=${STATE:-'CA'}
zip=${ZIP:-''}

payload="<AddressValidateRequest USERID=\"${userid}\"><Address ID=\"0\"><Address1></Address1>\
<Address2>${street}</Address2><City>${city}</City><State>${state}</State>\
<Zip5></Zip5><Zip4></Zip4></Address></AddressValidateRequest>"

url="http://${endpoint}?API=${api}&XML=${payload}"
wget -q -O- "$url" | xmllint --format -
