#!/bin/bash
#
# https://www.usps.com/business/web-tools-apis/general-api-developer-guide.htm#_Toc423593926

here=$(cd $(dirname $BASH_SOURCE[0]); echo $PWD)

quiet(){ $@ >/dev/null 2>&1; }
error(){ echo >&2 $*; }
die(){ echo "got $# arguments"; error "$@"; exit 1; }
have(){ quiet command -v "$1" || die "I require ${1} but it's not here"; }
usage(){
  cat <<-EOF

	usage: STREET='929 Colorado' CITY='Santa Monica' STATE=CA ${BASH_SOURCE[0]}
	
	The USPS user ID must be provided in the USPS_USERID environment variable.
	How about trying this:
	
	    export USPS_USERID=xxxxxxxx
	
	visit https://www.usps.com/business/web-tools-apis/welcome.htm to
	request a USPS Web Tools API username and password.
	
	EOF
  exit 1
}

have wget
have xmllint

[ -z "${USPS_USERID+x}" ] && usage

test_endpoint='production.shippingapis.com/ShippingAPITest.dll'
endpoint='production.shippingapis.com/ShippingAPI.dll'
api='Verify'
userid="$USPS_USERID"

# city and state are required. street is optional, but you probably want it
[ -z "${STREET+x}" ] && usage
[ -z "${CITY+x}" ] && usage
[ -z "${STATE+x}" ] && usage
street=$STREET
city=$CITY
state=$STATE
zip=${ZIP:-''}

payload="<AddressValidateRequest USERID=\"${userid}\"><Address ID=\"0\"><Address1></Address1>\
<Address2>${street}</Address2><City>${city}</City><State>${state}</State>\
<Zip5>${zip}</Zip5><Zip4></Zip4></Address></AddressValidateRequest>"

url="http://${endpoint}?API=${api}&XML=${payload}"
wget -q -O- "$url" | xmllint --format -
