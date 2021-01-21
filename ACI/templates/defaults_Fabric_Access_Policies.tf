/*
- This Resource File will create Recommended Default Policies for Fabric > Access Policies
- Need the vars_Fabric_Access_Policies.tf File for Variable Definitions
*/

/*
Create Attachable Access Entity Profiles
- access_aep
- inband_aep
- l3out_aep
- msite_aep
Fabric > Access Policies > Policies > Global > Attachable Access Entity Profiles : [Policy Name]
*/
resource "aci_attachable_access_entity_profile" "access_aep" {
	depends_on 				= [aci_physical_domain.default["access_phys"]]
	description 			= "Base AEP Policy.  Used for Host/Device Connectivity to Fabric"
	name        			= "access_aep"
	relation_infra_rs_dom_p	= [aci_physical_domain.default["access_phys"].id]
}

resource "aci_attachable_access_entity_profile" "inband_aep" {
	depends_on 				= [aci_physical_domain.default["inband_phys"],aci_l3_domain_profile.default["inband_L3"]]
	description 			= "Base AEP Policy.  Used for inband Device connectivity to Fabric"
	name        			= "inband_aep"
	relation_infra_rs_dom_p	= [aci_physical_domain.default["inband_phys"].id,aci_l3_domain_profile.default["inband_L3"].id]
}

resource "aci_attachable_access_entity_profile" "l3out_aep" {
	depends_on 				= [aci_l3_domain_profile.default["l3out_L3"]]
	description 			= "Base AEP Policy.  Used to Connect ACI Fabric to External Networks"
	name        			= "l3out_aep"
	relation_infra_rs_dom_p	= [aci_l3_domain_profile.default["l3out_L3"].id]
}

resource "aci_attachable_access_entity_profile" "msite_aep" {
	depends_on 				= [aci_l3_domain_profile.default["msite_L3"]]
	description 			= "Base AEP Policy.  Used to Connect ACI Fabrics to MultiSite Network"
	name        			= "msite_aep"
	relation_infra_rs_dom_p	= [aci_l3_domain_profile.default["msite_L3"].id]
}

/*
Create Interface CDP Policies
- cdp_Disabled
- cdp_Enabled
Fabric > Access Policies > Policies > Interface > CDP Interface : [Policy Name]
*/
resource "aci_cdp_interface_policy" "default" {
	for_each    = var.policies_cdp
	name        = each.value.name
	admin_st    = each.value.admin_st
}

/*
Create Interface Link Level Policies
- Policies for 100M thru 400G
- Auto Negotiation or no Negotiate
Fabric > Access Policies > Policies > Interface > Link Level : [Policy Name]
*/
resource "aci_fabric_if_pol" "default" {
	for_each    = var.policies_link_level
	name        = each.value.name
	description = each.value.description
	auto_neg    = each.value.auto_neg
	speed       = each.value.speed
}

/*
Create Fibre-Channel Interface Policies
- Policies
	- Port Modes: F or NP
	- Speed: 4G to 32G
	- Trunk or non-Trunk
Fabric > Access Policies > Policies > Interface > Fibre Channel Interface : [Policy Name]
*/
resource "aci_interface_fc_policy" "default" {
	for_each    = var.policies_int_fc
	name        = each.value.name
	port_mode	= each.value.port_mode
	speed		= each.value.speed
	trunk_mode  = each.value.trunk_mode
}

/*
Create Link Aggregation Control Protocol Policies
- Policies for Active, MacPin, Passive, Static
Fabric > Access Policies > Policies > Interface > Port Channel : [Policy Name]
*/
resource "aci_lacp_policy" "default" {
	for_each    = var.policies_lacp
	description = each.value.description
	name        = each.value.name
	mode        = each.value.mode
}

/*
Create LLDP Interface Policies
- Policies for Enable or Disable
Fabric > Access Policies > Policies > Interface > LLDP Interface : [Policy Name]
*/
resource "aci_lldp_interface_policy" "default" {
	for_each    = var.policies_lldp
	description = each.value.description
	name        = each.value.name
	admin_rx_st = each.value.admin_rx_st
	admin_tx_st = each.value.admin_tx_st
}

