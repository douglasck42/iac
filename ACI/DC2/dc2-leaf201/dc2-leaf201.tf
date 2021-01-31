# Use this Resource File to Register dc2-leaf201 with node id 201 to the Fabric
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
 - Distinguished Name: "topology/pod-1/node-201"
GUI Location:
 - Fabric > Access Policies > Inventory > Fabric Membership:[Registered Nodes or Nodes Pending Registration]
*/
resource "aci_fabric_node_member" "dc2-leaf201" {
	serial    = "TEP-1-101"
	name      = "dc2-leaf201"
	node_id   = "201"
	node_type = "unspecified"
	role      = "leaf"
	pod_id    = "1"
}

/*
API Information:
 - Class: "maintMaintGrp"
 - Distinguished Name: "uni/fabric/maintgrp-switch_MgA"
GUI Location:
 - Admin > Firmware > Nodes:MgA
*/
resource "aci_rest" "maint_grp_dc2-leaf201" {
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
                        "dn": "uni/fabric/maintgrp-switch_MgA/nodeblk-blk201-201",
                        "name": "blk201-201",
                        "from_": "201",
                        "to_": "201",
                        "rn": "nodeblk-blk201-201"
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
 - Distinguished Name: "uni/infra/funcprof/accportgrp-dc2-leaf201"
GUI Location:
 - Fabric > Access Policies > Interfaces > Spine Interfaces > Profiles > dc2-leaf201
*/
resource "aci_spine_interface_profile" "dc2-leaf201" {
	name   = "dc2-leaf201"
}

/*
API Information:
 - Class: "infraSpineP"
 - Distinguished Name: "uni/infra/spprof-dc2-leaf201"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-leaf201
*/
resource "aci_spine_profile" "dc2-leaf201" {
	name   = "dc2-leaf201"
}

/*
API Information:
 - Class: "infraSpineS"
 - Distinguished Name: "uni/infra/spprof-dc2-leaf201/spines-dc2-leaf201-typ-range"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-leaf201: Spine Selectors [dc2-leaf201]
*/
resource "aci_spine_switch_association" "dc2-leaf201" {
	spine_profile_dn               = aci_spine_profile.dc2-leaf201.id
	name                           = "dc2-leaf201"
	spine_switch_association_type  = "range"
}

/*
API Information:
 - Class: "infraRsSpAccPortP"
 - Distinguished Name: "uni/infra/spaccportprof-dc2-leaf201"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-leaf201: Spine Interface Selector Profiles: dc2-leaf201
*/
resource "aci_spine_port_selector" "dc2-leaf201" {
	spine_profile_dn   = aci_spine_profile.dc2-leaf201.id
	tdn                = aci_spine_interface_profile.dc2-leaf201.id
}

/*
API Information:
 - Class: "infraSpineS"
 - Distinguished Name: "uni/infra/spprof-dc2-leaf201/spines-dc2-leaf201-typ-range"
GUI Location:
 - Fabric > Access Policies > Switches > Spine Switches > Profiles > dc2-leaf201: Spine Selectors Policy Group: default
*/
resource "aci_rest" "spine_policy_group_dc2-leaf201" {
	depends_on  = [aci_spine_profile.dc2-leaf201]
	path		= "/api/node/mo/uni/infra/spprof-dc2-leaf201/spines-dc2-leaf201-typ-range.json"
	class_name	= "infraSpineS"
	payload		= <<EOF
{
    "infraSpineS": {
        "attributes": {
            "dn": "uni/infra/spprof-dc2-leaf201/spines-dc2-leaf201-typ-range"
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
 - Distinguished Name: "uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-1/node-201]"
GUI Location:
 - Tenants > mgmt > Node Management Addresses > Static Node Management Addresses
*/
resource "aci_rest" "inb_mgmt_dc2-leaf201_198-18-12-1" {
	depends_on  = [aci_application_epg.inb_default]
	path		= "/api/node/mo/uni/tn-mgmt.json"
	class_name	= "mgmtRsInBStNode"
	payload		= <<EOF
{
    "mgmtRsInBStNode": {
        "attributes": {
            "dn": "uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-1/node-201]",
            "addr": "198.18.12.201/24",
            "gw": "198.18.12.1",
            "tDn": "topology/pod-1/node-201",
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
 - Distinguished Name: "uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-dc2-leaf201]"
GUI Location:
 - Tenants > mgmt > Node Management Addresses > Static Node Management Addresses
*/
resource "aci_rest" "oob_mgmt_dc2-leaf201_198-18-2-1" {
	path		= "/api/node/mo/uni/tn-mgmt.json"
	class_name	= "mgmtRsOoBStNode"
	payload		= <<EOF
{
    "mgmtRsOoBStNode": {
        "attributes": {
            "dn": "uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-dc2-leaf201]",
            "addr": "198.18.2.201/24",
            "gw": "198.18.2.1",
            "tDn": "topology/pod-1/node-dc2-leaf201",
            "v6Addr": "::",
            "v6Gw": "::"
        }
    }
}
	EOF
}

