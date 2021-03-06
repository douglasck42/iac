/*
API Information:
 - Class: "aaaRadiusProvider"
 - Distinguished Name: "uni/userext/radiusext/radiusprovider-198.18.1.71"
GUI Location:
 - Admin > AAA > Authentication:RADIUS > Create RADIUS Provider
*/
resource "aci_rest" "aaaRadiusProvider_198-18-1-71" {
	path		= "/api/node/mo/uni/userext/radiusext/radiusprovider-198.18.1.71.json"
	class_name	= "aaaRadiusProvider"
	payload		= <<EOF
{
    "aaaRadiusProvider": {
        "attributes": {
            "dn": "uni/userext/radiusext/radiusprovider-198.18.1.71",
            "timeout": "5",
            "retries": "5",
            "monitorServer": "disabled",
            "key": "cisco1231",
            "authProtocol": "pap",
            "name": "198.18.1.71",
            "descr": "RADIUS Provider - 198.18.1.71.  Added by Terraform Startup Wizard.",
            "rn": "radiusprovider-198.18.1.71"
        },
        "children": [
            {
                "aaaRsSecProvToEpg": {
                    "attributes": {
                        "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                    },
                    "children": []
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "aaaUserEp"
 - Distinguished Name: "uni/userext"
GUI Location:
 - Admin > AAA > Authentication:AAA > Login Domain
*/
resource "aci_rest" "Ext_Login_RADIUS_prov-198-18-1-71" {
    depends_on  = [aci_rest.aaaRadiusProvider_198-18-1-71]
	path		= "/api/node/mo/uni/userext.json"
	class_name	= "aaaUserEp"
	payload		= <<EOF
{
    "aaaUserEp": {
        "attributes": {
            "dn": "uni/userext"
        },
        "children": [
            {
                "aaaLoginDomain": {
                    "attributes": {
                        "dn": "uni/userext/logindomain-ISE",
                        "name": "ISE",
                        "rn": "logindomain-ISE"
                    },
                    "children": [
                        {
                            "aaaDomainAuth": {
                                "attributes": {
                                    "dn": "uni/userext/logindomain-ISE/domainauth",
                                    "providerGroup": "ISE",
                                    "realm": "radius",
                                    "descr": "RADIUS Login Domain ISE. Created by Terraform Wizard.",
                                    "rn": "domainauth"
                                },
                                "children": []
                            }
                        }
                    ]
                }
            },
            {
                "aaaRadiusEp": {
                    "attributes": {
                        "dn": "uni/userext/radiusext"
                    },
                    "children": [
                        {
                            "aaaRadiusProviderGroup": {
                                "attributes": {
                                    "dn": "uni/userext/radiusext/radiusprovidergroup-ISE"
                                },
                                "children": [
                                    {
                                        "aaaProviderRef": {
                                            "attributes": {
                                                "dn": "uni/userext/radiusext/radiusprovidergroup-ISE/providerref-198.18.1.71",
                                                "order": "1",
                                                "name": "198.18.1.71",
                                                "descr": "Added RADIUS Server 198.18.1.71 - Terraform Startup Wizard"
                                            },
                                            "children": []
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        ]
    }
}
	EOF
}

