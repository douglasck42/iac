/*
 This File will include DNS, Domain, NTP, SmartCallHome,
 SNMP, Syslog and other Fabric Policy Configurations
*/

/*
System > System Settings > BGP Route Reflector: Autonomous System Number
*/
resource "aci_rest" "bgp_as_65513" {
	path		= "/api/node/mo/uni/fabric/bgpInstP-default/as.json"
	class_name	= "bgpAsP"
	payload		= <<EOF
{
    "bgpAsP": {
        "attributes": {
            "dn": "uni/fabric/bgpInstP-default/as",
            "asn": "65513",
            "rn": "as"
        },
        "children": []
    }
}
	EOF
}

/*
System > System Settings > BGP Route Reflector: Route Reflector Nodes
*/
resource "aci_rest" "bgp_rr_101" {
	path		= "/api/node/mo/uni/fabric/bgpInstP-default/rr/node-101.json"
	class_name	= "bgpRRNodePEp"
	payload		= <<EOF
{
    "bgpRRNodePEp": {
        "attributes": {
            "dn": "uni/fabric/bgpInstP-default/rr/node-101",
            "id": "101",
            "rn": "node-101"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Global > DNS Profiles > default: Management EPG
*/
resource "aci_rest" "dns_epg_oob-default" {
	path		= "/api/node/mo/uni/fabric/dnsp-default.json"
	class_name	= "dnsRsProfileToEpg"
	payload		= <<EOF
{
    "dnsRsProfileToEpg": {
        "attributes": {
            "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Global > DNS Profiles > default: DNS Providers
*/
resource "aci_rest" "dns_198_18_1_51" {
	path		= "/api/node/mo/uni/fabric/dnsp-default/prov-[198.18.1.51].json"
	class_name	= "dnsProv"
	payload		= <<EOF
{
    "dnsProv": {
        "attributes": {
            "dn": "uni/fabric/dnsp-default/prov-[198.18.1.51]",
            "addr": "198.18.1.51",
            "preferred": "no",
            "rn": "prov-[198.18.1.51]"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Global > DNS Profiles > default: DNS Providers
*/
resource "aci_rest" "dns_198_18_1_52" {
	path		= "/api/node/mo/uni/fabric/dnsp-default/prov-[198.18.1.52].json"
	class_name	= "dnsProv"
	payload		= <<EOF
{
    "dnsProv": {
        "attributes": {
            "dn": "uni/fabric/dnsp-default/prov-[198.18.1.52]",
            "addr": "198.18.1.52",
            "preferred": "yes",
            "rn": "prov-[198.18.1.52]"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Global > DNS Profiles > default: DNS Domains
*/
resource "aci_rest" "domain_sub_example_com" {
	path		= "/api/node/mo/uni/fabric/dnsp-default/dom-[sub.example.com].json"
	class_name	= "dnsDomain"
	payload		= <<EOF
{
    "dnsDomain": {
        "attributes": {
            "dn": "uni/fabric/dnsp-default/dom-[sub.example.com]",
            "name": "sub.example.com",
            "isDefault": "yes",
            "rn": "dom-[sub.example.com]"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Global > DNS Profiles > default: DNS Domains
*/
resource "aci_rest" "domain_example_com" {
	path		= "/api/node/mo/uni/fabric/dnsp-default/dom-[example.com].json"
	class_name	= "dnsDomain"
	payload		= <<EOF
{
    "dnsDomain": {
        "attributes": {
            "dn": "uni/fabric/dnsp-default/dom-[example.com]",
            "name": "example.com",
            "isDefault": "no",
            "rn": "dom-[example.com]"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > Date and Time > Policy default: NTP Servers
*/
resource "aci_rest" "ntp_198_18_1_51" {
	path		= "/api/node/mo/uni/fabric/time-default/ntpprov-198.18.1.51.json"
	class_name	= "datetimeNtpProv"
	payload		= <<EOF
{
    "datetimeNtpProv": {
        "attributes": {
            "dn": "uni/fabric/time-default/ntpprov-198.18.1.51",
            "name": "198.18.1.51",
            "preferred": "false",
            "rn": "ntpprov-198.18.1.51"
        },
        "children": [
            {
                "datetimeRsNtpProvToEpg": {
                    "attributes": {
                        "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > Date and Time > Policy default: NTP Servers
*/
resource "aci_rest" "ntp_198_18_1_52" {
	path		= "/api/node/mo/uni/fabric/time-default/ntpprov-198.18.1.52.json"
	class_name	= "datetimeNtpProv"
	payload		= <<EOF
{
    "datetimeNtpProv": {
        "attributes": {
            "dn": "uni/fabric/time-default/ntpprov-198.18.1.52",
            "name": "198.18.1.52",
            "preferred": "true",
            "rn": "ntpprov-198.18.1.52"
        },
        "children": [
            {
                "datetimeRsNtpProvToEpg": {
                    "attributes": {
                        "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
Admin > External Data Collectors > Monitoring Destinations > Smart Callhome > [Smart CallHome Dest Group]
*/
resource "aci_rest" "SmartCallHome_dg" {
	path		= "/api/node/mo/uni/fabric/smartgroup-SmartCallHome_dg.json"
	class_name	= "callhomeSmartGroup"
	payload		= <<EOF
{
    "callhomeSmartGroup": {
        "attributes": {
            "dn": "uni/fabric/smartgroup-SmartCallHome_dg",
            "name": "SmartCallHome_dg",
            "rn": "smartgroup-SmartCallHome_dg"
        },
        "children": [
            {
                "callhomeProf": {
                    "attributes": {
                        "dn": "uni/fabric/smartgroup-SmartCallHome_dg/prof",
                        "port": "25",
                        "from": "cust-aci-fabric@example.com",
                        "replyTo": "network-ops@example.com",
                        "email": "network-ops@example.com",
                        "phone": "+1 408-555-5555",
                        "contact": "25",
                        "addr": "5555 Some Streat Some City, CA 95000",
                        "contract": "5555555",
                        "customer": "5555555",
                        "site": "555555",
                        "rn": "prof"
                    },
                    "children": [
                        {
                            "callhomeSmtpServer": {
                                "attributes": {
                                    "dn": "uni/fabric/smartgroup-SmartCallHome_dg/prof/smtp",
                                    "host": "cisco-smtp.example.com",
                                    "rn": "smtp"
                                },
                                "children": [
                                    {
                                        "fileRsARemoteHostToEpg": {
                                            "attributes": {
                                                "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                                            },
                                            "children": []
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            },
            {
                "callhomeSmartDest": {
                    "attributes": {
                        "dn": "uni/fabric/smartgroup-SmartCallHome_dg/smartdest-SCH_Receiver",
                        "name": "SCH_Receiver",
                        "email": "network-ops@example.com,
                        "format": "short-txt",
                        "rn": "smartdest-SCH_Receiver"
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
Fabric > Fabric Policies > Policies > Monitoring > Common Policies > Callhome/Smart Callhome/SNMP/Syslog/TACACS:Smart CallHome > Create Smart CallHome Source
*/
resource "aci_rest" "callhomeSmartSrc" {
	path		= "/api/node/mo/uni/infra/moninfra-default/smartchsrc.json"
	class_name	= "callhomeSmartSrc"
	payload		= <<EOF
{
    "callhomeSmartSrc": {
        "attributes": {
            "dn": "uni/infra/moninfra-default/smartchsrc",
            "rn": "smartchsrc"
        },
        "children": [
            {
                "callhomeRsSmartdestGroup": {
                    "attributes": {
                        "tDn": "uni/fabric/smartgroup-SmartCallHome_dg"
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
Fabric > Fabric Policies > Policies > Pod > SNMP > default > Client Group Policies: [Client Group] > Client Entries
*/
resource "aci_rest" "snmp_client_198_18_1_61" {
	depends_on  = [aci_rest.snmp_cg]
	path		= "/api/node/mo/uni/fabric/snmppol-default/clgrp-Out-of-Band/client-[198.18.1.61].json"
	class_name	= "snmpClientP"
	payload		= <<EOF
{
    "snmpClientP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/clgrp-Out-of-Band/client-[198.18.1.61]",
            "name": "snmp-server1",
            "addr": "198.18.1.61",
            "rn": "client-198.18.1.61"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default > Client Group Policies: [Client Group] > Client Entries
*/
resource "aci_rest" "snmp_client_198_18_1_62" {
	depends_on  = [aci_rest.snmp_cg]
	path		= "/api/node/mo/uni/fabric/snmppol-default/clgrp-Out-of-Band/client-[198.18.1.62].json"
	class_name	= "snmpClientP"
	payload		= <<EOF
{
    "snmpClientP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/clgrp-Out-of-Band/client-[198.18.1.62]",
            "name": "snmp-server2",
            "addr": "198.18.1.62",
            "rn": "client-198.18.1.62"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default > Community Policies
*/
resource "aci_rest" "snmp_comm_read_access" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/community-read_access.json"
	class_name	= "snmpCommunityP"
	payload		= <<EOF
{
    "snmpCommunityP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/community-read_access",
            "descr": "Community String 1",
            "name": "read_access",
            "rn": "community-read_access"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default > Community Policies
*/
resource "aci_rest" "snmp_comm_will-this-work" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/community-will-this-work.json"
	class_name	= "snmpCommunityP"
	payload		= <<EOF
{
    "snmpCommunityP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/community-will-this-work",
            "descr": "Community String 2",
            "name": "will-this-work",
            "rn": "community-will-this-work"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: Contact/Location
*/
resource "aci_rest" "snmp_info" {
	path		= "/api/node/mo/uni/fabric/snmppol-default.json"
	class_name	= "snmpPol"
	payload		= <<EOF
{
    "snmpPol": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default",
            "descr": "This is the default SNMP Policy",
            "adminSt": "enabled",
            "contact": "cust-lab@example.com",
            "loc": "Customer Example"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: Trap Forward Servers
*/
resource "aci_rest" "snmp_trap_default_198_18_1_61" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/trapfwdserver-[198.18.1.61].json"
	class_name	= "snmpTrapFwdServerP"
	payload		= <<EOF
{
    "snmpTrapFwdServerP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/trapfwdserver-[198.18.1.61]",
            "addr": "198.18.1.61",
            "port": "162"
        },
        "children": []
    }
}
	EOF
}

/*
Admin > External Data Collectors > Monitoring Destinations > SNMP > [SNMP Dest Group]
*/
resource "aci_rest" "snmp_trap_dest_198_18_1_61" {
	path		= "/api/node/mo/uni/fabric/snmpgroup-SNMP-TRAP_dg.json"
	class_name	= "snmpGroup"
	payload		= <<EOF
{
    "snmpGroup": {
        "attributes": {
            "dn": "uni/fabric/snmpgroup-SNMP-TRAP_dg",
            "descr": "SNMP Trap Destination Group - Created by Terraform Startup Script",
            "name": "SNMP-TRAP_dg",
            "rn": "snmpgroup-SNMP-TRAP_dg"
        },
        "children": [
            {
                "snmpTrapDest": {
                    "attributes": {
                        "dn": "uni/fabric/snmpgroup-SNMP-TRAP_dg/trapdest-198.18.1.61-port-162",
                        "ver": "v2c",
                        "host": "198.18.1.61",
                        "port": "162",
                        "secName": "read_access",
                        "v3SecLvl": "noauth",
                        "rn": "trapdest-198.18.1.61-port-162"
                    },
                    "children": [
                        {
                            "fileRsARemoteHostToEpg": {
                                "attributes": {
                                    "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                                }
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

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: Trap Forward Servers
*/
resource "aci_rest" "snmp_trap_default_198_18_1_62" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/trapfwdserver-[198.18.1.62].json"
	class_name	= "snmpTrapFwdServerP"
	payload		= <<EOF
{
    "snmpTrapFwdServerP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/trapfwdserver-[198.18.1.62]",
            "addr": "198.18.1.62",
            "port": "162"
        },
        "children": []
    }
}
	EOF
}

/*
Admin > External Data Collectors > Monitoring Destinations > SNMP > [SNMP Dest Group]
*/
resource "aci_rest" "snmp_trap_dest_198_18_1_62" {
	path		= "/api/node/mo/uni/fabric/snmpgroup-SNMP-TRAP_dg.json"
	class_name	= "snmpGroup"
	payload		= <<EOF
{
    "snmpGroup": {
        "attributes": {
            "dn": "uni/fabric/snmpgroup-SNMP-TRAP_dg",
            "descr": "SNMP Trap Destination Group - Created by Terraform Startup Script",
            "name": "SNMP-TRAP_dg",
            "rn": "snmpgroup-SNMP-TRAP_dg"
        },
        "children": [
            {
                "snmpTrapDest": {
                    "attributes": {
                        "dn": "uni/fabric/snmpgroup-SNMP-TRAP_dg/trapdest-198.18.1.62-port-162",
                        "ver": "v3",
                        "host": "198.18.1.62",
                        "port": "162",
                        "secName": "read_access",
                        "v3SecLvl": "priv",
                        "rn": "trapdest-198.18.1.62-port-162"
                    },
                    "children": [
                        {
                            "fileRsARemoteHostToEpg": {
                                "attributes": {
                                    "tDn": "uni/tn-mgmt/mgmtp-default/oob-default"
                                }
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

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: SNMP V3 Users
*/
resource "aci_rest" "snmp_user_cisco_user1" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/user-cisco_user1.json"
	class_name	= "snmpUserP"
	payload		= <<EOF
{
    "snmpUserP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/user-cisco_user1",
            "name": "cisco_user1",
            "privType": "aes-128",
            "privKey": "cisco123",
            "authType": "hmac-sha1-96",
            "authKey": "cisco123"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: SNMP V3 Users
*/
resource "aci_rest" "snmp_user_cisco_user2" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/user-cisco_user2.json"
	class_name	= "snmpUserP"
	payload		= <<EOF
{
    "snmpUserP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/user-cisco_user2",
            "name": "cisco_user2",
            "privType": "des",
            "privKey": "cisco123",
            "authKey": "cisco123"
        },
        "children": []
    }
}
	EOF
}

/*
Fabric > Fabric Policies > Policies > Pod > SNMP > default: SNMP V3 Users
*/
resource "aci_rest" "snmp_user_cisco_user3" {
	path		= "/api/node/mo/uni/fabric/snmppol-default/user-cisco_user3.json"
	class_name	= "snmpUserP"
	payload		= <<EOF
{
    "snmpUserP": {
        "attributes": {
            "dn": "uni/fabric/snmppol-default/user-cisco_user3",
            "name": "cisco_user3",
            "privType": "none",
            "privKey": "",
            "authType": "hmac-sha1-96",
            "authKey": "cisco123"
        },
        "children": []
    }
}
	EOF
}

/*
Admin > External Data Collectors > Monitoring Destinations > Syslog > [Syslog Dest Group]
*/
resource "aci_rest" "syslog_dg_default" {
	path		= "/api/node/mo/uni/fabric/slgroup-default.json"
	class_name	= "syslogGroup"
	payload		= <<EOF
{
	"syslogGroup": {
		"attributes": {
			"dn": "uni/fabric/slgroup-default",
			"name": "default",
            "format": "aci",
			"includeMilliSeconds": "true",
			"includeTimeZone": "true",
			"descr": "Default Syslog Destination Group.  Created by Terraform Startup Script",
			"rn": "slgroup-default"
		},
		"children": [
			{
				"syslogConsole": {
					"attributes": {
						"dn": "uni/fabric/slgroup-default/console",
                        "adminState": "enabled",
                        "severity": "critical",
                        "rn": "console"
					},
					"children": []
				}
			},
			{
				"syslogFile": {
					"attributes": {
						"dn": "uni/fabric/slgroup-default/file",
                        "adminState": "enabled",
                        "severity": "information",
                        "rn": "file"
					},
					"children": []
				}
			},
			{
				"syslogProf": {
					"attributes": {
						"dn": "uni/fabric/slgroup-default/prof",
						"rn": "prof"
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
Fabric > Fabric Policies > Policies > Monitoring > Common Policies > Callhome/Smart Callhome/SNMP/Syslog/TACACS:Smart CallHome > Create Syslog Source
*/
resource "aci_rest" "syslog_Src_" {
	path		= "/api/node/mo/uni/fabric/moncommon/slsrc-.json"
	class_name	= "syslogSrc"
	payload		= <<EOF
{
	"syslogSrc": {
		"attributes": {
			"dn": "uni/fabric/moncommon/slsrc-",
			"name": "",
			"incl": "faults",
            "minSev": "information",
			"rn": "slsrc-",
		},
		"children": [
			{
				"syslogRsDestGroup": {
					"attributes": {
						"tDn": "uni/fabric/slgroup-",
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
Admin > External Data Collectors > Monitoring Destinations > Syslog > [Syslog Dest Group] > Create Syslog Remote Destination
*/
resource "aci_rest" "syslog_198_18_1_61" {
	path		= "/api/node/mo/uni/fabric/slgroup-default/rdst-198.18.1.61.json"
	class_name	= "syslogRemoteDest"
	payload		= <<EOF
{
	"syslogRemoteDest": {
		"attributes": {
			"dn": "uni/fabric/slgroup-default/rdst-198.18.1.61",
			"host": "198.18.1.61",
			"name": "198.18.1.61",
			"forwardingFacility": "local7",
			"port": "514",
			"severity": "warnings",
			"rn": "rdst-198.18.1.61"
		},
		"children": [
			{
				"fileRsARemoteHostToEpg": {
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

