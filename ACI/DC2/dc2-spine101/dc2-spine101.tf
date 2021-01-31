# Use this Resource File to Register dc2-spine101 with node id 101 to the Fabric
# Requirements are:
# serial: Actual Serial Number of the switch.
# name: Hostname you want to assign.
# node_id: unique ID used to identify the switch in the APIC.
#   in the "Cisco ACI Object Naming and Numbering: Best Practice
#   The recommendation is that the Spines should be 101-199
#   and leafs should start at 200+ thru 4000.  As the number of
#   spines should always be less than the number of leafs
#   https://www.cisco.com/c/en/us/td/docs/switches/datacenter/aci/apic/sw/kb/b-Cisco-ACI-Naming-and-Numbering.html#id_107280
# node_type: uremote-leaf-wan or unspecified.
# role: spine, leaf.
# pod_id: Typically this will be 1 unless you are running multipod.

/*
API Information:
 - Class: "fabricNode"
 - Distinguished Name: "topology/pod-1/node-101"
GUI Location:
 - Fabric > Access Policies > Inventory > Fabric Membership:[Registered Nodes or Nodes Pending Registration]
*/
resource "aci_fabric_node_member" "dc2-spine101" {
	serial    = "TEP-1-103"
	name      = "dc2-spine101"
	node_id   = "101"
	node_type = "unspecified"
	role      = "spine"
	pod_id    = "1"
}