/*
Create Mis-Cabling Protocol Interface Policies
- Policies for Enable or Disable
Fabric > Access Policies > Policies > Interface > MCP Interface : [Policy Name]
*/
resource "aci_miscabling_protocol_interface_policy" "default" {
	for_each    = var.policies_mcp
	description = each.value.description
	name        = each.value.name
	admin_st    = each.value.admin_st
}

/*
Create Spanning-Tree Policies
Fabric > Access Policies > Policies > Interface > Spanning Tree Interface : [Policy Name]
*/
resource "aci_rest" "stp-policies" {
	for_each   = var.policies_stp
	path       = "/api/node/mo/uni/infra/ifPol-${each.value.name}.json"
	class_name = "stpIfPol"
	payload    = <<EOF
{
	"stpIfPol": {
		"attributes": {
			"dn": "uni/infra/ifPol-${each.value.name}",
			"name": "${each.value.name}",
			"ctrl": "${each.value.ctrl}",
		},
	}
}
	EOF
}

/*
Create Default L3 Domain Profiles
Fabric > Access Policies > Physical and External Domains > L3 Domains: [Policy Name]
*/
resource "aci_l3_domain_profile" "default" {
	depends_on 				  = [aci_vlan_pool.default]
	for_each    			  = var.profile_l3dom
	name        			  = each.value.name
	relation_infra_rs_vlan_ns = "uni/infra/vlanns-[${each.value.vl_pool}]-static"
}

/*
Create Default Physical Domain Profiles
Fabric > Access Policies > Physical and External Domains > Physical Domains: [Policy Name]
*/
resource "aci_physical_domain" "default" {
	depends_on 	= [aci_vlan_pool.default]
	for_each    = var.profile_physdom
	name        = each.value.name
	relation_infra_rs_vlan_ns = "uni/infra/vlanns-[${each.value.vl_pool}]-static"
}

/*
Create a Default Access Policy Group for inband Ports
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Access Port:[Policy Name]
*/
resource "aci_leaf_access_port_policy_group" "inband_apg" {
	depends_on 					  		= [aci_rest.stp-policies,aci_fabric_if_pol.default,aci_attachable_access_entity_profile.inband_aep]
	description 				  		= "Inband port-group policy"
	name 						  		= "inband_apg"
	relation_infra_rs_att_ent_p	  		= "uni/infra/attentp-inband_aep"
	relation_infra_rs_cdp_if_pol  		= "uni/infra/cdpIfP-cdp_Disabled"
	relation_infra_rs_h_if_pol	  		= "uni/infra/hintfpol-inherit_Auto"
	relation_infra_rs_lldp_if_pol 		= "uni/infra/lldpIfP-lldp_Enabled"
	relation_infra_rs_mcp_if_pol  		= "uni/infra/mcpIfP-mcp_Enabled"
	relation_infra_rs_mon_if_infra_pol	= "uni/infra/moninfra-default"
    relation_infra_rs_stp_if_pol  		= "uni/infra/ifPol-BPDU_fg"
}

/*
Create a Default Access Policy Group for Access Ports
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Access Port:[Policy Name]
*/
resource "aci_leaf_access_port_policy_group" "access_host_apg" {
	depends_on 					  		= [aci_rest.stp-policies,aci_fabric_if_pol.default,aci_attachable_access_entity_profile.access_aep]
	description 				  		= "Template for a Host Access Port"
	name 						  		= "access_host_apg"
	relation_infra_rs_att_ent_p	  		= "uni/infra/attentp-access_aep"
	relation_infra_rs_cdp_if_pol  		= "uni/infra/cdpIfP-cdp_Enabled"
	relation_infra_rs_h_if_pol	  		= "uni/infra/hintfpol-inherit_Auto"
	relation_infra_rs_lldp_if_pol 		= "uni/infra/lldpIfP-lldp_Enabled"
	relation_infra_rs_mcp_if_pol  		= "uni/infra/mcpIfP-mcp_Enabled"
	relation_infra_rs_mon_if_infra_pol	= "uni/infra/moninfra-default"
    relation_infra_rs_stp_if_pol  		= "uni/infra/ifPol-BPDU_fg"
}

