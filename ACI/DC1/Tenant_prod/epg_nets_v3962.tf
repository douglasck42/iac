/*
API Information:
 - Class: "fvAEPg"
 - Distinguished Name: /uni/tn-prod/ap-nets/epg-v3962
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v3962
*/
resource "aci_application_epg" "nets_v3962" {
	depends_on						= [aci_tenant.prod,aci_application_profile.prod_nets]
	application_profile_dn			= aci_application_profile.prod_nets.id
	name							= "v3962"
	description						= "Wakanda.Mercy.L3Out"
	flood_on_encap					= "disabled"
	has_mcast_source				= "no"
	is_attr_based_epg				= "no"
	match_t							= "AtleastOne"
	pc_enf_pref						= "enforced"
	pref_gr_memb					= "include"
	prio							= "level3"
	shutdown						= "no"
	relation_fv_rs_bd				= aci_bridge_domain.prod_v3962.id
	relation_fv_rs_aepg_mon_pol		= "uni/tn-common/monepg-default"
}

/*
API Information:
 - Class: "fvRsDomAtt"
 - Distinguished Name: /uni/tn-prod/ap-nets/epg-v3962/rsdomAtt-[uni/phys-access_phys]
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v3962 > Domains (VMs and Bare-Metals)
*/
resource "aci_rest" "nets_v3962_phys-access_phys" {
	depends_on		= [aci_application_epg.nets_v3962]
	path		= "/api/node/mo/uni/tn-prod/ap-nets/epg-v3962.json"
	class_name	= "fvRsDomAtt"
	payload		= <<EOF
{
    "fvRsDomAtt": {
        "attributes": {
            "tDn": "uni/phys-access_phys"
        },
        "children": []
    }
}
	EOF
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-prod/ap-nets/epg-v3962/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc7_dc1-leaf201]"
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v3962 > Static Ports > Pod-1/Node-201-202/pg_vpc7_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v3962_Pod-1_Nodes-201-202_pg_vpc7_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v3962]
	application_epg_dn   = aci_application_epg.nets_v3962.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc7_dc1-leaf201]"
	encap                = "vlan-3962"
	mode                 = "regular"
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-prod/ap-nets/epg-v3962/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc9_dc1-leaf201]"
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v3962 > Static Ports > Pod-1/Node-201-202/pg_vpc9_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v3962_Pod-1_Nodes-201-202_pg_vpc9_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v3962]
	application_epg_dn   = aci_application_epg.nets_v3962.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc9_dc1-leaf201]"
	encap                = "vlan-3962"
	mode                 = "regular"
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-prod/ap-nets/epg-v3962/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc13_dc1-leaf201]"
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v3962 > Static Ports > Pod-1/Node-201-202/pg_vpc13_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v3962_Pod-1_Nodes-201-202_pg_vpc13_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v3962]
	application_epg_dn   = aci_application_epg.nets_v3962.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc13_dc1-leaf201]"
	encap                = "vlan-3962"
	mode                 = "regular"
}