/*
API Information:
 - Class: "maintMaintGrp"
 - Distinguished Name: "uni/fabric/maintgrp-switch_MgA"
GUI Location:
 - Admin > Firmware > Nodes:MgA
*/
resource "aci_rest" "maint_grp_dc2-spine101" {
	path		= "/api/node/mo/uni/fabric/maintgrp-switch_MgA.json"
	class_name	= "maintMaintGrp"
	payload		= <<EOF
{
    "maintMaintGrp": {
        "attributes": {
            "dn": "uni/fabric/maintgrp-switch_MgA"
        },
        "children": [
            {
                "fabricNodeBlk": {
                    "attributes": {
                        "dn": "uni/fabric/maintgrp-switch_MgA/nodeblk-blk101-101",
                        "name": "blk101-101",
                        "from_": "101",
                        "to_": "101",
                        "rn": "nodeblk-blk101-101"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraAccPortGrp"
 - Distinguished Name: "uni/infra/funcprof/accportgrp-dc2-spine101"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > dc2-spine101
*/
resource "aci_spine_interface_profile" "dc2-spine101" {
	name   = "dc2-spine101"
}

/*
API Information:
 - Class: "infraSpineP"
 - Distinguished Name: "uni/infra/spprof-dc2-spine101"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-spine101
*/
resource "aci_spine_profile" "dc2-spine101" {
	name   = "dc2-spine101"
}

/*
API Information:
 - Class: "infraSpineS"
 - Distinguished Name: "uni/infra/spprof-dc2-spine101/spines-dc2-spine101-typ-range"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-spine101: Spine Selectors [dc2-spine101]
*/
resource "aci_spine_switch_association" "dc2-spine101" {
	spine_profile_dn               = aci_spine_profile.dc2-spine101.id
	name                           = "dc2-spine101"
	spine_switch_association_type  = "range"
}

/*
API Information:
 - Class: "infraRsSpAccPortP"
 - Distinguished Name: "uni/infra/spaccportprof-dc2-spine101"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-spine101: Spine Interface Selector Profiles: dc2-spine101
*/
resource "aci_spine_port_selector" "dc2-spine101" {
	spine_profile_dn   = aci_spine_profile.dc2-spine101.id
	tdn                = aci_spine_interface_profile.dc2-spine101.id
}

/*
API Information:
 - Class: "infraSpineS"
 - Distinguished Name: "uni/infra/spprof-dc2-spine101/spines-dc2-spine101-typ-range"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-spine101: Spine Selectors Policy Group: default
*/
resource "aci_rest" "spine_policy_group_dc2-spine101" {
	depends_on  = [aci_spine_profile.dc2-spine101]
	path		= "/api/node/mo/uni/infra/spprof-dc2-spine101/spines-dc2-spine101-typ-range.json"
	class_name	= "infraSpineS"
	payload		= <<EOF
{
    "infraSpineS": {
        "attributes": {
            "dn": "uni/infra/spprof-dc2-spine101/spines-dc2-spine101-typ-range"
        },
        "children": [
            {
                "infraRsSpineAccNodePGrp": {
                    "attributes": {
                        "tDn": "uni/infra/funcprof/spaccnodepgrp-default"
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
 - Class: "mgmtRsInBStNode"
 - Distinguished Name: "uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-1/node-101]"
GUI Location:
 - Tenants > mgmt > Node Management Addresses > Static Node Management Addresses
*/
resource "aci_rest" "inb_mgmt_dc2-spine101_198-18-12-1" {
	depends_on  = [aci_application_epg.inb_default]
	path		= "/api/node/mo/uni/tn-mgmt.json"
	class_name	= "mgmtRsInBStNode"
	payload		= <<EOF
{
    "mgmtRsInBStNode": {
        "attributes": {
            "dn": "uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-1/node-101]",
            "addr": "198.18.12.101/24",
            "gw": "198.18.12.1",
            "tDn": "topology/pod-1/node-101",
            "v6Addr": "::",
            "v6Gw": "::"
        }
    }
}
	EOF
}

/*
API Information:
 - Class: "mgmtRsOoBStNode"
 - Distinguished Name: "uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-dc2-spine101]"
GUI Location:
 - Tenants > mgmt > Node Management Addresses > Static Node Management Addresses
*/
resource "aci_rest" "oob_mgmt_dc2-spine101_198-18-2-1" {
	path		= "/api/node/mo/uni/tn-mgmt.json"
	class_name	= "mgmtRsOoBStNode"
	payload		= <<EOF
{
    "mgmtRsOoBStNode": {
        "attributes": {
            "dn": "uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-dc2-spine101]",
            "addr": "198.18.2.101/24",
            "gw": "198.18.2.1",
            "tDn": "topology/pod-1/node-dc2-spine101",
            "v6Addr": "::",
            "v6Gw": "::"
        }
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-01-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-01" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-01-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-01-typ-range",
            "name": "Eth1-01",
            "rn": "shports-Eth1-01-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-01-typ-range/portblk-Eth1-01",
                        "fromCard": "1",
                        "fromPort": "1",
                        "toCard": "1",
                        "toPort": "1",
                        "name": "Eth1-01",
                        "rn": "portblk-Eth1-01"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-02-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-02" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-02-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-02-typ-range",
            "name": "Eth1-02",
            "rn": "shports-Eth1-02-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-02-typ-range/portblk-Eth1-02",
                        "fromCard": "1",
                        "fromPort": "2",
                        "toCard": "1",
                        "toPort": "2",
                        "name": "Eth1-02",
                        "rn": "portblk-Eth1-02"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-03-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-03" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-03-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-03-typ-range",
            "name": "Eth1-03",
            "rn": "shports-Eth1-03-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-03-typ-range/portblk-Eth1-03",
                        "fromCard": "1",
                        "fromPort": "3",
                        "toCard": "1",
                        "toPort": "3",
                        "name": "Eth1-03",
                        "rn": "portblk-Eth1-03"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-04-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-04" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-04-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-04-typ-range",
            "name": "Eth1-04",
            "rn": "shports-Eth1-04-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-04-typ-range/portblk-Eth1-04",
                        "fromCard": "1",
                        "fromPort": "4",
                        "toCard": "1",
                        "toPort": "4",
                        "name": "Eth1-04",
                        "rn": "portblk-Eth1-04"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-05-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-05" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-05-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-05-typ-range",
            "name": "Eth1-05",
            "rn": "shports-Eth1-05-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-05-typ-range/portblk-Eth1-05",
                        "fromCard": "1",
                        "fromPort": "5",
                        "toCard": "1",
                        "toPort": "5",
                        "name": "Eth1-05",
                        "rn": "portblk-Eth1-05"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-06-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-06" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-06-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-06-typ-range",
            "name": "Eth1-06",
            "rn": "shports-Eth1-06-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-06-typ-range/portblk-Eth1-06",
                        "fromCard": "1",
                        "fromPort": "6",
                        "toCard": "1",
                        "toPort": "6",
                        "name": "Eth1-06",
                        "rn": "portblk-Eth1-06"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-07-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-07" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-07-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-07-typ-range",
            "name": "Eth1-07",
            "rn": "shports-Eth1-07-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-07-typ-range/portblk-Eth1-07",
                        "fromCard": "1",
                        "fromPort": "7",
                        "toCard": "1",
                        "toPort": "7",
                        "name": "Eth1-07",
                        "rn": "portblk-Eth1-07"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-08-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-08" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-08-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-08-typ-range",
            "name": "Eth1-08",
            "rn": "shports-Eth1-08-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-08-typ-range/portblk-Eth1-08",
                        "fromCard": "1",
                        "fromPort": "8",
                        "toCard": "1",
                        "toPort": "8",
                        "name": "Eth1-08",
                        "rn": "portblk-Eth1-08"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-09-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-09" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-09-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-09-typ-range",
            "name": "Eth1-09",
            "rn": "shports-Eth1-09-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-09-typ-range/portblk-Eth1-09",
                        "fromCard": "1",
                        "fromPort": "9",
                        "toCard": "1",
                        "toPort": "9",
                        "name": "Eth1-09",
                        "rn": "portblk-Eth1-09"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-10-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-10" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-10-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-10-typ-range",
            "name": "Eth1-10",
            "rn": "shports-Eth1-10-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-10-typ-range/portblk-Eth1-10",
                        "fromCard": "1",
                        "fromPort": "10",
                        "toCard": "1",
                        "toPort": "10",
                        "name": "Eth1-10",
                        "rn": "portblk-Eth1-10"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-11-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-11" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-11-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-11-typ-range",
            "name": "Eth1-11",
            "rn": "shports-Eth1-11-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-11-typ-range/portblk-Eth1-11",
                        "fromCard": "1",
                        "fromPort": "11",
                        "toCard": "1",
                        "toPort": "11",
                        "name": "Eth1-11",
                        "rn": "portblk-Eth1-11"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-12-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-12" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-12-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-12-typ-range",
            "name": "Eth1-12",
            "rn": "shports-Eth1-12-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-12-typ-range/portblk-Eth1-12",
                        "fromCard": "1",
                        "fromPort": "12",
                        "toCard": "1",
                        "toPort": "12",
                        "name": "Eth1-12",
                        "rn": "portblk-Eth1-12"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-13-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-13" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-13-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-13-typ-range",
            "name": "Eth1-13",
            "rn": "shports-Eth1-13-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-13-typ-range/portblk-Eth1-13",
                        "fromCard": "1",
                        "fromPort": "13",
                        "toCard": "1",
                        "toPort": "13",
                        "name": "Eth1-13",
                        "rn": "portblk-Eth1-13"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-14-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-14" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-14-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-14-typ-range",
            "name": "Eth1-14",
            "rn": "shports-Eth1-14-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-14-typ-range/portblk-Eth1-14",
                        "fromCard": "1",
                        "fromPort": "14",
                        "toCard": "1",
                        "toPort": "14",
                        "name": "Eth1-14",
                        "rn": "portblk-Eth1-14"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-15-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-15" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-15-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-15-typ-range",
            "name": "Eth1-15",
            "rn": "shports-Eth1-15-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-15-typ-range/portblk-Eth1-15",
                        "fromCard": "1",
                        "fromPort": "15",
                        "toCard": "1",
                        "toPort": "15",
                        "name": "Eth1-15",
                        "rn": "portblk-Eth1-15"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-16-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-16" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-16-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-16-typ-range",
            "name": "Eth1-16",
            "rn": "shports-Eth1-16-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-16-typ-range/portblk-Eth1-16",
                        "fromCard": "1",
                        "fromPort": "16",
                        "toCard": "1",
                        "toPort": "16",
                        "name": "Eth1-16",
                        "rn": "portblk-Eth1-16"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-17-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-17" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-17-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-17-typ-range",
            "name": "Eth1-17",
            "rn": "shports-Eth1-17-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-17-typ-range/portblk-Eth1-17",
                        "fromCard": "1",
                        "fromPort": "17",
                        "toCard": "1",
                        "toPort": "17",
                        "name": "Eth1-17",
                        "rn": "portblk-Eth1-17"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-18-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-18" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-18-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-18-typ-range",
            "name": "Eth1-18",
            "rn": "shports-Eth1-18-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-18-typ-range/portblk-Eth1-18",
                        "fromCard": "1",
                        "fromPort": "18",
                        "toCard": "1",
                        "toPort": "18",
                        "name": "Eth1-18",
                        "rn": "portblk-Eth1-18"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-19-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-19" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-19-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-19-typ-range",
            "name": "Eth1-19",
            "rn": "shports-Eth1-19-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-19-typ-range/portblk-Eth1-19",
                        "fromCard": "1",
                        "fromPort": "19",
                        "toCard": "1",
                        "toPort": "19",
                        "name": "Eth1-19",
                        "rn": "portblk-Eth1-19"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-20-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-20" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-20-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-20-typ-range",
            "name": "Eth1-20",
            "rn": "shports-Eth1-20-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-20-typ-range/portblk-Eth1-20",
                        "fromCard": "1",
                        "fromPort": "20",
                        "toCard": "1",
                        "toPort": "20",
                        "name": "Eth1-20",
                        "rn": "portblk-Eth1-20"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-21-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-21" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-21-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-21-typ-range",
            "name": "Eth1-21",
            "rn": "shports-Eth1-21-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-21-typ-range/portblk-Eth1-21",
                        "fromCard": "1",
                        "fromPort": "21",
                        "toCard": "1",
                        "toPort": "21",
                        "name": "Eth1-21",
                        "rn": "portblk-Eth1-21"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-22-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-22" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-22-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-22-typ-range",
            "name": "Eth1-22",
            "rn": "shports-Eth1-22-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-22-typ-range/portblk-Eth1-22",
                        "fromCard": "1",
                        "fromPort": "22",
                        "toCard": "1",
                        "toPort": "22",
                        "name": "Eth1-22",
                        "rn": "portblk-Eth1-22"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-23-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-23" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-23-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-23-typ-range",
            "name": "Eth1-23",
            "rn": "shports-Eth1-23-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-23-typ-range/portblk-Eth1-23",
                        "fromCard": "1",
                        "fromPort": "23",
                        "toCard": "1",
                        "toPort": "23",
                        "name": "Eth1-23",
                        "rn": "portblk-Eth1-23"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-24-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-24" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-24-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-24-typ-range",
            "name": "Eth1-24",
            "rn": "shports-Eth1-24-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-24-typ-range/portblk-Eth1-24",
                        "fromCard": "1",
                        "fromPort": "24",
                        "toCard": "1",
                        "toPort": "24",
                        "name": "Eth1-24",
                        "rn": "portblk-Eth1-24"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-25-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-25" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-25-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-25-typ-range",
            "name": "Eth1-25",
            "rn": "shports-Eth1-25-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-25-typ-range/portblk-Eth1-25",
                        "fromCard": "1",
                        "fromPort": "25",
                        "toCard": "1",
                        "toPort": "25",
                        "name": "Eth1-25",
                        "rn": "portblk-Eth1-25"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-26-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-26" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-26-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-26-typ-range",
            "name": "Eth1-26",
            "rn": "shports-Eth1-26-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-26-typ-range/portblk-Eth1-26",
                        "fromCard": "1",
                        "fromPort": "26",
                        "toCard": "1",
                        "toPort": "26",
                        "name": "Eth1-26",
                        "rn": "portblk-Eth1-26"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-27-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-27" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-27-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-27-typ-range",
            "name": "Eth1-27",
            "rn": "shports-Eth1-27-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-27-typ-range/portblk-Eth1-27",
                        "fromCard": "1",
                        "fromPort": "27",
                        "toCard": "1",
                        "toPort": "27",
                        "name": "Eth1-27",
                        "rn": "portblk-Eth1-27"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-28-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-28" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-28-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-28-typ-range",
            "name": "Eth1-28",
            "rn": "shports-Eth1-28-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-28-typ-range/portblk-Eth1-28",
                        "fromCard": "1",
                        "fromPort": "28",
                        "toCard": "1",
                        "toPort": "28",
                        "name": "Eth1-28",
                        "rn": "portblk-Eth1-28"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-29-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-29" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-29-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-29-typ-range",
            "name": "Eth1-29",
            "rn": "shports-Eth1-29-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-29-typ-range/portblk-Eth1-29",
                        "fromCard": "1",
                        "fromPort": "29",
                        "toCard": "1",
                        "toPort": "29",
                        "name": "Eth1-29",
                        "rn": "portblk-Eth1-29"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-30-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-30" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-30-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-30-typ-range",
            "name": "Eth1-30",
            "rn": "shports-Eth1-30-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-30-typ-range/portblk-Eth1-30",
                        "fromCard": "1",
                        "fromPort": "30",
                        "toCard": "1",
                        "toPort": "30",
                        "name": "Eth1-30",
                        "rn": "portblk-Eth1-30"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-31-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-31" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-31-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-31-typ-range",
            "name": "Eth1-31",
            "rn": "shports-Eth1-31-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-31-typ-range/portblk-Eth1-31",
                        "fromCard": "1",
                        "fromPort": "31",
                        "toCard": "1",
                        "toPort": "31",
                        "name": "Eth1-31",
                        "rn": "portblk-Eth1-31"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth1-32-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth1-32" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth1-32-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-32-typ-range",
            "name": "Eth1-32",
            "rn": "shports-Eth1-32-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth1-32-typ-range/portblk-Eth1-32",
                        "fromCard": "1",
                        "fromPort": "32",
                        "toCard": "1",
                        "toPort": "32",
                        "name": "Eth1-32",
                        "rn": "portblk-Eth1-32"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-01-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-01" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-01-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-01-typ-range",
            "name": "Eth2-01",
            "rn": "shports-Eth2-01-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-01-typ-range/portblk-Eth2-01",
                        "fromCard": "2",
                        "fromPort": "1",
                        "toCard": "2",
                        "toPort": "1",
                        "name": "Eth2-01",
                        "rn": "portblk-Eth2-01"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-02-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-02" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-02-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-02-typ-range",
            "name": "Eth2-02",
            "rn": "shports-Eth2-02-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-02-typ-range/portblk-Eth2-02",
                        "fromCard": "2",
                        "fromPort": "2",
                        "toCard": "2",
                        "toPort": "2",
                        "name": "Eth2-02",
                        "rn": "portblk-Eth2-02"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-03-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-03" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-03-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-03-typ-range",
            "name": "Eth2-03",
            "rn": "shports-Eth2-03-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-03-typ-range/portblk-Eth2-03",
                        "fromCard": "2",
                        "fromPort": "3",
                        "toCard": "2",
                        "toPort": "3",
                        "name": "Eth2-03",
                        "rn": "portblk-Eth2-03"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-04-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-04" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-04-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-04-typ-range",
            "name": "Eth2-04",
            "rn": "shports-Eth2-04-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-04-typ-range/portblk-Eth2-04",
                        "fromCard": "2",
                        "fromPort": "4",
                        "toCard": "2",
                        "toPort": "4",
                        "name": "Eth2-04",
                        "rn": "portblk-Eth2-04"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-05-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-05" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-05-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-05-typ-range",
            "name": "Eth2-05",
            "rn": "shports-Eth2-05-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-05-typ-range/portblk-Eth2-05",
                        "fromCard": "2",
                        "fromPort": "5",
                        "toCard": "2",
                        "toPort": "5",
                        "name": "Eth2-05",
                        "rn": "portblk-Eth2-05"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-06-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-06" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-06-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-06-typ-range",
            "name": "Eth2-06",
            "rn": "shports-Eth2-06-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-06-typ-range/portblk-Eth2-06",
                        "fromCard": "2",
                        "fromPort": "6",
                        "toCard": "2",
                        "toPort": "6",
                        "name": "Eth2-06",
                        "rn": "portblk-Eth2-06"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-07-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-07" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-07-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-07-typ-range",
            "name": "Eth2-07",
            "rn": "shports-Eth2-07-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-07-typ-range/portblk-Eth2-07",
                        "fromCard": "2",
                        "fromPort": "7",
                        "toCard": "2",
                        "toPort": "7",
                        "name": "Eth2-07",
                        "rn": "portblk-Eth2-07"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-08-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-08" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-08-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-08-typ-range",
            "name": "Eth2-08",
            "rn": "shports-Eth2-08-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-08-typ-range/portblk-Eth2-08",
                        "fromCard": "2",
                        "fromPort": "8",
                        "toCard": "2",
                        "toPort": "8",
                        "name": "Eth2-08",
                        "rn": "portblk-Eth2-08"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-09-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-09" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-09-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-09-typ-range",
            "name": "Eth2-09",
            "rn": "shports-Eth2-09-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-09-typ-range/portblk-Eth2-09",
                        "fromCard": "2",
                        "fromPort": "9",
                        "toCard": "2",
                        "toPort": "9",
                        "name": "Eth2-09",
                        "rn": "portblk-Eth2-09"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-10-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-10" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-10-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-10-typ-range",
            "name": "Eth2-10",
            "rn": "shports-Eth2-10-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-10-typ-range/portblk-Eth2-10",
                        "fromCard": "2",
                        "fromPort": "10",
                        "toCard": "2",
                        "toPort": "10",
                        "name": "Eth2-10",
                        "rn": "portblk-Eth2-10"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-11-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-11" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-11-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-11-typ-range",
            "name": "Eth2-11",
            "rn": "shports-Eth2-11-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-11-typ-range/portblk-Eth2-11",
                        "fromCard": "2",
                        "fromPort": "11",
                        "toCard": "2",
                        "toPort": "11",
                        "name": "Eth2-11",
                        "rn": "portblk-Eth2-11"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-12-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-12" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-12-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-12-typ-range",
            "name": "Eth2-12",
            "rn": "shports-Eth2-12-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-12-typ-range/portblk-Eth2-12",
                        "fromCard": "2",
                        "fromPort": "12",
                        "toCard": "2",
                        "toPort": "12",
                        "name": "Eth2-12",
                        "rn": "portblk-Eth2-12"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-13-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-13" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-13-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-13-typ-range",
            "name": "Eth2-13",
            "rn": "shports-Eth2-13-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-13-typ-range/portblk-Eth2-13",
                        "fromCard": "2",
                        "fromPort": "13",
                        "toCard": "2",
                        "toPort": "13",
                        "name": "Eth2-13",
                        "rn": "portblk-Eth2-13"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-14-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-14" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-14-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-14-typ-range",
            "name": "Eth2-14",
            "rn": "shports-Eth2-14-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-14-typ-range/portblk-Eth2-14",
                        "fromCard": "2",
                        "fromPort": "14",
                        "toCard": "2",
                        "toPort": "14",
                        "name": "Eth2-14",
                        "rn": "portblk-Eth2-14"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-15-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-15" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-15-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-15-typ-range",
            "name": "Eth2-15",
            "rn": "shports-Eth2-15-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-15-typ-range/portblk-Eth2-15",
                        "fromCard": "2",
                        "fromPort": "15",
                        "toCard": "2",
                        "toPort": "15",
                        "name": "Eth2-15",
                        "rn": "portblk-Eth2-15"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-16-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-16" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-16-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-16-typ-range",
            "name": "Eth2-16",
            "rn": "shports-Eth2-16-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-16-typ-range/portblk-Eth2-16",
                        "fromCard": "2",
                        "fromPort": "16",
                        "toCard": "2",
                        "toPort": "16",
                        "name": "Eth2-16",
                        "rn": "portblk-Eth2-16"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-17-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-17" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-17-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-17-typ-range",
            "name": "Eth2-17",
            "rn": "shports-Eth2-17-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-17-typ-range/portblk-Eth2-17",
                        "fromCard": "2",
                        "fromPort": "17",
                        "toCard": "2",
                        "toPort": "17",
                        "name": "Eth2-17",
                        "rn": "portblk-Eth2-17"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-18-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-18" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-18-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-18-typ-range",
            "name": "Eth2-18",
            "rn": "shports-Eth2-18-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-18-typ-range/portblk-Eth2-18",
                        "fromCard": "2",
                        "fromPort": "18",
                        "toCard": "2",
                        "toPort": "18",
                        "name": "Eth2-18",
                        "rn": "portblk-Eth2-18"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-19-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-19" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-19-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-19-typ-range",
            "name": "Eth2-19",
            "rn": "shports-Eth2-19-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-19-typ-range/portblk-Eth2-19",
                        "fromCard": "2",
                        "fromPort": "19",
                        "toCard": "2",
                        "toPort": "19",
                        "name": "Eth2-19",
                        "rn": "portblk-Eth2-19"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-20-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-20" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-20-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-20-typ-range",
            "name": "Eth2-20",
            "rn": "shports-Eth2-20-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-20-typ-range/portblk-Eth2-20",
                        "fromCard": "2",
                        "fromPort": "20",
                        "toCard": "2",
                        "toPort": "20",
                        "name": "Eth2-20",
                        "rn": "portblk-Eth2-20"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-21-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-21" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-21-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-21-typ-range",
            "name": "Eth2-21",
            "rn": "shports-Eth2-21-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-21-typ-range/portblk-Eth2-21",
                        "fromCard": "2",
                        "fromPort": "21",
                        "toCard": "2",
                        "toPort": "21",
                        "name": "Eth2-21",
                        "rn": "portblk-Eth2-21"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-22-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-22" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-22-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-22-typ-range",
            "name": "Eth2-22",
            "rn": "shports-Eth2-22-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-22-typ-range/portblk-Eth2-22",
                        "fromCard": "2",
                        "fromPort": "22",
                        "toCard": "2",
                        "toPort": "22",
                        "name": "Eth2-22",
                        "rn": "portblk-Eth2-22"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-23-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-23" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-23-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-23-typ-range",
            "name": "Eth2-23",
            "rn": "shports-Eth2-23-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-23-typ-range/portblk-Eth2-23",
                        "fromCard": "2",
                        "fromPort": "23",
                        "toCard": "2",
                        "toPort": "23",
                        "name": "Eth2-23",
                        "rn": "portblk-Eth2-23"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-24-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-24" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-24-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-24-typ-range",
            "name": "Eth2-24",
            "rn": "shports-Eth2-24-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-24-typ-range/portblk-Eth2-24",
                        "fromCard": "2",
                        "fromPort": "24",
                        "toCard": "2",
                        "toPort": "24",
                        "name": "Eth2-24",
                        "rn": "portblk-Eth2-24"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-25-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-25" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-25-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-25-typ-range",
            "name": "Eth2-25",
            "rn": "shports-Eth2-25-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-25-typ-range/portblk-Eth2-25",
                        "fromCard": "2",
                        "fromPort": "25",
                        "toCard": "2",
                        "toPort": "25",
                        "name": "Eth2-25",
                        "rn": "portblk-Eth2-25"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-26-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-26" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-26-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-26-typ-range",
            "name": "Eth2-26",
            "rn": "shports-Eth2-26-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-26-typ-range/portblk-Eth2-26",
                        "fromCard": "2",
                        "fromPort": "26",
                        "toCard": "2",
                        "toPort": "26",
                        "name": "Eth2-26",
                        "rn": "portblk-Eth2-26"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-27-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-27" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-27-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-27-typ-range",
            "name": "Eth2-27",
            "rn": "shports-Eth2-27-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-27-typ-range/portblk-Eth2-27",
                        "fromCard": "2",
                        "fromPort": "27",
                        "toCard": "2",
                        "toPort": "27",
                        "name": "Eth2-27",
                        "rn": "portblk-Eth2-27"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-28-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-28" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-28-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-28-typ-range",
            "name": "Eth2-28",
            "rn": "shports-Eth2-28-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-28-typ-range/portblk-Eth2-28",
                        "fromCard": "2",
                        "fromPort": "28",
                        "toCard": "2",
                        "toPort": "28",
                        "name": "Eth2-28",
                        "rn": "portblk-Eth2-28"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-29-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-29" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-29-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-29-typ-range",
            "name": "Eth2-29",
            "rn": "shports-Eth2-29-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-29-typ-range/portblk-Eth2-29",
                        "fromCard": "2",
                        "fromPort": "29",
                        "toCard": "2",
                        "toPort": "29",
                        "name": "Eth2-29",
                        "rn": "portblk-Eth2-29"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-30-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-30" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-30-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-30-typ-range",
            "name": "Eth2-30",
            "rn": "shports-Eth2-30-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-30-typ-range/portblk-Eth2-30",
                        "fromCard": "2",
                        "fromPort": "30",
                        "toCard": "2",
                        "toPort": "30",
                        "name": "Eth2-30",
                        "rn": "portblk-Eth2-30"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-31-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-31" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-31-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-31-typ-range",
            "name": "Eth2-31",
            "rn": "shports-Eth2-31-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-31-typ-range/portblk-Eth2-31",
                        "fromCard": "2",
                        "fromPort": "31",
                        "toCard": "2",
                        "toPort": "31",
                        "name": "Eth2-31",
                        "rn": "portblk-Eth2-31"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-32-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-32" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-32-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-32-typ-range",
            "name": "Eth2-32",
            "rn": "shports-Eth2-32-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-32-typ-range/portblk-Eth2-32",
                        "fromCard": "2",
                        "fromPort": "32",
                        "toCard": "2",
                        "toPort": "32",
                        "name": "Eth2-32",
                        "rn": "portblk-Eth2-32"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-33-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-33" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-33-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-33-typ-range",
            "name": "Eth2-33",
            "rn": "shports-Eth2-33-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-33-typ-range/portblk-Eth2-33",
                        "fromCard": "2",
                        "fromPort": "33",
                        "toCard": "2",
                        "toPort": "33",
                        "name": "Eth2-33",
                        "rn": "portblk-Eth2-33"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-34-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-34" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-34-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-34-typ-range",
            "name": "Eth2-34",
            "rn": "shports-Eth2-34-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-34-typ-range/portblk-Eth2-34",
                        "fromCard": "2",
                        "fromPort": "34",
                        "toCard": "2",
                        "toPort": "34",
                        "name": "Eth2-34",
                        "rn": "portblk-Eth2-34"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-35-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-35" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-35-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-35-typ-range",
            "name": "Eth2-35",
            "rn": "shports-Eth2-35-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-35-typ-range/portblk-Eth2-35",
                        "fromCard": "2",
                        "fromPort": "35",
                        "toCard": "2",
                        "toPort": "35",
                        "name": "Eth2-35",
                        "rn": "portblk-Eth2-35"
                    }
                }
            }
        ]
    }
}
	EOF
}

/*
API Information:
 - Class: "infraSHPortS"
 - Distinguished Name: "uni/infra/spaccportprof-/shports-Eth2-36-typ-range"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > [Spine Interface Profile]:[Spine Interface Selector]
*/
resource "aci_rest" "dc2-spine101_Eth2-36" {
	depends_on       = [aci_spine_interface_profile.dc2-spine101]
	path             = "/api/node/mo/uni/infra/spaccportprof-dc2-spine101/shports-Eth2-36-typ-range.json"
	class_name       = "infraSHPortS"
	payload          = <<EOF
{
    "infraSHPortS": {
        "attributes": {
            "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-36-typ-range",
            "name": "Eth2-36",
            "rn": "shports-Eth2-36-typ-range"
        },
        "children": [
            {
                "infraPortBlk": {
                    "attributes": {
                        "dn": "uni/infra/spaccportprof-dc2-spine101/shports-Eth2-36-typ-range/portblk-Eth2-36",
                        "fromCard": "2",
                        "fromPort": "36",
                        "toCard": "2",
                        "toPort": "36",
                        "name": "Eth2-36",
                        "rn": "portblk-Eth2-36"
                    }
                }
            }
        ]
    }
}
	EOF
}