/*
Create Breakout Port Policy Groups for speed and breakout Options
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Breakout Port Group:2x100g_pg
*/
resource "aci_rest" "breakout_2x100g_pg" {
	path		= "/api/node/mo/uni/infra/funcprof/brkoutportgrp-2x100g_pg.json"
	class_name	= "infraBrkoutPortGrp"
	payload		= <<EOF
{
    "infraBrkoutPortGrp": {
        "attributes": {
            "dn": "uni/infra/funcprof/brkoutportgrp-2x100g_pg",
            "brkoutMap": "100g-2x",
            "name": "2x100g_pg",
            "descr": "Breakout of 400G to 2x100g.  Configured by Terraform startup Wizard",
            "rn": "brkoutportgrp-2x100g_pg"
        },
        "children": []
    }
}
	EOF
}

/*
Create Breakout Port Policy Groups for speed and breakout Options
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Breakout Port Group:4x10g_pg
*/
resource "aci_rest" "breakout_4x10g_pg" {
	path		= "/api/node/mo/uni/infra/funcprof/brkoutportgrp-4x10g_pg.json"
	class_name	= "infraBrkoutPortGrp"
	payload		= <<EOF
{
    "infraBrkoutPortGrp": {
        "attributes": {
            "dn": "uni/infra/funcprof/brkoutportgrp-4x10g_pg",
            "brkoutMap": "10g-4x",
            "name": "4x10g_pg",
            "descr": "Breakout of 40G to 4x10g.  Configured by Terraform startup Wizard",
            "rn": "brkoutportgrp-4x10g_pg"
        },
        "children": []
    }
}
	EOF
}

/*
Create Breakout Port Policy Groups for speed and breakout Options
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Breakout Port Group:4x25g_pg
*/
resource "aci_rest" "breakout_4x25g_pg" {
	for_each    = var.breakouts
	path		= "/api/node/mo/uni/infra/funcprof/brkoutportgrp-4x25g_pg.json"
	class_name	= "infraBrkoutPortGrp"
	payload		= <<EOF
{
    "infraBrkoutPortGrp": {
        "attributes": {
            "dn": "uni/infra/funcprof/brkoutportgrp-4x25g_pg",
            "brkoutMap": "25g-4x",
            "name": "4x25g_pg",
            "descr": "Breakout of 100G to 4x25g.  Configured by Terraform startup Wizard",
            "rn": "brkoutportgrp-4x25g_pg"
        },
        "children": []
    }
}
	EOF
}

/*
Create Breakout Port Policy Groups for speed and breakout Options
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Breakout Port Group:4x100g_pg
*/
resource "aci_rest" "breakout_4x100g_pg" {
	for_each    = var.breakouts
	path		= "/api/node/mo/uni/infra/funcprof/brkoutportgrp-4x100g_pg.json"
	class_name	= "infraBrkoutPortGrp"
	payload		= <<EOF
{
    "infraBrkoutPortGrp": {
        "attributes": {
            "dn": "uni/infra/funcprof/brkoutportgrp-4x100g_pg",
            "brkoutMap": "100g-4x",
            "name": "4x100g_pg",
            "descr": "Breakout of 400G to 4x100g.  Configured by Terraform startup Wizard",
            "rn": "brkoutportgrp-4x100g_pg"
        },
        "children": []
    }
}
	EOF
}

/*
Create Breakout Port Policy Groups for speed and breakout Options
Fabric > Access Policies > Interface > Leaf Interfaces > Policy Groups > Leaf Breakout Port Group:8x50g_pg
*/
resource "aci_rest" "breakout_8x50g_pg" {
	for_each    = var.breakouts
	path		= "/api/node/mo/uni/infra/funcprof/brkoutportgrp-8x50g_pg.json"
	class_name	= "infraBrkoutPortGrp"
	payload		= <<EOF
{
    "infraBrkoutPortGrp": {
        "attributes": {
            "dn": "uni/infra/funcprof/brkoutportgrp-8x50g_pg",
            "brkoutMap": "50g-8x",
            "name": "8x50g_pg",
            "descr": "Breakout of 400G to 8x50g.  Configured by Terraform startup Wizard",
            "rn": "brkoutportgrp-8x50g_pg"
        },
        "children": []
    }
}
	EOF
}

/*
Add Description to Virtual Port Channel default
Fabric > Access Policies > Policies > Switch > Virtual Port Channel default
*/
resource "aci_rest" "vpc_description" {
	path		= "/api/node/mo/uni/fabric/protpol.json"
	class_name	= "fabricProtPol"
	payload		= <<EOF
{
    "fabricProtPol": {
        "attributes": {
            "dn": "uni/fabric/protpol",
            "descr": "VPC Pair Configuration.  Configured by Terraform startup Wizard"
        },
        "children": []
    }
}
	EOF
}

/*
Create default Leaf Policy Group
Fabric > Access Policies > Switches > Leaf Switches > Policy Groups: default
*/
resource "aci_rest" "Leaf_Policy_Group" {
	path		= "/api/node/mo/uni/infra/funcprof/accnodepgrp-default.json"
	class_name	= "infraAccNodePGrp"
	payload		= <<EOF
{
	"infraAccNodePGrp": {
		"attributes": {
			"dn": "uni/infra/funcprof/accnodepgrp-default",
			"name": "default",
			"descr": "Default Policy Group for Leaf Switches - Created by Terraform Startup Script.",
			"rn": "accnodepgrp-default"
		},
		"children": [
			{
				"infraRsMstInstPol": {
					"attributes": {
						"tnStpInstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsTopoctrlFwdScaleProfPol": {
					"attributes": {
						"tnTopoctrlFwdScaleProfilePolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsTopoctrlFastLinkFailoverInstPol": {
					"attributes": {
						"tnTopoctrlFastLinkFailoverInstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsL2NodeAuthPol": {
					"attributes": {
						"tnL2NodeAuthPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsIaclLeafProfile": {
					"attributes": {
						"tnIaclLeafProfileName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsEquipmentFlashConfigPol": {
					"attributes": {
						"tnEquipmentFlashConfigPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsLeafPGrpToCdpIfPol": {
					"attributes": {
						"tnCdpIfPolName": "cdp_Enabled"
					},
					"children": []
				}
			},
			{
				"infraRsLeafPGrpToLldpIfPol": {
					"attributes": {
						"tnLldpIfPolName": "lldp_Enabled"
					},
					"children": []
				}
			},
			{
				"infraRsBfdIpv4InstPol": {
					"attributes": {
						"tnBfdIpv4InstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsBfdIpv6InstPol": {
					"attributes": {
						"tnBfdIpv6InstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsFcInstPol": {
					"attributes": {
						"tnFcInstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsPoeInstPol": {
					"attributes": {
						"tnPoeInstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsFcFabricPol": {
					"attributes": {
						"tnFcFabricPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsMonNodeInfraPol": {
					"attributes": {
						"tnMonInfraPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsNetflowNodePol": {
					"attributes": {
						"tnNetflowNodePolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsLeafCoppProfile": {
					"attributes": {
						"tnCoppLeafProfileName": "default"
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
Create default Spine Policy Group
Fabric > Access Policies > Switches > Spine Switches > Policy Groups: default
*/
resource "aci_rest" "Spine_Policy_Group" {
	path		= "/api/node/mo/uni/infra/funcprof/spaccnodepgrp-default.json"
	class_name	= "infraSpineAccNodePGrp"
	payload		= <<EOF
{
	"infraSpineAccNodePGrp": {
		"attributes": {
			"dn": "uni/infra/funcprof/spaccnodepgrp-default",
			"name": "default",
			"descr": "Default Policy Group for Spine Switches - Created by Terraform Startup Script.",
			"rn": "spaccnodepgrp-default"
		},
		"children": [
			{
				"infraRsSpineCoppProfile": {
					"attributes": {
						"tnCoppSpineProfileName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsSpineBfdIpv4InstPol": {
					"attributes": {
						"tnBfdIpv4InstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsSpineBfdIpv6InstPol": {
					"attributes": {
						"tnBfdIpv6InstPolName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsIaclSpineProfile": {
					"attributes": {
						"tnIaclSpineProfileName": "default"
					},
					"children": []
				}
			},
			{
				"infraRsSpinePGrpToCdpIfPol": {
					"attributes": {
						"tnCdpIfPolName": "cdp_Enabled"
					},
					"children": []
				}
			},
			{
				"infraRsSpinePGrpToLldpIfPol": {
					"attributes": {
						"tnLldpIfPolName": "lldp_Enabled"
					},
					"children": []
				}
			}
		]
	}
}
	EOF
}